@ECHO OFF
:TOP_INIT
CD /d "%prog_dir%"

REM //////////////////////////////////////////////////
REM /////////////////////////////////////////////////
REM FILE JOINER
REM /////////////////////////////////////////////////
REM ////////////////////////////////////////////////
:normalmode
cls
call :program_logo
echo -------------------------------------------------
echo Mode réunification activé
echo -------------------------------------------------
if exist "joinlist.txt" goto prevlist
goto manual_INIT
:prevlist
set conta=0
for /f "tokens=*" %%f in (joinlist.txt) do (
echo %%f
) >NUL 2>&1
setlocal enabledelayedexpansion
for /f "tokens=*" %%f in (joinlist.txt) do (
set /a conta=!conta! + 1
) >NUL 2>&1
if !conta! LEQ 0 ( del joinlist.txt )
endlocal
if not exist "joinlist.txt" goto manual_INIT
ECHO ............................................................................
ECHO Une liste précédente a été trouvée. QUE SOUHAITEZ-VOUS FAIRE?
:prevlist0
ECHO ............................................................................
echo Tapez "1" pour démarrer automatiquement le traitement de la liste précédente
echo Tapez "2" pour effacer la liste et en créer une nouvelle.
echo Tapez "3" pour continuer à construire la liste précédente
echo ............................................................................
echo NOTE: En appuyant sur 3, vous verrez la liste précédente 
echo avant de commencer le traitement des fichiers et vous 
echo pouvez ajouter et supprimer des éléments de la liste
echo.
ECHO ******************************************************
echo Ou tapez "0" pour revenir au menu du mode de sélection
ECHO ******************************************************
echo.
set /p bs="Faites votre choix: "
set bs=%bs:"=%
if /i "%bs%"=="3" goto showlist
if /i "%bs%"=="2" goto delist
if /i "%bs%"=="1" goto start
if /i "%bs%"=="0" exit /B
echo.
echo Mauvais choix
goto prevlist0
:delist
del joinlist.txt
cls
call :program_logo
echo -------------------------------------------------
echo Mode réunification activé
echo -------------------------------------------------
echo ................................................
echo Vous avez décidé de commencer une nouvelle liste
echo ................................................

:manual_INIT
endlocal
ECHO ***************************************************
echo Tapez "1" pour ajouter un dossier à la liste
echo Tapez "2" pour ajouter un fichier à la liste
echo tapez "0" pour revenir au menu du mode de sélection
ECHO ***************************************************
echo.
%pycommand% "%nut%" -t ns0 xc0 00 -tfile "%prog_dir%joinlist.txt" -uin "%uinput%" -ff "uinput"
set /p eval=<"%uinput%"
set eval=%eval:"=%
setlocal enabledelayedexpansion
echo+ >"%uinput%"
endlocal
if /i "%eval%"=="0" exit /B
if /i "%eval%"=="1" ( %pycommand% "%nut%" -lib_call listmanager selector2list -xarg "%prog_dir%joinlist.txt" mode=folder ext="ns0 xc0 00" ) 2>&1>NUL
if /i "%eval%"=="2" ( %pycommand% "%nut%" -lib_call listmanager selector2list -xarg "%prog_dir%joinlist.txt" mode=file ext="ns0 xc0 00" ) 2>&1>NUL
goto checkagain
echo.
:checkagain
echo QUE SOUHAITEZ-VOUS FAIRE?
echo .............................................................................................
echo "Gliser un autre fichier ou dossier et appuyez sur enter pour ajouter des articles à la liste"
echo.
echo Tapez "1" pour commencer le traitement
echo Tapez "2" pour ajouter un autre dossier à la liste
echo Tapez "3" pour ajouter un autre fichier à la liste
echo Tapez "e" pour sortir
echo Tapez "i" pour voir la liste des fichiers à traiter
echo Tapez "r" pour supprimer des fichiers (en partant du bas)
echo Tapez "z" pour enlever toute la liste
echo .............................................................................................
ECHO ******************************************************
echo Ou tapez "0" pour revenir au menu du mode de sélection
ECHO ******************************************************
echo.
%pycommand% "%nut%" -t ns0 xc0 00 -tfile "%prog_dir%joinlist.txt" -uin "%uinput%" -ff "uinput"
set /p eval=<"%uinput%"
set eval=%eval:"=%
setlocal enabledelayedexpansion
echo+ >"%uinput%"
endlocal

if /i "%eval%"=="0" exit /B
if /i "%eval%"=="1" goto start
if /i "%eval%"=="2" ( %pycommand% "%nut%" -lib_call listmanager selector2list -xarg "%prog_dir%joinlist.txt" mode=folder ext="ns0 xc0 00" ) 2>&1>NUL
if /i "%eval%"=="3" ( %pycommand% "%nut%" -lib_call listmanager selector2list -xarg "%prog_dir%joinlist.txt" mode=file ext="ns0 xc0 00" ) 2>&1>NUL
if /i "%eval%"=="e" goto salida
if /i "%eval%"=="i" goto showlist
if /i "%eval%"=="r" goto r_files
if /i "%eval%"=="z" del joinlist.txt

goto checkagain

:r_files
set /p bs="Entrez le nombre de fichiers que vous souhaitez supprimer (à partir du bas): "
set bs=%bs:"=%

setlocal enabledelayedexpansion
set conta=
for /f "tokens=*" %%f in (joinlist.txt) do (
set /a conta=!conta! + 1
)

set /a pos1=!conta!-!bs!
set /a pos2=!conta!
set string=

:update_list1
if !pos1! GTR !pos2! ( goto :update_list2 ) else ( set /a pos1+=1 )
set string=%string%,%pos1%
goto :update_list1 
:update_list2
set string=%string%,
set skiplist=%string%
Set "skip=%skiplist%"
setlocal DisableDelayedExpansion
(for /f "tokens=1,*delims=:" %%a in (' findstr /n "^" ^<joinlist.txt'
) do Echo=%skip%|findstr ",%%a," 2>&1>NUL ||Echo=%%b
)>joinlist.txt.new
endlocal
move /y "joinlist.txt.new" "joinlist.txt" >nul
endlocal

:showlist
cls
call :program_logo
echo -------------------------------------------------
echo Mode réunification activé
echo -------------------------------------------------
ECHO -------------------------------------------------
ECHO                 Fichiers à traiter 
ECHO -------------------------------------------------
for /f "tokens=*" %%f in (joinlist.txt) do (
echo %%f
)
setlocal enabledelayedexpansion
set conta=
for /f "tokens=*" %%f in (joinlist.txt) do (
set /a conta=!conta! + 1
)
echo .................................................
echo Vous avez ajouté !conta! Fichier(s) à traiter
echo .................................................
endlocal

goto checkagain

:s_cl_wrongchoice
echo wrong choice
echo ............
:start
echo *******************************************************
echo Choisissez comment traiter les fichiers
echo *******************************************************
echo Tapez "1" pour joindre .xc*,.ns*,.0* 
echo.
ECHO *************************************************
echo Ou tapez "b" pour revenir aux options de la liste
ECHO *************************************************
echo.
set /p bs="Faites votre choix: "
set bs=%bs:"=%
set vrepack=none
if /i "%bs%"=="b" goto checkagain
if /i "%bs%"=="1" goto joinfiles
if %vrepack%=="none" goto s_cl_wrongchoice

:joinfiles
cls
call :program_logo
CD /d "%prog_dir%"
for /f "tokens=*" %%f in (joinlist.txt) do (

%pycommand% "%nut%" %buffer% -o "%fold_output%" -tfile "%prog_dir%joinlist.txt" --joinfile ""
if exist "%fold_output%\output.nsp" ( %pycommand% "%nut%" -t nsp -renf "%fold_output%\output.nsp" >NUL 2>&1)
if exist "%fold_output%\output.xci" ( %pycommand% "%nut%" -t xci -renf "%fold_output%\output.xci" >NUL 2>&1)

%pycommand% "%nut%" --strip_lines "%prog_dir%joinlist.txt"
call :contador_NF
)
ECHO ------------------------------------------------------------
ECHO *********** Tous les fichiers ont été traités! *************
ECHO ------------------------------------------------------------
goto s_exit_choice

:s_exit_choice
if exist joinlist.txt del joinlist.txt
if /i "%va_exit%"=="true" echo Le programme vas fermé
if /i "%va_exit%"=="true" ( PING -n 2 127.0.0.1 >NUL 2>&1 )
if /i "%va_exit%"=="true" goto salida
echo.
echo Tapez "0" pour revenir au mode de sélection
echo Tapez "1" pour quitter le programme
echo.
set /p bs="Faites votre choix: "
set bs=%bs:"=%
if /i "%bs%"=="0" goto manual_Reentry
if /i "%bs%"=="1" goto salida
goto s_exit_choice

:contador_NF
setlocal enabledelayedexpansion
set /a conta=0
for /f "tokens=*" %%f in (joinlist.txt) do (
set /a conta=!conta! + 1
)
echo ...................................................
echo Encore !conta! Fichiers à traiter
echo ...................................................
PING -n 2 127.0.0.1 >NUL 2>&1
set /a conta=0
endlocal
exit /B


::///////////////////////////////////////////////////
::SUBROUTINES
::///////////////////////////////////////////////////

:squirrell
echo                    ,;:;;,
echo                   ;;;;;
echo           .=',    ;:;;:,
echo          /_', "=. ';:;:;
echo          @=:__,  \,;:;:'
echo            _(\.=  ;:;;'
echo           `"_(  _/="`
echo            `"'		
exit /B

:program_logo

ECHO                                        __          _ __    __         
ECHO                  ____  _____ ____     / /_  __  __(_) /___/ /__  _____
ECHO                 / __ \/ ___/ ___/    / __ \/ / / / / / __  / _ \/ ___/
ECHO                / / / (__  ) /__     / /_/ / /_/ / / / /_/ /  __/ /    
ECHO               /_/ /_/____/\___/____/_.___/\__,_/_/_/\__,_/\___/_/     
ECHO                              /_____/                                  
ECHO -------------------------------------------------------------------------------------
ECHO                         NINTENDO SWITCH CLEANER AND BUILDER
ECHO                      (THE XCI MULTI CONTENT BUILDER AND MORE)
ECHO -------------------------------------------------------------------------------------
ECHO =============================     BY JULESONTHEROAD     =============================
ECHO -------------------------------------------------------------------------------------
ECHO "                                POWERED BY SQUIRREL                                "
ECHO "                    BASED IN THE WORK OF BLAWAR AND LUCA FRAGA                     "
ECHO                                     VERSION %program_version%
ECHO -------------------------------------------------------------------------------------                   
ECHO Program's github: https://github.com/julesontheroad/NSC_BUILDER
ECHO Blawar's github:  https://github.com/blawar
ECHO Blawar's tinfoil: https://github.com/digableinc/tinfoil
ECHO Luca Fraga's github: https://github.com/LucaFraga
ECHO -------------------------------------------------------------------------------------
exit /B

:delay
PING -n 2 127.0.0.1 >NUL 2>&1
exit /B

:thumbup
echo.
echo    /@
echo    \ \
echo  ___\ \
echo (__O)  \
echo (____@) \
echo (____@)  \
echo (__o)_    \
echo       \    \
echo.
echo Amusez vous bien
exit /B


:salida
exit /B


