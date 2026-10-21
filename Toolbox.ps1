# =====================================================================
#  MY TOOLBOX - chay bang:  irm "https://DUONG-DAN-CUA-BAN/Toolbox.ps1" | iex
#  Muon them app / tinh chinh: chi can sua file catalog.json (khong can sua file nay)
# =====================================================================

# ============================ CAU HINH ===============================
$Ten     = "My Toolbox"
$BaseUrl = "https://raw.githubusercontent.com/thinhnguyen02031-lang/NGmods/main"   # <-- DOI CHO DUNG
# =====================================================================

$ErrorActionPreference = 'Continue'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

# ---- 1. Tu xin quyen Administrator ----
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $cmd = if ($PSCommandPath) { "& '$PSCommandPath'" } else { "irm '$BaseUrl/Toolbox.ps1' | iex" }
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$cmd`""
    return
}

# ---- 2. Nap danh muc catalog.json ----
function Get-Catalog {
    if ($PSScriptRoot) {
        $local = Join-Path $PSScriptRoot 'catalog.json'
        if (Test-Path $local) { return (Get-Content $local -Raw -Encoding UTF8 | ConvertFrom-Json) }
    }
    $url = "$BaseUrl/catalog.json?t=" + [DateTime]::Now.Ticks    # tranh cache
    $raw = Invoke-RestMethod $url -UseBasicParsing
    if ($raw -is [string]) { $raw = $raw.TrimStart([char]0xFEFF) | ConvertFrom-Json }
    return $raw
}

try { $catalog = Get-Catalog }
catch {
    Write-Host "Khong tai duoc catalog.json: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Kiem tra lai `$BaseUrl o dau file Toolbox.ps1" -ForegroundColor Yellow
    return
}

# ---- 3. Giao dien ----
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$form = New-Object System.Windows.Forms.Form
$form.Text = $Ten
$form.Size = New-Object System.Drawing.Size(860, 680)
$form.StartPosition = 'CenterScreen'
$form.Font = New-Object System.Drawing.Font('Segoe UI', 10)

$tabs = New-Object System.Windows.Forms.TabControl
$tabs.Dock = 'Fill'

foreach ($t in $catalog.tabs) {
    $page = New-Object System.Windows.Forms.TabPage
    $page.Text = $t.name

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
    foreach ($it in $t.items) { [void]$clb.Items.Add($it.name) }

    $clb.Tag  = @{ Items = @($t.items); Type = $t.type; Desc = $desc }
    $clb.Add_SelectedIndexChanged({
        param($s, $e)
        $i = $s.SelectedIndex
        if ($i -ge 0) { $s.Tag.Desc.Text = [string]$s.Tag.Items[$i].desc }
    })

    $page.Controls.Add($clb)
    $page.Controls.Add($desc)
    $page.Tag = $clb
    [void]$tabs.TabPages.Add($page)
}

# Khu vuc nut + log
$bottom = New-Object System.Windows.Forms.Panel
$bottom.Dock = 'Bottom'
$bottom.Height = 250

$btnPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$btnPanel.Dock = 'Top'
$btnPanel.Height = 46
$btnPanel.Padding = New-Object System.Windows.Forms.Padding(6, 6, 0, 0)

function New-Btn($text, $w) {
    $b = New-Object System.Windows.Forms.Button
    $b.Text = $text
    $b.Width = $w
    $b.Height = 32
    return $b
}
$btnRun   = New-Btn 'Cai / Chay muc da chon' 200
$btnUndo  = New-Btn 'Go / Hoan tac' 140
$btnAll   = New-Btn 'Chon tat ca' 110
$btnNone  = New-Btn 'Bo chon' 90
$btnPanel.Controls.AddRange(@($btnRun, $btnUndo, $btnAll, $btnNone))

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
$tabs.BringToFront()

function Write-Log($text) {
    $log.AppendText("$text`r`n")
    [System.Windows.Forms.Application]::DoEvents()
}

# ---- 4. Thuc thi 1 muc ----
function Invoke-Entry($item, $type, [bool]$undo) {
    Write-Log ">> $($item.name)"
    try {
        if ($type -eq 'winget') {
            if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
                Write-Log "Khong tim thay winget. Hay cai 'App Installer' tu Microsoft Store."
                return
            }
            if ($undo) { $a = @('uninstall', '--id', $item.id, '-e', '--silent') }
            else       { $a = @('install', '--id', $item.id, '-e', '--silent', '--accept-package-agreements', '--accept-source-agreements') }
            & winget @a 2>&1 | ForEach-Object {
                $s = "$_".Trim()
                if ($s -and $s -notmatch '^[\-\\|/\s]+$') { Write-Log $s }
            }
        }
        else {
            $c = if ($undo) { $item.undo } else { $item.run }
            if (-not $c) { Write-Log "(muc nay khong co lenh tuong ung)"; return }
            $out = Invoke-Expression $c 2>&1 | Out-String
            if ($out.Trim()) { Write-Log $out.Trim() }
        }
        Write-Log "Xong."
    }
    catch { Write-Log "LOI: $($_.Exception.Message)" }
}

function Invoke-Selected([bool]$undo) {
    $clb = $tabs.SelectedTab.Tag
    $idx = @($clb.CheckedIndices)
    if ($idx.Count -eq 0) { Write-Log "Chua chon muc nao."; return }
    $btnRun.Enabled = $false; $btnUndo.Enabled = $false
    foreach ($i in $idx) { Invoke-Entry $clb.Tag.Items[$i] $clb.Tag.Type $undo }
    Write-Log "===== HOAN TAT ====="
    $btnRun.Enabled = $true; $btnUndo.Enabled = $true
}

$btnRun.Add_Click({ Invoke-Selected $false })
$btnUndo.Add_Click({ Invoke-Selected $true })
$btnAll.Add_Click({
    $clb = $tabs.SelectedTab.Tag
    for ($i = 0; $i -lt $clb.Items.Count; $i++) { $clb.SetItemChecked($i, $true) }
})
$btnNone.Add_Click({
    $clb = $tabs.SelectedTab.Tag
    for ($i = 0; $i -lt $clb.Items.Count; $i++) { $clb.SetItemChecked($i, $false) }
})

Write-Log "San sang. Chon muc roi bam 'Cai / Chay'."
[void]$form.ShowDialog()
