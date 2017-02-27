echo time Loading>>GPU_Loading.txt
:begin
ping /n 0.1 127.1>nul
for /f "usebackq tokens=4 delims= " %%i in (`"@adb shell date"`) do @set var=%%i
for /f "usebackq tokens=* delims=" %%j in (`"@adb shell cat /proc/mali/utilization"`) do @set var2=%%j
echo %var% %var2% >>GPU_Loading.txt
goto begin
