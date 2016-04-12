#!/bin/bash

npm dedupe

echo Building dev
BUILD_ENV=development webpack --progress

echo Building production
BUILD_ENV=production webpack --progress --optimize-dedupe
