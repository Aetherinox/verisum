@ECHO 	    OFF
TITLE 	    VeriSum - Sign (Running)
SETLOCAL 	ENABLEDELAYEDEXPANSION
MODE        con:cols=125 lines=30
MODE        125,30
GOTO 		comment_end

-----------------------------------------------------------------------------------------------------

VeriSum > Sign

Supports signing an existing hash txt file in the output folder or an SHA
txt file can be dropped on top of this BAT.

Signed sig and asc will be placed in the specified output folder.

Supports:       [ x ] Drag/Drop sha txt file on BAT
                [ x ] Self activate BAT to sign sha txt in output folder

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
SET dir_lib=.lib
SET dir_output=checksums

:: -----------------------------------------------------------------------------------------------------
::  define:     files
:: -----------------------------------------------------------------------------------------------------

SET file_sha_src=%algo%.txt
SET file_sig=%algo%.sig
SET file_ext=asc

:: -----------------------------------------------------------------------------------------------------
::  define:     libraries
::              DO NOT EDIT
:: -----------------------------------------------------------------------------------------------------

SET echo=%dir_lib%"\cecho.exe"

:: -----------------------------------------------------------------------------------------------------
::  define:     GPG key id
::              set this to the GPG key_id you wish to use
::
::              if you are unsure of your GPG key id, open your command prompt / terminal
::              and execute the command:
::                  gpg --list-keys --keyid-format SHORT
:: -----------------------------------------------------------------------------------------------------

SET gpg_keyid=

:: -----------------------------------------------------------------------------------------------------
::  missing gpg key_id
::
::  give user a chance to manually input their gpg key if default gpg_keyid var missing.
::  if user fails to input on-the-fly keyid, then abort.
:: -----------------------------------------------------------------------------------------------------

IF [%gpg_keyid%]==[] (

    %echo%   {CF} Please open VeriSum_Sign.bat in notepad and assign a gpg key id to gpg_keyid {white}{\n\n}
    %echo%   {white} You can obtain your key id by installing {03}GPG/Gpg4win{#}.{white}{\n}
    %echo%   {white} Then open {03}Windows Terminal{#} or {03}Command Prompt{#} and execute the command: {white}{\n\n}
    %echo%   {white}      gpg --list-secret-keys --keyid-format=short{white}{\n\n\n}
    %echo%   {08} Example:{white}{\n\n}
    %echo%   {white}      {0C}SET{#} gpg_keyid={A0}AE92BC19{white}{\n\n\n}

    %echo%   {06}
    set /P v_input_keyid="Enter Key ID: "
    %echo%   {#}{\n\n}

    if [!v_input_keyid!]==[] (
        %echo%   {CF}No GPG keyid provided, aborting ...{white}{\n\n\n\n}
        %echo%   {08}Press any key to close utility {white}{\n}
        PAUSE >nul
        Exit /B 0
    )

    SET gpg_keyid=!v_input_keyid!

    GOTO NEXT
) else (
    GOTO NEXT
)

:: -----------------------------------------------------------------------------------------------------
:: func:    NEXT
::          called when code can progress
:: -----------------------------------------------------------------------------------------------------

:NEXT

TITLE 	    VeriSum - Sign (RUNNING)
:: -----------------------------------------------------------------------------------------------------
::  remove trailing slash
:: -----------------------------------------------------------------------------------------------------

IF %dir_home:~-1%==\ SET dir_home=%dir_home:~0,-1%

:: -----------------------------------------------------------------------------------------------------
::  header
:: -----------------------------------------------------------------------------------------------------

%echo%   {gray}-----------------------------------------------------------------------------------------------------{\n}{\n}
%echo% {lime}
%echo% %algo% - Sign{\n\n}{silver}
%echo%   Takes an existing {03}%file_sha_src%{#} file and signs it with a GPG key.{\n}
%echo%   Program will output a {03}%file_sig%{#} and {03}%file_sig%.%file_ext%{#}{\n\n}
%echo%   Open this file in notepad if you want to change the {03}algorithm{#} you wish to use{\n\n}
%echo%   Requires {fuchisa}Gpg4win{#} to be installed and {fuchisa}environment variables{#} setup.{\n}
%echo% {white}{\n}
%echo%   {gray}-----------------------------------------------------------------------------------------------------{\n}{\n\n}{white}

:: -----------------------------------------------------------------------------------------------------
:: check if folder dragged/dropped on bat OR
:: existing hash.txt file in the defined output folder
:: -----------------------------------------------------------------------------------------------------

if "%~1" == "" (
    if exist %dir_output%\%file_sha_src% (
        SET file_sha_src=%dir_output%\%file_sha_src%
        %echo%   Using existing file {lime}%dir_output%\%file_sha_src%{white}{\n\n\n}
        goto NEXT
    ) else (
        goto FAIL
    )
) else (
    SET file_sha_src=%~1
    %echo%   Using dragged file {lime}!file_sha_src!{white}{\n\n\n}
    goto NEXT
)
endlocal

:: -----------------------------------------------------------------------------------------------------
:: func:    FAIL
::          called if no folder dragged onto bat
:: -----------------------------------------------------------------------------------------------------

:FAIL

    %echo% {white}
    %echo%   {CF} ERROR {white}     File {D7} %file_sha_src% {white} not found {white}{\n\n\n\n\n\n\n}{gray}

    PAUSE
    Exit /B 0

:: -----------------------------------------------------------------------------------------------------
:: func:    NEXT
::          continue script
:: -----------------------------------------------------------------------------------------------------

:NEXT

    :: -----------------------------------------------------------------------------------------------------
    :: Replace \ with / for paths
    :: -----------------------------------------------------------------------------------------------------

    %echo%   {green}[ x ]{gray} Replacing slash characters {\n}

    (
    FOR /f "usebackqdelims=" %%a IN ("%file_sha_src%") DO (
    SET "line=%%a"
    SET "line=!line:\=/!"
    ECHO !line!
    )
    )>"%dir_output%\%file_sig%"

    timeout /t 1 /nobreak >nul

    :: -----------------------------------------------------------------------------------------------------
    :: Convert file.sig from CRLF (Windows) to LF (Unix)
    :: -----------------------------------------------------------------------------------------------------

    %echo%   {green}[ x ]{gray} CRLF to LF {blue}%dir_output%\%file_sig%{white}{\n}

    call %dir_lib%\dos2unix.exe -q "%dir_output%\%file_sig%"

    timeout /t 1 /nobreak >nul

    :: -----------------------------------------------------------------------------------------------------
    :: Create GPG signature
    :: -----------------------------------------------------------------------------------------------------

    %echo%   {green}[ x ]{gray} Generating armored GPG file {blue}%dir_output%\%file_sig%.%file_ext%{\n}
    %echo%   {green}[ x ]{gray} Signing file with key id {blue}%gpg_keyid%{\n}

    gpg --batch --yes -q --default-key "%gpg_keyid%" --clearsign "%dir_output%\%file_sig%"

    timeout /t 2 /nobreak >nul

    :: -----------------------------------------------------------------------------------------------------
    :: Convert file.sig.asc from CRLF (Windows) to LF (Unix)
    :: -----------------------------------------------------------------------------------------------------

    %echo%   {green}[ x ]{gray} CRLF to LF {blue}%dir_output%\%file_sig%.%file_ext%{white}{\n}

    call %dir_lib%\dos2unix.exe -q "%dir_output%\%file_sig%.%file_ext%"

    %echo%   {\n\n}{yellow}    Process has completed. Make sure no errors have appeared above.{gray}{\n\n\n\n}

    timeout /t 2 /nobreak >nul
    TITLE VeriSum - Sign (Complete)

    %echo%   {CF} Press any key to close utility {white}{\n}
    PAUSE >nul
    Exit /B 0