#/bin/sh

extract_data_lib="`dirname $0`"/extract_data_lib.sh

. $extract_data_lib


N_SOCKETS=2

MAX_SOCKET_ID="`expr $N_SOCKETS - 1`"
SOCKETS_LIST="`seq 0 $MAX_SOCKET_ID`"

SOCKETS_LIST="`echo $SOCKETS_LIST`"

echo "SOCKETS_LIST=$SOCKETS_LIST"

if [ $# -ne 1 ];then
    echo "$0 <profile-result-dir>"
    exit
fi

profile_result_dir="$1"

if [ ! -d "$profile_result_dir" ];then
    echo "$profile_result_dir doesn't exist"
    exit
fi

cd $profile_result_dir
subdirs="`ls -d */`"
cd -

echo "subdirs=$subdirs"


for dir in $subdirs; do

    echo "Process $profile_result_dir/$dir ..."
 
    dirbase=`basename $profile_result_dir/$dir`
    dirname=`dirname $profile_result_dir/$dir`

    datadir="$dirname/$dirbase"


    echo "datadir=$datadir"

    extract_csv_appoutput $datadir

    extract_csv_cpucache $datadir

    extract_csv_numastat $datadir

#    extract_csv_cpupower $datadir

    extract_csv_memorybank $datadir

#    extract_csv_vmstat $datadir

done

echo "--- Finished ---"

