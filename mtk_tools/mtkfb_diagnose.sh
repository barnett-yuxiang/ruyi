#!/bin/sh

# 在出問題時, 錄製mtkfb.log，具体的操作如下：
# 先操作一次正常的和异常的，然后在問題錄到畫面有問題的時候下diagnose
# adb shell "echo diagnose > /d/mtkfb"
#
# 再dump ringbuffer
# adb shell "cat /d/mtkfb" > mtkfb.log

DATE=$(date +%Y%m%d%H%M%S)

echo "echo diagnose > /d/mtkfb"
adb shell "echo diagnose > /d/mtkfb"

sleep 1  #等1秒后执行下一条

echo "adb shell "cat /d/mtkfb" > mtkfb.log"
adb shell "cat /d/mtkfb" > mtkfb.log.""$DATE
