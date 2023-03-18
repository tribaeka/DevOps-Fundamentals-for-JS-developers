#!/bin/bash

DEFAULT_CONFIGURATION=development

if [ -z "$1" ]; then
  ENV_CONFIGURATION=$DEFAULT_CONFIGURATION
else
  ENV_CONFIGURATION=$1
fi

if [ -f dist/client-app.zip ]; then
    rm dist/client-app.zip
fi

npm i

npm run build --configuration=$ENV_CONFIGURATION

cd dist || exit

zip -r client-app.zip *

find . ! -name 'client-app.zip' -delete
