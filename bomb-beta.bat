@echo off
title [ fogos - remake ]
color 05
setlocal enabledelayedexpansion

::este arquivo e de testes, ele ainda esta na fazer inicial, pretendo colocar mais opções a ele.


:: Caminhos principais
set BASE=D:\setup\
set ADB=%BASE%\adb\
set SYSTEM=%BASE%\sistemas\
set STOCK=%SYSTEM%\stock\
set TWRP=%BASE%\twrp
set CUSTOM=D:\setup\sistemas\custom\

:: menu inicial

:main
color 05
cls
echo         menu inicial


echo 1 -- entrar no menu de stock rom
echo 2 -- entrar no menu de custom rom
echo 3 -- entrar no menu de recoverys -- n esta pronto
echo -- mais funcoes em breve --
echo 0 - Sair


set /p opcao=Escolha uma opcao: 

if "%opcao%"=="1" goto STOCK
if "%opcao%"=="2" goto ROMS
if "%opcao%"=="3" goto RECOVERYS
if "%opcao%"=="0" exit

:STOCK

cls
echo ================================
echo   Instalador de Stock ROM
echo ================================


set /a count=0
for /d %%i in (%STOCK%*) do (
    set /a count+=1
    echo [!count!] %%~nxi
    set "opcao[!count!]=%%i"
)


echo [0] Sair
echo.
set /p escolha=Selecione uma opcao: 

if "%escolha%"=="0" goto fim

if defined opcao[%escolha%] (
    set "pasta=!opcao[%escolha%]!"
    goto instalar
) else (
    echo Opcao invalida!
    pause
    goto menu
)

:instalar
echo Você selecionou a ROM "%pasta%"
echo ================================
echo   Escolha o modo de instalação
echo ================================
echo [1] Instalar com vbmeta (sem verificação)
echo [2] Instalar com vbmeta (com verificação)
echo [0] Cancelar


set /p vbopcao=Selecione uma opcao: 

if "%vbopcao%"=="0" goto main
if "%vbopcao%"=="1" goto vbmeta_sem
if "%vbopcao%"=="2" goto vbmeta_com

echo Opcao invalida!
pause
goto instalar

:vbmeta_sem
echo Instalando ROM "%pasta%" com vbmeta sem verificação...
rem comandos de instalacao aqui (exemplo: fastboot --disable-verity --disable-verification flash vbmeta vbmeta.img)

echo esperando comfirmação do usuario para instalar a stock..

pause

%ADB%\fastboot flash partition %pasta%\gpt.bin

%ADB%\fastboot flash bootloader %pasta%\bootloader.img

%ADB%\fastboot --disable-verity --disable-verification flash vbmeta %pasta%\vbmeta.img

%ADB%\fastboot flash vbmeta_system %pasta%\vbmeta_system.img

%ADB%\fastboot flash radio %pasta%\radio.img

%ADB%\fastboot flash bluetooth %pasta%\BTFM.bin

%ADB%\fastboot flash dsp %pasta%\dspso.bin

%ADB%\fastboot flash logo %pasta%\logo.bin

%ADB%\fastboot flash boot %pasta%\boot.img

%ADB%\fastboot flash vendor_boot %pasta%\vendor_boot.img

%ADB%\fastboot flash dtbo %pasta%\dtbo.img

for %%f in ("%pasta%\super.img_sparsechunk.*") do (
    %ADB%\fastboot flash super "%%f"
)


%ADB%\fastboot erase debug_token

%ADB%\fastboot erase carrier

%ADB%\fastboot erase userdata

%ADB%\fastboot erase metadata

%ADB%\fastboot erase ddr

%ADB%\fastboot oem fb_mode_clear

%ADB%\fastboot oem config unset console

%ADB%\fastboot oem config unset cmdl

%ADB%\fastboot reboot

set pasta=0

pause
goto main

:vbmeta_com
echo Instalando ROM "%pasta%" com vbmeta com verificação...
rem comandos de instalacao aqui (exemplo: fastboot flash vbmeta vbmeta.img)

echo esperando comfirmação do usuario para instalar a stock..

pause

%ADB%\fastboot flash partition %pasta%\gpt.bin

%ADB%\fastboot flash bootloader %pasta%\bootloader.img

%ADB%\fastboot flash vbmeta %pasta%\vbmeta.img

%ADB%\fastboot flash vbmeta_system %pasta%\vbmeta_system.img

%ADB%\fastboot flash radio %pasta%\radio.img

%ADB%\fastboot flash bluetooth %pasta%\BTFM.bin

%ADB%\fastboot flash dsp %pasta%\dspso.bin

%ADB%\fastboot flash logo %pasta%\logo.bin

%ADB%\fastboot flash boot %pasta%\boot.img

%ADB%\fastboot flash vendor_boot %pasta%\vendor_boot.img

%ADB%\fastboot flash dtbo %pasta%\dtbo.img

for %%f in ("%pasta%\super.img_sparsechunk.*") do (
    %ADB%\fastboot flash super "%%f"
)

%ADB%\fastboot erase debug_token

%ADB%\fastboot erase carrier

%ADB%\fastboot erase userdata

%ADB%\fastboot erase metadata

%ADB%\fastboot erase ddr

%ADB%\fastboot oem fb_mode_clear

%ADB%\fastboot oem config unset console

%ADB%\fastboot oem config unset cmdl

%ADB%\fastboot reboot

set pasta=0

pause
goto main

:ROMS
echo Você selecionou a Custom ROM "%pasta2%"
cd /d "%pasta2%"

echo Procurando arquivo .zip da ROM...
set "romzip="

set /a count=0
for %%f in (*.zip) do (
    set /a count+=1
    echo [!count!] %%f
    set "zipopcao[!count!]=%%f"
)

if %count%==0 (
    echo Nenhum arquivo .zip encontrado em "%pasta2%"
    pause
    goto main
)

echo [0] Cancelar
set /p escolhazip=Selecione o arquivo .zip: 

if "%escolhazip%"=="0" goto main

if defined zipopcao[%escolhazip%] (
    set "romzip=!zipopcao[%escolhazip%]!"
) else (
    echo Opcao invalida!
    pause
    goto instalar_custom
)

echo Arquivo de ROM selecionado: "%romzip%"
echo esperando confirmação do usuario para instalar a rom..
pause

%ADB%\fastboot flash boot boot.img
%ADB%\fastboot flash dtbo dtbo.img
%ADB%\fastboot flash vendor_boot vendor_boot.img

echo 50%% parte da instalação concluída, inicie no modo recovery e entre no sideload para continuar
pause

%ADB%\adb sideload "%romzip%"

pause
goto main


:RECOVERYS

