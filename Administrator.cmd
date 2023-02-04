:START
@ECHO OFF&&CLS&&TITLE  Download from github.com/joshuacline&&COLOR 0C&&REG QUERY "HKU\S-1-5-19\Environment">NUL
IF NOT %ERRORLEVEL% EQU 0 ECHO Right-Click ^& Run As Administrator&&PAUSE&&EXIT 0
FOR /F "TOKENS=*" %%a in ('WHOAMI') do (IF "%%a"=="nt authority\system" GOTO:ADMIN)
ECHO (1) Install Administrator Service&&ECHO (2) Uninstall Administrator Service&&ECHO Press (Enter) to exit...&&SET "SELECT="&&SET /P "SELECT=$>>"
SET "REMOVE="&&IF "%SELECT%"=="2" SET "ADMIN=0"&&SET "REMOVE=1"&&SC DELETE Administrator>NUL 2>&1
IF DEFINED REMOVE GOTO:JUMP
IF NOT "%SELECT%"=="1" EXIT 0
COPY /Y "%0" "%PROGRAMDATA%\Administrator.cmd">NUL 2>&1
SC CREATE Administrator BINPATH="CMD /C START %PROGRAMDATA%\Administrator.cmd" START=DEMAND>NUL 2>&1
SC SDSET Administrator D:(A;;RPWPDTCR;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;RPWPDT;;;BU)(A;;CCLCSWLOCRRC;;;IU)(A;;CCLCSWLOCRRC;;;SU)S:(AU;FA;WDWO;;;BA)
CLS&&ECHO Administrator Installed @ %PROGRAMDATA%\Administrator.cmd&&ECHO Start Administrator via Taskmgr Services-tab&&SET /P PAUSED=Press (Enter) to continue...
GOTO:START
:ADMIN
TAKEOWN /F "%PROGRAMDATA%\Administrator.cmd" /R /D Y>NUL 2>&1
SET "ADMIN="&&FOR /F "TOKENS=3 SKIP=1 DELIMS=: " %%a in ('REG QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v Administrator /s') do (IF "%%a"=="0x0" CALL SET "ADMIN=1"
IF "%%a"=="0x1" CALL SET "ADMIN=0")
IF NOT DEFINED ADMIN SET "ADMIN=1"
REG.EXE ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "Administrator" /t REG_DWORD /d "%ADMIN%" /f>NUL 2>&1
IF "%ADMIN%"=="0" FOR /F "TOKENS=2* SKIP=1 DELIMS=:\. " %%a in ('REG QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" /v LastLoggedOnUser /s') do (IF "%%a"=="REG_SZ" NET localgroup Administrators "%%b" /delete)
IF "%ADMIN%"=="1" FOR /F "TOKENS=2* SKIP=1 DELIMS=:\. " %%a in ('REG QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" /v LastLoggedOnUser /s') do (IF "%%a"=="REG_SZ" NET localgroup Administrators "%%b" /add)
:JUMP
IF "%REMOVE%"=="1" ECHO Removing Administrator Service...&&REG.EXE DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "Administrator" /f>NUL 2>&1
IF "%REMOVE%"=="1" CLS&&ECHO Administrator Service Removed&&DEL /F "%PROGRAMDATA%\Administrator.cmd">NUL 2>&1
IF "%REMOVE%"=="1" SET /P PAUSED=Press (Enter) to continue...
IF "%REMOVE%"=="1" GOTO:START
EXIT 0