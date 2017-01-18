#!/bin/bash

n=1
while [ $n -le 30 ]
do
    echo $n
    adb shell dumpsys SurfaceFlinger
    let n++    #或者写作n=$(( $n + 1 ))
done
