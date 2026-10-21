# =====================================================================
#  NG SETUP v2 - bo cai dat sau khi cai Windows (1 file duy nhat)
#  Chay:  irm "https://raw.githubusercontent.com/thinhnguyen02031-lang/NGmods/main/NGSetup.ps1" | iex
#
#  MUON THEM DO VAO: keo xuong muc "DANH MUC", chon nhom can them roi chep 1 dong mau.
#    App winget : @{ Name='Ten'; Id='Ma.Winget'; Domain='trang-web.com'; Desc='Mo ta'; Rec=$true }
#                 (Domain dung de lay LOGO tu dong; Id tim bang: winget search ten-app)
#    Lenh       : @{ Name='Ten'; Desc='Mo ta'; Run={ lenh }; Undo={ lenh hoan tac }; Rec=$true }
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

function Remove-AppxSafe($name) {
    $p = Get-AppxPackage -Name $name -AllUsers -ErrorAction SilentlyContinue
    if ($p) { $p | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue; "Da go: $name" }
    else    { "Khong co san: $name" }
}

# ---- Script Giu Mic (chay ngam, duoc ghi ra file khi ban bam cai) ----
$MicScript = @'
# GiuMic - giu am luong micro khong duoi 80%
$NguongDuoi = 80
$MucDat     = 100
$ChuKyGiay  = 1
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
[Guid("5CDF2C82-841E-4546-9722-0CF74078229A"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioEndpointVolume {
    int RegisterControlChangeNotify(IntPtr p);
    int UnregisterControlChangeNotify(IntPtr p);
    int GetChannelCount(out uint c);
    int SetMasterVolumeLevel(float l, ref Guid ctx);
    int SetMasterVolumeLevelScalar(float l, ref Guid ctx);
    int GetMasterVolumeLevel(out float l);
    int GetMasterVolumeLevelScalar(out float l);
}
[Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDevice {
    int Activate(ref Guid iid, int clsCtx, IntPtr p, [MarshalAs(UnmanagedType.IUnknown)] out object o);
}
[Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDeviceEnumerator {
    int EnumAudioEndpoints(int flow, int mask, out IntPtr devs);
    int GetDefaultAudioEndpoint(int flow, int role, out IMMDevice dev);
}
[ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")]
class MMDeviceEnumerator { }
public static class Mic {
    static IAudioEndpointVolume Lay() {
        var en = (IMMDeviceEnumerator)(new MMDeviceEnumerator());
        IMMDevice dev;
        en.GetDefaultAudioEndpoint(1, 0, out dev);
        Guid iid = typeof(IAudioEndpointVolume).GUID;
        object o;
        dev.Activate(ref iid, 23, IntPtr.Zero, out o);
        return (IAudioEndpointVolume)o;
    }
    public static int Doc() { float v; Lay().GetMasterVolumeLevelScalar(out v); return (int)Math.Round(v * 100); }
    public static void Dat(int pt) { Guid g = Guid.Empty; Lay().SetMasterVolumeLevelScalar(pt / 100f, ref g); }
}
"@
while ($true) {
    try { if ([Mic]::Doc() -lt $NguongDuoi) { [Mic]::Dat($MucDat) } } catch {}
    Start-Sleep -Seconds $ChuKyGiay
}
'@

# =====================================================================
#                              DANH MUC
#  Moi nhom (Category) co: Group, Name, Sub, Glyph (icon), Color, Type, Items
#  Type = 'winget' (cai app) hoac 'script' (chay lenh)
#  Rec=$true -> duoc tick san khi mo bang ("khuyen dung")
# =====================================================================
$Catalog = @(

# ============================== UNG DUNG ==============================
@{ Group='UNG DUNG'; Name='Trinh duyet'; Sub='Chrome, Firefox, Brave, Coc Coc...'; Glyph='E774'; Color=@(79,140,255); Type='winget'; Items=@(
    @{ Name='Google Chrome';   Id='Google.Chrome';        Domain='google.com/chrome';  Desc='Trinh duyet pho bien nhat cua Google.'; Rec=$true },
    @{ Name='Mozilla Firefox'; Id='Mozilla.Firefox';      Domain='firefox.com';        Desc='Trinh duyet ma nguon mo, tap trung rieng tu.' },
    @{ Name='Brave';           Id='Brave.Brave';          Domain='brave.com';          Desc='Chan quang cao san, nhanh va rieng tu.' },
    @{ Name='Coc Coc';         Id='CocCoc.CocCoc';        Domain='coccoc.com';         Desc='Trinh duyet Viet, ho tro tai video tot.' },
    @{ Name='Microsoft Edge';  Id='Microsoft.Edge';       Domain='microsoft.com/edge'; Desc='Trinh duyet cua Microsoft.' },
    @{ Name='Opera';           Id='Opera.Opera';          Domain='opera.com';          Desc='Co VPN va thanh ben tien loi.' },
    @{ Name='Opera GX';        Id='Opera.OperaGX';        Domain='opera.com/gx';       Desc='Ban Opera danh cho game thu.' },
    @{ Name='Vivaldi';         Id='Vivaldi.Vivaldi';      Domain='vivaldi.com';        Desc='Trinh duyet tuy bien cuc manh.' }
)},

@{ Group='UNG DUNG'; Name='Game'; Sub='Steam, Epic, GOG, Battle.net, launcher...'; Glyph='E7FC'; Color=@(167,110,255); Type='winget'; Items=@(
    @{ Name='Steam';               Id='Valve.Steam';                         Domain='steampowered.com'; Desc='Nen tang game lon nhat the gioi.' },
    @{ Name='Epic Games Launcher'; Id='EpicGames.EpicGamesLauncher';         Domain='epicgames.com';    Desc='Nhan game mien phi moi tuan.' },
    @{ Name='GOG Galaxy';          Id='GOG.Galaxy';                          Domain='gog.com';          Desc='Game khong DRM, gop thu vien nhieu nen tang.' },
    @{ Name='EA app';              Id='ElectronicArts.EADesktop';            Domain='ea.com';           Desc='Launcher cua Electronic Arts.' },
    @{ Name='Ubisoft Connect';     Id='Ubisoft.Connect';                     Domain='ubisoft.com';      Desc='Launcher cua Ubisoft.' },
    @{ Name='Battle.net';          Id='Blizzard.BattleNet';                  Domain='battle.net';       Desc='Launcher cua Blizzard (WoW, Overwatch...).' },
    @{ Name='Playnite';            Id='Playnite.Playnite';                   Domain='playnite.link';    Desc='Quan ly tat ca game o mot noi.' },
    @{ Name='Heroic Games Launcher'; Id='HeroicGamesLauncher.HeroicGamesLauncher'; Domain='heroicgameslauncher.com'; Desc='Dung Epic / GOG ma khong can launcher goc.' },
    @{ Name='Minecraft Launcher';  Id='Mojang.MinecraftLauncher';            Domain='minecraft.net';    Desc='Launcher chinh thuc cua Minecraft.' },
    @{ Name='Prism Launcher';      Id='PrismLauncher.PrismLauncher';         Domain='prismlauncher.org'; Desc='Quan ly nhieu ban Minecraft va mod.' }
)},

@{ Group='UNG DUNG'; Name='Chat & Hop'; Sub='Zalo, Discord, Telegram, Zoom...'; Glyph='E8BD'; Color=@(52,199,143); Type='winget'; Items=@(
    @{ Name='Zalo';      Id='VNGCorp.Zalo';                    Domain='zalo.me';           Desc='Chat Zalo tren may tinh.' },
    @{ Name='Discord';   Id='Discord.Discord';                 Domain='discord.com';       Desc='Chat thoai va nhan tin cho game thu.' },
    @{ Name='Telegram';  Id='Telegram.TelegramDesktop';        Domain='telegram.org';      Desc='Nhan tin nhanh, an toan.' },
    @{ Name='WhatsApp';  Id='WhatsApp.WhatsApp';               Domain='whatsapp.com';      Desc='Nhan tin WhatsApp.' },
    @{ Name='Viber';     Id='Viber.Viber';                     Domain='viber.com';         Desc='Goi va nhan tin Viber.' },
    @{ Name='Signal';    Id='OpenWhisperSystems.Signal';       Domain='signal.org';        Desc='Nhan tin ma hoa dau cuoi.' },
    @{ Name='Slack';     Id='SlackTechnologies.Slack';         Domain='slack.com';         Desc='Lam viec nhom.' },
    @{ Name='Zoom';      Id='Zoom.Zoom';                       Domain='zoom.us';           Desc='Hop truc tuyen.' },
    @{ Name='Microsoft Teams'; Id='Microsoft.Teams';           Domain='teams.microsoft.com'; Desc='Hop va lam viec nhom cua Microsoft.' }
)},

@{ Group='UNG DUNG'; Name='Media & Sang tao'; Sub='VLC, OBS, Spotify, GIMP, Blender...'; Glyph='E714'; Color=@(255,120,90); Type='winget'; Items=@(
    @{ Name='VLC Media Player';  Id='VideoLAN.VLC';                       Domain='videolan.org';      Desc='Phat moi loai video, nhac.'; Rec=$true },
    @{ Name='PotPlayer';         Id='Daum.PotPlayer';                     Domain='potplayer.daum.net'; Desc='Trinh phat video manh, nhieu tuy chinh.' },
    @{ Name='MPC-HC';            Id='clsid2.mpc-hc';                      Domain='mpc-hc.org';        Desc='Trinh phat video nhe.' },
    @{ Name='K-Lite Codec Pack'; Id='CodecGuide.K-LiteCodecPack.Standard'; Domain='codecguide.com';   Desc='Bo codec de xem moi dinh dang.' },
    @{ Name='Spotify';           Id='Spotify.Spotify';                    Domain='spotify.com';       Desc='Nghe nhac truc tuyen.' },
    @{ Name='OBS Studio';        Id='OBSProject.OBSStudio';               Domain='obsproject.com';    Desc='Quay va livestream man hinh.' },
    @{ Name='Streamlabs';        Id='Streamlabs.Streamlabs';              Domain='streamlabs.com';    Desc='Livestream de dung.' },
    @{ Name='Audacity';          Id='Audacity.Audacity';                  Domain='audacityteam.org';  Desc='Thu va chinh sua am thanh.' },
    @{ Name='HandBrake';         Id='HandBrake.HandBrake';                Domain='handbrake.fr';      Desc='Chuyen doi, nen video.' },
    @{ Name='GIMP';              Id='GIMP.GIMP';                          Domain='gimp.org';          Desc='Chinh sua anh mien phi (nhu Photoshop).' },
    @{ Name='Krita';             Id='KDE.Krita';                          Domain='krita.org';         Desc='Ve ky thuat so.' },
    @{ Name='Blender';           Id='BlenderFoundation.Blender';          Domain='blender.org';       Desc='Dung hinh 3D va lam phim hoat hinh.' },
    @{ Name='Paint.NET';         Id='dotPDN.PaintDotNet';                 Domain='getpaint.net';      Desc='Chinh anh don gian, nhanh.' },
    @{ Name='IrfanView';         Id='IrfanSkiljan.IrfanView';             Domain='irfanview.com';     Desc='Xem anh sieu nhe.' }
)},

@{ Group='UNG DUNG'; Name='Van phong & Luu tru'; Sub='PDF, Office, ghi chu, dam may...'; Glyph='E8A5'; Color=@(255,196,60); Type='winget'; Items=@(
    @{ Name='Adobe Acrobat Reader'; Id='Adobe.Acrobat.Reader.64-bit'; Domain='adobe.com';             Desc='Doc va ky file PDF.' },
    @{ Name='SumatraPDF';  Id='SumatraPDF.SumatraPDF';          Domain='sumatrapdfreader.org';  Desc='Doc PDF sieu nhe.' },
    @{ Name='Foxit Reader'; Id='Foxit.FoxitReader';             Domain='foxit.com';             Desc='Doc PDF nhe, nhieu tinh nang.' },
    @{ Name='LibreOffice'; Id='TheDocumentFoundation.LibreOffice'; Domain='libreoffice.org';    Desc='Bo Office mien phi (Word, Excel, PowerPoint).' },
    @{ Name='Obsidian';    Id='Obsidian.Obsidian';              Domain='obsidian.md';           Desc='Ghi chu dang lien ket.' },
    @{ Name='Notion';      Id='Notion.Notion';                  Domain='notion.so';             Desc='Ghi chu va quan ly cong viec.' },
    @{ Name='Google Drive'; Id='Google.GoogleDrive';            Domain='drive.google.com';      Desc='Dong bo file voi Google Drive.' },
    @{ Name='Dropbox';     Id='Dropbox.Dropbox';                Domain='dropbox.com';           Desc='Luu tru va dong bo file.' }
)},

@{ Group='UNG DUNG'; Name='Lap trinh'; Sub='Git, VS Code, Python, Node, Docker...'; Glyph='E943'; Color=@(70,190,230); Type='winget'; Items=@(
    @{ Name='Visual Studio Code'; Id='Microsoft.VisualStudioCode'; Domain='code.visualstudio.com'; Desc='Trinh soan code pho bien.' },
    @{ Name='Git';                Id='Git.Git';                    Domain='git-scm.com';           Desc='Quan ly phien ban ma nguon.' },
    @{ Name='GitHub Desktop';     Id='GitHub.GitHubDesktop';       Domain='desktop.github.com';    Desc='Dung Git bang giao dien do hoa.' },
    @{ Name='Notepad++';          Id='Notepad++.Notepad++';        Domain='notepad-plus-plus.org'; Desc='Soan thao van ban va code nhe.'; Rec=$true },
    @{ Name='Python 3.12';        Id='Python.Python.3.12';         Domain='python.org';            Desc='Ngon ngu lap trinh Python.' },
    @{ Name='Node.js LTS';        Id='OpenJS.NodeJS.LTS';          Domain='nodejs.org';            Desc='Moi truong chay JavaScript.' },
    @{ Name='Visual Studio 2022 Community'; Id='Microsoft.VisualStudio.2022.Community'; Domain='visualstudio.microsoft.com'; Desc='IDE day du cua Microsoft.' },
    @{ Name='Java JDK 21 (Temurin)'; Id='EclipseAdoptium.Temurin.21.JDK'; Domain='adoptium.net';  Desc='Bo phat trien Java.' },
    @{ Name='Docker Desktop';     Id='Docker.DockerDesktop';       Domain='docker.com';            Desc='Chay container.' },
    @{ Name='Postman';            Id='Postman.Postman';            Domain='postman.com';           Desc='Thu nghiem API.' },
    @{ Name='Windows Terminal';   Id='Microsoft.WindowsTerminal';  Domain='microsoft.com/windows'; Desc='Terminal hien dai.' },
    @{ Name='PowerShell 7';       Id='Microsoft.PowerShell';       Domain='microsoft.com/powershell'; Desc='PowerShell ban moi.' },
    @{ Name='Android Studio';     Id='Google.AndroidStudio';       Domain='developer.android.com'; Desc='Lap trinh ung dung Android.' },
    @{ Name='Go';                 Id='GoLang.Go';                  Domain='go.dev';                Desc='Ngon ngu Go.' },
    @{ Name='Rust (rustup)';      Id='Rustlang.Rustup';            Domain='rust-lang.org';         Desc='Ngon ngu Rust.' },
    @{ Name='PuTTY';              Id='PuTTY.PuTTY';                Domain='putty.org';             Desc='Ket noi SSH.' },
    @{ Name='WinSCP';             Id='WinSCP.WinSCP';              Domain='winscp.net';            Desc='Chuyen file qua SFTP / SCP.' },
    @{ Name='FileZilla';          Id='TimKosse.FileZilla.Client';  Domain='filezilla-project.org'; Desc='Client FTP.' }
)},

@{ Group='UNG DUNG'; Name='Tien ich'; Sub='7-Zip, PowerToys, Rufus, AnyDesk...'; Glyph='E71D'; Color=@(120,200,120); Type='winget'; Items=@(
    @{ Name='7-Zip';       Id='7zip.7zip';                       Domain='7-zip.org';        Desc='Nen / giai nen file mien phi.'; Rec=$true },
    @{ Name='WinRAR';      Id='RARLab.WinRAR';                   Domain='rarlab.com';       Desc='Giai nen rar, zip.' },
    @{ Name='NanaZip';     Id='M2Team.NanaZip';                  Domain='apps.microsoft.com'; Desc='Ban 7-Zip giao dien Windows 11.' },
    @{ Name='PowerToys';   Id='Microsoft.PowerToys';             Domain='learn.microsoft.com/windows/powertoys'; Desc='Bo tien ich cua Microsoft.' },
    @{ Name='Everything';  Id='voidtools.Everything';            Domain='voidtools.com';    Desc='Tim file tuc thi.' },
    @{ Name='ShareX';      Id='ShareX.ShareX';                   Domain='getsharex.com';    Desc='Chup, quay man hinh nang cao.' },
    @{ Name='Greenshot';   Id='Greenshot.Greenshot';             Domain='getgreenshot.org'; Desc='Chup man hinh nhe, ve chu thich.' },
    @{ Name='qBittorrent'; Id='qBittorrent.qBittorrent';         Domain='qbittorrent.org';  Desc='Tai torrent, khong quang cao.' },
    @{ Name='AnyDesk';     Id='AnyDeskSoftwareGmbH.AnyDesk';     Domain='anydesk.com';      Desc='Dieu khien may tinh tu xa.' },
    @{ Name='TeamViewer';  Id='TeamViewer.TeamViewer';           Domain='teamviewer.com';   Desc='Dieu khien may tinh tu xa.' },
    @{ Name='Rufus';       Id='Rufus.Rufus';                     Domain='rufus.ie';         Desc='Tao USB cai Windows.' },
    @{ Name='Ventoy';      Id='Ventoy.Ventoy';                   Domain='ventoy.net';       Desc='USB boot nhieu file ISO.' },
    @{ Name='Balena Etcher'; Id='Balena.Etcher';                 Domain='etcher.balena.io'; Desc='Ghi file ISO ra USB.' },
    @{ Name='WinDirStat';  Id='WinDirStat.WinDirStat';           Domain='windirstat.net';   Desc='Xem o dia bi chiem boi gi.' },
    @{ Name='Bulk Crap Uninstaller'; Id='Klocman.BulkCrapUninstaller'; Domain='bcuninstaller.com'; Desc='Go phan mem sach se.' },
    @{ Name='Sysinternals Process Explorer'; Id='Microsoft.Sysinternals.ProcessExplorer'; Domain='learn.microsoft.com/sysinternals'; Desc='Quan ly tien trinh nang cao.' },
    @{ Name='Bitwarden';   Id='Bitwarden.Bitwarden';             Domain='bitwarden.com';    Desc='Quan ly mat khau.' },
    @{ Name='f.lux';       Id='flux.flux';                       Domain='justgetflux.com';  Desc='Giam anh sang xanh ban dem.' },
    @{ Name='Proton VPN';  Id='Proton.ProtonVPN';                Domain='protonvpn.com';    Desc='VPN co goi mien phi.' },
    @{ Name='Cloudflare WARP'; Id='Cloudflare.Warp';             Domain='cloudflare.com';   Desc='VPN / DNS an toan cua Cloudflare.' }
)},

@{ Group='UNG DUNG'; Name='Am thanh & Mic'; Sub='Giu Mic khong bi tut am luong...'; Glyph='E720'; Color=@(255,95,140); Type='script'; Items=@(
    @{ Name='Giu Mic (tu keo len khi duoi 80%)'; Desc='Chay ngam, moi giay kiem tra mic va tu keo len 100% neu tut duoi 80%.'
       Run  = { $d = "$env:LOCALAPPDATA\NGSetup"; New-Item $d -ItemType Directory -Force | Out-Null
                $f = "$d\GiuMic.ps1"; Set-Content -Path $f -Value $MicScript -Encoding UTF8
                Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -like '*GiuMic.ps1*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
                Start-Process powershell.exe -WindowStyle Hidden -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',$f
                'Da chay ngam. Mic duoi 80% se tu keo len 100%.' }
       Undo = { Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -like '*GiuMic.ps1*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
                Remove-Item "$env:LOCALAPPDATA\NGSetup\GiuMic.ps1" -Force -ErrorAction SilentlyContinue; 'Da tat va xoa Giu Mic.' } },

    @{ Name='Giu Mic: tu chay cung Windows'; Desc='Tao tac vu tu chay Giu Mic moi khi dang nhap (can cai muc tren truoc).'
       Run  = { $f = "$env:LOCALAPPDATA\NGSetup\GiuMic.ps1"
                if (-not (Test-Path $f)) { throw 'Hay cai muc "Giu Mic" ben tren truoc.' }
                $a = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$f`""
                $t = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
                $p = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
                Register-ScheduledTask -TaskName 'NGSetup-GiuMic' -Action $a -Trigger $t -Principal $p -Force | Out-Null
                'Da bat tu chay cung Windows.' }
       Undo = { Unregister-ScheduledTask -TaskName 'NGSetup-GiuMic' -Confirm:$false -ErrorAction SilentlyContinue; 'Da tat tu chay cung Windows.' } },

    @{ Name='Mo cai dat thiet bi thu am'; Desc='Mo bang Recording devices de chinh mic thu cong.'
       Run  = { Start-Process control.exe -ArgumentList 'mmsys.cpl,,1'; 'Da mo.' } },

    @{ Name='Mo cai dat am thanh Windows'; Desc='Mo trang Sound trong Settings.'
       Run  = { Start-Process 'ms-settings:sound'; 'Da mo.' } }
)},

# ======================== THU VIEN & DRIVER ===========================
@{ Group='THU VIEN & DRIVER'; Name='Thu vien (Runtime)'; Sub='Visual C++, .NET, DirectX, Java - game va app can'; Glyph='E8F1'; Color=@(130,150,255); Type='winget'; Items=@(
    @{ Name='Visual C++ 2015-2022 (x64)'; Id='Microsoft.VCRedist.2015+.x64'; Domain='visualstudio.microsoft.com'; Desc='Can cho rat nhieu game va phan mem.'; Rec=$true },
    @{ Name='Visual C++ 2015-2022 (x86)'; Id='Microsoft.VCRedist.2015+.x86'; Domain='visualstudio.microsoft.com'; Desc='Ban 32-bit cua thu vien tren.'; Rec=$true },
    @{ Name='Visual C++ 2013 (x64)';      Id='Microsoft.VCRedist.2013.x64';  Domain='visualstudio.microsoft.com'; Desc='Cho game / phan mem doi cu.'; Rec=$true },
    @{ Name='Visual C++ 2013 (x86)';      Id='Microsoft.VCRedist.2013.x86';  Domain='visualstudio.microsoft.com'; Desc='Ban 32-bit.'; Rec=$true },
    @{ Name='Visual C++ 2012 (x64)';      Id='Microsoft.VCRedist.2012.x64';  Domain='visualstudio.microsoft.com'; Desc='Cho game / phan mem doi cu.'; Rec=$true },
    @{ Name='Visual C++ 2012 (x86)';      Id='Microsoft.VCRedist.2012.x86';  Domain='visualstudio.microsoft.com'; Desc='Ban 32-bit.'; Rec=$true },
    @{ Name='Visual C++ 2010 (x64)';      Id='Microsoft.VCRedist.2010.x64';  Domain='visualstudio.microsoft.com'; Desc='Cho game / phan mem doi cu.' },
    @{ Name='Visual C++ 2010 (x86)';      Id='Microsoft.VCRedist.2010.x86';  Domain='visualstudio.microsoft.com'; Desc='Ban 32-bit.' },
    @{ Name='Visual C++ 2008 (x64)';      Id='Microsoft.VCRedist.2008.x64';  Domain='visualstudio.microsoft.com'; Desc='Cho game / phan mem rat cu.' },
    @{ Name='Visual C++ 2008 (x86)';      Id='Microsoft.VCRedist.2008.x86';  Domain='visualstudio.microsoft.com'; Desc='Ban 32-bit.' },
    @{ Name='Visual C++ 2005 (x64)';      Id='Microsoft.VCRedist.2005.x64';  Domain='visualstudio.microsoft.com'; Desc='Cho game / phan mem rat cu.' },
    @{ Name='Visual C++ 2005 (x86)';      Id='Microsoft.VCRedist.2005.x86';  Domain='visualstudio.microsoft.com'; Desc='Ban 32-bit.' },
    @{ Name='.NET Desktop Runtime 8';     Id='Microsoft.DotNet.DesktopRuntime.8'; Domain='dotnet.microsoft.com'; Desc='Chay cac app .NET moi.'; Rec=$true },
    @{ Name='.NET Desktop Runtime 6';     Id='Microsoft.DotNet.DesktopRuntime.6'; Domain='dotnet.microsoft.com'; Desc='Chay cac app .NET 6.'; Rec=$true },
    @{ Name='DirectX End-User Runtime';   Id='Microsoft.DirectX';            Domain='microsoft.com';              Desc='File DirectX cho game cu (d3dx9...).'; Rec=$true },
    @{ Name='WebView2 Runtime';           Id='Microsoft.EdgeWebView2Runtime'; Domain='microsoft.com/edge';        Desc='Nhieu app hien dai can thu vien nay.'; Rec=$true },
    @{ Name='Java Runtime 17 (Temurin)';  Id='EclipseAdoptium.Temurin.17.JRE'; Domain='adoptium.net';             Desc='Chay app Java, Minecraft...' }
)},

@{ Group='THU VIEN & DRIVER'; Name='Driver & Phan cung'; Sub='NVIDIA, Intel, AMD, theo doi nhiet do, o cung...'; Glyph='EDA2'; Color=@(118,185,0); Type='winget'; Items=@(
    @{ Name='NVIDIA GeForce Experience'; Id='Nvidia.GeForceExperience'; Domain='nvidia.com'; Desc='Cap nhat driver card NVIDIA.' },
    @{ Name='Intel Driver & Support Assistant'; Id='Intel.IntelDriverAndSupportAssistant'; Domain='intel.com'; Desc='Tu tim driver cho phan cung Intel.' },
    @{ Name='CPU-Z';           Id='CPUID.CPU-Z';                     Domain='cpuid.com';        Desc='Xem thong tin CPU, RAM, mainboard.' },
    @{ Name='GPU-Z';           Id='TechPowerUp.GPU-Z';               Domain='techpowerup.com';  Desc='Xem thong tin card do hoa.' },
    @{ Name='HWiNFO';          Id='REALiX.HWiNFO';                   Domain='hwinfo.com';       Desc='Giam sat nhiet do, phan cung chi tiet.' },
    @{ Name='CrystalDiskInfo'; Id='CrystalDewWorld.CrystalDiskInfo'; Domain='crystalmark.info'; Desc='Kiem tra suc khoe o cung / SSD.' },
    @{ Name='MSI Afterburner'; Id='Guru3D.Afterburner';              Domain='msi.com';          Desc='Ep xung, theo doi card do hoa.' },
    @{ Name='Logitech G HUB';  Id='Logitech.GHUB';                   Domain='logitechg.com';    Desc='Chinh chuot / ban phim Logitech G.' },
    @{ Name='SteelSeries GG';  Id='SteelSeries.GG';                  Domain='steelseries.com';  Desc='Chinh thiet bi SteelSeries.' },
    @{ Name='Tai driver AMD (mo trang web)'; Domain='amd.com'; Desc='Mo trang tai driver chinh thuc cua AMD.'; Glyph='E774'
       Run = { Start-Process 'https://www.amd.com/en/support/download/drivers.html'; 'Da mo trang AMD.' } }
)},

# ============================= TINH CHINH =============================
@{ Group='TINH CHINH'; Name='Giao dien & Explorer'; Sub='Hien duoi file, dark mode, menu chuot phai...'; Glyph='E771'; Color=@(79,140,255); Type='script'; Items=@(
    @{ Name='Hien duoi file (.txt, .exe...)'; Desc='Hien phan mo rong cua ten file trong Explorer.'; Rec=$true
       Run  = { Set-ItemProperty $Adv HideFileExt 0; Stop-Process -Name explorer -Force }
       Undo = { Set-ItemProperty $Adv HideFileExt 1; Stop-Process -Name explorer -Force } },
    @{ Name='Hien file va thu muc an'; Desc='Hien cac file an trong Explorer.'
       Run  = { Set-ItemProperty $Adv Hidden 1; Stop-Process -Name explorer -Force }
       Undo = { Set-ItemProperty $Adv Hidden 2; Stop-Process -Name explorer -Force } },
    @{ Name='Hien icon This PC / User tren Desktop'; Desc='Dua icon My Computer va thu muc nguoi dung ra man hinh.'; Rec=$true
       Run  = { $p = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'; New-Item $p -Force | Out-Null
                Set-ItemProperty $p '{20D04FE0-3AEA-1069-A2D8-08002B30309D}' 0 -Type DWord
                Set-ItemProperty $p '{59031a47-3f72-44a7-89c5-5595fe6b30ee}' 0 -Type DWord; Stop-Process -Name explorer -Force }
       Undo = { $p = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'
                Set-ItemProperty $p '{20D04FE0-3AEA-1069-A2D8-08002B30309D}' 1 -Type DWord
                Set-ItemProperty $p '{59031a47-3f72-44a7-89c5-5595fe6b30ee}' 1 -Type DWord; Stop-Process -Name explorer -Force } },
    @{ Name='Menu chuot phai kieu cu (Win 11)'; Desc='Dung menu chuot phai day du nhu Windows 10.'
       Run  = { New-Item 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32' -Force -Value '' | Out-Null; Stop-Process -Name explorer -Force }
       Undo = { Remove-Item 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}' -Recurse -Force; Stop-Process -Name explorer -Force } },
    @{ Name='Che do toi (Dark mode)'; Desc='Giao dien toi cho Windows va ung dung.'
       Run  = { Set-ItemProperty $Pers AppsUseLightTheme 0; Set-ItemProperty $Pers SystemUsesLightTheme 0 }
       Undo = { Set-ItemProperty $Pers AppsUseLightTheme 1; Set-ItemProperty $Pers SystemUsesLightTheme 1 } },
    @{ Name='An o tim kiem tren taskbar'; Desc='Taskbar gon hon.'
       Run  = { Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' SearchboxTaskbarMode 0 -Type DWord }
       Undo = { Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' SearchboxTaskbarMode 1 -Type DWord } },
    @{ Name='An nut Task View tren taskbar'; Desc='Bot mot nut it dung.'
       Run  = { Set-ItemProperty $Adv ShowTaskViewButton 0 -Type DWord; Stop-Process -Name explorer -Force }
       Undo = { Set-ItemProperty $Adv ShowTaskViewButton 1 -Type DWord; Stop-Process -Name explorer -Force } }
)},

@{ Group='TINH CHINH'; Name='Rieng tu & Quang cao'; Sub='Tat quang cao, goi y Bing, theo doi...'; Glyph='E72E'; Color=@(255,95,95); Type='script'; Items=@(
    @{ Name='Tat goi y web (Bing) trong o tim kiem Start'; Desc='Tim kiem Start chi hien ket qua tren may.'; Rec=$true
       Run  = { $p = 'HKCU:\Software\Policies\Microsoft\Windows\Explorer'; New-Item $p -Force | Out-Null; Set-ItemProperty $p DisableSearchBoxSuggestions 1 -Type DWord }
       Undo = { Remove-ItemProperty 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' -Name DisableSearchBoxSuggestions -ErrorAction SilentlyContinue } },
    @{ Name='Tat quang cao / goi y app trong Start va Settings'; Desc='Tat app goi y tu cai va cac thong bao quang cao.'; Rec=$true
       Run  = { foreach ($n in 'SystemPaneSuggestionsEnabled','SilentInstalledAppsEnabled','SubscribedContent-338388Enabled','SubscribedContent-338389Enabled','SubscribedContent-310093Enabled','SubscribedContent-353694Enabled','SubscribedContent-353696Enabled') { Set-ItemProperty $CDM $n 0 -Type DWord } }
       Undo = { foreach ($n in 'SystemPaneSuggestionsEnabled','SilentInstalledAppsEnabled','SubscribedContent-338388Enabled','SubscribedContent-338389Enabled','SubscribedContent-310093Enabled','SubscribedContent-353694Enabled','SubscribedContent-353696Enabled') { Set-ItemProperty $CDM $n 1 -Type DWord } } },
    @{ Name='Tat Advertising ID'; Desc='Ngan app theo doi de quang cao.'; Rec=$true
       Run  = { $p = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo'; New-Item $p -Force | Out-Null; Set-ItemProperty $p Enabled 0 -Type DWord }
       Undo = { Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' Enabled 1 -Type DWord } },
    @{ Name='Giam gui du lieu chan doan (telemetry)'; Desc='Dat muc thu thap du lieu cua Windows xuong thap nhat.'
       Run  = { $p = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; New-Item $p -Force | Out-Null; Set-ItemProperty $p AllowTelemetry 0 -Type DWord }
       Undo = { Remove-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name AllowTelemetry -ErrorAction SilentlyContinue } }
)},

@{ Group='TINH CHINH'; Name='Hieu nang & Game'; Sub='Power plan, chuot, Game Mode, GPU scheduling...'; Glyph='E945'; Color=@(255,170,40); Type='script'; Items=@(
    @{ Name='Che do nguon: High Performance'; Desc='May chay het cong suat (tieu thu dien nhieu hon).'
       Run  = { powercfg /setactive SCHEME_MIN; 'Da chuyen sang High Performance.' }
       Undo = { powercfg /setactive SCHEME_BALANCED; 'Da quay lai Balanced.' } },
    @{ Name='Bat Game Mode'; Desc='Windows uu tien tai nguyen cho game dang chay.'; Rec=$true
       Run  = { $p = 'HKCU:\Software\Microsoft\GameBar'; New-Item $p -Force | Out-Null; Set-ItemProperty $p AutoGameModeEnabled 1 -Type DWord; Set-ItemProperty $p AllowAutoGameMode 1 -Type DWord }
       Undo = { Set-ItemProperty 'HKCU:\Software\Microsoft\GameBar' AutoGameModeEnabled 0 -Type DWord } },
    @{ Name='Bat GPU Scheduling (HAGS)'; Desc='Lap lich GPU bang phan cung, can card do hoa doi moi. Khoi dong lai de ap dung.'
       Run  = { Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' HwSchMode 2 -Type DWord; 'Xong, hay khoi dong lai may.' }
       Undo = { Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' HwSchMode 1 -Type DWord; 'Xong, hay khoi dong lai may.' } },
    @{ Name='Tat tang toc chuot (Enhance pointer precision)'; Desc='Chuot di chuyen tuyen tinh, tot cho game. Hieu luc sau khi dang xuat.'
       Run  = { Set-ItemProperty 'HKCU:\Control Panel\Mouse' MouseSpeed '0'; Set-ItemProperty 'HKCU:\Control Panel\Mouse' MouseThreshold1 '0'; Set-ItemProperty 'HKCU:\Control Panel\Mouse' MouseThreshold2 '0' }
       Undo = { Set-ItemProperty 'HKCU:\Control Panel\Mouse' MouseSpeed '1'; Set-ItemProperty 'HKCU:\Control Panel\Mouse' MouseThreshold1 '6'; Set-ItemProperty 'HKCU:\Control Panel\Mouse' MouseThreshold2 '10' } },
    @{ Name='Tat bang hoi Sticky Keys (nhan Shift 5 lan)'; Desc='Het bi nhay cua so khi nhan Shift lien tuc trong game.'; Rec=$true
       Run  = { Set-ItemProperty 'HKCU:\Control Panel\Accessibility\StickyKeys' Flags '506' }
       Undo = { Set-ItemProperty 'HKCU:\Control Panel\Accessibility\StickyKeys' Flags '510' } },
    @{ Name='Tat Hibernate (giai phong o C)'; Desc='Xoa hiberfil.sys, giai phong vai GB. Fast Startup cung se tat.'
       Run  = { powercfg /hibernate off; 'Da tat Hibernate.' }
       Undo = { powercfg /hibernate on; 'Da bat Hibernate.' } }
)},

@{ Group='TINH CHINH'; Name='Go app rac'; Sub='Go tung app co san khong can dung (khong hoan tac duoc)'; Glyph='E74D'; Color=@(235,90,90); Type='script'; Items=@(
    @{ Name='Bing News (Tin tuc)';       Desc='App tin tuc Bing.';                     Run = { Remove-AppxSafe 'Microsoft.BingNews' } },
    @{ Name='Bing Weather (Thoi tiet)';  Desc='App thoi tiet.';                        Run = { Remove-AppxSafe 'Microsoft.BingWeather' } },
    @{ Name='Solitaire Collection';      Desc='Bo game bai Solitaire.';                Run = { Remove-AppxSafe 'Microsoft.MicrosoftSolitaireCollection' } },
    @{ Name='Get Help / Tips';           Desc='App tro giup va meo vat.';              Run = { Remove-AppxSafe 'Microsoft.GetHelp'; Remove-AppxSafe 'Microsoft.Getstarted' } },
    @{ Name='Feedback Hub';              Desc='Gui phan hoi cho Microsoft.';           Run = { Remove-AppxSafe 'Microsoft.WindowsFeedbackHub' } },
    @{ Name='Clipchamp';                 Desc='Trinh chinh sua video cua Microsoft.';  Run = { Remove-AppxSafe 'Clipchamp.Clipchamp' } },
    @{ Name='Microsoft Teams (ca nhan)'; Desc='Teams cai san tren Win 11.';            Run = { Remove-AppxSafe 'MicrosoftTeams' } },
    @{ Name='People';                    Desc='App danh ba.';                          Run = { Remove-AppxSafe 'Microsoft.People' } },
    @{ Name='Skype';                     Desc='App Skype cai san.';                    Run = { Remove-AppxSafe 'Microsoft.SkypeApp' } },
    @{ Name='3D Viewer / Mixed Reality'; Desc='Xem 3D va Mixed Reality Portal.';       Run = { Remove-AppxSafe 'Microsoft.Microsoft3DViewer'; Remove-AppxSafe 'Microsoft.MixedReality.Portal' } },
    @{ Name='Office Hub';                Desc='App Office quang cao Microsoft 365.';   Run = { Remove-AppxSafe 'Microsoft.MicrosoftOfficeHub' } },
    @{ Name='Cortana';                   Desc='Tro ly ao Cortana.';                    Run = { Remove-AppxSafe 'Microsoft.549981C3F5F10' } }
)},

# ============================== HE THONG ==============================
@{ Group='HE THONG'; Name='Bao tri & Sua loi'; Sub='Diem khoi phuc, don rac, sua file he thong'; Glyph='E895'; Color=@(79,200,170); Type='script'; Items=@(
    @{ Name='Tao diem khoi phuc he thong'; Desc='NEN LAM TRUOC TIEN: de quay lai neu co gi hong. Tu dong chay truoc cac muc khac.'; Rec=$true; First=$true
       Run  = { Enable-ComputerRestore -Drive "$env:SystemDrive\"; Checkpoint-Computer -Description 'NGSetup' -RestorePointType MODIFY_SETTINGS; 'Da tao diem khoi phuc.' } },
    @{ Name='Mo Windows Update'; Desc='Mo trang cap nhat de bam "Check for updates" (nen lam sau khi cai Windows).'
       Run  = { Start-Process 'ms-settings:windowsupdate'; 'Da mo Windows Update.' } },
    @{ Name='Don file tam va thung rac'; Desc='Xoa file trong Temp (nguoi dung + Windows) va don thung rac.'; Rec=$true
       Run  = { Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item "$env:WINDIR\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
                Clear-RecycleBin -Force -ErrorAction SilentlyContinue; 'Da don xong.' } },
    @{ Name='Sua loi he thong (SFC + DISM)'; Desc='Quet va sua file Windows bi hong. Mat khoang 10-30 phut.'
       Run  = { $a = (& dism.exe /Online /Cleanup-Image /RestoreHealth) -join "`n"; $b = (& sfc.exe /scannow) -join "`n"
                ($a -replace "`0",''); ($b -replace "`0",'') } }
)},

@{ Group='HE THONG'; Name='Tinh nang Windows'; Sub='.NET 3.5, WSL, Sandbox, DirectPlay...'; Glyph='E713'; Color=@(150,160,255); Type='script'; Items=@(
    @{ Name='Bat .NET Framework 3.5'; Desc='Can cho game / phan mem doi cu. Can internet.'; Rec=$true
       Run  = { Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -All -NoRestart | Out-Null; 'Xong (co the can khoi dong lai).' } },
    @{ Name='Bat DirectPlay'; Desc='Can cho mot so game rat cu.'
       Run  = { Enable-WindowsOptionalFeature -Online -FeatureName DirectPlay -All -NoRestart | Out-Null; 'Xong (co the can khoi dong lai).' } },
    @{ Name='Bat WSL (Linux tren Windows)'; Desc='Bat WSL va Virtual Machine Platform.'
       Run  = { Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart | Out-Null
                Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart | Out-Null; 'Xong, hay khoi dong lai may.' } },
    @{ Name='Bat Windows Sandbox'; Desc='May ao dung 1 lan de thu phan mem la (chi ban Pro/Enterprise).'
       Run  = { Enable-WindowsOptionalFeature -Online -FeatureName Containers-DisposableClientVM -All -NoRestart | Out-Null; 'Xong, hay khoi dong lai may.' } },
    @{ Name='Bat Hyper-V'; Desc='May ao Hyper-V (chi ban Pro/Enterprise).'
       Run  = { Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -All -NoRestart | Out-Null; 'Xong, hay khoi dong lai may.' } }
)},

@{ Group='HE THONG'; Name='Mang & DNS'; Sub='Doi DNS, lam moi mang'; Glyph='E701'; Color=@(70,190,230); Type='script'; Items=@(
    @{ Name='Doi DNS sang Cloudflare (1.1.1.1)'; Desc='Thuong nhanh va on dinh hon DNS mac dinh cua nha mang.'
       Run  = { Get-NetAdapter | Where-Object Status -eq 'Up' | ForEach-Object { Set-DnsClientServerAddress -InterfaceIndex $_.ifIndex -ServerAddresses ('1.1.1.1','1.0.0.1') }
                ipconfig /flushdns | Out-Null; 'Da doi DNS.' }
       Undo = { Get-NetAdapter | Where-Object Status -eq 'Up' | ForEach-Object { Set-DnsClientServerAddress -InterfaceIndex $_.ifIndex -ResetServerAddresses }
                ipconfig /flushdns | Out-Null; 'Da tra DNS ve mac dinh.' } },
    @{ Name='Doi DNS sang Google (8.8.8.8)'; Desc='DNS cong cong cua Google.'
       Run  = { Get-NetAdapter | Where-Object Status -eq 'Up' | ForEach-Object { Set-DnsClientServerAddress -InterfaceIndex $_.ifIndex -ServerAddresses ('8.8.8.8','8.8.4.4') }
                ipconfig /flushdns | Out-Null; 'Da doi DNS.' }
       Undo = { Get-NetAdapter | Where-Object Status -eq 'Up' | ForEach-Object { Set-DnsClientServerAddress -InterfaceIndex $_.ifIndex -ResetServerAddresses }
                ipconfig /flushdns | Out-Null; 'Da tra DNS ve mac dinh.' } },
    @{ Name='Xoa cache DNS'; Desc='Lam moi bo nho DNS khi vao web bi loi.'; Rec=$true
       Run  = { ipconfig /flushdns | Out-String } },
    @{ Name='Dat lai mang (Winsock + IP)'; Desc='Sua loi mang kho hieu. Can khoi dong lai may.'
       Run  = { netsh winsock reset | Out-String; netsh int ip reset | Out-String; 'Xong, hay khoi dong lai may.' } }
)}

)
# ============================ HET DANH MUC ============================


# ---- 2. Thanh phan giao dien tu ve (C#) ----
$cs = @'
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Text;
using System.Runtime.InteropServices;
using System.Windows.Forms;

public static class Theme {
    public static Color Bg        = Color.FromArgb(15, 17, 21);
    public static Color Side      = Color.FromArgb(20, 23, 29);
    public static Color Card      = Color.FromArgb(27, 31, 39);
    public static Color CardHot   = Color.FromArgb(34, 39, 50);
    public static Color CardSel   = Color.FromArgb(28, 42, 68);
    public static Color Border    = Color.FromArgb(46, 52, 64);
    public static Color BorderSoft= Color.FromArgb(35, 40, 50);
    public static Color Text      = Color.FromArgb(234, 237, 242);
    public static Color Muted     = Color.FromArgb(140, 148, 162);
    public static Color Accent    = Color.FromArgb(79, 140, 255);
}

public static class Gfx {
    public static GraphicsPath Round(RectangleF r, float rad) {
        float d = rad * 2f;
        GraphicsPath p = new GraphicsPath();
        p.AddArc(r.X, r.Y, d, d, 180, 90);
        p.AddArc(r.Right - d, r.Y, d, d, 270, 90);
        p.AddArc(r.Right - d, r.Bottom - d, d, d, 0, 90);
        p.AddArc(r.X, r.Bottom - d, d, d, 90, 90);
        p.CloseFigure();
        return p;
    }
    public static void Quality(Graphics g) {
        g.SmoothingMode = SmoothingMode.AntiAlias;
        g.InterpolationMode = InterpolationMode.HighQualityBicubic;
        g.PixelOffsetMode = PixelOffsetMode.HighQuality;
        g.TextRenderingHint = TextRenderingHint.ClearTypeGridFit;
    }
}

public static class Native {
    [DllImport("dwmapi.dll")] static extern int DwmSetWindowAttribute(IntPtr hwnd, int attr, ref int val, int size);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern IntPtr SendMessage(IntPtr h, int msg, IntPtr w, string l);
    [DllImport("uxtheme.dll", CharSet = CharSet.Unicode)] static extern int SetWindowTheme(IntPtr h, string a, string b);
    [DllImport("kernel32.dll")] static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")] static extern bool ShowWindow(IntPtr h, int cmd);
    [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);

    public static void DarkTitle(IntPtr h) {
        try { int v = 1; if (DwmSetWindowAttribute(h, 20, ref v, 4) != 0) DwmSetWindowAttribute(h, 19, ref v, 4); } catch { }
    }
    public static void Cue(IntPtr h, string t) { try { SendMessage(h, 0x1501, (IntPtr)1, t); } catch { } }
    public static void DarkScroll(IntPtr h) { try { SetWindowTheme(h, "DarkMode_Explorer", null); } catch { } }
    public static bool HideConsole() {
        try {
            IntPtr h = GetConsoleWindow();
            if (h != IntPtr.Zero && IsWindowVisible(h)) { ShowWindow(h, 0); return true; }
        } catch { }
        return false;
    }
    public static void ShowConsole() { try { IntPtr h = GetConsoleWindow(); if (h != IntPtr.Zero) ShowWindow(h, 5); } catch { } }
}

public class FlowBuf : FlowLayoutPanel {
    public FlowBuf() { DoubleBuffered = true; }
    protected override CreateParams CreateParams {
        get { CreateParams cp = base.CreateParams; cp.ExStyle |= 0x02000000; return cp; }
    }
    protected override void OnHandleCreated(EventArgs e) { base.OnHandleCreated(e); Native.DarkScroll(Handle); }
}

public class ToolCard : Control {
    public string Title = "";
    public string Desc = "";
    public string Letter = "?";
    public string Glyph = "";
    public Color Tint = Theme.Accent;
    public Image Logo;
    bool selected, hot;
    public event EventHandler SelectedChanged;

    static Font fTitle  = new Font("Segoe UI Semibold", 10.5f, FontStyle.Regular, GraphicsUnit.Point);
    static Font fDesc   = new Font("Segoe UI", 8.5f, FontStyle.Regular, GraphicsUnit.Point);
    static Font fGlyph  = new Font("Segoe MDL2 Assets", 17f, FontStyle.Regular, GraphicsUnit.Point);
    static Font fLetter = new Font("Segoe UI", 16f, FontStyle.Bold, GraphicsUnit.Point);

    public ToolCard() {
        SetStyle(ControlStyles.UserPaint | ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw, true);
        Size = new Size(280, 84);
        Margin = new Padding(6);
        Cursor = Cursors.Hand;
    }
    public bool Selected {
        get { return selected; }
        set { if (selected != value) { selected = value; Invalidate(); if (SelectedChanged != null) SelectedChanged(this, EventArgs.Empty); } }
    }
    protected override void OnMouseEnter(EventArgs e) { hot = true; Invalidate(); base.OnMouseEnter(e); }
    protected override void OnMouseLeave(EventArgs e) { hot = false; Invalidate(); base.OnMouseLeave(e); }
    protected override void OnMouseClick(MouseEventArgs e) { if (e.Button == MouseButtons.Left) Selected = !Selected; base.OnMouseClick(e); }
    protected override void OnPaintBackground(PaintEventArgs e) { }

    protected override void OnPaint(PaintEventArgs e) {
        Graphics g = e.Graphics;
        Gfx.Quality(g);
        g.Clear(Theme.Bg);
        RectangleF rect = new RectangleF(0.5f, 0.5f, Width - 2, Height - 2);
        Color fill = selected ? Theme.CardSel : (hot ? Theme.CardHot : Theme.Card);
        Color line = selected ? Theme.Accent : (hot ? Theme.Border : Theme.BorderSoft);
        using (GraphicsPath p = Gfx.Round(rect, 12)) {
            using (SolidBrush b = new SolidBrush(fill)) g.FillPath(b, p);
            using (Pen pen = new Pen(line, selected ? 1.6f : 1f)) g.DrawPath(pen, p);
        }

        RectangleF ib = new RectangleF(14, (Height - 48) / 2f, 48, 48);
        using (GraphicsPath ip = Gfx.Round(ib, 11)) {
            if (Logo != null) {
                using (SolidBrush b = new SolidBrush(Color.FromArgb(238, 241, 247))) g.FillPath(b, ip);
                g.DrawImage(Logo, ib.X + 9, ib.Y + 9, 30, 30);
            } else {
                using (SolidBrush b = new SolidBrush(Color.FromArgb(46, Tint.R, Tint.G, Tint.B))) g.FillPath(b, ip);
                using (StringFormat sf = new StringFormat()) {
                    sf.Alignment = StringAlignment.Center; sf.LineAlignment = StringAlignment.Center;
                    using (SolidBrush tb = new SolidBrush(Tint)) {
                        if (!string.IsNullOrEmpty(Glyph)) g.DrawString(Glyph, fGlyph, tb, new RectangleF(ib.X, ib.Y + 1, ib.Width, ib.Height), sf);
                        else g.DrawString(Letter, fLetter, tb, ib, sf);
                    }
                }
            }
        }

        using (StringFormat sf = new StringFormat(StringFormatFlags.NoWrap)) {
            sf.Trimming = StringTrimming.EllipsisCharacter;
            using (SolidBrush tb = new SolidBrush(Theme.Text))
                g.DrawString(Title, fTitle, tb, new RectangleF(76, 15, Math.Max(10, Width - 76 - 44), 22), sf);
        }
        using (StringFormat sf = new StringFormat()) {
            sf.Trimming = StringTrimming.EllipsisWord;
            using (SolidBrush tb = new SolidBrush(Theme.Muted))
                g.DrawString(Desc, fDesc, tb, new RectangleF(76, 38, Math.Max(10, Width - 76 - 14), Height - 38 - 8), sf);
        }

        RectangleF cb = new RectangleF(Width - 34, 14, 20, 20);
        if (selected) {
            using (SolidBrush b = new SolidBrush(Theme.Accent)) g.FillEllipse(b, cb);
            using (Pen pen = new Pen(Color.White, 2f)) {
                pen.StartCap = LineCap.Round; pen.EndCap = LineCap.Round; pen.LineJoin = LineJoin.Round;
                g.DrawLines(pen, new PointF[] { new PointF(cb.X + 5.5f, cb.Y + 10.5f), new PointF(cb.X + 8.8f, cb.Y + 13.8f), new PointF(cb.X + 14.5f, cb.Y + 6.8f) });
            }
        } else {
            using (Pen pen = new Pen(Theme.Border, 1.5f)) g.DrawEllipse(pen, cb);
        }
    }
}

public class NavItem : Control {
    public string Glyph = "";
    public Color Tint = Theme.Accent;
    public int Count;
    public bool Active;
    bool hot;
    static Font fGlyph = new Font("Segoe MDL2 Assets", 12f, FontStyle.Regular, GraphicsUnit.Point);
    static Font fText  = new Font("Segoe UI", 9.5f, FontStyle.Regular, GraphicsUnit.Point);
    static Font fBadge = new Font("Segoe UI", 8f, FontStyle.Bold, GraphicsUnit.Point);

    public NavItem() {
        SetStyle(ControlStyles.UserPaint | ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw, true);
        Size = new Size(222, 36);
        Cursor = Cursors.Hand;
    }
    protected override void OnMouseEnter(EventArgs e) { hot = true; Invalidate(); base.OnMouseEnter(e); }
    protected override void OnMouseLeave(EventArgs e) { hot = false; Invalidate(); base.OnMouseLeave(e); }
    protected override void OnPaintBackground(PaintEventArgs e) { }

    protected override void OnPaint(PaintEventArgs e) {
        Graphics g = e.Graphics;
        Gfx.Quality(g);
        g.Clear(Theme.Side);
        if (Active || hot) {
            using (GraphicsPath p = Gfx.Round(new RectangleF(4, 1, Width - 8, Height - 2), 9))
            using (SolidBrush b = new SolidBrush(Active ? Color.FromArgb(32, 46, 78) : Color.FromArgb(28, 33, 42)))
                g.FillPath(b, p);
        }
        if (Active) {
            using (GraphicsPath p = Gfx.Round(new RectangleF(0, Height / 2f - 9, 4, 18), 2))
            using (SolidBrush b = new SolidBrush(Theme.Accent))
                g.FillPath(b, p);
        }
        using (StringFormat sf = new StringFormat()) {
            sf.LineAlignment = StringAlignment.Center;
            sf.Alignment = StringAlignment.Center;
            using (SolidBrush b = new SolidBrush(Tint)) g.DrawString(Glyph, fGlyph, b, new RectangleF(10, 0, 26, Height), sf);
        }
        using (StringFormat sf = new StringFormat(StringFormatFlags.NoWrap)) {
            sf.LineAlignment = StringAlignment.Center;
            sf.Trimming = StringTrimming.EllipsisCharacter;
            using (SolidBrush b = new SolidBrush(Active ? Theme.Text : Color.FromArgb(190, 196, 208)))
                g.DrawString(Text, fText, b, new RectangleF(44, 0, Width - 44 - 44, Height), sf);
        }
        if (Count > 0) {
            string t = Count.ToString();
            float w = Math.Max(24, 12 + t.Length * 7);
            RectangleF pr = new RectangleF(Width - 12 - w, (Height - 18) / 2f, w, 18);
            using (GraphicsPath p = Gfx.Round(pr, 9))
            using (SolidBrush b = new SolidBrush(Theme.Accent))
                g.FillPath(b, p);
            using (StringFormat sf = new StringFormat()) {
                sf.Alignment = StringAlignment.Center; sf.LineAlignment = StringAlignment.Center;
                g.DrawString(t, fBadge, Brushes.White, pr, sf);
            }
        }
    }
}

public class PillButton : Control {
    public int Kind;   // 0 = chinh (xanh), 1 = phu, 2 = nguy hiem (do)
    bool hot, down;
    static Font fBtn = new Font("Segoe UI Semibold", 9.5f, FontStyle.Regular, GraphicsUnit.Point);

    public PillButton() {
        SetStyle(ControlStyles.UserPaint | ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw | ControlStyles.Selectable, true);
        Size = new Size(120, 34);
        Cursor = Cursors.Hand;
    }
    protected override void OnMouseEnter(EventArgs e) { hot = true; Invalidate(); base.OnMouseEnter(e); }
    protected override void OnMouseLeave(EventArgs e) { hot = false; down = false; Invalidate(); base.OnMouseLeave(e); }
    protected override void OnMouseDown(MouseEventArgs e) { down = true; Invalidate(); base.OnMouseDown(e); }
    protected override void OnMouseUp(MouseEventArgs e) { down = false; Invalidate(); base.OnMouseUp(e); }
    protected override void OnEnabledChanged(EventArgs e) { Invalidate(); base.OnEnabledChanged(e); }
    protected override void OnTextChanged(EventArgs e) { Invalidate(); base.OnTextChanged(e); }
    protected override void OnPaintBackground(PaintEventArgs e) { }

    protected override void OnPaint(PaintEventArgs e) {
        Graphics g = e.Graphics;
        Gfx.Quality(g);
        g.Clear(Parent != null ? Parent.BackColor : Theme.Bg);
        Color fill, line, txt;
        if (!Enabled) { fill = Color.FromArgb(32, 36, 45); line = fill; txt = Theme.Muted; }
        else if (Kind == 0) {
            fill = down ? Color.FromArgb(52, 104, 214) : (hot ? Color.FromArgb(100, 156, 255) : Theme.Accent);
            line = fill; txt = Color.White;
        } else if (Kind == 2) {
            fill = hot ? Color.FromArgb(70, 32, 38) : Color.FromArgb(52, 28, 33);
            line = Color.FromArgb(110, 50, 58); txt = Color.FromArgb(255, 135, 135);
        } else {
            fill = hot ? Theme.CardHot : Theme.Card; line = Theme.Border; txt = Theme.Text;
        }
        using (GraphicsPath p = Gfx.Round(new RectangleF(0.5f, 0.5f, Width - 2, Height - 2), Height / 2f - 1))
        {
            using (SolidBrush b = new SolidBrush(fill)) g.FillPath(b, p);
            using (Pen pen = new Pen(line, 1f)) g.DrawPath(pen, p);
        }
        using (StringFormat sf = new StringFormat()) {
            sf.Alignment = StringAlignment.Center; sf.LineAlignment = StringAlignment.Center;
            sf.Trimming = StringTrimming.EllipsisCharacter; sf.FormatFlags = StringFormatFlags.NoWrap;
            using (SolidBrush b = new SolidBrush(txt)) g.DrawString(Text, fBtn, b, new RectangleF(0, 0, Width, Height), sf);
        }
    }
}

public class RoundBox : Panel {
    static Font fGlyph = new Font("Segoe MDL2 Assets", 11f, FontStyle.Regular, GraphicsUnit.Point);
    public RoundBox() {
        SetStyle(ControlStyles.UserPaint | ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw, true);
        BackColor = Theme.Card;
    }
    protected override void OnPaintBackground(PaintEventArgs e) { }
    protected override void OnPaint(PaintEventArgs e) {
        Graphics g = e.Graphics;
        Gfx.Quality(g);
        g.Clear(Parent != null ? Parent.BackColor : Theme.Bg);
        using (GraphicsPath p = Gfx.Round(new RectangleF(0.5f, 0.5f, Width - 2, Height - 2), 10)) {
            using (SolidBrush b = new SolidBrush(Theme.Card)) g.FillPath(b, p);
            using (Pen pen = new Pen(Theme.Border, 1f)) g.DrawPath(pen, p);
        }
        using (StringFormat sf = new StringFormat()) {
            sf.LineAlignment = StringAlignment.Center;
            using (SolidBrush b = new SolidBrush(Theme.Muted)) g.DrawString("\uE721", fGlyph, b, new RectangleF(12, 0, 24, Height), sf);
        }
    }
}
'@
if (-not ('ToolCard' -as [type])) {
    Add-Type -TypeDefinition $cs -ReferencedAssemblies 'System.Windows.Forms', 'System.Drawing'
}

# ---- 3. Winget: kiem tra / tu cai neu thieu ----
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

# ---- 4. Logo ung dung: tai nen (song song) + luu cache ----
$script:IconDir = Join-Path $env:LOCALAPPDATA 'NGSetup\icons'
New-Item $script:IconDir -ItemType Directory -Force | Out-Null
$script:LogoCache = @{}
$script:Pending   = @{}
$script:Ticks     = 0

function Get-IconFile($domain) { return (Join-Path $script:IconDir ((($domain -replace '[^a-zA-Z0-9]', '_')) + '.png')) }

function Get-Logo($domain) {
    if ($script:LogoCache.ContainsKey($domain)) { return $script:LogoCache[$domain] }
    $f = Get-IconFile $domain
    if (-not (Test-Path $f)) { return $null }
    try {
        $bytes = [IO.File]::ReadAllBytes($f)
        if ($bytes.Length -lt 100) { return $null }
        $ms = New-Object IO.MemoryStream(, $bytes)
        $img = [System.Drawing.Image]::FromStream($ms)
        $bmp = New-Object System.Drawing.Bitmap($img)
        $img.Dispose(); $ms.Dispose()
        $script:LogoCache[$domain] = $bmp
        return $bmp
    } catch { return $null }
}

function Start-IconDownloads($domains) {
    $todo = @($domains | Where-Object { -not (Test-Path (Get-IconFile $_)) })
    if ($todo.Count -eq 0) { return }
    $pool = [runspacefactory]::CreateRunspacePool(1, 8)
    $pool.Open()
    foreach ($d in $todo) {
        $ps = [powershell]::Create()
        $ps.RunspacePool = $pool
        [void]$ps.AddScript({
            param($d, $f)
            try {
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                $wc = New-Object Net.WebClient
                $url = 'https://www.google.com/s2/favicons?sz=128&domain_url=' + [Uri]::EscapeDataString('https://' + $d)
                $b = $wc.DownloadData($url)
                if ($b.Length -gt 100) { [IO.File]::WriteAllBytes($f + '.tmp', $b); Move-Item ($f + '.tmp') $f -Force }
            } catch {}
        }).AddArgument($d).AddArgument((Get-IconFile $d))
        [void]$ps.BeginInvoke()
    }
}

# ---- 5. Dung giao dien ----
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$form = New-Object System.Windows.Forms.Form
$form.Text = $Ten
$form.Size = New-Object System.Drawing.Size(1260, 800)
$form.MinimumSize = New-Object System.Drawing.Size(1000, 640)
$form.StartPosition = 'CenterScreen'
$form.BackColor = [Theme]::Bg
$form.ForeColor = [Theme]::Text
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9.5)
$form.Add_HandleCreated({ [Native]::DarkTitle($form.Handle) })

# --- Thanh ben trai ---
$side = New-Object System.Windows.Forms.Panel
$side.Dock = 'Left'
$side.Width = 262
$side.BackColor = [Theme]::Side

$brand = New-Object System.Windows.Forms.Panel
$brand.Dock = 'Top'
$brand.Height = 78
$brand.BackColor = [Theme]::Side
$lbBrand = New-Object System.Windows.Forms.Label
$lbBrand.Text = $Ten
$lbBrand.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 17)
$lbBrand.ForeColor = [Theme]::Text
$lbBrand.AutoSize = $true
$lbBrand.Location = New-Object System.Drawing.Point(18, 14)
$lbBrandSub = New-Object System.Windows.Forms.Label
$lbBrandSub.Text = 'Cai dat sau khi cai Windows'
$lbBrandSub.Font = New-Object System.Drawing.Font('Segoe UI', 8.5)
$lbBrandSub.ForeColor = [Theme]::Muted
$lbBrandSub.AutoSize = $true
$lbBrandSub.Location = New-Object System.Drawing.Point(20, 48)
$brand.Controls.AddRange(@($lbBrand, $lbBrandSub))

$navFlow = New-Object FlowBuf
$navFlow.Dock = 'Fill'
$navFlow.FlowDirection = 'TopDown'
$navFlow.WrapContents = $false
$navFlow.AutoScroll = $true
$navFlow.BackColor = [Theme]::Side
$navFlow.Padding = New-Object System.Windows.Forms.Padding(8, 0, 0, 12)

$side.Controls.Add($brand)
$side.Controls.Add($navFlow)
$brand.BringToFront(); $navFlow.BringToFront()

# --- Khu noi dung ---
$content = New-Object System.Windows.Forms.Panel
$content.Dock = 'Fill'
$content.BackColor = [Theme]::Bg

$header = New-Object System.Windows.Forms.Panel
$header.Dock = 'Top'
$header.Height = 82
$header.BackColor = [Theme]::Bg
$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 18)
$lblTitle.ForeColor = [Theme]::Text
$lblTitle.AutoSize = $true
$lblTitle.Location = New-Object System.Drawing.Point(24, 12)
$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Font = New-Object System.Drawing.Font('Segoe UI', 9.5)
$lblSub.ForeColor = [Theme]::Muted
$lblSub.AutoSize = $true
$lblSub.Location = New-Object System.Drawing.Point(26, 50)

$searchBox = New-Object RoundBox
$searchBox.Width = 320
$searchBox.Height = 40
$searchBox.Location = New-Object System.Drawing.Point(600, 20)
$search = New-Object System.Windows.Forms.TextBox
$search.BorderStyle = 'None'
$search.BackColor = [Theme]::Card
$search.ForeColor = [Theme]::Text
$search.Font = New-Object System.Drawing.Font('Segoe UI', 10.5)
$search.Location = New-Object System.Drawing.Point(40, 10)
$search.Width = 266
$search.Anchor = 'Top, Left, Right'
$search.Add_HandleCreated({ [Native]::Cue($search.Handle, 'Tim ung dung, tinh chinh...') })
$searchBox.Controls.Add($search)
$header.Controls.AddRange(@($lblTitle, $lblSub, $searchBox))
$header.Add_Resize({ $searchBox.Left = [Math]::Max(300, $header.ClientSize.Width - $searchBox.Width - 28) })

$toolbar = New-Object System.Windows.Forms.FlowLayoutPanel
$toolbar.Dock = 'Top'
$toolbar.Height = 46
$toolbar.BackColor = [Theme]::Bg
$toolbar.Padding = New-Object System.Windows.Forms.Padding(18, 4, 0, 0)

function New-Pill($text, $w, $kind, $h = 32) {
    $b = New-Object PillButton
    $b.Text = $text; $b.Width = $w; $b.Height = $h; $b.Kind = $kind
    $b.Margin = New-Object System.Windows.Forms.Padding(6, 3, 0, 3)
    return $b
}
$btnSelAll   = New-Pill 'Chon het muc nay' 150 1
$btnSelNone  = New-Pill 'Bo chon muc nay' 150 1
$btnSelRec   = New-Pill 'Chon bo khuyen dung (tat ca)' 220 1
$btnClearAll = New-Pill 'Bo chon tat ca' 130 1
$toolbar.Controls.AddRange(@($btnSelAll, $btnSelNone, $btnSelRec, $btnClearAll))

$actionBar = New-Object System.Windows.Forms.Panel
$actionBar.Dock = 'Bottom'
$actionBar.Height = 68
$actionBar.BackColor = [Theme]::Side

$btnPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$btnPanel.Dock = 'Right'
$btnPanel.AutoSize = $true
$btnPanel.FlowDirection = 'RightToLeft'
$btnPanel.WrapContents = $false
$btnPanel.BackColor = [Theme]::Side
$btnRun  = New-Pill 'CAI / CHAY  (0)' 220 0 42
$btnUndo = New-Pill 'Go / Hoan tac' 140 2 42
$btnLog  = New-Pill 'Nhat ky' 100 1 42
foreach ($b in @($btnRun, $btnUndo, $btnLog)) { $b.Margin = New-Object System.Windows.Forms.Padding(8, 13, 8, 13) }
$btnRun.Margin = New-Object System.Windows.Forms.Padding(8, 13, 20, 13)
$btnPanel.Controls.AddRange(@($btnRun, $btnUndo, $btnLog))

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Dock = 'Fill'
$lblStatus.ForeColor = [Theme]::Muted
$lblStatus.Font = New-Object System.Drawing.Font('Segoe UI', 9.5)
$lblStatus.TextAlign = 'MiddleLeft'
$lblStatus.Padding = New-Object System.Windows.Forms.Padding(24, 0, 0, 0)
$lblStatus.Text = 'San sang.'
$actionBar.Controls.Add($btnPanel)
$actionBar.Controls.Add($lblStatus)
$btnPanel.BringToFront(); $lblStatus.BringToFront()

$log = New-Object System.Windows.Forms.TextBox
$log.Multiline = $true
$log.ReadOnly = $true
$log.ScrollBars = 'Vertical'
$log.Dock = 'Bottom'
$log.Height = 190
$log.Visible = $false
$log.BorderStyle = 'None'
$log.BackColor = [System.Drawing.Color]::FromArgb(10, 12, 15)
$log.ForeColor = [System.Drawing.Color]::FromArgb(200, 206, 216)
$log.Font = New-Object System.Drawing.Font('Consolas', 9.5)
$log.Add_HandleCreated({ [Native]::DarkScroll($log.Handle) })

$flow = New-Object FlowBuf
$flow.Dock = 'Fill'
$flow.AutoScroll = $true
$flow.BackColor = [Theme]::Bg
$flow.Padding = New-Object System.Windows.Forms.Padding(18, 6, 6, 12)

$content.Controls.Add($header)
$content.Controls.Add($toolbar)
$content.Controls.Add($actionBar)
$content.Controls.Add($log)
$content.Controls.Add($flow)
$header.BringToFront(); $toolbar.BringToFront(); $actionBar.BringToFront(); $log.BringToFront(); $flow.BringToFront()

$form.Controls.Add($side)
$form.Controls.Add($content)
$side.BringToFront(); $content.BringToFront()

function Write-Log($text) {
    $log.AppendText("$text`r`n")
    [System.Windows.Forms.Application]::DoEvents()
}

# ---- 6. The cho tung muc + thanh dieu huong ----
function New-Tint($rgb) { return [System.Drawing.Color]::FromArgb($rgb[0], $rgb[1], $rgb[2]) }
function New-GlyphChar($hex) { return [string][char][Convert]::ToInt32($hex, 16) }

$script:AllDomains = New-Object System.Collections.ArrayList
$lastGroup = $null

foreach ($cat in $Catalog) {
    # tieu de nhom
    if ($cat.Group -ne $lastGroup) {
        $gl = New-Object System.Windows.Forms.Label
        $gl.Text = $cat.Group
        $gl.AutoSize = $false
        $gl.Width = 224
        $gl.Height = 34
        $gl.TextAlign = 'BottomLeft'
        $gl.Padding = New-Object System.Windows.Forms.Padding(14, 0, 0, 4)
        $gl.Font = New-Object System.Drawing.Font('Segoe UI', 8, [System.Drawing.FontStyle]::Bold)
        $gl.ForeColor = [Theme]::Muted
        $gl.BackColor = [Theme]::Side
        $navFlow.Controls.Add($gl)
        $lastGroup = $cat.Group
    }

    $tint = New-Tint $cat.Color

    $nav = New-Object NavItem
    $nav.Text = $cat.Name
    $nav.Glyph = New-GlyphChar $cat.Glyph
    $nav.Tint = $tint
    $nav.Width = 224
    $nav.Height = 36
    $nav.Margin = New-Object System.Windows.Forms.Padding(0, 1, 0, 1)
    $nav.Tag = $cat
    $nav.Add_Click({ param($s, $e) Show-Category $s.Tag })
    $cat.Nav = $nav
    $navFlow.Controls.Add($nav)

    foreach ($it in $cat.Items) {
        $it.Type = $cat.Type
        $card = New-Object ToolCard
        $card.Title = [string]$it.Name
        $card.Desc  = [string]$it.Desc
        $card.Letter = ([string]$it.Name).Substring(0, 1).ToUpper()
        $card.Tint = $tint
        if (-not $it.Domain) {
            $gh = if ($it.Glyph) { $it.Glyph } else { $cat.Glyph }
            $card.Glyph = New-GlyphChar $gh
        } else {
            $card.Glyph = ''
            $logo = Get-Logo $it.Domain
            if ($logo) { $card.Logo = $logo }
            else {
                if (-not $script:Pending.ContainsKey($it.Domain)) { $script:Pending[$it.Domain] = New-Object System.Collections.ArrayList }
                [void]$script:Pending[$it.Domain].Add($card)
                if (-not $script:AllDomains.Contains($it.Domain)) { [void]$script:AllDomains.Add($it.Domain) }
            }
        }
        $card.Selected = [bool]$it.Rec
        $card.Tag = $it
        $card.Add_SelectedChanged({ Update-Counts })
        $it.Card = $card
    }
}

function Update-Counts {
    $total = 0
    foreach ($c in $Catalog) {
        $n = 0
        foreach ($it in $c.Items) { if ($it.Card.Selected) { $n++ } }
        if ($c.Nav.Count -ne $n) { $c.Nav.Count = $n; $c.Nav.Invalidate() }
        $total += $n
    }
    $script:Total = $total
    $btnRun.Text = "CAI / CHAY  ($total)"
    $btnRun.Invalidate()
    if (-not $script:Busy) { $lblStatus.Text = if ($total -gt 0) { "Da chon $total muc." } else { 'Chua chon muc nao.' } }
}

function Resize-Cards {
    $avail = $flow.ClientSize.Width - $flow.Padding.Horizontal - 22
    $cols = [Math]::Max(1, [Math]::Floor($avail / 310))
    $w = [int]([Math]::Floor($avail / $cols)) - 12
    foreach ($c in $flow.Controls) { $c.Width = $w }
}

function Show-Items($cards, $title, $sub) {
    $lblTitle.Text = $title
    $lblSub.Text = $sub
    $flow.SuspendLayout()
    $flow.Controls.Clear()
    if ($cards.Count -gt 0) { $flow.Controls.AddRange([System.Windows.Forms.Control[]]@($cards)) }
    Resize-Cards
    $flow.ResumeLayout($true)
    $flow.AutoScrollPosition = New-Object System.Drawing.Point(0, 0)
}

function Show-Category($cat) {
    $script:CurrentCat = $cat
    foreach ($c in $Catalog) { $on = ($c -eq $cat); if ($c.Nav.Active -ne $on) { $c.Nav.Active = $on; $c.Nav.Invalidate() } }
    $script:Muting = $true; $search.Text = ''; $script:Muting = $false
    $cards = @(); foreach ($it in $cat.Items) { $cards += $it.Card }
    Show-Items $cards $cat.Name $cat.Sub
}

$search.Add_TextChanged({
    if ($script:Muting) { return }
    $q = $search.Text.Trim()
    if (-not $q) { Show-Category $script:CurrentCat; return }
    $hits = @()
    foreach ($c in $Catalog) {
        foreach ($it in $c.Items) {
            if (([string]$it.Name).IndexOf($q, [StringComparison]::OrdinalIgnoreCase) -ge 0 -or ([string]$it.Desc).IndexOf($q, [StringComparison]::OrdinalIgnoreCase) -ge 0) { $hits += $it.Card }
        }
    }
    foreach ($c in $Catalog) { if ($c.Nav.Active) { $c.Nav.Active = $false; $c.Nav.Invalidate() } }
    Show-Items $hits 'Ket qua tim kiem' "$($hits.Count) muc khop voi '$q'"
})
$flow.Add_Resize({ Resize-Cards })

# --- Cac nut chon nhanh ---
$btnSelAll.Add_Click({  foreach ($c in $flow.Controls) { $c.Selected = $true } })
$btnSelNone.Add_Click({ foreach ($c in $flow.Controls) { $c.Selected = $false } })
$btnSelRec.Add_Click({  foreach ($cat in $Catalog) { foreach ($it in $cat.Items) { $it.Card.Selected = [bool]$it.Rec } } })
$btnClearAll.Add_Click({ foreach ($cat in $Catalog) { foreach ($it in $cat.Items) { $it.Card.Selected = $false } } })
$btnLog.Add_Click({ $log.Visible = -not $log.Visible })

# ---- 7. Thuc thi ----
function Invoke-Entry($item, [bool]$undo) {
    Write-Log ">> $($item.Name)"
    try {
        if ($item.Id) {
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

$script:Busy = $false
function Invoke-Selected([bool]$undo) {
    if ($script:Busy) { return }
    $sel = @()
    foreach ($c in $Catalog) { foreach ($it in $c.Items) { if ($it.Card.Selected) { $sel += $it } } }
    if ($sel.Count -eq 0) { $lblStatus.Text = 'Chua chon muc nao.'; return }

    if ($undo) {
        $r = [System.Windows.Forms.MessageBox]::Show("Go / hoan tac $($sel.Count) muc da chon?", $Ten, 'YesNo', 'Question')
        if ($r -ne 'Yes') { return }
    }
    # muc "First" (diem khoi phuc) chay truoc
    $ordered = @(); foreach ($it in $sel) { if ($it.First) { $ordered += $it } }
    foreach ($it in $sel) { if (-not $it.First) { $ordered += $it } }

    $script:Busy = $true
    $log.Visible = $true
    foreach ($b in @($btnRun, $btnUndo)) { $b.Enabled = $false }
    $ok = 0; $fail = 0; $i = 0
    foreach ($it in $ordered) {
        $i++
        $lblStatus.Text = "Dang chay $i/$($ordered.Count): $($it.Name)"
        if (Invoke-Entry $it $undo) { $ok++ } else { $fail++ }
    }
    Write-Log "===== HOAN TAT: $ok thanh cong, $fail loi ====="
    $script:Busy = $false
    foreach ($b in @($btnRun, $btnUndo)) { $b.Enabled = $true }
    $lblStatus.Text = "Xong: $ok thanh cong, $fail loi."
    [System.Media.SystemSounds]::Asterisk.Play()
}
$btnRun.Add_Click({ Invoke-Selected $false })
$btnUndo.Add_Click({ Invoke-Selected $true })

# ---- 8. Khoi dong ----
$iconTimer = New-Object System.Windows.Forms.Timer
$iconTimer.Interval = 600
$iconTimer.Add_Tick({
    $script:Ticks++
    foreach ($d in @($script:Pending.Keys)) {
        $img = Get-Logo $d
        if ($img) {
            foreach ($c in $script:Pending[$d]) { $c.Logo = $img; $c.Invalidate() }
            $script:Pending.Remove($d)
        }
    }
    if ($script:Pending.Count -eq 0 -or $script:Ticks -gt 150) { $iconTimer.Stop() }
})

Update-Counts
Show-Category $Catalog[0]
Write-Log "Chon muc can dung roi bam 'CAI / CHAY'. Muc co dau tick san la 'khuyen dung'."
if (Test-Winget) { Write-Log 'Winget: da co.' } else { Write-Log 'Winget: chua co - se tu cai khi ban cai ung dung dau tien.' }

$form.Add_Shown({
    $searchBox.Left = [Math]::Max(300, $header.ClientSize.Width - $searchBox.Width - 28)
    Start-IconDownloads $script:AllDomains
    if ($script:Pending.Count -gt 0) { $iconTimer.Start() }
})

$hid = [Native]::HideConsole()
try { [void]$form.ShowDialog() }
finally { if ($hid) { [Native]::ShowConsole() } }
