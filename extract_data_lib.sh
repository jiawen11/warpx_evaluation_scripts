#!/bin/sh

extract_csv_vmstat() {

    datadir="$1"

    app_vmstat_in=$datadir/app_vmstat.txt
    app_vmstat_out=$datadir/app_vmstat.csv

    if [ -f "$app_vmstat_in" ];then
        echo "Creating $app_vmstat_out ..."
        echo "RSS_KiB" > $app_vmstat_out
        cat $app_vmstat_in |grep RSS|awk '{print $2}' >> $app_vmstat_out
    fi

}

extract_csv_appoutput(){
    datadir="$1"

    appoutput_in=$datadir/appoutput.txt
    appoutput_out=$datadir/appoutput.csv

    echo "step_time" > $appoutput_out

    cat $appoutput_in | grep This|cut -d';' -f2|cut -d'=' -f2|cut -d's' -f1 | sed 's/\ //g'>> $appoutput_out

}


get_channel_read_and_write(){
    val="1234"
}

extract_csv_memorybank(){


    #x_1_2_3="test"
    #val="x_1_2_3"
    #x=`eval echo '$'$val`
    #echo "x=$x"
    #exit

    datadir="$1"

    memorybank_in=$datadir/pcm_memory.txt
    memorybank_out=$datadir/pcm_memory.csv


    #header="socket_0_channel_0 socket_0_channel_1 socket_0_channel_2 socket_0_channel_3"
    #header="$header "

    header="system_read,system_write,system_total"


    for socket in $SOCKETS_LIST; do
        #echo "$socket"

        title1="socket_""$socket""_read"

        title2="socket_""$socket""_write"

        title3="socket_""$socket""_pwrite"

        title4="socket_""$socket""_total"

        header="$header,$title1,$title2,$title3,$title4"


        for channel in $CHANNELS_LIST;do
            title5="socket_""$socket""_channel_""$channel""_read"

            title6="socket_""$socket""_channel_""$channel""_write"

            header="$header,$title5,$title6"
        done

    done

    echo $header > $memorybank_out
    #echo $header | tee $memorybank_out


    #echo "extract_csv_memorybank() -- Fixme"
    #cp $memorybank_in $memorybank_out

    record=""

    while read line; do

        #
        #
        # sync to line "Memory Channel Monitoring"
        #
        #
        line=`echo $line|grep 'Memory Channel Monitoring'`

        if [ "$line" = "" ];then
            continue
        fi


        read line

        if [ "$line" = "" ];then
            break
        fi


        #
        # echo "|-"|tr -d '|-'
        #
        for channel in $CHANNELS_LIST;do

            #
            # read socket N channel M
            #

            read line

            if [ "$line" = "" ];then
                break
            fi

            #echo $line


            if [ "`echo $line|grep Reads`" = "" ];then
                echo $line
                exit
            fi


            col=3
            channel_read=""
            for socket in $SOCKETS_LIST;do

                channel_read="`echo $line|cut -d':' -f$col|cut -d'-' -f1|tr -d \'\|\-\'`"
                channel_read="`echo $channel_read`"
                col="`expr $col + 2`"

                #if [ "$channel_read" = "" ];then
                #    echo $line
                #fi

                eval "socket_""$socket""_channel_""$channel""_read=$channel_read"

                #echo "socket_$socket""_channel_$channel""_read=$channel_read"
            done

            #
            # write socket N channel M
            #


            read line

            if [ "$line" = "" ];then
                break
            fi


            #echo $line

            col=2
            channel_write=""
            for socket in $SOCKETS_LIST;do

                channel_write="`echo $line|cut -d':' -f$col|cut -d'-' -f1`"
                channel_write="`echo $channel_write`"
                col="`expr $col + 1`"

                eval "socket_""$socket""_channel_""$channel""_write=$channel_write"
                #echo "socket_$socket""_channel_$channel""_write=$channel_write"
            done


        done


        #
        # socket total read
        #


        read line

        if [ "$line" = "" ];then
            break
        fi

        #echo $line

        col=2
        for socket in $SOCKETS_LIST;do
            socket_read="`echo $line|cut -d':' -f$col|cut -d'-' -f1`"
            socket_read="`echo $socket_read`"

            eval "socket_""$socket""_read=$socket_read"

            #echo "socket_$socket""_read=$socket_read"
            col="`expr $col + 1`"
        done

        #
        # socket total write
        #


        read line

        if [ "$line" = "" ];then
            break
        fi

        #echo $line

        col=2
        for socket in $SOCKETS_LIST;do
            socket_write="`echo $line|cut -d':' -f$col|cut -d'-' -f1`"
            socket_write="`echo $socket_write`"
            eval "socket_""$socket""_write=$socket_write"
            #echo "socket_$socket""_write=$socket_write"
            col="`expr $col + 1`"
        done

        #
        # socket total pwrite
        #


        read line

        if [ "$line" = "" ];then
            break
        fi

        #echo $line

        col=2
        for socket in $SOCKETS_LIST;do
            socket_pwrite="`echo $line|cut -d':' -f$col|cut -d'-' -f1`"
            socket_pwrite="`echo $socket_pwrite`"
            eval "socket_""$socket""_pwrite=$socket_pwrite"
            #echo "socket_$socket""_pwrite=$socket_pwrite"
            col="`expr $col + 1`"
        done


        #
        # socket total
        #


        read line

        if [ "$line" = "" ];then
            break
        fi

        #echo $line

        col=2
        for socket in $SOCKETS_LIST;do
            socket_total="`echo $line|cut -d':' -f$col|cut -d'-' -f1`"
            socket_total="`echo $socket_total`"
            #echo "socket_$socket""_total=$socket_total"
            eval "socket_""$socket""_total=$socket_total"
            col="`expr $col + 1`"
        done


        #
        # skip two lines
        #

        read line
        read line

        if [ "$line" = "" ];then
            break
        fi

        #
        # system read
        #

        read line

        if [ "$line" = "" ];then
            break
        fi

        #echo $line

        system_read="`echo $line|cut -d':' -f2|cut -d'-' -f1`"
        system_read="`echo $system_read`"
        eval "system_read=$system_read"

        #
        # system write
        #

        read line

        if [ "$line" = "" ];then
            break
        fi

        #echo $line

        system_write="`echo $line|cut -d':' -f2|cut -d'-' -f1`"
        system_write="`echo $system_write`"
        eval "system_write=$system_write"


        #
        # system total
        #

        read line

        if [ "$line" = "" ];then
            break
        fi

        #echo $line

        system_total="`echo $line|cut -d':' -f2|cut -d'-' -f1`"
        system_total="`echo $system_total`"
        eval "system_total=$system_total"


        #exit


        #
        # write to CSV files
        #

        record=""

        #"system_read system_write system_total"

        record="$system_read,$system_write,$system_total"


        for socket in $SOCKETS_LIST; do
        #echo "$socket"

            var1="socket_""$socket""_read"
            val1="`eval echo '$'$var1`"

            #echo $val1

            var2="socket_""$socket""_write"
            val2="`eval echo '$'$var2`"

            var3="socket_""$socket""_pwrite"
            val3="`eval echo '$'$var3`"

            var4="socket_""$socket""_total"
            val4="`eval echo '$'$var4`"

            #header="$header $title1 $title2 $title3 $title4"

            record="$record,$val1,$val2,$val3,$val4"

            for channel in $CHANNELS_LIST;do
               var5="socket_""$socket""_channel_""$channel""_read"
               val5="`eval echo '$'$var5`"

               var6="socket_""$socket""_channel_""$channel""_write"
               val6="`eval echo '$'$var6`"

               #header="$header $title5 $title6"
               record="$record,$val5,$val6"
            done

        done

        #channel=1
        #socket=1
        #eval echo '$'"socket_""$socket""_total"

        echo $record |tee -a $memorybank_out

    done < $memorybank_in


}

extract_csv_cpucache() {
    #
    #
    #

    datadir="$1"

    cpucache_in=$datadir/pcm_latency.txt
    cpucache_out=$datadir/pcm_latency.csv

    if [ -f "$cpucache_in" ];then
        echo "Creating $cpucache_out ..."
        #echo "Socket0,Socket1" > $cpucache_out

        header=""

        for id in $SOCKETS_LIST; do
            if [ "$id" = "0" ]; then
                header="Socket""$id"
            else
                header="$header,Socket$id"
            fi
        done


        echo "$header" |tee $cpucache_out

      #  cat $cpucache_in | \
      #          grep Socket | \
      #          sed '/Thread/d'| \
      #          awk '{if(NR%2==0){printf $0 "\n"}else{printf "%s,",$0}}' | \
      #          sed 's/://g'|\
      #          sed 's/Socket0//g'|\
      #          sed 's/Socket1//g' >> $app_cpucache_out

        record=""
        n=0

        #echo $header

        while read line; do
            line=`echo $line|grep Socket|sed '/Thread/d'|cut -d: -f2`

            if [ "$line" = "" ];then
                continue
            fi

            socket_id="`echo $n % $N_SOCKETS|bc`"
            n="`expr $n + 1`"


            if [ "$socket_id" = "0" ]; then
                record="$line"
            else
                record="$record"",""$line"
            fi

            if [ "$socket_id" = "$MAX_SOCKET_ID" ];then
                echo $record |tee -a $cpucache_out
                #echo $header
                #echo $record
            fi

        done < $cpucache_in

    fi


}


extract_csv_numastat() {
    datadir="$1"

    #
    #
    #

    numastat_in=$datadir/numastat.txt
    numastat_out=$datadir/numastat.csv

    if [ -f "$numastat_in" ];then
        echo "Creating $numastat_out ..."
        echo "MemUsed" > $numastat_out
        cat $numastat_in | grep MemUsed|awk '{print $4}' >> $numastat_out
        cat $numastat_out
    fi


}


extract_csv_cpupower(){
    datadir="$1"
    #
    #
    #

    app_cpupower_in=$datadir/app_cpupower.txt
    app_cpupower_out=$datadir/app_cpupower.csv


    if [ -f "$app_cpupower_in" ];then
        echo "Creating $app_cpupower_in ..."
        #echo "S0_CPU,S0_MEM,S1_CPU,S1_MEM" > $app_cpupower_out

        header=""


        for id in $SOCKETS_LIST; do
            if [ "$id" = "0" ]; then
                header="S""$id""_CPU"",""S""$id""_MEM"
            else
                header="$header,""S""$id""_CPU"",""S""$id""_MEM"
            fi

        done

        #echo "$header"


        # S0; Consumed energy units: 1053740; Consumed Joules: 64.32; Watts: 32.16; Thermal headroom below TjMax: 33
        # S0; Consumed DRAM energy units: 772740; Consumed DRAM Joules: 11.82; DRAM Watts: 5.91
        # S1; Consumed energy units: 1052202; Consumed Joules: 64.22; Watts: 32.11; Thermal headroom below TjMax: 40
        # S1; Consumed DRAM energy units: 761241; Consumed DRAM Joules: 11.65; DRAM Watts: 5.82

        echo "$header" | tee  $app_cpupower_out

        n=0

        #echo "$header"

        record=""

        while read line; do
            line=`echo $line|grep Watts`

            if [ "$line" = "" ];then
                continue
            fi

            socket_id="`echo $n % $N_SOCKETS|bc`"
            item_id="`echo $n % 2|bc`"

            mod="`echo $n % 4|bc`"

            max_mod="`echo $N_SOCKETS \* 2 - 1 | bc`"

            n="`expr $n + 1`"

            line=`echo $line|cut -d';' -f4|cut -d':' -f2`

            #if [ "$item_id" = "0" ];then
            #    #CPU
            #    echo "Socket#$socket_id CPU $line Watts"
            #else
            #    #Mem
            #    echo "Socket#$socket_id MEM $line Watts"
            #fi

            if [ "$mod" = "0" ];then
                record="$line"
            else
                record="$record,$line"
            fi

            if [ "$mod" = "$max_mod" ];then
                echo "$record" | tee -a $app_cpupower_out
            fi


            #echo $line
        done < $app_cpupower_in

    fi


}
