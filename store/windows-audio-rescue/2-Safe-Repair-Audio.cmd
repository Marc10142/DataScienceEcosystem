@echo off
title Marc OS Audio Rescue - Safe Repair
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dp0AudioRescue.ps1"" -Repair'"
