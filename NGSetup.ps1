# =====================================================================
#  NG SETUP - bo cong cu cai dat sau khi cai Windows (1 file duy nhat)
#  Chay:  irm "https://raw.githubusercontent.com/thinhnguyen02031-lang/NGmods/main/NGSetup.ps1" | iex
#
#  MUON THEM DO VAO: keo xuong muc "DANH MUC" va them 1 khoi @{ ... } theo mau co san.
# =====================================================================

$Ten       = 'NG Setup'
$ScriptUrl = 'https://raw.githubusercontent.com/thinhnguyen02031-lang/NGmods/main/NGSetup.ps1'

$ErrorActionPreference = 'Continue'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

# ---- 1. Tu xin quyen Administrator ----
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $cmd = if ($PSCommandPath) { "& '$PSCommandPath'" } else { "irm '$ScriptUrl?x=$(Get-Random)' | iex" }
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$cmd`""
    return
}

# Duong dan hay dung trong cac lenh tinh chinh
$Adv  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$Pers = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
$CDM  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'

# =====================================================================
#                              DANH MUC
#  Moi tab co:  Tab = ten tab ; Type = 'winget' hoac 'script' ; Items = danh sach
#
#  Muc kieu winget :  @{ Name='Ten'; Id='Ma.WingetId'; Desc='Mo ta'; Rec=$true }
#      (tim ma bang lenh:  winget search ten-app)
#  Muc kieu script :  @{ Name='Ten'; Desc='Mo ta'; Run={ lenh PowerShell }; Undo={ lenh hoan tac }; Rec=$true }
#
#  Rec=$true  -> tu dong duoc tick san khi mo bang (muc "khuyen dung")
# =====================================================================
$Catalog = @(

    # ------------------------------------------------------------ UNG DUNG
    @{ Tab = 'Ung dung'; Type = 'winget'; Items = @(
        @{ Name = 'Google Chrome';        Id = 'Google.Chrome';                  Desc = 'Trinh duyet web cua Google.'; Rec = $true },
        @{ Name = 'Mozilla Firefox';      Id = 'Mozilla.Firefox';                Desc = 'Trinh duyet web ma nguon mo.' },
        @{ Name = 'Brave';                Id = 'Brave.Brave';                    Desc = 'Trinh duyet chan quang cao san.' },
        @{ Name = '7-Zip';                Id = '7zip.7zip';                      Desc = 'Giai nen / nen file mien phi.'; Rec = $true },
        @{ Name = 'WinRAR';               Id = 'RARLab.WinRAR';                  Desc = 'Giai nen file rar, zip.' },
        @{ Name = 'VLC Media Player';     Id = 'VideoLAN.VLC';                   Desc = 'Phat video, nhac moi dinh dang.'; Rec = $true },
        @{ Name = 'Notepad++';            Id = 'Notepad++.Notepad++';            Desc = 'Soan thao van ban / code nhe.'; Rec = $true },
        @{ Name = 'Adobe Acrobat Reader'; Id = 'Adobe.Acrobat.Reader.64-bit';    Desc = 'Doc file PDF.' },
        @{ Name = 'LibreOffice';          Id = 'TheDocumentFoundation.LibreOffice'; Desc = 'Bo Office mien phi (Word, Excel...).' },
        @{ Name = 'Zalo';                 Id = 'VNGCorp.Zalo';                   Desc = 'Chat Zalo tren may tinh.' },
        @{ Name = 'Telegram';             Id = 'Telegram.TelegramDesktop';       Desc = 'Chat Telegram.' },
        @{ Name = 'Discord';              Id = 'Discord.Discord';                Desc = 'Chat thoai va nhan tin.' },
        @{ Name = 'Steam';                Id = 'Valve.Steam';                    Desc = 'Nen tang choi game Steam.' },
        @{ Name = 'Epic Games Launcher';  Id = 'EpicGames.EpicGamesLauncher';    Desc = 'Nen tang game Epic.' },
        @{ Name = 'Spotify';              Id = 'Spotify.Spotify';                Desc = 'Nghe nhac.' },
        @{ Name = 'OBS Studio';           Id = 'OBSProject.OBSStudio';           Desc = 'Quay / livestream man hinh.' },
        @{ Name = 'qBittorrent';          Id = 'qBittorrent.qBittorrent';        Desc = 'Tai torrent.' },
        @{ Name = 'ShareX';               Id = 'ShareX.ShareX';                  Desc = 'Chup / quay man hinh nang cao.' },
        @{ Name = 'PowerToys';            Id = 'Microsoft.PowerToys';            Desc = 'Bo tien ich cua Microsoft.' },
        @{ Name = 'Everything';           Id = 'voidtools.Everything';           Desc = 'Tim file cuc nhanh.' },
        @{ Name = 'AnyDesk';              Id = 'AnyDeskSoftwareGmbH.AnyDesk';    Desc = 'Dieu khien may tinh tu xa.' },
        @{ Name = 'TeamViewer';           Id = 'TeamViewer.TeamViewer';          Desc = 'Dieu khien may tinh tu xa.' },
        @{ Name = 'Rufus';                Id = 'Rufus.Rufus';                    Desc = 'Tao USB cai Windows.' },
        @{ Name = 'Balena Etcher';        Id = 'Balena.Etcher';                  Desc = 'Ghi file ISO ra USB.' },
        @{ Name = 'WinDirStat';           Id = 'WinDirStat.WinDirStat';          Desc = 'Xem o dia bi day boi cai gi.' },
        @{ Name = 'Bulk Crap Uninstaller'; Id = 'Klocman.BulkCrapUninstaller';   Desc = 'Go cai dat phan mem sach se.' },
        @{ Name = 'Git';                  Id = 'Git.Git';                        Desc = 'Quan ly ma nguon.' },
        @{ Name = 'Visual Studio Code';   Id = 'Microsoft.VisualStudioCode';     Desc = 'Soan code cua Microsoft.' },
        @{ Name = 'Python 3.12';          Id = 'Python.Python.3.12';             Desc = 'Ngon ngu lap trinh Python.' },
        @{ Name = 'Node.js LTS';          Id = 'OpenJS.NodeJS.LTS';              Desc = 'Moi truong chay JavaScript.' }
    )},

    # ------------------------------------------------- THU VIEN / RUNTIME
    @{ Tab = 'Thu vien (Runtime)'; Type = 'winget'; Items = @(
        @{ Name = 'Visual C++ 2015-2022 (x64)'; Id = 'Microsoft.VCRedist.2015+.x64'; Desc = 'Can cho rat nhieu game va phan mem.'; Rec = $true },
        @{ Name = 'Visual C++ 2015-2022 (x86)'; Id = 'Microsoft.VCRedist.2015+.x86'; Desc = 'Ban 32-bit cua thu vien tren.'; Rec = $true },
        @{ Name = 'Visual C++ 2013 (x64)';      Id = 'Microsoft.VCRedist.2013.x64';  Desc = 'Cho game / phan mem doi cu.'; Rec = $true },
        @{ Name = 'Visual C++ 2013 (x86)';      Id = 'Microsoft.VCRedist.2013.x86';  Desc = 'Ban 32-bit.'; Rec = $true },
        @{ Name = 'Visual C++ 2012 (x64)';      Id = 'Microsoft.VCRedist.2012.x64';  Desc = 'Cho game / phan mem doi cu.'; Rec = $true },
        @{ Name = 'Visual C++ 2012 (x86)';      Id = 'Microsoft.VCRedist.2012.x86';  Desc = 'Ban 32-bit.'; Rec = $true },
        @{ Name = 'Visual C++ 2010 (x64)';      Id = 'Microsoft.VCRedist.2010.x64';  Desc = 'Cho game / phan mem doi cu.' },
        @{ Name = 'Visual C++ 2010 (x86)';      Id = 'Microsoft.VCRedist.2010.x86';  Desc = 'Ban 32-bit.' },
        @{ Name = 'Visual C++ 2008 (x64)';      Id = 'Microsoft.VCRedist.2008.x64';  Desc = 'Cho game / phan mem rat cu.' },
        @{ Name = 'Visual C++ 2008 (x86)';      Id = 'Microsoft.VCRedist.2008.x86';  Desc = 'Ban 32-bit.' },
        @{ Name = 'Visual C++ 2005 (x64)';      Id = 'Microsoft.VCRedist.2005.x64';  Desc = 'Cho game / phan mem rat cu.' },
        @{ Name = 'Visual C++ 2005 (x86)';      Id = 'Microsoft.VCRedist.2005.x86';  Desc = 'Ban 32-bit.' },
        @{ Name = '.NET Desktop Runtime 8';     Id = 'Microsoft.DotNet.DesktopRuntime.8'; Desc = 'Chay cac app .NET moi.'; Rec = $true },
        @{ Name = '.NET Desktop Runtime 6';     Id = 'Microsoft.DotNet.DesktopRuntime.6'; Desc = 'Chay cac app .NET 6.'; Rec = $true },
        @{ Name = 'DirectX End-User Runtime';   Id = 'Microsoft.DirectX';            Desc = 'Cac file DirectX cho game cu (d3dx9...).'; Rec = $true },
        @{ Name = 'WebView2 Runtime';           Id = 'Microsoft.EdgeWebView2Runtime'; Desc = 'Nhieu app hien dai can thu vien nay.'; Rec = $true },
        @{ Name = 'Java Runtime 17 (Temurin)';  Id = 'EclipseAdoptium.Temurin.17.JRE'; Desc = 'Chay app Java, Minecraft...' }
    )},

    # ------------------------------------------------ DRIVER / PHAN CUNG
    @{ Tab = 'Driver - Phan cung'; Type = 'winget'; Items = @(
        @{ Name = 'NVIDIA GeForce Experience'; Id = 'Nvidia.GeForceExperience';  Desc = 'Cap nhat driver card NVIDIA.' },
        @{ Name = 'Intel Driver & Support Assistant'; Id = 'Intel.IntelDriverAndSupportAssistant'; Desc = 'Tu tim driver cho phan cung Intel.' },
        @{ Name = 'CPU-Z';                Id = 'CPUID.CPU-Z';                    Desc = 'Xem thong tin CPU, RAM, mainboard.' },
        @{ Name = 'GPU-Z';                Id = 'TechPowerUp.GPU-Z';              Desc = 'Xem thong tin card do hoa.' },
        @{ Name = 'HWiNFO';               Id = 'REALiX.HWiNFO';                  Desc = 'Giam sat nhiet do, phan cung chi tiet.' },
        @{ Name = 'CrystalDiskInfo';      Id = 'CrystalDewWorld.CrystalDiskInfo'; Desc = 'Kiem tra suc khoe o cung / SSD.' },
        @{ Name = 'MSI Afterburner';      Id = 'Guru3D.Afterburner';             Desc = 'Ep xung / theo doi card do hoa.' }
    )},

    # ------------------------------------------------------- TINH CHINH
    @{ Tab = 'Tinh chinh'; Type = 'script'; Items = @(
        @{ Name = 'Tao diem khoi phuc he thong'; Desc = 'NEN LAM TRUOC TIEN: de quay lai neu co gi hong.'; Rec = $true
           Run  = { Enable-ComputerRestore -Drive "$env:SystemDrive\"; Checkpoint-Computer -Description 'NGSetup' -RestorePointType MODIFY_SETTINGS; 'Da tao diem khoi phuc.' } },

        @{ Name = 'Hien duoi file (.txt, .exe...)'; Desc = 'Hien phan mo rong cua ten file trong Explorer.'; Rec = $true
           Run  = { Set-ItemProperty $Adv HideFileExt 0; Stop-Process -Name explorer -Force }
           Undo = { Set-ItemProperty $Adv HideFileExt 1; Stop-Process -Name explorer -Force } },

        @{ Name = 'Hien file va thu muc an'; Desc = 'Hien cac file an trong Explorer.'
           Run  = { Set-ItemProperty $Adv Hidden 1; Stop-Process -Name explorer -Force }
           Undo = { Set-ItemProperty $Adv Hidden 2; Stop-Process -Name explorer -Force } },

        @{ Name = 'Hien icon This PC / User tren Desktop'; Desc = 'Dua icon My Computer va thu muc nguoi dung ra man hinh.'; Rec = $true
           Run  = { $p = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'; New-Item $p -Force | Out-Null
                    Set-ItemProperty $p '{20D04FE0-3AEA-1069-A2D8-08002B30309D}' 0 -Type DWord
                    Set-ItemProperty $p '{59031a47-3f72-44a7-89c5-5595fe6b30ee}' 0 -Type DWord; Stop-Process -Name explorer -Force }
           Undo = { $p = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'
                    Set-ItemProperty $p '{20D04FE0-3AEA-1069-A2D8-08002B30309D}' 1 -Type DWord
                    Set-ItemProperty $p '{59031a47-3f72-44a7-89c5-5595fe6b30ee}' 1 -Type DWord; Stop-Process -Name explorer -Force } },

        @{ Name = 'Menu chuot phai kieu cu (Win 11)'; Desc = 'Dung menu chuot phai day du nhu Windows 10.'
           Run  = { New-Item 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32' -Force -Value '' | Out-Null; Stop-Process -Name explorer -Force }
           Undo = { Remove-Item 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}' -Recurse -Force; Stop-Process -Name explorer -Force } },

        @{ Name = 'Che do toi (Dark mode)'; Desc = 'Giao dien toi cho Windows va ung dung.'
           Run  = { Set-ItemProperty $Pers AppsUseLightTheme 0; Set-ItemProperty $Pers SystemUsesLightTheme 0 }
           Undo = { Set-ItemProperty $Pers AppsUseLightTheme 1; Set-ItemProperty $Pers SystemUsesLightTheme 1 } },

        @{ Name = 'Tat goi y web (Bing) trong o tim kiem Start'; Desc = 'Tim kiem Start chi hien ket qua tren may.'; Rec = $true
           Run  = { $p = 'HKCU:\Software\Policies\Microsoft\Windows\Explorer'; New-Item $p -Force | Out-Null; Set-ItemProperty $p DisableSearchBoxSuggestions 1 -Type DWord }
           Undo = { Remove-ItemProperty 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' -Name DisableSearchBoxSuggestions -ErrorAction SilentlyContinue } },

        @{ Name = 'An o tim kiem tren thanh taskbar'; Desc = 'Taskbar gon hon.'
           Run  = { Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' SearchboxTaskbarMode 0 -Type DWord }
           Undo = { Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' SearchboxTaskbarMode 1 -Type DWord } },

        @{ Name = 'An nut Task View tren taskbar'; Desc = 'Bot mot nut it dung.'
           Run  = { Set-ItemProperty $Adv ShowTaskViewButton 0 -Type DWord; Stop-Process -Name explorer -Force }
           Undo = { Set-ItemProperty $Adv ShowTaskViewButton 1 -Type DWord; Stop-Process -Name explorer -Force } },

        @{ Name = 'Tat quang cao / goi y app trong Start va Settings'; Desc = 'Tat app goi y tu cai va cac thong bao quang cao.'; Rec = $true
           Run  = { foreach ($n in 'SystemPaneSuggestionsEnabled','SilentInstalledAppsEnabled','SubscribedContent-338388Enabled','SubscribedContent-338389Enabled','SubscribedContent-310093Enabled','SubscribedContent-353694Enabled','SubscribedContent-353696Enabled') { Set-ItemProperty $CDM $n 0 -Type DWord } }
           Undo = { foreach ($n in 'SystemPaneSuggestionsEnabled','SilentInstalledAppsEnabled','SubscribedContent-338388Enabled','SubscribedContent-338389Enabled','SubscribedContent-310093Enabled','SubscribedContent-353694Enabled','SubscribedContent-353696Enabled') { Set-ItemProperty $CDM $n 1 -Type DWord } } },

        @{ Name = 'Tat Advertising ID'; Desc = 'Ngan app theo doi de quang cao.'; Rec = $true
           Run  = { $p = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo'; New-Item $p -Force | Out-Null; Set-ItemProperty $p Enabled 0 -Type DWord }
           Undo = { Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' Enabled 1 -Type DWord } },

        @{ Name = 'Giam gui du lieu chan doan (telemetry)'; Desc = 'Dat muc thu thap du lieu cua Windows xuong thap nhat.'
           Run  = { $p = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; New-Item $p -Force | Out-Null; Set-ItemProperty $p AllowTelemetry 0 -Type DWord }
           Undo = { Remove-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name AllowTelemetry -ErrorAction SilentlyContinue } },

        @{ Name = 'Tat tang toc chuot (Enhance pointer precision)'; Desc = 'Chuot di chuyen tuyen tinh, tot cho game. Hieu luc sau khi dang xuat / khoi dong lai.'
           Run  = { Set-ItemProperty 'HKCU:\Control Panel\Mouse' MouseSpeed '0'; Set-ItemProperty 'HKCU:\Control Panel\Mouse' MouseThreshold1 '0'; Set-ItemProperty 'HKCU:\Control Panel\Mouse' MouseThreshold2 '0' }
           Undo = { Set-ItemProperty 'HKCU:\Control Panel\Mouse' MouseSpeed '1'; Set-ItemProperty 'HKCU:\Control Panel\Mouse' MouseThreshold1 '6'; Set-ItemProperty 'HKCU:\Control Panel\Mouse' MouseThreshold2 '10' } },

        @{ Name = 'Tat bang hoi Sticky Keys (nhan Shift 5 lan)'; Desc = 'Het bi nhay cua so khi nhan Shift lien tuc trong game.'; Rec = $true
           Run  = { Set-ItemProperty 'HKCU:\Control Panel\Accessibility\StickyKeys' Flags '506' }
           Undo = { Set-ItemProperty 'HKCU:\Control Panel\Accessibility\StickyKeys' Flags '510' } },

        @{ Name = 'Che do nguon: High Performance'; Desc = 'May chay het cong suat (tieu thu dien nhieu hon).'
           Run  = { powercfg /setactive SCHEME_MIN; 'Da chuyen sang High Performance.' }
           Undo = { powercfg /setactive SCHEME_BALANCED; 'Da quay lai Balanced.' } },

        @{ Name = 'Tat Hibernate (giai phong o C)'; Desc = 'Xoa file hiberfil.sys, giai phong vai GB. Fast Startup cung se tat.'
           Run  = { powercfg /hibernate off; 'Da tat Hibernate.' }
           Undo = { powercfg /hibernate on; 'Da bat Hibernate.' } },

        @{ Name = 'Go app rac cua Windows'; Desc = 'Go: Bing News/Weather, Solitaire, Get Help, Feedback Hub, Clipchamp, Teams ca nhan... (khong co hoan tac, cai lai tu Store).'
           Run  = { $ds = 'Microsoft.BingNews','Microsoft.BingWeather','Microsoft.GetHelp','Microsoft.Getstarted','Microsoft.MicrosoftSolitaireCollection','Microsoft.WindowsFeedbackHub','Clipchamp.Clipchamp','MicrosoftTeams','Microsoft.People','Microsoft.549981C3F5F10'
                    foreach ($d in $ds) { Get-AppxPackage -Name $d -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue }; 'Da go xong.' } }
    )},

    # --------------------------------------------------------- HE THONG
    @{ Tab = 'He thong'; Type = 'script'; Items = @(
        @{ Name = 'Mo Windows Update'; Desc = 'Mo trang cap nhat de bam "Check for updates" (nen lam sau khi cai Windows).'
           Run  = { Start-Process 'ms-settings:windowsupdate'; 'Da mo Windows Update.' } },

        @{ Name = 'Bat .NET Framework 3.5'; Desc = 'Can cho game / phan mem doi cu. Can internet.'; Rec = $true
           Run  = { Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -All -NoRestart | Out-Null; 'Xong (co the can khoi dong lai).' } },

        @{ Name = 'Bat DirectPlay'; Desc = 'Can cho mot so game rat cu.'
           Run  = { Enable-WindowsOptionalFeature -Online -FeatureName DirectPlay -All -NoRestart | Out-Null; 'Xong (co the can khoi dong lai).' } },

        @{ Name = 'Bat WSL (Linux tren Windows)'; Desc = 'Bat tinh nang WSL va Virtual Machine Platform.'
           Run  = { Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart | Out-Null
                    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart | Out-Null; 'Xong, hay khoi dong lai may.' } },

        @{ Name = 'Bat Windows Sandbox'; Desc = 'May ao dung 1 lan de thu phan mem la (chi ban Pro/Enterprise).'
           Run  = { Enable-WindowsOptionalFeature -Online -FeatureName Containers-DisposableClientVM -All -NoRestart | Out-Null; 'Xong, hay khoi dong lai may.' } },

        @{ Name = 'Doi DNS sang Cloudflare (1.1.1.1)'; Desc = 'Thuong nhanh va on dinh hon DNS mac dinh cua nha mang.'
           Run  = { Get-NetAdapter | Where-Object Status -eq 'Up' | ForEach-Object { Set-DnsClientServerAddress -InterfaceIndex $_.ifIndex -ServerAddresses ('1.1.1.1','1.0.0.1') }
                    ipconfig /flushdns | Out-Null; 'Da doi DNS.' }
           Undo = { Get-NetAdapter | Where-Object Status -eq 'Up' | ForEach-Object { Set-DnsClientServerAddress -InterfaceIndex $_.ifIndex -ResetServerAddresses }
                    ipconfig /flushdns | Out-Null; 'Da tra DNS ve mac dinh.' } },

        @{ Name = 'Don file tam va thung rac'; Desc = 'Xoa file trong Temp (nguoi dung + Windows) va don thung rac.'; Rec = $true
           Run  = { Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
                    Remove-Item "$env:WINDIR\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
                    Clear-RecycleBin -Force -ErrorAction SilentlyContinue; 'Da don xong.' } },

        @{ Name = 'Sua loi he thong (SFC + DISM)'; Desc = 'Quet va sua file Windows bi hong. Mat khoang 10-30 phut.'
           Run  = { $a = (& dism.exe /Online /Cleanup-Image /RestoreHealth) -join "`n"; $b = (& sfc.exe /scannow) -join "`n"
                    ($a -replace "`0",'') ; ($b -replace "`0",'') } }
    )},

    # ----------------------------------------------- CONG CU CUA TOI
    #  Vi du: tai app cua ban (de file GiuMic.exe vao repo GitHub cua ban) roi chay.
    @{ Tab = 'Cong cu cua toi'; Type = 'script'; Items = @(
        @{ Name = 'Giu Mic (GiuMic.exe)'; Desc = 'Tu keo mic len khi bi tut. Can upload GiuMic.exe vao repo NGmods truoc.'
           Run  = { $f = "$env:LOCALAPPDATA\GiuMic.exe"; Invoke-WebRequest 'https://github.com/thinhnguyen02031-lang/NGmods/raw/main/GiuMic.exe' -OutFile $f -UseBasicParsing; Start-Process $f; 'Da chay GiuMic (xem icon canh dong ho).' }
           Undo = { Stop-Process -Name GiuMic -Force -ErrorAction SilentlyContinue; Remove-Item "$env:LOCALAPPDATA\GiuMic.exe" -Force -ErrorAction SilentlyContinue; 'Da go GiuMic.' } }
    )}
)
# ============================ HET DANH MUC ============================


# ---- 2. Winget: kiem tra / tu cai neu thieu ----
function Test-Winget { return [bool](Get-Command winget -ErrorAction SilentlyContinue) }

function Install-Winget {
    Write-Log 'Dang cai winget (App Installer), vui long cho...'
    $ProgressPreference = 'SilentlyContinue'
    $tmp = Join-Path $env:TEMP 'ngwinget'
    New-Item $tmp -ItemType Directory -Force | Out-Null

    $vclibs = Join-Path $tmp 'vclibs.appx'
    Invoke-WebRequest 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' -OutFile $vclibs -UseBasicParsing

    $zip = Join-Path $tmp 'xaml.zip'
    Invoke-WebRequest 'https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.8.6' -OutFile $zip -UseBasicParsing
    Expand-Archive $zip (Join-Path $tmp 'xaml') -Force
    $xaml = Get-ChildItem (Join-Path $tmp 'xaml') -Recurse -Filter 'Microsoft.UI.Xaml.2.8.appx' | Where-Object { $_.FullName -match 'x64' } | Select-Object -First 1

    $bundle = Join-Path $tmp 'winget.msixbundle'
    Invoke-WebRequest 'https://aka.ms/getwinget' -OutFile $bundle -UseBasicParsing

    Add-AppxPackage -Path $bundle -DependencyPath @($vclibs, $xaml.FullName)

    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User') + ";$env:LOCALAPPDATA\Microsoft\WindowsApps"
}

function Confirm-Winget {
    if (Test-Winget) { return $true }
    try { Install-Winget } catch { Write-Log "Khong cai duoc winget: $($_.Exception.Message)" }
    if (Test-Winget) { Write-Log 'Da cai xong winget.'; return $true }
    Write-Log "Hay mo Microsoft Store, tim 'App Installer' va cap nhat, roi chay lai."
    return $false
}

# ---- 3. Giao dien ----
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$form = New-Object System.Windows.Forms.Form
$form.Text = $Ten
$form.Size = New-Object System.Drawing.Size(900, 720)
$form.StartPosition = 'CenterScreen'
$form.Font = New-Object System.Drawing.Font('Segoe UI', 10)

$head = New-Object System.Windows.Forms.Label
$head.Dock = 'Top'
$head.Height = 34
$head.Padding = New-Object System.Windows.Forms.Padding(8, 8, 0, 0)
$head.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$head.Text = "$Ten  -  tick muc can dung roi bam nut o duoi.  Muc co san dau tick la 'khuyen dung'."

$tabs = New-Object System.Windows.Forms.TabControl
$tabs.Dock = 'Fill'

foreach ($t in $Catalog) {
    $page = New-Object System.Windows.Forms.TabPage
    $page.Text = $t.Tab

    $desc = New-Object System.Windows.Forms.Label
    $desc.Dock = 'Bottom'
    $desc.Height = 48
    $desc.Padding = New-Object System.Windows.Forms.Padding(6, 6, 6, 0)
    $desc.ForeColor = [System.Drawing.Color]::DimGray
    $desc.Text = 'Chon mot muc de xem mo ta.'

    $clb = New-Object System.Windows.Forms.CheckedListBox
    $clb.Dock = 'Fill'
    $clb.CheckOnClick = $true
    $clb.BorderStyle = 'None'
    $items = @($t.Items)
    for ($i = 0; $i -lt $items.Count; $i++) {
        [void]$clb.Items.Add($items[$i].Name, [bool]$items[$i].Rec)
    }
    $clb.Tag = @{ Items = $items; Type = $t.Type; Desc = $desc }
    $clb.Add_SelectedIndexChanged({
        param($s, $e)
        $i = $s.SelectedIndex
        if ($i -ge 0) { $s.Tag.Desc.Text = [string]$s.Tag.Items[$i].Desc }
    })

    $page.Controls.Add($clb)
    $page.Controls.Add($desc)
    $page.Tag = $clb
    [void]$tabs.TabPages.Add($page)
}

$bottom = New-Object System.Windows.Forms.Panel
$bottom.Dock = 'Bottom'
$bottom.Height = 270

$btnPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$btnPanel.Dock = 'Top'
$btnPanel.Height = 84
$btnPanel.Padding = New-Object System.Windows.Forms.Padding(6, 6, 0, 0)

function New-Btn($text, $w) {
    $b = New-Object System.Windows.Forms.Button
    $b.Text = $text
    $b.Width = $w
    $b.Height = 32
    return $b
}
$btnRun     = New-Btn 'Cai / Chay (tab nay)' 190
$btnUndo    = New-Btn 'Go / Hoan tac (tab nay)' 210
$btnRec     = New-Btn 'Chon khuyen dung' 160
$btnAll     = New-Btn 'Chon tat ca' 110
$btnNone    = New-Btn 'Bo chon' 90
$btnRunAll  = New-Btn 'CHAY TAT CA CAC TAB (muc da tick)' 330
$btnRunAll.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$btnPanel.Controls.AddRange(@($btnRun, $btnUndo, $btnRec, $btnAll, $btnNone, $btnRunAll))

$log = New-Object System.Windows.Forms.TextBox
$log.Multiline = $true
$log.ReadOnly = $true
$log.ScrollBars = 'Vertical'
$log.Dock = 'Fill'
$log.BackColor = [System.Drawing.Color]::FromArgb(24, 24, 24)
$log.ForeColor = [System.Drawing.Color]::Gainsboro
$log.Font = New-Object System.Drawing.Font('Consolas', 9.5)

$bottom.Controls.Add($log)
$bottom.Controls.Add($btnPanel)

$form.Controls.Add($tabs)
$form.Controls.Add($bottom)
$form.Controls.Add($head)
$tabs.BringToFront()

function Write-Log($text) {
    $log.AppendText("$text`r`n")
    [System.Windows.Forms.Application]::DoEvents()
}

# ---- 4. Thuc thi 1 muc ----
function Invoke-Entry($item, $type, [bool]$undo) {
    Write-Log ">> $($item.Name)"
    try {
        if ($type -eq 'winget') {
            if (-not (Confirm-Winget)) { Write-Log 'Bo qua (khong co winget).'; return $false }
            if ($undo) { $a = @('uninstall', '--id', $item.Id, '-e', '--silent', '--source', 'winget') }
            else       { $a = @('install', '--id', $item.Id, '-e', '--silent', '--source', 'winget', '--accept-package-agreements', '--accept-source-agreements') }
            & winget @a 2>&1 | ForEach-Object {
                $s = "$_".Trim()
                if ($s -and $s -notmatch '^[\-\\|/\s]+$') { Write-Log $s }
            }
            $code = $LASTEXITCODE
            if ($code -eq 0)           { Write-Log 'Xong.'; return $true }
            if ($code -eq -1978335189) { Write-Log 'Da co san / khong can lam gi.'; return $true }
            Write-Log "Winget bao loi, ma: $code (kiem tra lai Id trong danh muc)"
            return $false
        }
        else {
            $sb = if ($undo) { $item.Undo } else { $item.Run }
            if (-not $sb) { Write-Log '(muc nay khong co lenh tuong ung)'; return $true }
            $old = $ErrorActionPreference
            $ErrorActionPreference = 'Stop'
            try { $out = & $sb | Out-String } finally { $ErrorActionPreference = $old }
            if ($out.Trim()) { Write-Log $out.Trim() }
            Write-Log 'Xong.'
            return $true
        }
    }
    catch { Write-Log "LOI: $($_.Exception.Message)"; return $false }
}

function Invoke-Tabs($tabPages, [bool]$undo) {
    $todo = @()
    foreach ($pg in $tabPages) {
        $clb = $pg.Tag
        foreach ($i in @($clb.CheckedIndices)) { $todo += , @($clb.Tag.Items[$i], $clb.Tag.Type) }
    }
    if ($todo.Count -eq 0) { Write-Log 'Chua tick muc nao.'; return }

    foreach ($b in @($btnRun, $btnUndo, $btnRunAll)) { $b.Enabled = $false }
    $ok = 0; $fail = 0
    foreach ($job in $todo) {
        if (Invoke-Entry $job[0] $job[1] $undo) { $ok++ } else { $fail++ }
    }
    Write-Log "===== HOAN TAT: $ok thanh cong, $fail loi ====="
    foreach ($b in @($btnRun, $btnUndo, $btnRunAll)) { $b.Enabled = $true }
}

$btnRun.Add_Click({ Invoke-Tabs @($tabs.SelectedTab) $false })
$btnUndo.Add_Click({ Invoke-Tabs @($tabs.SelectedTab) $true })
$btnRunAll.Add_Click({ Invoke-Tabs @($tabs.TabPages) $false })

$btnRec.Add_Click({
    $clb = $tabs.SelectedTab.Tag
    for ($i = 0; $i -lt $clb.Items.Count; $i++) { $clb.SetItemChecked($i, [bool]$clb.Tag.Items[$i].Rec) }
})
$btnAll.Add_Click({
    $clb = $tabs.SelectedTab.Tag
    for ($i = 0; $i -lt $clb.Items.Count; $i++) { $clb.SetItemChecked($i, $true) }
})
$btnNone.Add_Click({
    $clb = $tabs.SelectedTab.Tag
    for ($i = 0; $i -lt $clb.Items.Count; $i++) { $clb.SetItemChecked($i, $false) }
})

Write-Log 'San sang.'
if (Test-Winget) { Write-Log 'Winget: da co.' } else { Write-Log 'Winget: chua co - se tu cai khi ban cai ung dung dau tien.' }
Write-Log "Goi y: vao tab 'Tinh chinh' chay 'Tao diem khoi phuc' truoc."
[void]$form.ShowDialog()
