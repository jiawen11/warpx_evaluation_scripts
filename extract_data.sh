#/bin/sh

extract_data_lib="`dirname $0`"/extract_data_lib.sh

. $extract_data_lib


N_SOCKETS=2
N_CHANNELS_PER_SOCKET=4

# 
# socket
#
MAX_SOCKET_ID="`expr $N_SOCKETS - 1`"
SOCKETS_LIST="`seq 0 $MAX_SOCKET_ID`"
SOCKETS_LIST="`echo $SOCKETS_LIST`"


#
# channel
#
MAX_CHANNEL_ID="`expr $N_CHANNELS_PER_SOCKET - 1`"
CHANNELS_LIST="`seq 0 $MAX_CHANNEL_ID`"
CHANNELS_LIST="`echo $CHANNELS_LIST`"

echo "SOCKETS_LIST=$SOCKETS_LIST"
echo "CHANNELS_LIST=$CHANNELS_LIST"


if [ $# -ne 1 ];then
    echo "$0 <profile-result-dir>"
    exit
fi

profile_result_dir="$1"

if [ ! -d "$profile_result_dir" ];then
    echo "$profile_result_dir doesn't exist"
    exit
fi

cd $profile_result_dir/warpx_problems
subdirs="`ls -d */*/`"
cd -

echo "subdirs=$subdirs"


for dir in $subdirs; do

 

    dirbase=`basename $profile_result_dir/warpx_problems/$dir`
    dirname=`dirname $profile_result_dir/warpx_problems/$dir`

    datadir="$dirname/$dirbase"


    echo "datadir=$datadir"

    #continue
#    extract_csv_appoutput $datadir

#    extract_csv_cpucache $datadir

#    extract_csv_numastat $datadir


    extract_csv_memorybank $datadir


done

echo "--- Finished ---"

