#!/bin/bash
# Wrapper to run the install script in debug mode
bash -x "$(dirname "$0")/install.sh" "$@"
