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
call "%associed_language_script%" "display_title"
IF EXIST templogs (
	del /q templogs 2>nul
	rmdir /s /q templogs 2>nul
)
mkdir templogs
call "%associed_language_script%" "intro"
pause
:define_action_choice
cls
set biskeys_param=
set biskeys_file_path=
set action_choice=
call "%associed_language_script%" "display_title"
call "%associed_language_script%" "first_action_choice"
IF "%action_choice%"=="1" cls & goto:info_nand
IF "%action_choice%"=="2" cls & goto:dump_nand
IF "%action_choice%"=="3" cls & goto:restaure_nand
IF "%action_choice%"=="4" cls & goto:autorcm_management
IF "%action_choice%"=="5" (
	cls
	call tools\storage\nand_joiner.bat
	IF EXIST templogs (
		del /q templogs 2>nul
		rmdir /s /q templogs 2>nul
	)
	mkdir templogs
	goto:define_action_choice
)
IF "%action_choice%"=="6" (
	cls
	call tools\storage\nand_spliter.bat
	IF EXIST templogs (
		del /q templogs 2>nul
		rmdir /s /q templogs 2>nul
	)
	mkdir templogs
	goto:define_action_choice
)
IF "%action_choice%"=="7" (
	cls
	call tools\storage\emunand_partition_file_create.bat
	IF EXIST templogs (
		del /q templogs 2>nul
		rmdir /s /q templogs 2>nul
	)
	mkdir templogs
	goto:define_action_choice
)
IF "%action_choice%"=="8" (
	cls
	call tools\storage\extract_nand_files_from_emunand_partition_file.bat
	IF EXIST templogs (
		del /q templogs 2>nul
		rmdir /s /q templogs 2>nul
	)
	mkdir templogs
	goto:define_action_choice
)
IF "%action_choice%"=="9" cls & goto:decrypt_nand
IF "%action_choice%"=="10" cls & goto:encrypt_nand
IF "%action_choice%"=="11" cls & goto:incognito_apply
IF "%action_choice%"=="12" (
	cls
	call tools\storage\ninfs.bat
	IF EXIST templogs (
		del /q templogs 2>nul
		rmdir /s /q templogs 2>nul
	)
	mkdir templogs
	goto:define_action_choice
)
IF "%action_choice%"=="13" cls & goto:resize_user_partition
IF "%action_choice%"=="0" (
	cls
	call tools\storage\mount_discs.bat "auto_close"
	IF EXIST templogs (
		del /q templogs 2>nul
		rmdir /s /q templogs 2>nul
	)
	mkdir templogs
	goto:define_action_choice
)
goto:end_script

:info_nand
set input_path=
set action_choice=
call "%associed_language_script%" "nand_infos_begin"
call :list_disk
call "%associed_language_script%" "nand_choice"
IF "%action_choice%" == "" (
	goto:define_action_choice
)
call :verif_disk_choice %action_choice% info_nand
IF "%action_choice%" == "0" (
	call :nand_file_input_select
) else (
	IF EXIST templogs\disks_list.txt (
		TOOLS\gnuwin32\bin\sed.exe -n %action_choice%p <templogs\disks_list.txt > templogs\tempvar.txt 2> nul
		set /p input_path=<templogs\tempvar.txt
	)
)
IF "%input_path%"=="" (
	call "%associed_language_script%" "dump_not_exist_error"
	echo.
	goto:info_nand
)
call "%associed_language_script%" "biskeys_file_selection_empty_authorised"
call :set_debug_param_only
IF /i "%debug_option%"=="o" (
	tools\NxNandManager\NxNandManager.exe --info -i "%input_path%" %biskeys_param% DEBUG_MODE
) else (
	call :get_type_nand "%input_path%" "display"
)
echo.
pause
goto:define_action_choice

:dump_nand
set input_path=
set output_path=
set action_choice=
call "%associed_language_script%" "dump_input_begin"
call :list_disk
call "%associed_language_script%" "nand_choice"
IF "%action_choice%" == "" (
	goto:define_action_choice
)
call :verif_disk_choice %action_choice% dump_nand
IF "%action_choice%" == "0" (
	call :nand_file_input_select
) else (
	IF EXIST templogs\disks_list.txt (
		TOOLS\gnuwin32\bin\sed.exe -n %action_choice%p <templogs\disks_list.txt > templogs\tempvar.txt 2> nul
		set /p input_path=<templogs\tempvar.txt
	)
)
IF "%input_path%"=="" (
	call "%associed_language_script%" "dump_not_exist_error"
	echo.
	goto:dump_nand
)
set partition=
call :get_type_nand "%input_path%"
IF /i "%nand_type%"=="RAWNAND" call :partition_select dump_nand
IF /i "%nand_type%"=="RAWNAND (splitted dump)" call :partition_select dump_nand
IF /i "%nand_type%"=="FULL NAND" call :partition_select dump_nand full_nand_choice
echo.
call "%associed_language_script%" "dump_output_folder_choice"
set /p output_path=<templogs\tempvar.txt
IF "%output_path%"=="" (
	call "%associed_language_script%" "dump_output_folder_empty_error"
	goto:dump_nand
)
IF NOT "%output_path%"=="" set output_path=%output_path%\
IF NOT "%output_path%"=="" set output_path=%output_path:\\=\%
IF NOT "%partition%"=="" (
	set output_path=%output_path%%partition%
) else (
	IF "%nand_type%"=="RAWNAND" (
		set output_path=%output_path%rawnand.bin
	) else IF "%nand_type%"=="RAWNAND (splitted dump)" (
		set output_path=%output_path%rawnand.bin
	) else IF "%nand_type%"=="FULL NAND" (
		set output_path=%output_path%full_nand.bin
	) else (
		set output_path=%output_path%%nand_type%
	)
)
IF EXIST "%output_path%" (
	call "%associed_language_script%" "dump_erase_existing_file_choice"
)
IF NOT "%erase_output_file%"=="" set erase_output_file=%erase_output_file:~0,1%
call "tools\Storage\functions\modify_yes_no_always_never_vars.bat" "erase_output_file" "o/n_choice"
IF EXIST "%output_path%" (
	IF /i NOT "%erase_output_file%"=="o" (
		call "%associed_language_script%" "canceled"
		goto:dump_nand
	) else (
		del /q "%output_path%"
	)
)
call :set_NNM_params
::echo -i "%input_path%" -o "%output_path%" %params%%lflags%
tools\NxNandManager\NxNandManager.exe -i "%input_path%" -o "%output_path%" %params%%lflags%
echo.
pause
goto:define_action_choice

:restaure_nand
set input_path=
set output_path=
set action_choice=
call "%associed_language_script%" "restaure_input_file_begin"
pause
call :nand_file_input_select
IF "%input_path%"=="" (
	call "%associed_language_script%" "restaure_input_empty_error"
	echo.
	pause
	goto:define_action_choice
)
call "%associed_language_script%" "restaure_output_begin"
call :list_disk
call "%associed_language_script%" "nand_choice"
IF "%action_choice%" == "" (
	goto:define_action_choice
)
call :verif_disk_choice %action_choice% restaure_nand
IF "%action_choice%" == "0" (
	call :nand_file_output_select
) else (
	IF EXIST templogs\disks_list.txt (
		TOOLS\gnuwin32\bin\sed.exe -n %action_choice%p <templogs\disks_list.txt > templogs\tempvar.txt 2> nul
		set /p output_path=<templogs\tempvar.txt
	)
)
IF "%output_path%"=="" (
	call "%associed_language_script%" "dump_not_exist_error"
	echo.
	goto:restaure_nand
)
set partition=
call :get_type_nand "%output_path%"
IF /i "%nand_type%"=="RAWNAND" call :partition_select restaure_nand
IF /i "%nand_type%"=="RAWNAND (splitted dump)" call :partition_select restaure_nand
IF /i "%nand_type%"=="FULL NAND" call :partition_select restaure_nand full_nand_choice
set output_nand_type=%nand_type%
call :get_type_nand "%input_path%"
set input_nand_type=%nand_type%
IF "%input_nand_type%"=="UNKNOWN" (
	call "%associed_language_script%" "restaure_input_dump_invalid_error"
	goto:restaure_nand
)
IF "%input_nand_type%"=="RAWNAND (splitted dump)" (
	set input_nand_type=RAWNAND
)
IF "%output_nand_type%"=="UNKNOWN" (
	call "%associed_language_script%" "restaure_output_dump_invalid_error"
	goto:restaure_nand
)
IF "%output_nand_type%"=="RAWNAND (splitted dump)" (
	set output_nand_type=RAWNAND
)
IF NOT "%partition%"=="" (
	IF "%output_nand_type%"=="RAWNAND" (
		IF NOT "PARTITION %partition%"=="%input_nand_type%" (
			call "%associed_language_script%" "restaure_partitions_not_match_error"
			goto:restaure_nand
		)
	) else IF "%output_nand_type%"=="FULL NAND" (
		IF "%partition%"=="BOOT0" (
			IF NOT "%input_nand_type%"=="BOOT0" (
				call "%associed_language_script%" "restaure_partitions_not_match_error"
				goto:restaure_nand
			)
		) else IF "%partition%"=="BOOT1" (
			IF NOT "%input_nand_type%"=="BOOT1" (
				call "%associed_language_script%" "restaure_partitions_not_match_error"
				goto:restaure_nand
			)
		) else IF NOT "PARTITION %partition%"=="%input_nand_type%" (
			call "%associed_language_script%" "restaure_partitions_not_match_error"
			goto:restaure_nand
		)
	) else (
			call "%associed_language_script%" "restaure_try_partition_on_other_than_rawnand_error"
		goto:restaure_nand
	)
) else (
	IF NOT "%input_nand_type%"=="%output_nand_type%" (
		call "%associed_language_script%" "restaure_input_and_output_type_not_match_error"
		goto:restaure_nand
	)
)
call :set_NNM_params
::echo -i "%input_path%" -o "%output_path%" %params%%lflags%
tools\NxNandManager\NxNandManager.exe -i "%input_path%" -o "%output_path%" %params%%lflags%
echo.
pause
goto:define_action_choice

:autorcm_management
set input_path=
set action_choice=
call "%associed_language_script%" "autorcm_dump_choice_begin"
call :list_disk
call "%associed_language_script%" "nand_choice"
IF "%action_choice%" == "" (
	goto:define_action_choice
)
call :verif_disk_choice %action_choice% autorcm_management
IF "%action_choice%" == "0" (
	call :nand_file_input_select
) else (
	IF EXIST templogs\disks_list.txt (
		TOOLS\gnuwin32\bin\sed.exe -n %action_choice%p <templogs\disks_list.txt > templogs\tempvar.txt 2> nul
		set /p input_path=<templogs\tempvar.txt
	)
)
IF "%input_path%"=="" (
	call "%associed_language_script%" "dump_not_exist_error"
	echo.
	goto:autorcm_management
)
echo.
set action_choice=
set autorcm_param=
call "%associed_language_script%" "autorcm_choice"
IF "%action_choice%" == "1" (
	set autorcm_param=--enable_autoRCM
) else IF "%action_choice%" == "2" (
	set autorcm_param=--disable_autoRCM
) else (
	goto:autorcm_management
)
call :get_type_nand "%input_path%"
set input_nand_type=%nand_type%
IF "%input_nand_type%"=="FULL NAND" (
	set input_nand_type=BOOT0
)
IF NOT "%input_nand_type%"=="BOOT0" (
	call "%associed_language_script%" "autorcm_nand_type_must_be_boot0_error"
	goto:autorcm_management
)
call :set_debug_param_only
IF /i "%debug_option%"=="o" (
	tools\NxNandManager\NxNandManager.exe %autorcm_param% -i "%input_path%" DEBUG_MODE
) else (
	tools\NxNandManager\NxNandManager.exe %autorcm_param% -i "%input_path%" >nul
)
IF %errorlevel% NEQ 0 (
	call "%associed_language_script%" "autorcm_action_error"
) else (
	IF "%action_choice%" == "1" call "%associed_language_script%" "autorcm_enabled_success"
IF "%action_choice%" == "2" call "%associed_language_script%" "autorcm_disabled_success"
)
echo.
pause
goto:define_action_choice

:decrypt_nand
set input_path=
set output_path=
set biskeys_param=
set action_choice=
call "%associed_language_script%" "decrypt_input_begin"
call :list_disk
call "%associed_language_script%" "nand_choice"
IF "%action_choice%" == "" (
	goto:define_action_choice
)
call :verif_disk_choice %action_choice% decrypt_nand
IF "%action_choice%" == "0" (
	call :nand_file_input_select
) else (
	IF EXIST templogs\disks_list.txt (
		TOOLS\gnuwin32\bin\sed.exe -n %action_choice%p <templogs\disks_list.txt > templogs\tempvar.txt 2> nul
		set /p input_path=<templogs\tempvar.txt
	)
)
IF "%input_path%"=="" (
	call "%associed_language_script%" "dump_not_exist_error"
	echo.
	goto:decrypt_nand
)
set partition=
call :get_type_nand "%input_path%"
IF /i "%nand_type%"=="RAWNAND (splitted dump)" set nand_type=RAWNAND
IF /i "%nand_type%"=="RAWNAND" (
	call :partition_select dump_nand
) else IF /i "%nand_type%"=="FULL NAND" (
	call :partition_select dump_nand all_partitions_excepted
) else IF /i "%nand_type:~0,9%"=="partition" (
	echo %nand_type%|tools\gnuwin32\bin\cut.exe -d " " -f 2 >templogs\tempvar.txt
	set /p partition=<templogs\tempvar.txt
	goto:decrypt_verif_encrypted_or_not
) else (
	call "%associed_language_script%" "decrypt_rawnand_not_selected_error"
	goto:decrypt_nand
)
:decrypt_verif_encrypted_or_not
IF /i NOT "%nand_encrypted:~0,3%"=="Yes" (
	call "%associed_language_script%" "decrypt_verif_encrypted_or_not_error"
	goto:decrypt_nand
)
echo.
call :select_biskeys_file
IF "%biskeys_file_path%"=="" (
	call "%associed_language_script%" "biskeys_file_not_selected_error"
	goto:decrypt_nand
)
tools\NxNandManager\NxNandManager.exe --info -i "%input_path%" %biskeys_param% >nul 2>&1
IF %errorlevel% NEQ 0 (
	call "%associed_language_script%" "decrypt_biskeys_not_valid_error"
	goto:decrypt_nand
) else (
	set biskeys_param=-keyset "%biskeys_file_path%"
)
echo.
call "%associed_language_script%" "dump_output_folder_choice"
set /p output_path=<templogs\tempvar.txt
IF "%output_path%"=="" (
	call "%associed_language_script%" "dump_output_folder_empty_error"
	goto:decrypt_nand
)
IF NOT "%output_path%"=="" set output_path=%output_path%\
IF NOT "%output_path%"=="" set output_path=%output_path:\\=\%
IF NOT "%partition%"=="" (
	set output_path=%output_path%%partition%.bin
) else (
	IF "%nand_type%"=="RAWNAND" (
		set output_path=%output_path%rawnand_decrypted.bin
	) else IF "%nand_type%"=="RAWNAND (splitted dump)" (
		set output_path=%output_path%rawnand_decrypted.bin
	)
)
IF EXIST "%output_path%" (
	call "%associed_language_script%" "dump_erase_existing_file_choice"
)
IF NOT "%erase_output_file%"=="" set erase_output_file=%erase_output_file:~0,1%
call "tools\Storage\functions\modify_yes_no_always_never_vars.bat" "erase_output_file" "o/n_choice"
IF EXIST "%output_path%" (
	IF /i NOT "%erase_output_file%"=="o" (
		call "%associed_language_script%" "canceled"
		goto:decrypt_nand
	) else (
		del /q "%output_path%"
	)
)
IF /i NOT "%nand_type%"=="RAWNAND" (
	set partition=
)
call :set_NNM_params
IF /i "%nand_type%"=="RAWNAND" (
	IF "%partition%"=="" (
		tools\NxNandManager\NxNandManager_old.exe -i "%input_path%" -o "%output_path%" -d %biskeys_param% %params%%lflags%
		goto:skip_decrypt_nxnandmanager_command
	)
)
tools\NxNandManager\NxNandManager.exe -i "%input_path%" -o "%output_path%" -d %biskeys_param% %params%%lflags%
:skip_decrypt_nxnandmanager_command
echo.
pause
goto:define_action_choice

:encrypt_nand
set input_path=
set output_path=
set biskeys_param=
set action_choice=
call "%associed_language_script%" "encrypt_input_begin"
pause
call :nand_file_input_select
IF "%input_path%"=="" (
	call "%associed_language_script%" "encrypt_input_empty_error"
	echo.
	pause
	goto:define_action_choice
)
set partition=
call :get_type_nand "%input_path%"
IF /i "%nand_type%"=="RAWNAND (splitted dump)" set nand_type=RAWNAND
IF /i "%nand_type%"=="RAWNAND" (
	call :partition_select dump_nand
) else IF /i "%nand_type%"=="FULL NAND" (
	call :partition_select dump_nand all_partitions_excepted
) else IF /i "%nand_type:~0,9%"=="partition" (
	echo %nand_type%|tools\gnuwin32\bin\cut.exe -d " " -f 2 >templogs\tempvar.txt
	set /p partition=<templogs\tempvar.txt
	goto:encrypt_verif_encrypted_or_not
) else (
	call "%associed_language_script%" "encrypt_rawnand_not_selected_error"
	goto:encrypt_nand
)
:encrypt_verif_encrypted_or_not
IF /i NOT "%nand_encrypted%"=="No" (
	call "%associed_language_script%" "encrypt_verif_encrypted_or_not_error"
	goto:encrypt_nand
)
echo.
call :select_biskeys_file
IF "%biskeys_file_path%"=="" (
	call "%associed_language_script%" "biskeys_file_not_selected_error"
	goto:encrypt_nand
) else (
	set biskeys_param=-keyset "%biskeys_file_path%"
)
echo.
call "%associed_language_script%" "dump_output_folder_choice"
set /p output_path=<templogs\tempvar.txt
IF "%output_path%"=="" (
	call "%associed_language_script%" "dump_output_folder_empty_error"
	goto:encrypt_nand
)
IF NOT "%output_path%"=="" set output_path=%output_path%\
IF NOT "%output_path%"=="" set output_path=%output_path:\\=\%
IF NOT "%partition%"=="" (
	set output_path=%output_path%%partition%
) else (
	IF "%nand_type%"=="RAWNAND" (
		set output_path=%output_path%rawnand.bin
	) else IF "%nand_type%"=="RAWNAND (splitted dump)" (
		set output_path=%output_path%rawnand.bin
	)
)
IF EXIST "%output_path%" (
	call "%associed_language_script%" "dump_erase_existing_file_choice"
)
IF NOT "%erase_output_file%"=="" set erase_output_file=%erase_output_file:~0,1%
call "tools\Storage\functions\modify_yes_no_always_never_vars.bat" "erase_output_file" "o/n_choice"
IF EXIST "%output_path%" (
	IF /i NOT "%erase_output_file%"=="o" (
		call "%associed_language_script%" "canceled"
		goto:encrypt_nand
	) else (
		del /q "%output_path%"
	)
)
IF /i NOT "%nand_type%"=="RAWNAND" (
	set partition=
)
call :set_NNM_params
IF /i "%nand_type%"=="RAWNAND" (
	IF "%partition%"=="" (
		tools\NxNandManager\NxNandManager_old.exe -i "%input_path%" -o "%output_path%" -e %biskeys_param% %params%%lflags%
		goto:skip_encrypt_nxnandmanager_command
	)
)
tools\NxNandManager\NxNandManager.exe -i "%input_path%" -o "%output_path%" -e %biskeys_param% %params%%lflags%
:skip_encrypt_nxnandmanager_command
echo.
pause
goto:define_action_choice

:incognito_apply
set input_path=
set output_path=
set biskeys_param=
set action_choice=
call "%associed_language_script%" "incognito_input_begin"
call :list_disk
call "%associed_language_script%" "nand_choice"
IF "%action_choice%" == "" (
	goto:define_action_choice
)
call :verif_disk_choice %action_choice% incognito_apply
IF "%action_choice%" == "0" (
	call :nand_file_input_select
) else (
	IF EXIST templogs\disks_list.txt (
		TOOLS\gnuwin32\bin\sed.exe -n %action_choice%p <templogs\disks_list.txt > templogs\tempvar.txt 2> nul
		set /p input_path=<templogs\tempvar.txt
	)
)
IF "%input_path%"=="" (
	call "%associed_language_script%" "dump_not_exist_error"
	echo.
	goto:incognito_apply
)
set partition=
call :get_type_nand "%input_path%"
IF /i "%nand_type%"=="RAWNAND (splitted dump)" set nand_type=RAWNAND
IF /i "%nand_type%"=="RAWNAND" (
	set partition=PRODINFO
	goto:incognito_verif_encrypted_or_not
) else IF /i "%nand_type%"=="FULL NAND" (
	set partition=PRODINFO
	goto:incognito_verif_encrypted_or_not
) else IF /i "%nand_type%"=="partition PRODINFO" (
	goto:incognito_verif_encrypted_or_not
) else (
	call "%associed_language_script%" "incognito_nand_type_error"
	goto:incognito_apply
)
:incognito_verif_encrypted_or_not
echo.
set decrypt_param=
IF /i NOT "%nand_encrypted:~0,3%"=="Yes" (
	set biskeys_param=
	goto:skip_incognito_biskeys_file_choice
) else (
	set decrypt_param=-d 
	call :select_biskeys_file
	IF "!biskeys_file_path!"=="" (
		call "%associed_language_script%" "biskeys_file_not_selected_error"
		goto:incognito_apply
	)
)
tools\NxNandManager\NxNandManager.exe --info -i "%input_path%" %biskeys_param% >nul 2>&1
IF %errorlevel% NEQ 0 (
	call "%associed_language_script%" "incognito_biskeys_not_valid_error"
	goto:incognito_apply
) else (
	set biskeys_param=-keyset "%biskeys_file_path%"
)
echo.
:skip_incognito_biskeys_file_choice
call :set_NNM_params
call :get_base_folder_path_of_a_file_path "%input_path%"
tools\NxNandManager\NxNandManager.exe --incognito -i "%input_path%" %biskeys_param% %decrypt_param%%params%%lflags%
IF %errorlevel% NEQ 0 (
	call "%associed_language_script%" "incognito_action_error"
	goto:skip_move_nnm_prodinfo_backup
) else (
	call "%associed_language_script%" "incognito_action_success"
	IF NOT EXIST "PRODINFO.backup" goto:skip_move_nnm_prodinfo_backup
)
set /a temp_count=0
:move_nnm_prodinfo_backup
IF %temp_count% EQU 0 (
	IF EXIST "%base_folder_path_of_a_file_path%\PRODINFO.backup" (
		set /a temp_count=2
		goto:move_nnm_prodinfo_backup
	) else (
		move "PRODINFO.backup" "%base_folder_path_of_a_file_path%\PRODINFO.backup" >nul
		call "%associed_language_script%" "incognito_prodinfo_backup_moved"
	)
) else (
	IF EXIST "%base_folder_path_of_a_file_path%\PRODINFO.backup%temp_count%" (
		set /a temp_count +=1
		goto:move_nnm_prodinfo_backup
	) else (
		move "PRODINFO.backup" "%base_folder_path_of_a_file_path%\PRODINFO.backup%temp_count%" >nul
		call "%associed_language_script%" "incognito_prodinfo_backup_moved"
	)
)
:skip_move_nnm_prodinfo_backup
pause
goto:define_action_choice

:resize_user_partition
set input_path=
set output_path=
set partition_size=
set action_choice=
call "%associed_language_script%" "resize_user_part_input_begin"
call :list_disk
call "%associed_language_script%" "nand_choice"
IF "%action_choice%" == "" (
	goto:define_action_choice
)
call :verif_disk_choice %action_choice% resize_user_partition
IF "%action_choice%" == "0" (
	call :nand_file_input_select
) else (
	IF EXIST templogs\disks_list.txt (
		TOOLS\gnuwin32\bin\sed.exe -n %action_choice%p <templogs\disks_list.txt > templogs\tempvar.txt 2> nul
		set /p input_path=<templogs\tempvar.txt
	)
)
IF "%input_path%"=="" (
	call "%associed_language_script%" "dump_not_exist_error"
	echo.
	goto:resize_user_partition
)
call :get_type_nand "%input_path%"
IF /i "%nand_type%"=="RAWNAND" goto:resize_user_partition_input_ok
IF /i "%nand_type%"=="RAWNAND (splitted dump)" goto:resize_user_partition_input_ok
IF /i "%nand_type%"=="FULL NAND" goto:resize_user_partition_input_ok
call "%associed_language_script%" "resize_user_part_bad_input_choice"
goto:resize_user_partition
:resize_user_partition_input_ok
echo.
call :select_biskeys_file
IF "%biskeys_file_path%"=="" (
	call "%associed_language_script%" "biskeys_file_not_selected_error"
	goto:resize_user_partition
)
tools\NxNandManager\NxNandManager.exe --info -i "%input_path%" %biskeys_param% >nul 2>&1
IF %errorlevel% NEQ 0 (
	call "%associed_language_script%" "decrypt_biskeys_not_valid_error"
	goto:resize_user_partition
) else (
	set biskeys_param=-keyset "%biskeys_file_path%"
)
echo.
call "%associed_language_script%" "dump_output_folder_choice"
set /p output_path=<templogs\tempvar.txt
IF "%output_path%"=="" (
	call "%associed_language_script%" "dump_output_folder_empty_error"
	goto:resize_user_partition
)
IF NOT "%output_path%"=="" set output_path=%output_path%\
IF NOT "%output_path%"=="" set output_path=%output_path:\\=\%
IF "%nand_type%"=="RAWNAND" (
		set output_path=%output_path%rawnand_resized.bin
) else IF "%nand_type%"=="RAWNAND (splitted dump)" (
		set output_path=%output_path%rawnand_resized.bin
) else IF "%nand_type%"=="FULL NAND" (
		set output_path=%output_path%full_nand_resized.bin
)
IF EXIST "%output_path%" (
	call "%associed_language_script%" "dump_erase_existing_file_choice"
)
IF NOT "%erase_output_file%"=="" set erase_output_file=%erase_output_file:~0,1%
call "tools\Storage\functions\modify_yes_no_always_never_vars.bat" "erase_output_file" "o/n_choice"
IF EXIST "%output_path%" (
	IF /i NOT "%erase_output_file%"=="o" (
		call "%associed_language_script%" "canceled"
		goto:resize_user_partition
	) else (
		del /q "%output_path%"
	)
)
set partition=
call :set_NNM_params
:define_resize_partition_size_value
set resize_user_partition_value=
call "%associed_language_script%" "resize_user_part_value_choice"
IF "%resize_user_partition_value%"=="" (
	call "%associed_language_script%" "canceled"
	goto:resize_user_partition
)
call TOOLS\Storage\functions\strlen.bat nb "%resize_user_partition_value%"
set i=0
:check_chars_resize_partition_size_value
IF %i% NEQ %nb% (
	set check_chars=0
	FOR %%z in (0 1 2 3 4 5 6 7 8 9) do (
		IF "!resize_user_partition_value:~%i%,1!"=="%%z" (
			set /a i+=1
			set check_chars=1
			goto:check_chars_resize_partition_size_value
		)
	)
	IF "!check_chars!"=="0" (
	call "%associed_language_script%" "bad_char_error"
	goto:define_resize_partition_size_value
	)
)
IF %resize_user_partition_value% LSS 2000 (
	call "%associed_language_script%" "resize_user_part_define_greater_size_error"
goto:define_resize_partition_size_value
)
set params=-user_resize=%resize_user_partition_value%
set resize_user_partition_format=
call "%associed_language_script%" "resize_user_partition_format_choice"
IF NOT "%resize_user_partition_format%"=="" set resize_user_partition_format=%resize_user_partition_format:~0,1%
call "tools\Storage\functions\modify_yes_no_always_never_vars.bat" "resize_user_partition_format" "o/n_choice"
IF /i "%resize_user_partition_format%"=="o" (
	set lflags=%lflags%FORMAT_USER
)
tools\NxNandManager\NxNandManager.exe -i "%input_path%" -o "%output_path%" %biskeys_param% %params% %lflags%
echo.
pause
goto:define_action_choice

:get_type_nand
set nand_type=
set nand_file_or_disk=
set nand_encrypted=
set nand_size=
set nand_autorcm=
set nand_bootloader_ver=
set begin_partition_line=
set nand_backup_gpt=
set nand_serial_number=
set nand_device_id=
set nand_mac_address=
set nand_firmware_ver=
set nand_exfat_driver=
set nand_last_boot=
set nand_sectors_interval=
set temp_input_file=%~1
tools\NxNandManager\NxNandManager.exe --info -i "%temp_input_file%" %biskeys_param% >templogs\infos_nand.txt
set temp_input_file=
tools\gnuwin32\bin\grep.exe "NAND type" <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
set /p nand_type=<templogs\tempvar.txt
set nand_type=%nand_type:~1%
tools\gnuwin32\bin\grep.exe "File/Disk" <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
set /p nand_file_or_disk=<templogs\tempvar.txt
set nand_file_or_disk=%nand_file_or_disk:~1%
IF /i "%nand_type%"=="FULL NAND" (
	set temp_nand_file_or_disk=%nand_file_or_disk%
	echo !temp_nand_file_or_disk! | tools\gnuwin32\bin\cut.exe -d " " -f 1 >templogs\tempvar.txt
	set /p nand_file_or_disk=<templogs\tempvar.txt
		echo !temp_nand_file_or_disk! | tools\gnuwin32\bin\cut.exe -d ( -f 2 >templogs\tempvar.txt
	set /p nand_sectors_interval=<templogs\tempvar.txt
	set nand_sectors_interval=!nand_sectors_interval:~0,-1!
)
tools\gnuwin32\bin\grep.exe "Encrypted " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
set /p nand_encrypted=<templogs\tempvar.txt
set nand_encrypted=%nand_encrypted:~1%
tools\gnuwin32\bin\grep.exe "Size " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
set /p nand_size=<templogs\tempvar.txt
set nand_size=%nand_size:~1%
IF "%nand_type%"=="BOOT0" (
	tools\gnuwin32\bin\grep.exe "AutoRCM " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
	set /p nand_autorcm=<templogs\tempvar.txt
	set nand_autorcm=!nand_autorcm:~1!
	tools\gnuwin32\bin\grep.exe "Bootloader ver" <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
	set /p nand_bootloader_ver=<templogs\tempvar.txt
	set nand_bootloader_ver=!nand_bootloader_ver:~1!
)
IF "%nand_type%"=="RAWNAND" (
	tools\gnuwin32\bin\grep.exe -E -n "^^Partitions" <"templogs\infos_nand.txt" |tools\gnuwin32\bin\cut.exe -d : -f 1 >templogs\tempvar.txt
	set /p begin_partition_line=<templogs\tempvar.txt
	tools\gnuwin32\bin\grep.exe "Backup GPT " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
	set /p nand_backup_gpt=<templogs\tempvar.txt
		set nand_backup_gpt=!nand_backup_gpt:~1!
		IF "!nand_backup_gpt:~0,5!"=="FOUND" (
		echo !nand_backup_gpt!|tools\gnuwin32\bin\cut.exe -d ^( -f 2 >templogs\tempvar.txt
		set /p nand_backup_gpt=<templogs\tempvar.txt
		) else (
		set nand_backup_gpt=0
		)
	IF "%nand_encrypted%"=="No" (
		tools\gnuwin32\bin\grep.exe "Firmware ver" <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
		set /p nand_firmware_ver=<templogs\tempvar.txt
		set nand_firmware_ver=!nand_firmware_ver:~1!
		tools\gnuwin32\bin\grep.exe "ExFat driver " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
		set /p nand_exfat_driver=<templogs\tempvar.txt
		set nand_exfat_driver=!nand_exfat_driver:~1!
		tools\gnuwin32\bin\grep.exe "Last boot " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2- >templogs\tempvar.txt
		set /p nand_last_boot=<templogs\tempvar.txt
		set nand_last_boot=!nand_last_boot:~1!
		tools\gnuwin32\bin\grep.exe "Serial number " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
		set /p nand_serial_number=<templogs\tempvar.txt
		set nand_serial_number=!nand_serial_number:~1!
		tools\gnuwin32\bin\grep.exe "Device Id " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
		set /p nand_device_id=<templogs\tempvar.txt
		set nand_device_id=!nand_device_id:~1!
		tools\gnuwin32\bin\grep.exe "MAC Address " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
		set /p nand_mac_address=<templogs\tempvar.txt
		set nand_mac_address=!nand_mac_address:~1!
	) else IF "%nand_encrypted%"=="Yes" (
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "Firmware ver" <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "Firmware ver" <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
			set /p nand_firmware_ver=<templogs\tempvar.txt
			set nand_firmware_ver=!nand_firmware_ver:~1!
		)
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "ExFat driver " <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "ExFat driver " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
			set /p nand_exfat_driver=<templogs\tempvar.txt
			set nand_exfat_driver=!nand_exfat_driver:~1!
		)
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "Last boot " <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "Last boot " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2- >templogs\tempvar.txt
			set /p nand_last_boot=<templogs\tempvar.txt
			set nand_last_boot=!nand_last_boot:~1!
		)
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "Serial number " <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "Serial number " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
			set /p nand_serial_number=<templogs\tempvar.txt
			set nand_serial_number=!nand_serial_number:~1!
		)
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "Device Id " <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "Device Id " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
			set /p nand_device_id=<templogs\tempvar.txt
			set nand_device_id=!nand_device_id:~1!
		)
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "MAC Address " <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "MAC Address " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
			set /p nand_mac_address=<templogs\tempvar.txt
			set nand_mac_address=!nand_mac_address:~1!
		)
	)
)
IF "%nand_type%"=="RAWNAND ^(splitted dump^)" (
	tools\gnuwin32\bin\grep.exe -E -n "^^Partitions" <"templogs\infos_nand.txt" |tools\gnuwin32\bin\cut.exe -d : -f 1 >templogs\tempvar.txt
	set /p begin_partition_line=<templogs\tempvar.txt
	tools\gnuwin32\bin\grep.exe "Backup GPT " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
	set /p nand_backup_gpt=<templogs\tempvar.txt
		set nand_backup_gpt=!nand_backup_gpt:~1!
		IF "!nand_backup_gpt:~0,5!"=="FOUND" (
		echo !nand_backup_gpt!|tools\gnuwin32\bin\cut.exe -d ^( -f 2 >templogs\tempvar.txt
		set /p nand_backup_gpt=<templogs\tempvar.txt
		) else (
		set nand_backup_gpt=0
		)
	IF "%nand_encrypted%"=="No" (
		tools\gnuwin32\bin\grep.exe "Firmware ver" <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
		set /p nand_firmware_ver=<templogs\tempvar.txt
		set nand_firmware_ver=!nand_firmware_ver:~1!
		tools\gnuwin32\bin\grep.exe "ExFat driver " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
		set /p nand_exfat_driver=<templogs\tempvar.txt
		set nand_exfat_driver=!nand_exfat_driver:~1!
		tools\gnuwin32\bin\grep.exe "Last boot " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2- >templogs\tempvar.txt
		set /p nand_last_boot=<templogs\tempvar.txt
		set nand_last_boot=!nand_last_boot:~1!
		tools\gnuwin32\bin\grep.exe "Serial number " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
		set /p nand_serial_number=<templogs\tempvar.txt
		set nand_serial_number=!nand_serial_number:~1!
		tools\gnuwin32\bin\grep.exe "Device Id " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
		set /p nand_device_id=<templogs\tempvar.txt
		set nand_device_id=!nand_device_id:~1!
		tools\gnuwin32\bin\grep.exe "MAC Address " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
		set /p nand_mac_address=<templogs\tempvar.txt
		set nand_mac_address=!nand_mac_address:~1!
	) else IF "%nand_encrypted%"=="Yes" (
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "Firmware ver" <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "Firmware ver" <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
			set /p nand_firmware_ver=<templogs\tempvar.txt
			set nand_firmware_ver=!nand_firmware_ver:~1!
		)
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "ExFat driver " <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "ExFat driver " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
			set /p nand_exfat_driver=<templogs\tempvar.txt
			set nand_exfat_driver=!nand_exfat_driver:~1!
		)
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "Last boot " <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "Last boot " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2- >templogs\tempvar.txt
			set /p nand_last_boot=<templogs\tempvar.txt
			set nand_last_boot=!nand_last_boot:~1!
		)
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "Serial number " <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "Serial number " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
			set /p nand_serial_number=<templogs\tempvar.txt
			set nand_serial_number=!nand_serial_number:~1!
		)
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "Device Id " <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "Device Id " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
			set /p nand_device_id=<templogs\tempvar.txt
			set nand_device_id=!nand_device_id:~1!
		)
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "MAC Address " <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "MAC Address " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
			set /p nand_mac_address=<templogs\tempvar.txt
			set nand_mac_address=!nand_mac_address:~1!
		)
	)
)
IF "%nand_type%"=="FULL NAND" (
	tools\gnuwin32\bin\grep.exe "AutoRCM " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
	set /p nand_autorcm=<templogs\tempvar.txt
	set nand_autorcm=!nand_autorcm:~1!
	tools\gnuwin32\bin\grep.exe "Bootloader ver" <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
	set /p nand_bootloader_ver=<templogs\tempvar.txt
	set nand_bootloader_ver=!nand_bootloader_ver:~1!
	tools\gnuwin32\bin\grep.exe -E -n "^^Partitions" <"templogs\infos_nand.txt" |tools\gnuwin32\bin\cut.exe -d : -f 1 >templogs\tempvar.txt
	set /p begin_partition_line=<templogs\tempvar.txt
	tools\gnuwin32\bin\grep.exe "Backup GPT " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
	set /p nand_backup_gpt=<templogs\tempvar.txt
		set nand_backup_gpt=!nand_backup_gpt:~1!
		IF "!nand_backup_gpt:~0,5!"=="FOUND" (
		echo !nand_backup_gpt!|tools\gnuwin32\bin\cut.exe -d ^( -f 2 >templogs\tempvar.txt
		set /p nand_backup_gpt=<templogs\tempvar.txt
		) else (
		set nand_backup_gpt=0
		)
	IF "%nand_encrypted%"=="No" (
		tools\gnuwin32\bin\grep.exe "Firmware ver" <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
		set /p nand_firmware_ver=<templogs\tempvar.txt
		set nand_firmware_ver=!nand_firmware_ver:~1!
		tools\gnuwin32\bin\grep.exe "ExFat driver " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
		set /p nand_exfat_driver=<templogs\tempvar.txt
		set nand_exfat_driver=!nand_exfat_driver:~1!
		tools\gnuwin32\bin\grep.exe "Last boot " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2- >templogs\tempvar.txt
		set /p nand_last_boot=<templogs\tempvar.txt
		set nand_last_boot=!nand_last_boot:~1!
		tools\gnuwin32\bin\grep.exe "Serial number " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
		set /p nand_serial_number=<templogs\tempvar.txt
		set nand_serial_number=!nand_serial_number:~1!
		tools\gnuwin32\bin\grep.exe "Device Id " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
		set /p nand_device_id=<templogs\tempvar.txt
		set nand_device_id=!nand_device_id:~1!
		tools\gnuwin32\bin\grep.exe "MAC Address " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
		set /p nand_mac_address=<templogs\tempvar.txt
		set nand_mac_address=!nand_mac_address:~1!
	) else IF "%nand_encrypted%"=="Yes" (
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "Firmware ver" <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "Firmware ver" <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
			set /p nand_firmware_ver=<templogs\tempvar.txt
			set nand_firmware_ver=!nand_firmware_ver:~1!
		)
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "ExFat driver " <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "ExFat driver " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
			set /p nand_exfat_driver=<templogs\tempvar.txt
			set nand_exfat_driver=!nand_exfat_driver:~1!
		)
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "Last boot " <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "Last boot " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2- >templogs\tempvar.txt
			set /p nand_last_boot=<templogs\tempvar.txt
			set nand_last_boot=!nand_last_boot:~1!
		)
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "Serial number " <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "Serial number " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
			set /p nand_serial_number=<templogs\tempvar.txt
			set nand_serial_number=!nand_serial_number:~1!
		)
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "Device Id " <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "Device Id " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
			set /p nand_device_id=<templogs\tempvar.txt
			set nand_device_id=!nand_device_id:~1!
		)
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "MAC Address " <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "MAC Address " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
			set /p nand_mac_address=<templogs\tempvar.txt
			set nand_mac_address=!nand_mac_address:~1!
		)
	)
)
IF "%nand_type%"=="PARTITION PRODINFO" (
	IF "%nand_encrypted%"=="No" (
		tools\gnuwin32\bin\grep.exe "Serial number " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
		set /p nand_serial_number=<templogs\tempvar.txt
		set nand_serial_number=!nand_serial_number:~1!
		tools\gnuwin32\bin\grep.exe "Device Id " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
		set /p nand_device_id=<templogs\tempvar.txt
		set nand_device_id=!nand_device_id:~1!
		tools\gnuwin32\bin\grep.exe "MAC Address " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
		set /p nand_mac_address=<templogs\tempvar.txt
		set nand_mac_address=!nand_mac_address:~1!
	) else IF "%nand_encrypted%"=="Yes" (
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "Serial number " <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "Serial number " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
			set /p nand_serial_number=<templogs\tempvar.txt
			set nand_serial_number=!nand_serial_number:~1!
		)
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "Device Id " <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "Device Id " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
			set /p nand_device_id=<templogs\tempvar.txt
			set nand_device_id=!nand_device_id:~1!
		)
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "MAC Address " <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "MAC Address " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
			set /p nand_mac_address=<templogs\tempvar.txt
			set nand_mac_address=!nand_mac_address:~1!
		)
	)
)
IF "%nand_type%"=="PARTITION SYSTEM" (
	IF "%nand_encrypted%"=="No" (
		tools\gnuwin32\bin\grep.exe "Firmware ver" <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
		set /p nand_firmware_ver=<templogs\tempvar.txt
		set nand_firmware_ver=!nand_firmware_ver:~1!
		tools\gnuwin32\bin\grep.exe "ExFat driver " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
		set /p nand_exfat_driver=<templogs\tempvar.txt
		set nand_exfat_driver=!nand_exfat_driver:~1!
		tools\gnuwin32\bin\grep.exe "Last boot " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2- >templogs\tempvar.txt
		set /p nand_last_boot=<templogs\tempvar.txt
		set nand_last_boot=!nand_last_boot:~1!
	) else IF "%nand_encrypted%"=="Yes" (
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "Firmware ver" <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "Firmware ver" <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
			set /p nand_firmware_ver=<templogs\tempvar.txt
			set nand_firmware_ver=!nand_firmware_ver:~1!
		)
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "ExFat driver " <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "ExFat driver " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2 >templogs\tempvar.txt
			set /p nand_exfat_driver=<templogs\tempvar.txt
			set nand_exfat_driver=!nand_exfat_driver:~1!
		)
		set temp_count=
		tools\gnuwin32\bin\grep.exe -c "Last boot " <"templogs\infos_nand.txt" >templogs\tempvar.txt
		set /p temp_count=<templogs\tempvar.txt
		IF "!temp_count!"=="1" (
			tools\gnuwin32\bin\grep.exe "Last boot " <"templogs\infos_nand.txt" | tools\gnuwin32\bin\cut.exe -d : -f 2- >templogs\tempvar.txt
			set /p nand_last_boot=<templogs\tempvar.txt
			set nand_last_boot=!nand_last_boot:~1!
		)
	)
)
IF "%~2"=="display" (
	call "%associed_language_script%" "display_infos_nand"
)
exit /B

:list_disk
IF EXIST templogs\disks_list.txt del /q templogs\disks_list.txt
tools\NxNandManager\NxNandManager.exe --list >templogs\temp_disks_list.txt
if %errorlevel% EQU -1009 (
	del /q templogs\temp_disks_list.txt
	exit /B
)
TOOLS\gnuwin32\bin\grep.exe -c "" <templogs\temp_disks_list.txt > templogs\tempvar.txt
set /p count_disks=<templogs\tempvar.txt
set /a temp_count_disks=0
set /a real_count=0
copy nul templogs\disks_list.txt >nul
:disks_listing
set /a temp_count_disks+=1
IF %temp_count_disks% GTR %count_disks% (
	goto:finish_disks_listing
)
TOOLS\gnuwin32\bin\sed.exe -n %temp_count_disks%p <templogs\temp_disks_list.txt >templogs\tempvar.txt
set /p temp_disk=<templogs\tempvar.txt
IF NOT "%temp_disk:~0,4%" == "\\.\" goto:disks_listing
echo %temp_disk% | tools\gnuwin32\bin\cut.exe -d [ -f 1 >templogs\tempvar.txt
set /p temp_disk=<templogs\tempvar.txt
set temp_disk=%temp_disk: =%
call :get_type_nand "%temp_disk%"
echo %temp_disk%>>templogs\disks_list.txt
set /a real_count=%real_count%+1
echo %real_count%: %temp_disk%; %nand_type%
goto:disks_listing
:finish_disks_listing
del /q templogs\temp_disks_list.txt
exit /b

:nand_file_input_select
set input_path=
call "%associed_language_script%" "nand_file_select_choice"
set /p input_path=<templogs\tempvar.txt
exit /b

:nand_file_output_select
set output_path=
call "%associed_language_script%" "nand_file_select_choice"
set /p output_path=<templogs\tempvar.txt
exit /b

:select_biskeys_file
set biskeys_path=
call "%associed_language_script%" "biskeys_file_select_choice"
set /p biskeys_file_path=<templogs\tempvar.txt
exit /b

:verif_disk_choice
set choice=%~1
set label_verif_disk_choice=%~2
call TOOLS\Storage\functions\strlen.bat nb "%choice%"
set i=0
:check_chars_choice
IF %i% NEQ %nb% (
	set check_chars=0
	FOR %%z in (0 1 2 3 4 5 6 7 8 9) do (
		IF "!choice:~%i%,1!"=="%%z" (
			set /a i+=1
			set check_chars=1
			goto:check_chars_choice
		)
	)
	IF "!check_chars!"=="0" (
	call "%associed_language_script%" "nand_choice_char_error"
	goto:%label_verif_disk_choice%
	)
)
exit /b

:partition_select
set partition=
set label_partition_select=%~1
set choose_partition=
IF "%~2"=="all_partitions_excepted" (
	set except_all=Y
) else (
	set except_all=
)
call "%associed_language_script%" "partition_choice_begin"
echo 1: PRODINFO.
echo 2: PRODINFOF.
echo 3: BCPKG2-1-Normal-Main
echo 4: BCPKG2-2-Normal-Sub
echo 5: BCPKG2-3-SafeMode-Main
echo 6: BCPKG2-4-SafeMode-Sub
echo 7: BCPKG2-5-Repair-Main
echo 8: BCPKG2-6-Repair-Sub
echo 9: SAFE
echo 10: SYSTEM
echo 11: USER
IF "%~2"=="full_nand_choice" (
	echo 12: BOOT0
	echo 13: BOOT1
	echo 14: RAWNAND
)
call "%associed_language_script%" "partition_choice"
IF "%choose_partition%" == "" goto:%label_partition_select%
call :verif_disk_choice %choose_partition% partition_select
IF "%except_all%"=="Y" (
	IF %choose_partition% EQU 0 (
		call "%associed_language_script%" "bad_value"
		goto:partition_select
	)
)
IF "%~2"=="full_nand_choice" (
	IF %choose_partition% GTR 14 (
		call "%associed_language_script%" "bad_value"
		goto:partition_select
	)
) else (
	IF %choose_partition% GTR 11 (
		call "%associed_language_script%" "bad_value"
		goto:partition_select
	)
)
IF %choose_partition% EQU 1 set partition=PRODINFO
IF %choose_partition% EQU 2 set partition=PRODINFOF
IF %choose_partition% EQU 3 set partition=BCPKG2-1-Normal-Main
IF %choose_partition% EQU 4 set partition=BCPKG2-2-Normal-Sub
IF %choose_partition% EQU 5 set partition=BCPKG2-3-SafeMode-Main
IF %choose_partition% EQU 6 set partition=BCPKG2-4-SafeMode-Sub
IF %choose_partition% EQU 7 set partition=BCPKG2-5-Repair-Main
IF %choose_partition% EQU 8 set partition=BCPKG2-6-Repair-Sub
IF %choose_partition% EQU 9 set partition=SAFE
IF %choose_partition% EQU 10 set partition=SYSTEM
IF %choose_partition% EQU 11 set partition=USER
IF %choose_partition% EQU 12 set partition=BOOT0
IF %choose_partition% EQU 13 set partition=BOOT1
IF %choose_partition% EQU 14 set partition=RAWNAND
exit /b

:set_NNM_params
set params=
set lflags=
set force_option=
set skip_md5=
set debug_option=
IF NOT "%partition%"=="" set params=-part=%partition% 
call "%associed_language_script%" "force_param_choice"
IF NOT "%force_option%"=="" set force_option=%force_option:~0,1%
call "tools\Storage\functions\modify_yes_no_always_never_vars.bat" "force_option" "o/n_choice"
IF /i "%force_option%"=="o" (
	set lflags=%lflags%FORCE 
)
call "%associed_language_script%" "skipmd5_param_choice"
IF NOT "%skip_md5%"=="" set skip_md5=%skip_md5:~0,1%
call "tools\Storage\functions\modify_yes_no_always_never_vars.bat" "skip_md5" "o/n_choice"
IF /i "%skip_md5%"=="o" (
	set lflags=%lflags%BYPASS_MD5SUM 
)
call "%associed_language_script%" "debug_param_choice"
IF NOT "%debug_option%"=="" set debug_option=%debug_option:~0,1%
call "tools\Storage\functions\modify_yes_no_always_never_vars.bat" "debug_option" "o/n_choice"
IF /i "%debug_option%"=="o" (
	set lflags=%lflags%DEBUG_MODE 
)
exit /b

:set_debug_param_only
set debug_option=
call "%associed_language_script%" "debug_param_choice"
IF NOT "%debug_option%"=="" set debug_option=%debug_option:~0,1%
call "tools\Storage\functions\modify_yes_no_always_never_vars.bat" "debug_option" "o/n_choice"
exit /b

:get_base_folder_path_of_a_file_path
set base_folder_path_of_a_file_path=
set base_folder_path_of_a_file_path=%~dp1
exit /b

:end_script
IF EXIST templogs (
	rmdir /s /q templogs
)
endlocal