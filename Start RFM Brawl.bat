@echo off
setlocal
set "GODOT=%GODOT_EXE%"
if not defined GODOT if exist "%USERPROFILE%\Desktop\Aplikacje\Godot_v4.7.2-stable_win64.exe" set "GODOT=%USERPROFILE%\Desktop\Aplikacje\Godot_v4.7.2-stable_win64.exe"
if not defined GODOT set "GODOT=godot"
"%GODOT%" --path "%~dp0"
if errorlevel 1 pause
endlocal
