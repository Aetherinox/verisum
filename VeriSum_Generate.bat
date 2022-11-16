@ECHO 	    OFF
TITLE 	    VeriSum - Generate (Running)
SETLOCAL 	ENABLEDELAYEDEXPANSION
MODE        con:cols=125 lines=30
MODE        125,30
GOTO 		comment_end

-----------------------------------------------------------------------------------------------------

VeriSum > Generate

Generates a hash txt file either by dropping a src folder onto this BAT OR
executing the BAT itself and automatically generating a hash based on the
folder defined in var:dir_root

Hash txt will be placed in specified output folder defined in var:dir_output

Supports:       [ x ] Drag/Drop src (project) folder onto BAT
                [ x ] Self activate BAT to generate from src (project) folder

-----------------------------------------------------------------------------------------------------

:comment_end

ECHO.

:: -----------------------------------------------------------------------------------------------------
::  define:     algorithm
::              sets the algorithm to use.
::              default = SHA256
::
::              If changing this, ensure you also change it in all files:
::              -   VeriSum_GENERATE.BAT
::              -   VeriSum_SIGN.BAT
::              -   VeriSum_VERIFY.BAT
::
:: options:     MD5
::              SHA1
::              SHA256
::              SHA384
::              SHA512
::              Streebog
::              Blake2s
::              Blake2b
::              Blake3
:: -----------------------------------------------------------------------------------------------------

SET algo=SHA256

:: -----------------------------------------------------------------------------------------------------
::  define:     directories
:: -----------------------------------------------------------------------------------------------------

SET dir_home=%~dp0
SET dir_root=project
SET dir_lib=.lib
SET dir_output=checksums

:: -----------------------------------------------------------------------------------------------------
::  define:     files
:: -----------------------------------------------------------------------------------------------------

SET file_src=%~1
SET file_sha_src=%algo%.txt
SET file_sha_tmp=%algo%.tmp

:: -----------------------------------------------------------------------------------------------------
::  define:     libraries
::              DO NOT EDIT
:: -----------------------------------------------------------------------------------------------------

SET echo=%dir_lib%"\cecho.exe"

:: -----------------------------------------------------------------------------------------------------
::  header
:: -----------------------------------------------------------------------------------------------------

%echo%   {gray}-----------------------------------------------------------------------------------------------------{\n}{\n}
%echo% {lime}
%echo% %algo% - Generate{\n\n}{silver}
%echo%   Generates a {03}%file_sha_src%{#} text file which lists all the files associated to a{\n}
%echo%   folder provided and includes folder/file path.{\n\n}
%echo%   Open this file in notepad if you want to change the {03}algorithm{#} you wish to use{\n\n}
%echo%   Requires {fuchisa}Gpg4win{#} to be installed and {fuchisa}environment variables{#} setup.{\n}
%echo% {white}{\n}
%echo%   {gray}-----------------------------------------------------------------------------------------------------{\n}{\n\n}{white}

:: -----------------------------------------------------------------------------------------------------
:: check if folder dragged/dropped on bat OR
:: existing hash.txt file in the defined output folder
:: -----------------------------------------------------------------------------------------------------

setlocal EnableDelayedExpansion
if "%~1" == "" (
    if exist %dir_root% (
        SET file_src=%dir_home%%dir_root%
        %echo%   Using existing file {lime}!file_src!{white}{\n\n\n}
        goto NEXT
    ) else (
        goto FAIL
    )
) else (
    SET file_src=%~1
    %echo%   Using dragged file {lime}!file_src!{white}{\n\n\n}
	goto NEXT
)
endlocal

:: -----------------------------------------------------------------------------------------------------
:: func:    FAIL
::          called if no folder dragged onto bat
:: -----------------------------------------------------------------------------------------------------

:FAIL

	%echo% {white}
	%echo%   {CF} ERROR {white}     Folder not dropped on {D7} VeriSum_Generate.BAT {white}{\n\n\n\n\n\n\n}{gray}

	PAUSE
	Exit /B 0

:: -----------------------------------------------------------------------------------------------------
:: func:    NEXT
::          continue script
:: -----------------------------------------------------------------------------------------------------

:NEXT

    :: -----------------------------------------------------------------------------------------------------
    :: Generate hash.tmp
    :: -----------------------------------------------------------------------------------------------------

    call  %dir_lib%\verisum.exe "%file_src%" "%algo%" -o "%dir_output%\%file_sha_tmp%" -progress -all -allPath -rewrite -lowercase -quiet -fast -nosym -ignore *gitignore -ignore *.md -ignore *docs >nul

    %echo%   {green}[ x ]{gray} Generating hash list from provided files{\n}

    TITLE VeriSum - Generate (Running)
    timeout /t 3 /nobreak >nul

    :: -----------------------------------------------------------------------------------------------------
    :: Replace \ with / in hash.tmp
    :: Save changes to hash.txt
    :: -----------------------------------------------------------------------------------------------------

    (
    FOR /f "usebackqdelims=" %%a IN ("%dir_output%\%file_sha_tmp%") DO (
    SET "line=%%a"
    SET "line=!line:\=/!"
    ECHO !line!
    )
    )>"%dir_output%\%file_sha_src%"

    %echo%   {green}[ x ]{gray} Replacing slash characters {\n}

    timeout /t 1 /nobreak >nul

    :: -----------------------------------------------------------------------------------------------------
    :: cd to output folder
    :: delete hash.tmp
    :: -----------------------------------------------------------------------------------------------------

    cd %dir_output%

    if exist "%file_sha_tmp%" del "%file_sha_tmp%"

    cd %dir_home%

    :: -----------------------------------------------------------------------------------------------------
    :: convert hash.txt line breaks
    :: CRLF -> LF
    ::
    :: failure to do this will result in linux machines being unable
    :: to properly read the file.
    :: -----------------------------------------------------------------------------------------------------

    %echo%   {green}[ x ]{gray} CRLF to LF {blue}%dir_output%\%file_sha_src%{white}{\n}

    call %dir_lib%\dos2unix.exe -q "%dir_home%\%dir_output%\%file_sha_src%" >nul

    timeout /t 1 /nobreak >nul

    %echo%   {\n\n}{03}    %algo%{white} Successfully Generated{\n}
    %echo%          {5F}%dir_output%\%file_sha_src%{\n\n\n\n}{gray}

    timeout /t 2 /nobreak >nul
    TITLE VeriSum - Generate (Complete)

    %echo%   {CF} Press any key to close utility {white}{\n}
    PAUSE >nul

    Exit /B 0