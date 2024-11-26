@echo off
setlocal enabledelayedexpansion

:: Debug Breakpoint 1: Start script
echo [DEBUG] Starting the script...

:: Check if the script is running in PowerShell
set powershell_detected=false
for /f "delims=" %%i in ('powershell -Command "$PSVersionTable.PSVersion.Major"') do (
    set powershell_detected=true
    echo [DEBUG] PowerShell detected.
)

:: Debug Breakpoint 2: Check environment
if "!powershell_detected!"=="true" (
    echo [DEBUG] Running in PowerShell.
) else (
    echo [DEBUG] Running in CMD.
)

:: Debug Breakpoint 3: Check for Python
if "!powershell_detected!"=="true" (
    echo [DEBUG] Using where.exe to check for Python...
    where.exe python >nul 2>nul
) else (
    echo [DEBUG] Using where to check for Python...
    where python >nul 2>nul
)

:: Explicitly check the errorlevel
echo [DEBUG] Checking errorlevel after where command: %errorlevel%
if %errorlevel%==0 (
    echo [DEBUG] Python is installed. Proceeding to check Python version...
    python --version
    if %errorlevel% neq 0 (
        echo [DEBUG] Unable to execute the Python command. Ensure Python is in the PATH.
        exit /b 1
    )
    echo [DEBUG] Python command works. Proceeding to compilation...
    
) else (
    echo [DEBUG] Python is not installed.
    echo Would you like to install Python now? (y/n)
    set doesthislinerun=true
    set /p user_choice=
    echo value of doesthislinerun is !doesthislinerun!
    echo [DEBUG] User chose: !user_choice!

    if /i "!user_choice!"=="y" (
        echo [DEBUG] Downloading Python installer...
        if "!powershell_detected!"=="true" (
            powershell -Command "Start-BitsTransfer -Source https://www.python.org/ftp/python/3.11.5/python-3.11.5-amd64.exe -Destination '^%USERPROFILE^%\Downloads\python-installer.exe'"
        ) else (
            bitsadmin /transfer "PythonDownload" https://www.python.org/ftp/python/3.11.5/python-3.11.5-amd64.exe "%USERPROFILE%\Downloads\python-installer.exe"
        )
        
        echo [DEBUG] Downloading completed with errorlevel: %errorlevel%
        if %errorlevel% neq 0 (
            echo [DEBUG] Failed to download the Python installer.
            echo Failed to download the Python installer. Please check your internet connection and try again.
            exit /b 1
        )
        
        echo Launching the installer...
        start /wait "%USERPROFILE%\Downloads\python-installer.exe"
        
        echo [DEBUG] Installer finished with errorlevel: %errorlevel%
        if %errorlevel% neq 0 (
            echo [DEBUG] Python installation failed.
            echo Python installation failed. Please check the installer for errors.
            exit /b 1
        )
        echo [DEBUG] Python installation complete.
    ) else (
        echo [DEBUG] User chose not to install Python.
        echo Python installation skipped. Exiting.
        exit /b 1
    )

)

:: Debug Breakpoint 4: Compile Python files
echo [DEBUG] Compiling Python files in the current directory...
python -m compileall . >nul 2>nul
echo [DEBUG] After compilation command: %errorlevel%
if %errorlevel% neq 0 (
    echo [DEBUG] Compilation failed.
    echo Compilation failed. Please check for errors in your Python scripts.
    exit /b 1
)

echo [DEBUG] Compilation successful.
echo Compilation successful.
pause
