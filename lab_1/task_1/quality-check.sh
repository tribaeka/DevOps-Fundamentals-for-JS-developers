#!/bin/bash

npm run test

if [ $? -eq 0 ]; then
  echo "Tests passed."
else
  echo "Tests failed."
fi

npm run lint

if [ $? -eq 0 ]; then
  echo "Linting passed."
else
  echo "Linting failed."
fi

npm run e2e

if [ $? -eq 0 ]; then
  echo "End-to-end tests passed."
else
  echo "End-to-end tests failed."
fi
