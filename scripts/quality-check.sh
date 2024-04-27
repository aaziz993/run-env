#!/bin/bash

. ./scripts/util.sh

local_properties_file="local.properties"

if [[ -z "$SONAR_TOKEN" && -f "$local_properties_file" ]]; then
    export SONAR_TOKEN
    SONAR_TOKEN="$(property "sonar.token" "$local_properties_file")"
fi

./gradlew sonar --no-configuration-cache
