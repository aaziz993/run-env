#!/bin/bash

function property {
  grep "${1}" "${2}" | cut -d'=' -f2
}
