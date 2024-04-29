#!/bin/bash

function property {
  grep "${1}" "${2}" | cut -d'=' -f2
}

version="1.0.0-SNAPSHOT"

run_number=.12

version_snapshot_suffix=-SNAPSHOT


tag="$( [[ "$version" == *"$version_snapshot_suffix" ]] && echo "${version%-*}$run_number$version_snapshot_suffix" || echo )"

echo "$tag"
