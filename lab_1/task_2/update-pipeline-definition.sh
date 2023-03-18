#!/bin/bash

function help() {
    echo "Usage: update-pipeline-definition.sh <pipeline definition file> [--configuration <configuration>] [--owner <owner>] [--branch <branch>] [--poll-for-source-changes <true/false>] [--help]"
    echo ""
    echo "Options:"
    echo "  --configuration             Pipeline configuration, e.g. development, staging, production."
    echo "  --owner                     The GitHub owner/account name of repository."
    echo "  --branch                    Branch to use for the pipeline."
    echo "  --repo                      The GitHub repo that will be used by pipeline."
    echo "  --poll-for-source-changes   Enable or disable polling for source code changes."
    echo "  --help                      Show this help message."
    exit 1
}

if [ $1 == '--help'  ]; then
    help
fi

if ! [ -x "$(command -v jq)" ]; then
  echo 'Error: jq is not installed.' >&2
  echo 'Please install jq before running this script. Visit https://stedolan.github.io/jq/download/ for installation instructions.' >&2
  exit 1
fi


if [[ ! -f "$1" || $(file --mime-type -b "$1") != "application/json" ]]; then
    echo "Error: First argument is not a valid JSON file."
    exit 1
fi

INITIAL_NUM_OF_ARGS=$#
PIPELINE_DEFINITION_FILE=$1
shift

if ! jq -e '.pipeline.version' "$PIPELINE_DEFINITION_FILE" >/dev/null; then
    echo "Error: Version property is missing. Please update pipeline definition file."
    exit 1
fi

if ! jq '.pipeline.stages[0].actions[0].configuration.Branch' $PIPELINE_DEFINITION_FILE >/dev/null; then
    echo "Error: Branch property is missing. Please update pipeline definition file."
    exit 1
fi

if ! jq '.pipeline.stages[0].actions[0].configuration.Owner' $PIPELINE_DEFINITION_FILE >/dev/null; then
    echo "Error: Owner property is missing. Please update pipeline definition file."
    exit 1
fi

if ! jq '.pipeline.stages[0].actions[0].configuration.Repo' $PIPELINE_DEFINITION_FILE >/dev/null; then
    echo "Error: Repo property is missing. Please update pipeline definition file."
    exit 1
fi

if ! jq '.pipeline.stages[0].actions[0].configuration.PollForSourceChanges' $PIPELINE_DEFINITION_FILE >/dev/null; then
    echo "Error: PollForSourceChanges property is missing. Please update pipeline definition file."
    exit 1
fi

if ! jq '.pipeline.stages[1].actions[].configuration.EnvironmentVariables' $PIPELINE_DEFINITION_FILE >/dev/null; then
    echo "Error: QualityGate env vars is missing. Please update pipeline definition file."
    exit 1
fi

if ! jq '.pipeline.stages[3].actions[].configuration.EnvironmentVariables' $PIPELINE_DEFINITION_FILE >/dev/null; then
    echo "Error: Build env vars is missing. Please update pipeline definition file."
    exit 1
fi

BRANCH=main
POLL_FOR_SOURCE_CHANGES=false

while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -c|--configuration)
        BUILD_CONFIGURATION="$2"
        shift
        shift
        ;;
        -o|--owner)
        OWNER="$2"
        shift
        shift
        ;;
        -r|--repo)
        REPO="$2"
        shift
        shift
        ;;
        -b|--branch)
        BRANCH="$2"
        shift
        shift
        ;;
        -p|--poll-for-source-changes)
        POLL_FOR_SOURCE_CHANGES="$2"
        shift
        shift
        ;;
        *)
        echo "Unknown option: $key"
        exit 1
        ;;
    esac
done

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
NEW_FILENAME="pipeline-$DATE.json"

if [ $INITIAL_NUM_OF_ARGS -eq 1 ]; then
    jq '.pipeline.version += 1' "$PIPELINE_DEFINITION_FILE" | \
    jq 'del(.metadata)'  > "$NEW_FILENAME"
else
    ESCAPED_BUILD_CONFIG=$(jq -nr --arg build_config "$BUILD_CONFIGURATION" '$build_config | @json')
    jq '.pipeline.version += 1' "$PIPELINE_DEFINITION_FILE" | \
    jq 'del(.metadata)' | \
    jq --arg branch "$BRANCH" '.pipeline.stages[0].actions[0].configuration.Branch = $branch' | \
    jq --arg owner "$OWNER" '.pipeline.stages[0].actions[0].configuration.Owner = $owner' | \
    jq --arg repo "$REPO" '.pipeline.stages[0].actions[0].configuration.Repo = $repo' | \
    jq --argjson poll "$POLL_FOR_SOURCE_CHANGES" '.pipeline.stages[0].actions[0].configuration.PollForSourceChanges = $poll' | \
    jq --argjson buildconfig "$ESCAPED_BUILD_CONFIG" '.pipeline.stages[].actions[].configuration.EnvironmentVariables = "[{\"name\":\"BUILD_CONFIGURATION\",\"value\":\($buildconfig),\"type\":\"PLAINTEXT\"}]"' > "$NEW_FILENAME"
fi

echo "Created new file: $NEW_FILENAME"
