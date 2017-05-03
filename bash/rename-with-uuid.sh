#!/bin/bash

# Rename files with uuid

set -Cuex +H

for filename in "$@"; do
  ext="${filename##*.}"
  mv $filename `uuidgen`.$ext
done
