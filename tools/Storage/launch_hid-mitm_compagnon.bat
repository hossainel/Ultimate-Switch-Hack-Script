::script by shadow256
call tools\storage\functions\ini_scripts.bat
Setlocal enabledelayedexpansion
set this_script_full_path=%~0
set associed_language_script=%language_path%\!this_script_full_path:%ushs_base_path%=!
set associed_language_script=%ushs_base_path%%associed_language_script%
IF NOT EXIST "%associed_language_script%" (
	set associed_language_script=languages\FR_fr\!this_script_full_path:%ushs_base_path%=!
	set associed_language_script=%ushs_base_path%!associed_language_script!
	echo Associed language file not found, use the update manager to install the file. French language will be tryed.
	pause
)
IF NOT EXIST "%associed_language_script%" (
	echo Language error, please use the update manager to update the script. The script couldn't continue.
	pause
	endlocal
	goto:eof
)
IF EXIST "%~0.version" (
	set /p this_script_version=<"%~0.version"
) else (
	set this_script_version=1.00.00
)
:start
cls
set IP_Adress=
call "%associed_language_script%" "display_title"
call "%associed_language_script%" "intro"
ECHO.
call "%associed_language_script%" "ip_choice"
IF "%IP_Adress%"=="" goto:end_script
tools\Hid-mitm_compagnon\input_pc_win.exe %IP_Adress%
ECHO.
goto start
:end_script
endlocal