@setlocal enableextensions enabledelayedexpansion
@echo off
set apiurl=https://api.tinify.com/shrink
set filename=
set filenameOut=
set apikey=
set error=

:: Process all arguments
set prev=
:argsloop
shift
IF "%0" NEQ "" (
  IF "%prev%" EQU "-i" (
    set "filename=%0" & set "prev="
    GOTO :argsloop
  )
  IF "%prev%" EQU "-o" (
    set "filenameOut=%0" & set "prev="
    GOTO :argsloop
  )
  IF "%prev%" EQU "-key" (
    set "apikey=%0" & set "prev="
    GOTO :argsloop
  )
  set "prev=%0"
  GOTO :argsloop
)

IF "%filename%" EQU "" (
  set error=No input file given.
  GOTO :usage
)

:: Check api_key parameter, read API_KEY file if not given via command line
IF "%apikey%" EQU "" (
  IF NOT EXIST API_KEY (
    set error=File API_KEY does not exist. Create it and fill it with your Api key
    GOTO :error
  )
  set /p apikey=<API_KEY
)
IF "%apikey%" EQU "" (
  set error=Api key is empty, please fill the API_KEY file with your Api key
  GOTO :error
)

:: Set output file to input file if needed
IF "%filenameOut%" EQU "" (
  set filenameOut=%filename%
)

IF NOT EXIST %filename% (
  set error=File "%filename%" does not exist
  GOTO :error
)

IF "%filename:~-3%" NEQ "png" (
IF "%filename:~-3%" NEQ "gif" (
IF "%filename:~-3%" NEQ "jpg" (
IF "%filename:~-4%" NEQ "jpeg" (
  set error=Cannot optimize image. Only png, gif, jpg, jpeg extension allowed.
  GOTO :error
))))

echo.
echo Input File:  %filename%
echo Output File: %filenameOut%
echo Api Key:     %apikey%
echo.

:: api call
echo Resizing %filename% via Api.
FOR /f "tokens=*" %%a IN ('curl -s --user api:%apikey% --data-binary @%filename% %apiurl%') DO (set json=%%a)

:: check if json has an error message
set "jsontest=%json:"error":"=%"
set "msg=%json:*message":"=%"
set "msg=%msg:"=" & rem."%"
IF "!jsontest!" NEQ "!json!" (
  set error=Api Message: %msg%
  GOTO :error
)

:: check if json has minimized image url
set "jsontest=%json:"url":"=%"
IF "!jsontest!" EQU "!json!" (
  set error="url" not found in json.
  GOTO :error
)

:: extract minimized image url
set "url=%json:*url":"=%"
set "url=%url:"=" & rem."%"

:: save image via curl
echo Saving %url% to %filenameOut%.
curl -s -o %filenameOut% %url%
GOTO :end

:error
echo An error occured: %error%
GOTO :end

:usage
echo Wrong usage: %error%
echo.
echo Usage:
echo %~nx0 -i INPUT_FILE [-o OUTPUT_FILE] [-key APIKEY]
echo.
echo    -i:   Path to image file with extension png, gif, jpg or jpeg
echo    -o:   Path to output file (optional, input_file is overwritten by default)
echo    -key: Api key (optional, content of a file named API_KEY is used as default)
GOTO :end

:end
endlocal


