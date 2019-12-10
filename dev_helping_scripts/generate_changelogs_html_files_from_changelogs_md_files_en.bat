::script by shadow256
chcp 65001 >nul
cd ..
call :write_begining_of_file "languages\EN_us\doc\files\changelog.html"
call :write_begining_of_file "languages\EN_us\doc\files\packs_changelog.html"
"tools\gnuwin32\bin\tail.exe" -n+1 <"changelog_en.md" >>"languages\EN_us\doc\files\changelog.html"
"tools\gnuwin32\bin\tail.exe" -n+1 <"packs_changelog_en.md" >>"languages\EN_us\doc\files\packs_changelog.html"
call :write_ending_of_file "languages\EN_us\doc\files\changelog.html"
call :write_ending_of_file "languages\EN_us\doc\files\packs_changelog.html"
goto:eof

:write_begining_of_file
set file=%~1
copy nul "%file%" >nul
echo ^<!DOCTYPE HTML^>>>"%file%"
echo ^<html lang="en-US"^>>>"%file%"
echo ^<head^>>>"%file%"
IF "%~1"=="languages\FR_fr\doc\files\changelog.html" (
	echo ^<title^>Changelog Ultimate Switch Hack Script^</title^>>>"%file%"
) else IF "%~1"=="languages\FR_fr\doc\files\packs_changelog.html" (
	echo ^<title^>Pack Changelog of CFWs/modules/homebrews^</title^>>>"%file%"
)
echo ^<meta charset="UTF-8"^>>>"%file%"
echo ^<meta http-equiv="X-UA-Compatible" content="IE=edge"^>>>"%file%"
echo ^</head^>>>"%file%"
echo ^<body^>>>"%file%"
exit /b

:write_ending_of_file
set file=%~1
echo ^</body^>>>"%file%"
echo ^</html^>>>"%file%"
exit /b