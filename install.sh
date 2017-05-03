#!/bin/bash

# Install scripts to specified destination

set -Cuex +H

: ${DEST:?you should set destination}

normalized_dest=`readlink -f $DEST`
bin_name=`basename bash/rename-with-uuid.sh .sh`
dest=$normalized_dest/$bin_name

if [[ ! -e $dest ]]; then
  ln -s `readlink -f bash/rename-with-uuid.sh` $dest
fi
