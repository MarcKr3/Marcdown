@echo off
rem Runs board from PowerShell or cmd through Git Bash (comes with Git for Windows).
setlocal
for /f "delims=" %%G in ('where git.exe 2^>nul') do if not defined GITEXE set "GITEXE=%%G"
if not defined GITEXE (echo board: install Git for Windows first & exit /b 1)
for %%D in ("%GITEXE%\..\..") do set "GITROOT=%%~fD"
set "BASHEXE=%GITROOT%\bin\bash.exe"
if not exist "%BASHEXE%" for %%D in ("%GITROOT%\..") do set "BASHEXE=%%~fD\bin\bash.exe"
if not exist "%BASHEXE%" (echo board: Git Bash not found next to %GITEXE% & exit /b 1)
"%BASHEXE%" "%~dp0board" %*
