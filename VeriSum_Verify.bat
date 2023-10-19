@ECHO 	    OFF
TITLE 	    VeriSum - Verify
SETLOCAL 	ENABLEDELAYEDEXPANSION
MODE        con:cols=125 lines=30
MODE        125,30
GOTO 		comment_end

-----------------------------------------------------------------------------------------------------

VeriSum > Verify

Verifies a generated hash txt file with the contents of the project folder.
Results will be printed in console and a log file will be stored in .logs

Supports:       [ x ] Auto detecting digest txt
                      digest file should be placed in 'checksums' folder as 'ALG.txt'
                      Ex:   checksums\SHA256.txt

                      Be sure to change the variable 'SET algo' in this file.
                      SHA256 is the default algorithm.

                      If you set the algorithm variable to SHA512, then your checksum
                      file should be
                            checksums\SHA512.txt

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
SET dir_logs=.logs
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
::  config file
:: -----------------------------------------------------------------------------------------------------

for /F "tokens=*" %%I in (cfg\config.ini) do set %%I

    :: -----------------------------------------------------------------------------------------------------
    ::  remove trailing slash
    :: -----------------------------------------------------------------------------------------------------

    IF %dir_home:~-1%==\ SET dir_home=%dir_home:~0,-1%

    :: -----------------------------------------------------------------------------------------------------
    ::  header
    :: -----------------------------------------------------------------------------------------------------

    %echo%   {gray}-----------------------------------------------------------------------------------------------------{\n}{\n}
    %echo% {lime}
    %echo% %algo% - Verify{\n\n}{silver}
    %echo%   Verifies a generated hash txt file with the contents of the project folder.{\n}
    %echo%   Results will be printed in console and a log file will be stored in {03}%dir_logs%{#}{\n\n}
    %echo%   Open this file in notepad if you want to change the {03}algorithm{#} you wish to use{\n}
    %echo% {white}{\n}
    %echo%   {gray}-----------------------------------------------------------------------------------------------------{\n}{\n}{white}

    :: -----------------------------------------------------------------------------------------------------
    :: verify checksum
    :: -----------------------------------------------------------------------------------------------------

    call %dir_lib%\verisum.exe "%dir_home%\%dir_root%" %algo% -o "%dir_home%\%dir_logs%\%algo%_verify.txt" -verify "%dir_home%\%dir_output%\%algo%.txt" -progress -lowercase -rewrite -fast -clean -ignore *gitignore -ignore *.md -ignore *docs

    %echo%   {gray}{\n\n\n\n}

    timeout /t 2 /nobreak >nul
    TITLE VeriSum - Verify (Complete)

    %echo%   {CF} Press any key to close utility {white}{\n}
    PAUSE >nul
    Exit /B 0