#!/system/bin/sh
#

RQ_dir=/sys/devices/system/cpu/cpu0/rq-stats/cpu_normalized_load
while :;
do
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        little=`cat /sys/devices/system/cpu/cpu0/online`
        if [ $little -eq 1 ]; then
                lit_freq=`cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq`
                echo "little cpufreq: $lit_freq"
        fi
        big=`cat /sys/devices/system/cpu/cpu4/online`
        if [ $big -eq 1 ]; then
                big_freq=`cat /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_cur_freq`
                echo "big  cpufreq  : $big_freq"
        fi
        perf=`cat /proc/hps/num_base_perf_serv`
        echo "perfservice cpu core: $perf"
        cat $RQ_dir
        echo " "
        sleep 1
done

exit 1







