<#
Marc OS Windows Audio Rescue Toolkit v1.0
Diagnoses common Windows 11 speaker and microphone problems.
Safe Repair restarts audio services and performs a Plug and Play rescan.
No drivers are installed/removed, no registry values are changed, and no data is transmitted.
#>
[CmdletBinding()]
param([switch]$Repair,[switch]$NoReport)
$ErrorActionPreference='SilentlyContinue'
$script:Lines=New-Object System.Collections.Generic.List[string]
function Add-Line { param([string]$Text=''); $script:Lines.Add($Text); Write-Host $Text }
function Section { param([string]$Title); Add-Line ''; Add-Line ('='*68); Add-Line $Title; Add-Line ('='*68) }
function Is-Administrator { try { $identity=[Security.Principal.WindowsIdentity]::GetCurrent(); $principal=New-Object Security.Principal.WindowsPrincipal($identity); return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) } catch { return $false } }
$admin=Is-Administrator
Add-Line 'Marc OS Windows Audio Rescue Toolkit v1.0'
Add-Line ('Run time: '+(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
Add-Line ('Computer: '+$env:COMPUTERNAME)
Add-Line ('User: '+$env:USERNAME)
Add-Line ('Administrator: '+$admin)
Section '1. WINDOWS VERSION'
try { $os=Get-CimInstance Win32_OperatingSystem; Add-Line ('Windows: '+$os.Caption); Add-Line ('Version: '+$os.Version); Add-Line ('Build: '+$os.BuildNumber) } catch { Add-Line 'Could not read Windows version.' }
Section '2. CORE AUDIO SERVICES'
foreach($name in @('AudioEndpointBuilder','Audiosrv')) { $svc=Get-Service -Name $name; if($svc){ Add-Line ('{0}: {1} | Start type: {2}' -f $svc.DisplayName,$svc.Status,$svc.StartType) } else { Add-Line ('Service not found: '+$name) } }
Section '3. WINDOWS SOUND DEVICES'
try { $soundDevices=Get-CimInstance Win32_SoundDevice; if($soundDevices){ foreach($d in $soundDevices){ Add-Line ('Name: '+$d.Name); Add-Line ('  Status: '+$d.Status); Add-Line ('  Manufacturer: '+$d.Manufacturer); Add-Line ('  PNP Device ID: '+$d.PNPDeviceID) } } else { Add-Line 'No Win32_SoundDevice entries were returned.' } } catch { Add-Line 'Could not enumerate Win32_SoundDevice.' }
Section '4. AUDIO ENDPOINTS / MEDIA DEVICES'
try { $pnp=Get-PnpDevice -PresentOnly | Where-Object { $_.Class -in @('AudioEndpoint','MEDIA','Media') }; if($pnp){ $pnp | Sort-Object Class,FriendlyName | ForEach-Object { Add-Line ('[{0}] {1} | Status: {2} | Problem: {3}' -f $_.Class,$_.FriendlyName,$_.Status,$_.Problem) } } else { Add-Line 'No present AudioEndpoint/MEDIA devices were found.' } } catch { Add-Line 'Get-PnpDevice was unavailable or device enumeration failed.' }
Section '5. MICROPHONE PRIVACY'
$micPath='HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone'
try { $mic=Get-ItemProperty -Path $micPath; if($mic.Value){ Add-Line ('Windows microphone consent: '+$mic.Value); if($mic.Value -eq 'Deny'){ Add-Line 'WARNING: Windows microphone access appears to be denied for this user.' } } else { Add-Line 'Microphone consent value not explicitly set.' } } catch { Add-Line 'Could not read microphone privacy setting.' }
Section '6. QUICK INTERPRETATION'
$audioSvc=Get-Service Audiosrv; $endpointSvc=Get-Service AudioEndpointBuilder
if($audioSvc.Status -ne 'Running'){ Add-Line 'ACTION: Windows Audio is not running.' }
if($endpointSvc.Status -ne 'Running'){ Add-Line 'ACTION: Windows Audio Endpoint Builder is not running.' }
if($soundDevices.Count -eq 0){ Add-Line 'ACTION: Windows sees no sound device. Focus on drivers, BIOS/firmware, or hardware.' }
if($soundDevices.Count -gt 0){ Add-Line 'Windows sees at least one sound device.' }
Add-Line 'If speakers work but no microphone appears, focus on microphone privacy,'
Add-Line 'hidden/disabled recording devices, OEM audio drivers, and device re-detection.'
if($Repair){ Section '7. SAFE REPAIR ACTIONS'; if(-not $admin){ Add-Line 'Repair mode requires Administrator rights.' } else { foreach($name in @('AudioEndpointBuilder','Audiosrv')){ try { $svc=Get-Service -Name $name; if($svc.Status -eq 'Running'){ Add-Line ('Restarting '+$svc.DisplayName+'...'); Restart-Service -Name $name -Force } else { Add-Line ('Starting '+$svc.DisplayName+'...'); Start-Service -Name $name }; $svc=Get-Service -Name $name; Add-Line ('Result: '+$svc.Status) } catch { Add-Line ('Could not repair service '+$name) } }; Add-Line 'Requesting a Windows Plug and Play hardware rescan...'; try { $p=Start-Process -FilePath 'pnputil.exe' -ArgumentList '/scan-devices' -Wait -PassThru -WindowStyle Hidden; Add-Line ('PnP rescan exit code: '+$p.ExitCode) } catch { Add-Line 'PnP rescan could not be started.' }; Add-Line 'Safe repair actions complete.'; Add-Line 'No drivers were removed or installed.' } }
if(-not $NoReport){ Section '8. REPORT'; try { $desktop=[Environment]::GetFolderPath('Desktop'); $stamp=Get-Date -Format 'yyyyMMdd_HHmmss'; $report=Join-Path $desktop ('MarcOS_Audio_Report_'+$stamp+'.txt'); $script:Lines | Set-Content -Path $report -Encoding UTF8; Add-Line ('Saved report: '+$report) } catch { Add-Line 'Could not save the report to the Desktop.' } }
Section 'NEXT STEPS'
Add-Line '1. Settings > System > Sound: select the correct Output/Input.'
Add-Line '2. Settings > Privacy & security > Microphone: allow microphone access.'
Add-Line '3. Run mmsys.cpl > Recording > Show Disabled Devices.'
Add-Line '4. If still missing, install the OEM audio/chipset driver from the PC manufacturer.'
Add-Line ''
Add-Line 'This toolkit is a troubleshooting aid, not a guarantee of repair.'
Add-Line 'It sends no information anywhere.'
Write-Host ''; Write-Host 'Finished. Press Enter to close.'; [void](Read-Host)
