# Marc OS Windows Audio Rescue Toolkit v1.0

Thanks for purchasing the toolkit.

## Download

Download these files from this folder to the **same folder** on your Windows 11 PC:

- `AudioRescue.ps1`
- `1-Diagnose-Audio.cmd`
- `2-Safe-Repair-Audio.cmd`
- `60-Second-Quick-Check.txt`
- `LICENCE.txt`

Then double-click **1-Diagnose-Audio.cmd** for a diagnostic report. If you want the low-risk repair routine, double-click **2-Safe-Repair-Audio.cmd** and approve the Windows Administrator prompt.

## What it checks

- Windows Audio and Audio Endpoint Builder services
- sound hardware visible to Windows
- present audio endpoints/media devices
- the current user's microphone privacy setting
- common patterns such as speakers working while the microphone is missing

Safe Repair only restarts the Windows audio services and requests a Plug and Play hardware rescan. It does not install or remove drivers, alter the registry, or transmit data.

## If the microphone is still missing

1. Open **Settings > System > Sound** and check Input.
2. Open **Settings > Privacy & security > Microphone** and enable microphone access.
3. Press **Win + R**, enter `mmsys.cpl`, open **Recording**, right-click the blank area, then enable **Show Disabled Devices** and **Show Disconnected Devices**.
4. If needed, install the official audio/chipset driver from the PC manufacturer's support site and restart Windows.

Windows is a trademark of Microsoft. This product is independent and is not affiliated with or endorsed by Microsoft.
