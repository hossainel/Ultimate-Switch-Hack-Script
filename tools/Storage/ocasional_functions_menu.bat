::Script by Shadow256
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
:define_action_choice
call "%associed_language_script%" "display_title"
set action_choice=
cls
call "%associed_language_script%" "display_menu"
IF "%action_choice%"=="1" goto:biskey_dump
IF "%action_choice%"=="2" goto:install_drivers
IF "%action_choice%"=="3" goto:create_update
IF "%action_choice%"=="4" goto:verif_serials
IF "%action_choice%"=="5" goto:test_keys
IF "%action_choice%"=="6" goto:hid-mitm_compagnon
IF "%action_choice%"=="7" goto:emuguiibo
IF "%action_choice%"=="8" goto:game_saves_unpack
IF "%action_choice%"=="9" goto:launch_linux
IF "%action_choice%"=="10" goto:update_shofel2
IF "%action_choice%"=="11" goto:nsZip
goto:end_script
:biskey_dump
set action_choice=
echo.
cls
IF EXIST "tools\Storage\biskey_dump.bat" (
	call tools\Storage\update_manager.bat "update_biskey_dump.bat"
) else (
	call tools\Storage\update_manager.bat "update_biskey_dump.bat" "force"
)
call TOOLS\Storage\biskey_dump.bat
@echo off
goto:define_action_choice
:install_drivers
set action_choice=
echo.
cls
IF EXIST "tools\Storage\install_drivers.bat" (
	call tools\Storage\update_manager.bat "update_install_drivers.bat"
) else (
	call tools\Storage\update_manager.bat "update_install_drivers.bat" "force"
)
call TOOLS\Storage\install_drivers.bat
@echo off
goto:define_action_choice
:create_update
set action_choice=
echo.
cls
IF EXIST "tools\Storage\create_update.bat" (
	call tools\Storage\update_manager.bat "update_create_update.bat"
) else (
	call tools\Storage\update_manager.bat "update_create_update.bat" "force"
)
call TOOLS\Storage\create_update.bat
@echo off
goto:define_action_choice
:verif_serials
set action_choice=
echo.
cls
IF EXIST "tools\Storage\serial_checker.bat" (
	call tools\Storage\update_manager.bat "update_serial_checker.bat"
) else (
	call tools\Storage\update_manager.bat "update_serial_checker.bat" "force"
)
call TOOLS\Storage\serial_checker.bat
@echo off
goto:define_action_choice
:test_keys
set action_choice=
echo.
cls
IF EXIST "tools\Storage\test_keys.bat" (
	call tools\Storage\update_manager.bat "update_test_keys.bat"
) else (
	call tools\Storage\update_manager.bat "update_test_keys.bat" "force"
)
call TOOLS\Storage\test_keys.bat
@echo off
goto:define_action_choice
:hid-mitm_compagnon
set action_choice=
echo.
cls
IF EXIST "tools\Storage\launch_hid-mitm_compagnon.bat" (
	call tools\Storage\update_manager.bat "update_launch_hid-mitm_compagnon.bat"
) else (
	call tools\Storage\update_manager.bat "update_launch_hid-mitm_compagnon.bat" "force"
)
call tools\Storage\launch_hid-mitm_compagnon.bat
@echo off
goto:define_action_choice
:emuguiibo
set action_choice=
echo.
cls
IF EXIST "tools\Storage\launch_emuGUIibo.bat" (
	call tools\Storage\update_manager.bat "update_launch_emuGUIibo.bat"
) else (
	call tools\Storage\update_manager.bat "update_launch_emuGUIibo.bat" "force"
)
call tools\Storage\launch_emuGUIibo.bat
@echo off
goto:define_action_choice
:game_saves_unpack
set action_choice=
echo.
cls
IF EXIST "tools\Storage\game_saves_unpack.bat" (
	call tools\Storage\update_manager.bat "update_game_saves_unpack.bat"
) else (
	call tools\Storage\update_manager.bat "update_game_saves_unpack.bat" "force"
)
call tools\Storage\game_saves_unpack.bat
@echo off
goto:define_action_choice
:launch_linux
set action_choice=
echo.
cls
IF EXIST "tools\Storage\launch_linux.bat" (
	call tools\Storage\update_manager.bat "update_launch_linux.bat"
) else (
	call tools\Storage\update_manager.bat "update_launch_linux.bat" "force"
)
call TOOLS\Storage\launch_linux.bat
@echo off
goto:define_action_choice
:update_shofel2
set action_choice=
echo.
cls
IF EXIST "tools\Storage\update_shofel2.bat" (
	call tools\Storage\update_manager.bat "update_update_shofel2.bat"
) else (
	call tools\Storage\update_manager.bat "update_update_shofel2.bat" "force"
)
call TOOLS\Storage\update_shofel2.bat
@echo off
goto:define_action_choice
:nsZip
set action_choice=
echo.
cls
IF EXIST "tools\Storage\nsZip.bat" (
	call tools\Storage\update_manager.bat "update_nsZip.bat"
) else (
	call tools\Storage\update_manager.bat "update_nsZip.bat" "force"
)
call TOOLS\Storage\nsZip.bat
@echo off
goto:define_action_choice
:end_script
endlocal