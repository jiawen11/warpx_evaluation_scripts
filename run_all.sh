#!/bin/sh -x

rootpath="`dirname $0`"

MPINPS="1 4 8 16 32"

for np in $MPINPS;do
    echo "MPI racks: $np"

    $rootpath/profile_warpx.sh $np
done


echo "Finished."
