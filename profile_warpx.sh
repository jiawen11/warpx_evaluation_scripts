#!/bin/sh -x


export PATH=$PATH:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

#MPINP=16

if [ "$1" = "" ];then
    #MPINP=1
    echo "$0 <Number-of-MPI-Racks>"
    exit
else
    MPINP="$1"
fi

echo "MPINP=$MPINP"


MPIRUN="/usr/bin/mpirun"


PROFILE_TOTAL_SECONDS=300 #maximum to 5 minutes for each one

rootdir="`dirname $0`"

warpx_run="$rootdir/warpx_deploy/warpx_run"

result_dir="$rootdir/profile_result_np""$MPINP"

if [ -d "$result_dir"".old" ];then
    rm -rf "$result_dir"".old" 2>/dev/zero
fi

if [ -d "$result_dir" ];then
    mv $result_dir "$result_dir"".old"
fi

mkdir $result_dir 2>/dev/zero

SUDO=/usr/bin/sudo

warpx_exe_2d="$warpx_run/warpx_2d"
warpx_exe_3d="$warpx_run/warpx_3d"


if [ ! -f "$warpx_exe_2d" ];then
    echo "$warpx_exe_2d not found"
    exit
fi

if [ ! -f "$warpx_exe_3d" ];then
    echo "$warpx_exe_3d not found"
    exit
fi


warpx_problems_2d=""
warpx_problems_2d="$warpx_problems_2d warpx_problems/beam-driven-acceleration/inputs_2d.dms"
warpx_problems_2d="$warpx_problems_2d warpx_problems/beam-driven-acceleration/inputs_2d_boost.dms"
warpx_problems_2d="$warpx_problems_2d warpx_problems/laser-driven-acceleration/inputs_2d.dms"
warpx_problems_2d="$warpx_problems_2d warpx_problems/laser-driven-acceleration/inputs_2d_boost.dms"


warpx_problems_3d=""
warpx_problems_3d="$warpx_problems_3d warpx_problems/beam-driven-acceleration/test_3d_boost_32x32x256"
warpx_problems_3d="$warpx_problems_3d warpx_problems/beam-driven-acceleration/test_3d_boost_64x64x512"
warpx_problems_3d="$warpx_problems_3d warpx_problems/laser-driven-acceleration/test_3d_128x128x1024"
warpx_problems_3d="$warpx_problems_3d warpx_problems/laser-driven-acceleration/test_3d_64x64x512"


ls -l $warpx_run/


echo "Profiling WarpX 2D ..."


do_cleanup() {
    killall mpirun 2>/dev/zero
    killall $warpx_exe_2d 2>/dev/zero
    killall $warpx_exe_3d 2>/dev/zero
    $SUDO killall pcm-memory 2>/dev/zero
    $SUDO killall pcm-latency 2>/dev/zero
    $SUDO killall numastat 2>/dev/zero

}


copy_plotfiles(){

    target_dir="$1"

    if [ ! -d "plotfiles" ];then
        return
    fi

     if [ ! -d "$target_dir" ];then
        return
    fi

    mv plotfiles $target_dir/ 2>/dev/zero

}


profile_warpx() {

    problem_type="$1"


    if [ "$problem_type" = "2D" ];then
        warpx_exe=$warpx_exe_2d
        warpx_problems="$warpx_problems_2d"
    else
        warpx_exe=$warpx_exe_3d
        warpx_problems="$warpx_problems_3d"
    fi


    if [ ! -f "$warpx_exe" ];then
        echo "command $warpx_exe not found"
        exit
    fi

    #warpx_exe_basename="`basename $warpx_exe`"

    echo "problem_type=$problem_type"
    echo "warpx_exe=$warpx_exe"
    #echo "warpx_exe_basename=$warpx_exe_basename"
    echo "warpx_problems=$warpx_problems"


    for problem in $warpx_problems; do
        echo "problem input: $problem"

        if [ ! -f "$problem" ];then
            echo "input file $problem not found."
            #continue
            exit
        fi

        do_cleanup
 
        #problem_name="`dirname $problem`"
        #problem_name="`basename $problem_name`"

        #echo "problem_name=$problem_name"


        log_dir="$result_dir/$problem"


        mkdir -p $log_dir 2>/dev/zero

        touch $log_dir/pcm_memory.txt
        touch $log_dir/pcm_latency.txt
        touch $log_dir/numastat.txt
        touch $log_dir/appoutput.txt

        echo "Profiling --- start ---"

        $SUDO pcm-memory 1 >$log_dir/pcm_memory.txt        2>/dev/zero &
        $SUDO pcm-latency -pmm -v >$log_dir/pcm_latency.txt  1 2>/dev/zero &

        $MPIRUN -np $MPINP $warpx_exe $problem >$log_dir/appoutput.txt &


        #ps -ax|grep $warpx_exe_basename

        #ps -ax|grep $warpx_exe_basename|sed '/grep/d'

        #ps -ax|grep $warpx_exe_basename|sed '/grep/d'|awk 'NR==2 {print $1}'

        check_status=`ps -ax|grep mpirun|sed '/grep/d'`

        if [ "$check_status" = "" ];then
            echo "Profiling --- end earlier ---"
            do_cleanup
            continue
        fi

        echo "PID: $warpx_pid"


        t=0
        while [ "$t" -lt "$PROFILE_TOTAL_SECONDS" ];do
            t="`expr $t + 1`"

            check_status=`ps -ax|grep mpirun|sed '/grep/d'`
            #check_status=`ps -ax|grep mpirun|sed '/grep/d'|awk 'NR==2 {print $1}'`
        
            if [ "$check_status" = "" ];then
                break
            fi

            echo "t=$t" >> $log_dir/numastat.txt
            numastat -m >> $log_dir/numastat.txt 2>/dev/zero

            sleep 1
        done

        do_cleanup
        #copy_plotfiles $result_dir/$problem_name


        echo "Profiling --- end ---"

    done
}

handle_signal_INT(){
    echo "Terminating ..."
    do_cleanup
    exit
}

trap "handle_signal_INT"  INT

profile_warpx "3D"
#profile_warpx "2D"

echo "Finished."
