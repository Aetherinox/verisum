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
::  define:     defaults
:: -----------------------------------------------------------------------------------------------------

SET v_cli_cstype=

:: -----------------------------------------------------------------------------------------------------
::  define:     libraries
::              DO NOT EDIT
:: -----------------------------------------------------------------------------------------------------

SET echo=%dir_lib%"\cecho.exe"

:: -----------------------------------------------------------------------------------------------------
::  config file
:: -----------------------------------------------------------------------------------------------------

for /F "tokens=*" %%I in (cfg\config.ini) do set %%I

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

        ( dir /b /a "!file_src!" | findstr /V "^\..*" ) > nul && (
            echo %dir% non-empty >nul
        ) || (

            %echo% {white}
            %echo% {CF} ERROR {white}     Folder {YELLOW}!file_src!{white} is empty{\n}{white}
            %echo%   {white}            Must contain at least one file that doesn't start with a period.{white}{\n\n\n\n\n}

            %echo%   {DF} Press any key to exit {white}{\n}
            PAUSE >nul

            Exit /B 0
        )

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

    %echo%   Would you like to create a single checksum for all files, or a checksum for each file.{white}{\n\n}
    %echo%   {white}      {0C}1{#} Per File Checksum{white}{\n}
    %echo%   {white}      {0C}2{#} Single Checksum{white}{\n\n}

    %echo%   {06}
    set /P v_input_cs_type="Enter Choice: "
    %echo%   {#}{\n\n}

    if [!v_input_cs_type!]==[] (
        %echo%   {white}No choice provided, defaulting to {yellow}Per File Checksum{white}{\n\n\n\n}
        SET v_input_cs_type=1
    )

    if /I "%v_input_cs_type%" EQU "1" (
        SET v_cli_cstype=--all --allpath
        GOTO GENERATE
    )

    if /I "%v_input_cs_type%" EQU "2" (
        SET v_cli_cstype=
        GOTO GENERATE
    ) else (
        %echo% {\n\n}
        %echo%   {4F} Unrecognized Option {0E} !v_input_cs_type! {white}
        %echo% {\n\n}{white}

        goto NEXT
    )

:GENERATE

    :: -----------------------------------------------------------------------------------------------------
    :: Generate hash.tmp
    :: -----------------------------------------------------------------------------------------------------

    call  %dir_lib%\verisum.exe "%file_src%" "%algo%" -o "%dir_output%\%file_sha_tmp%" --progress !v_cli_cstype! --rewrite --lowercase --quiet --fast --nosym --ignore *gitignore --ignore *.md --ignore *.user --ignore *.sln --ignore *.application --ignore *.manifest --ignore *.pdb --ignore *docs >nul

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

    %echo%   {\n\n}{03}    %algo%{white} Successfully Generated{white}{\n}
    %echo%          {5F}%dir_output%\%file_sha_src%{white}{\n\n\n\n\n}

    timeout /t 2 /nobreak >nul
    TITLE VeriSum - Generate (Complete)

    %echo%   {CF} Press any key to exit {white}{\n}
    PAUSE >nul

    Exit /B 0