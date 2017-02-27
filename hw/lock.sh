# File:		lock.sh
# Author:	caobo
# Email:	caobo@meizu.com
# Description:  lock cpu gpu freq and so on
#!/bin/sh

#lock.sh会自动生成一个lockconfig文件，用于保存以下参数,不需要手动去修改它。
#默认锁住CPU，GPU的时间为1 hours
DEFAULT_TIMEOUT=3600000
#打印的采样率为0.5s
DEFAULT_PRINT_SAMPLE=0.5
#机型会自动判断
PRODUCT_NAME=
#CPU核数
CPU_ONLINE=
PRE_CPU_ONLINE=
#CPU频率
CPU_FREQ=
PRE_CPU_FREQ=
#GPU频率
GPU_FREQ=
PRE_GPU_FREQ=
#custom参数列表
CUSTOM=
PRE_CUSTOM=
#需要重新写参数标志位
NEEDWRITECONFIG=0
#三星需要标记perfScheduler
PERFSCHEDULER=

HOMEPATH=/home/yuxiang/repo_script/lock_cpu_gpu

#创建配置脚本
function createlockconfig()
{
    if [ -f lockconfig ];then
    rm lockconfig
    fi
    touch lockconfig
    echo "DEFAULT_TIMEOUT=$DEFAULT_TIMEOUT" >> lockconfig
    echo "DEFAULT_PRINT_SAMPLE=$DEFAULT_PRINT_SAMPLE" >> lockconfig
    echo "CPU_ONLINE=$CPU_ONLINE" >> lockconfig
    echo "CPU_FREQ=$CPU_FREQ" >> lockconfig
    echo "GPU_FREQ=$GPU_FREQ" >> lockconfig
    echo "CUSTOM=$CUSTOM" >> lockconfig
    echo "NEEDWRITECONFIG=$NEEDWRITECONFIG" >> lockconfig
}

#load config
function loadlockconfig()
{
	if [ -f lockconfig ];then
		. lockconfig
	fi
}

#phone load config
function phoneloadlockconfig()
{
	. /sdcard/lockconfig
}

#push lock.sh 以及lockconfig 到手机的/sdcard
function pushlocksh()
{
	adb root 1>/dev/null 2>&1
	adb remount 1>/dev/null 2>&1
	adb push $HOMEPATH/lock.sh /sdcard/  1>/dev/null 2>&1
	adb shell chmod 777 /sdcard/lock.sh
}

function pushlockconfig()
{
	createlockconfig
	adb push lockconfig /sdcard/  1>/dev/null 2>&1
	adb shell chmod 777 /sdcard/lockconfig
	rm lockconfig
}

#获得手机可以配置的参数信息
function getCapacity()
{
	PRODUCT_NAME=`getprop ro.product.mobile.name`
	if [ "$PRODUCT_NAME" == "" ];then
	PRODUCT_NAME=`getprop ro.product.name`
	fi
	echo "PRODUCT_NAME=$PRODUCT_NAME" >> /sdcard/lockconfig
	echo "手机机型： $PRODUCT_NAME"
	echo "CPU可配置频率值:"
	if [ "$PRODUCT_NAME" == "m86" ];then
		echo "小核：`cat /sys/devices/system/cpu/cpufreq/mp-cpufreq/cluster0_freq_table`"
		echo "大核：`cat /sys/devices/system/cpu/cpufreq/mp-cpufreq/cluster1_freq_table`"
	elif [ "$PRODUCT_NAME" == "m76" ];then
		echo "小核：`cat /sys/devices/system/cpu/cpufreq/mp-cpufreq/kfc_freq_table`"
		echo "大核：`cat /sys/devices/system/cpu/cpufreq/mp-cpufreq/cpu_freq_table`"
	else
		echo "`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies`"
	fi

	echo "GPU可配置频率值:"
	if [ "$PRODUCT_NAME" == "m86" -o "$PRODUCT_NAME" == "m76" ];then
		echo "`cat /sys/bus/platform/devices/14ac0000.mali/dvfs_table`"
	else
		echo "`cat /proc/gpufreq/gpufreq_opp_dump`"
	fi
}

#使用帮助
function help()
{
	echo "/*************配置会受到温控以及性能模式的影响*************/"
	echo "-h	帮助"
	echo "-s	设置"
	getCapacity
	exit 1
}

#读取手机当前运行信息
function readphoneruninfo()
{
	if [ "$PRODUCT_NAME" == "" ];then
		echo "/*************Start Get phone Message*************/"
		PRODUCT_NAME=`getprop ro.product.mobile.name`
		if [ "$PRODUCT_NAME" == "" ];then
		PRODUCT_NAME=`getprop ro.product.name`
			if [ "$PRODUCT_NAME" == "" ];then
				PRODUCT_NAME=m81
				echo "Can't not find product mobile name, Use m81 instead"
			fi
		fi
		echo "当前手机型号为：$PRODUCT_NAME"
	fi
	if [ "$PRODUCT_NAME" == "m85" -o "$PRODUCT_NAME" == "m71" -o "$PRODUCT_NAME" == "ma01"  ];then
		MODE=`cat /sys/power/power_mode`
		ONLINE=`cat /sys/devices/system/cpu/online`
		CPUFREQ=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`
		GPUFREQ=`cat /proc/gpufreq/gpufreq_var_dump | grep -w g_cur_gpu_freq`
		SETCPUCORE=`cat /proc/hps/num_base_perf_serv`
	elif [ "$PRODUCT_NAME" == "m81" -o "$PRODUCT_NAME" == "m2" -o "$PRODUCT_NAME" == "M57AC"  -o "$PRODUCT_NAME" == "m2 note"];then
		MODE=`cat /sys/power/power_mode`
		ONLINE=`cat /sys/devices/system/cpu/online`
		CPUFREQ=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`
		GPUFREQ=`cat /proc/gpufreq/gpufreq_var_dump | grep frequency`
		SETCPUCORE=`cat /proc/hps/num_base_perf_serv`
		CPUTEMP=`cat /sys/class/thermal/thermal_zone7/temp`
	elif [ "$PRODUCT_NAME" == "m86" ];then
		MODE=`cat /sys/power/power_mode`
		ONLINE=`cat /sys/devices/system/cpu/online`
		CPUFREQ=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`
		if [ ! -f "/sys/devices/system/cpu/cpu4/cpufreq/scaling_cur_freq" ];then
			BIGCPUFREQ="null"
		else
			BIGCPUFREQ=`cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_cur_freq`
		fi
		GPUFREQ=`cat /sys/bus/platform/devices/14ac0000.mali/clock`
	elif [ "$PRODUCT_NAME" == "m76" ];then
		MODE=`cat /sys/power/power_mode`
		ONLINE=`cat /sys/devices/system/cpu/online`
		CPUFREQ=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`
			if [ ! -f "/sys/devices/system/cpu/cpu4/cpufreq/scaling_cur_freq" ];then
			BIGCPUFREQ="null"
			else
			BIGCPUFREQ=`cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_cur_freq`
			fi
		GPUFREQ=`cat /sys/bus/platform/devices/14ac0000.mali/clock`
		CPUTEMP=`cat /sys/devices/10060000.tmu/cpu_temp`
		BOARDTMEP=`cat /sys/devices/10060000.tmu/ntc_temp`
		PERF=`getprop debug.perfscheduler.disable`
		if [ "$PERF" == "" ];then
			PERF=true
		else
			PERF=close
		fi
	elif [ "$PRODUCT_NAME" == "m80" -o "$PRODUCT_NAME" == "m91" -o "$PRODUCT_NAME" == "m95" ];then
		MODE=`cat /sys/power/power_mode`
		ONLINE=`cat /sys/devices/system/cpu/online`
		CPUFREQ_0=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`
			if [ ! -f "/sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq" ];then
			CPUFREQ_1="0"
			else
			CPUFREQ_1=`cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq`
			fi
			if [ ! -f "/sys/devices/system/cpu/cpu2/cpufreq/scaling_cur_freq" ];then
			CPUFREQ_2="0"
			else
			CPUFREQ_2=`cat /sys/devices/system/cpu/cpu2/cpufreq/scaling_cur_freq`
			fi
			if [ ! -f "/sys/devices/system/cpu/cpu3/cpufreq/scaling_cur_freq" ];then
			CPUFREQ_3="0"
			else
			CPUFREQ_3=`cat /sys/devices/system/cpu/cpu3/cpufreq/scaling_cur_freq`
			fi
			if [ ! -f "/sys/devices/system/cpu/cpu4/cpufreq/scaling_cur_freq" ];then
			CPUFREQ_4="0"
			else
			CPUFREQ_4=`cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_cur_freq`
			fi
			if [ ! -f "/sys/devices/system/cpu/cpu5/cpufreq/scaling_cur_freq" ];then
			CPUFREQ_5="0"
			else
			CPUFREQ_5=`cat /sys/devices/system/cpu/cpu5/cpufreq/scaling_cur_freq`
			fi
			if [ ! -f "/sys/devices/system/cpu/cpu6/cpufreq/scaling_cur_freq" ];then
			CPUFREQ_6="0"
			else
			CPUFREQ_6=`cat /sys/devices/system/cpu/cpu6/cpufreq/scaling_cur_freq`
			fi
			if [ ! -f "/sys/devices/system/cpu/cpu7/cpufreq/scaling_cur_freq" ];then
			CPUFREQ_7="0"
			else
			CPUFREQ_7=`cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_cur_freq`
			fi
			if [ ! -f "/sys/devices/system/cpu/cpu8/cpufreq/scaling_cur_freq" ];then
			CPUFREQ_8="0"
			else
			CPUFREQ_8=`cat /sys/devices/system/cpu/cpu8/cpufreq/scaling_cur_freq`
			fi
			if [ ! -f "/sys/devices/system/cpu/cpu9/cpufreq/scaling_cur_freq" ];then
			CPUFREQ_9="0"
			else
			CPUFREQ_9=`cat /sys/devices/system/cpu/cpu9/cpufreq/scaling_cur_freq`
			fi
		CPUFREQ=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`
		GPUFREQ=`cat /proc/gpufreq/gpufreq_var_dump | grep -w g_cur_gpu_freq`
		SETCPUCORE=`cat /proc/hps/num_base_perf_serv`
	elif [ "$PRODUCT_NAME" == "a02" -o "$PRODUCT_NAME" == "s25" ];then
		MODE=`cat /sys/power/power_mode`
		ONLINE=`cat /sys/devices/system/cpu/online`
		CPUFREQ_0=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`
			if [ ! -f "/sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq" ];then
			CPUFREQ_1="0"
			else
			CPUFREQ_1=`cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq`
			fi
			if [ ! -f "/sys/devices/system/cpu/cpu2/cpufreq/scaling_cur_freq" ];then
			CPUFREQ_2="0"
			else
			CPUFREQ_2=`cat /sys/devices/system/cpu/cpu2/cpufreq/scaling_cur_freq`
			fi
			if [ ! -f "/sys/devices/system/cpu/cpu3/cpufreq/scaling_cur_freq" ];then
			CPUFREQ_3="0"
			else
			CPUFREQ_3=`cat /sys/devices/system/cpu/cpu3/cpufreq/scaling_cur_freq`
			fi
			if [ ! -f "/sys/devices/system/cpu/cpu4/cpufreq/scaling_cur_freq" ];then
			CPUFREQ_4="0"
			else
			CPUFREQ_4=`cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_cur_freq`
			fi
			if [ ! -f "/sys/devices/system/cpu/cpu5/cpufreq/scaling_cur_freq" ];then
			CPUFREQ_5="0"
			else
			CPUFREQ_5=`cat /sys/devices/system/cpu/cpu5/cpufreq/scaling_cur_freq`
			fi
			if [ ! -f "/sys/devices/system/cpu/cpu6/cpufreq/scaling_cur_freq" ];then
			CPUFREQ_6="0"
			else
			CPUFREQ_6=`cat /sys/devices/system/cpu/cpu6/cpufreq/scaling_cur_freq`
			fi
			if [ ! -f "/sys/devices/system/cpu/cpu7/cpufreq/scaling_cur_freq" ];then
			CPUFREQ_7="0"
			else
			CPUFREQ_7=`cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_cur_freq`
			fi
			if [ ! -f "/sys/devices/system/cpu/cpu8/cpufreq/scaling_cur_freq" ];then
			CPUFREQ_8="0"
			else
			CPUFREQ_8=`cat /sys/devices/system/cpu/cpu8/cpufreq/scaling_cur_freq`
			fi
			if [ ! -f "/sys/devices/system/cpu/cpu9/cpufreq/scaling_cur_freq" ];then
			CPUFREQ_9="0"
			else
			CPUFREQ_9=`cat /sys/devices/system/cpu/cpu9/cpufreq/scaling_cur_freq`
			fi
		CPUFREQ=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`
		GPUFREQ=`cat /proc/gpufreq/gpufreq_var_dump | grep -w g_cur_gpu_freq`
	else
		echo "Error"
	fi
}

#打印手机运行信息
function printphoneruninfo()
{
	while :;
	do
		phoneloadlockconfig
		if [ $NEEDWRITECONFIG == "1" ];then
			configsamsung
		elif [ $NEEDWRITECONFIG == "2" ];then
			configmtk
		fi

		readphoneruninfo

		echo "Mode : $MODE     | OnLine : $ONLINE     |GPU : $GPUFREQ     | C : $CPUTEMP℃     | B : $BOARDTMEP℃     | Perf : $PERF"
		echo ""
		echo "CPU :  cpu0 : $CPUFREQ_0      | cpu1 : $CPUFREQ_1     | cpu2 : $CPUFREQ_2     | cpu3 : $CPUFREQ_3     |cpu4 : $CPUFREQ_4"
		echo "CPU :  cpu5 : $CPUFREQ_5      | cpu6 : $CPUFREQ_6     | cpu7 : $CPUFREQ_7     | cpu8 : $CPUFREQ_8     |cpu9 : $CPUFREQ_9 "

		sleep $DEFAULT_PRINT_SAMPLE
	done
}

#MTK配置
function configmtk()
{
	cpuonlinemtk
	cpufreqmtk
	gpufreqmtk
}
#CPU ONLINE
function cpuonlinemtk()
{
	if [ "$CPU_ONLINE" != "$PRE_CPU_ONLINE" ];then
		echo 0 > /proc/hps/enabled
		i=0
		while [ i -lt $CPU_ONLINE ]
		do
			echo 1 >/sys/devices/system/cpu/cpu${i}/online
			let "i+=1"
		done
	fi
}
#CPU 频率
function cpufreqmtk()
{
	if [ "$CPU_FREQ" != "$PRE_CPU_FREQ" ];then
		echo $CPU_FREQ > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
	fi
}
#GPU 频率
function gpufreqmtk()
{
	if [ "$GPU_FREQ" != "$PRE_GPU_FREQ" ];then
		echo $GPU_FREQ > /proc/gpufreq/gpufreq_opp_freq
	fi
}
#end MTK配置

#SAMSUNG配置
function configsamsung()
{
	if [ "$CUSTOM" != "$PRE_CUSTOM" ];then
		echo "custom" > /sys/power/perf_mode
		echo "0" > /sys/power/perf_boost
		echo $CUSTOM > /sys/power/perf_custom
		echo "2" > /sys/power/perf_boost_hmp
		echo "$DEFAULT_TIMEOUT" > /sys/power/perf_boost_timeout
		echo "$DEFAULT_TIMEOUT" > /sys/power/perf_boost_hmp_timeout
		echo "1" > /sys/power/perf_boost
	fi
}
#end SAMSUNG配置

#从终端中读配置信息
function readfromterminator()
{
	if [ "$PRODUCT_NAME" == "m86" -o "$PRODUCT_NAME" == "m76" ];then
		echo "e.g：b_f l_f g_f 0 0 l_C b_c"
		echo "e.g：2100000 1500000 350 0 0 2 3"
		read -p "请输入配置参数：" CUSTOM_TEMP
		echo "配置参数列表： $CUSTOM_TEMP"
		CUSTOM="\"$CUSTOM_TEMP\""
		if [ "$CUSTOM" != "" ];then
			NEEDWRITECONFIG=1
		fi
	else
		read -p "CPU核数？:" CPU_ONLINE
		if [ "$CPU_ONLINE" == "" ];then
			CPU_ONLINE=0
		fi
		echo "配置锁定核数为：$CPU_ONLINE"
		read -p "CPU频率？:" CPU_FREQ
		if [ "$CPU_FREQ" == "" ];then
			CPU_FREQ=0
		fi
		echo "配置CPU的频率为：$CPU_FREQ"
		read -p "GPU频率？:" GPU_FREQ
		if [ "$GPU_FREQ" == "" ];then
			GPU_FREQ=0
		fi
		echo "配置GPU的频率为：$GPU_FREQ"
		NEEDWRITECONFIG=2
	fi
}

#不用带参数，直接运行./lock.sh
if [ $# -lt 1 ];then
	pushlocksh
	pushlockconfig
	adb shell sh /sdcard/lock.sh -r
fi


while getopts "rhHsSt:" opt;
do
	case $opt in
	r)
	printphoneruninfo
	;;
	h)
	pushlocksh
	adb shell sh /sdcard/lock.sh -H
	;;
	H)
	help
	;;
	s)
	pushlocksh
	adb shell sh /sdcard/lock.sh -H
	adb pull /sdcard/lockconfig . 1>/dev/null 2>&1
	loadlockconfig
	readfromterminator
	createlockconfig
	pushlockconfig
	;;
	t)
	loadlockconfig
	DEFAULT_PRINT_SAMPLE=$OPTARG
	createlockconfig
	pushlockconfig
	;;
	?)
	echo "not support"
	esac
done
