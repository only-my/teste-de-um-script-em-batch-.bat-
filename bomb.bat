@echo off
title [ fogos - remake ]
color 05
setlocal enabledelayedexpansion

:: Se existir config.json, tenta carregar
:: Se existir config.log, carregar variáveis
if exist config.log (
    for /f "tokens=1,2 delims==" %%a in (config.log) do (
        set "%%a=%%b"
    )
)

:DIR
if not defined BASE set /p BASE=Digite o caminho BASE: 
if not defined ADB set /p ADB=Digite o caminho da pasta ADB: 
if not defined STOCK set /p STOCK=Digite o caminho da pasta Stock ROMs:
if not defined CUSTOM set /p CUSTOM=Digite o caminho da pasta Custom ROMs: 
if not defined TWRP set /p TWRP=Digite o caminho da pasta TWRP: 
if not defined ROOT set /p ROOT=Digite o caminho da pasta Manager Root:

:: Verificação dos caminhos
set SAVE=0

if not exist "%BASE%" set SAVE=1
if not exist "%ADB%" set SAVE=1
if not exist "%STOCK%" set SAVE=1
if not exist "%CUSTOM%" set SAVE=1
if not exist "%TWRP%" set SAVE=1
if not exist "%ROOT%" set SAVE=1

:: Se precisar salvar (arquivo não existe ou caminhos inválidos)
:: Se precisar salvar (arquivo não existe ou caminhos inválidos)
if %SAVE%==1 (
    (
    echo BASE=%BASE%
    echo ADB=%ADB%
    echo STOCK=%STOCK%
    echo CUSTOM=%CUSTOM%
    echo TWRP=%TWRP%
    echo ROOT=%ROOT%
    ) > config.log
    echo Configuracao salva em config.log
) else (
    echo Configuracao valida, sem necessidade de salvar novamente.
)



echo Configuracao concluida com sucesso!
pause

:: Menu principal
:MENU
cls
echo [ fogos - remake ]
echo.
echo 1. Instalar Stock ROM
echo 2. Instalar Custom ROM
echo 3. Instalar TWRP
echo 4. instalar manager root
echo 0. Sair
echo.
set /p OPTION=Escolha uma opcao:

if "%OPTION%"=="1" goto STOCK_ROM
if "%OPTION%"=="2" goto CUSTOM_ROM  
if "%OPTION%"=="3" goto INSTALL_TWRP
if "%OPTION%"=="4" goto INSTALL_ROOT
if "%OPTION%"=="0" exit

:: Função para instalar Stock ROM
:STOCK_ROM
cls
echo Instalando Stock ROM...
%ADB%\adb.exe devices
echo Conecte o dispositivo no modo fastboot e pressione qualquer tecla para continuar...
pause >nul
%ADB%\fastboot.exe devices
echo Instalando Stock ROM...
:: Aqui você pode adicionar os comandos específicos para instalar a Stock ROM usando fastboot


:: Preparação
%ADB%\fastboot getvar max-sparse-size
%ADB%\fastboot oem fb_mode_set

:: Flash dos arquivos principais
%ADB%\fastboot flash partition "%STOCK%\gpt.bin"
%ADB%\fastboot flash bootloader "%STOCK%\bootloader.img"
%ADB%\fastboot flash vbmeta "%STOCK%\vbmeta.img"
%ADB%\fastboot flash vbmeta_system "%STOCK%\vbmeta_system.img"
%ADB%\fastboot flash radio "%STOCK%\radio.img"
%ADB%\fastboot flash bluetooth "%STOCK%\BTFM.bin"
%ADB%\fastboot flash dsp "%STOCK%\dspso.bin"
%ADB%\fastboot flash logo "%STOCK%\logo.bin"
%ADB%\fastboot flash boot "%STOCK%\boot.img"
%ADB%\fastboot flash vendor_boot "%STOCK%\vendor_boot.img"
%ADB%\fastboot flash dtbo "%STOCK%\dtbo.img"

:: Flash dos super.img_sparsechunk.*
for %%f in ("%STOCK%\super.img_sparsechunk.*") do (
    %ADB%\fastboot flash super "%%f"
)

:: Erases
%ADB%\fastboot erase debug_token
%ADB%\fastboot erase carrier
%ADB%\fastboot erase userdata
%ADB%\fastboot erase metadata
%ADB%\fastboot erase ddr

:: OEM configs
%ADB%\fastboot oem fb_mode_clear
%ADB%\fastboot oem config unset console
%ADB%\fastboot oem config unset cmdl
%ADB%\fastboot reboot

echo Stock ROM instalada com sucesso!
pause
goto MENU

:: Função para instalar Custom ROM
:CUSTOM_ROM
color 0D
cls
echo Instalando Custom ROM...
:: Aqui você pode adicionar os comandos específicos para instalar a Custom ROM usando fastboot ou adb

:: Efeito RGB (apenas visual, sem entrada)
    echo Instalando Custom ROM...
    set /a count=0
    for /d %%i in ("%CUSTOM%\*") do (
        set /a count+=1
        echo [!count!] %%~nxi
    )
    echo [0] Cancelar

:: Menu final (entrada do usuário)
cls
echo Instalando Custom ROM...
set /a count=0
for /d %%i in ("%CUSTOM%\*") do (
    set /a count+=1
    echo [!count!] %%~nxi
    set "opcao[!count!]=%%i"
)
echo [0] Cancelar
set /p escolha=Selecione uma pasta: 

if "%escolha%"=="0" goto MENU

if not defined opcao[%escolha%] (
    echo ❌ Opcao invalida!
    pause
    goto CUSTOM_ROM
)

set "pasta=!opcao[%escolha%]!"
echo Você escolheu: !pasta!

:: Checar arquivos obrigatórios
set "erro=0"
for %%f in (boot.img dtbo.img vendor_boot.img) do (
    if not exist "!pasta!\%%f" (
        echo ❌ %%f nao encontrado
        set "erro=1"
    )
)

if "!erro!"=="1" (
    echo Corrija os arquivos faltando e tente novamente.
    pause
    goto CUSTOM_ROM
)

echo ✅ Todos os arquivos necessarios estao presentes.

:: Flash imagens
%ADB%\fastboot flash boot "!pasta!\boot.img"
%ADB%\fastboot flash dtbo "!pasta!\dtbo.img"
%ADB%\fastboot flash vendor_boot "!pasta!\vendor_boot.img"

:: Listar arquivos .zip
set /a countzip=0
for %%f in ("!pasta!\*.zip") do (
    set /a countzip+=1
    echo [!countzip!] %%~nxf
    set "zipopcao[!countzip!]=%%f"
)

if %countzip%==0 (
    echo ❌ Nenhum arquivo .zip encontrado.
    pause
    goto MENU
)

echo [0] Cancelar
set /p escolhazip=Selecione o arquivo .zip: 

if "%escolhazip%"=="0" goto MENU

if not defined zipopcao[%escolhazip%] (
    echo ❌ Opcao invalida!
    pause
    goto CUSTOM_ROM
)

set "romzip=!zipopcao[%escolhazip%]!"
echo Entre em modo recovery e coloque em sideload, depois pressione qualquer tecla...
pause >nul

%ADB%\adb devices
echo Instalando via sideload: !romzip!
%ADB%\adb sideload "!romzip!"
echo ✅ Custom ROM instalada com sucesso!
pause
goto MENU
