Param(
[Parameter(Mandatory=$True)]
[string]$version,

[switch]$enableAutoUpdate,
[switch]$doNotUninstallPreviousVersionBeforeInstall,
[switch]$doNotDownloadInstallerIfAlreadyDownloaded
)




$sourceUrl = "http://ftp.mozilla.org/pub/mozilla.org/firefox/releases/" + $version +"/win32/en-US/Firefox%20Setup%20" + $version +".exe"
$tempDownloadDestination = $env:temp + "\firefox_installer_" + $version + ".exe"

Write-Host -ForegroundColor GREEN "Downloading Firefox `n`rVersion: $version `n`rURL: $sourceUrl `n`rDestination: $tempDownloadDestination"

Write-Host "***************************************************************************"

if((Test-Path $tempDownloadDestination) -and $doNotDownloadInstallerIfAlreadyDownloaded){
    Write-Host -ForegroundColor GREEN "Installer seems to already be downloaded, will use existing one located:`r`n$tempDownloadDestination"
} else {

    if(Test-Path $tempDownloadDestination){
        Write-Host "Prevesous download exists, cleaning up."
        rm $tempDownloadDestination -Force
    }
    
Write-Host "Starting download"
$webclient = New-Object System.Net.WebClient
$webclient.DownloadFile($sourceUrl,$tempDownloadDestination)
Write-Host "Download finished"

    if(Test-Path $tempDownloadDestination){
        Write-Host "Installer appears to have downloaded successfully"
    } else {
        Write-Host -ForegroundColor red "Installer did not download correctly, please check the URL actulaly exists!`r`n$sourceUrl"
        Exit 1
    }
}


if($doNotUninstallPreviousVersionBeforeInstall){
    Write-Host "You have chosen not to uninstall previous version of Firefox"
}else{
    Write-Host "Uninstalling previous version of Firefox" 
       
    Start-Process -FilePath $tempDownloadDestination -ArgumentList /S -NoNewWindow -Wait
    Write-Host "Uninstall finished"
}

Write-Host "Attempting silent install of Firefox $version"
Start-Process -FilePath $tempDownloadDestination -ArgumentList -ms -NoNewWindow -Wait
Write-Host -ForegroundColor GREEN "Firefox installer finished"


$pathToFirefoxInstall = "\Program Files\Mozilla Firefox"
$64BitFirefoxPath = "\Program Files (x86)\Mozilla Firefox"

if(Test-Path $pathToFirefoxInstall){
    Write-Host "Using default Firefox Install Path: $pathToFirefoxInstall"
} else {
    if(Test-Path $64BitFirefoxPath){
      $pathToFirefoxInstall = $64BitFirefoxPath  
    } else {
        Write-Host -ForegroundColor RED "ERROR: Cannot find Firefox Installation in following two places: `r`n$pathToFirefoxInstall`n`r$64BitFirefoxPath"
        Exit 1
    }
}

$prefeDefaultsDir = "$pathToFirefoxInstall\defaults"

if((Test-Path $prefeDefaultsDir) -ne $true){
    Write-Host "$prefeDefaultsDir does not exist, creating it"
    mkdir $prefeDefaultsDir
}

$prefsDir = "$prefeDefaultsDir\pref"
if((Test-Path $prefsDir) -ne $true){
    Write-Host "$prefsDir does not exist, creating it"
    mkdir $prefsDir
}

$cfgFileName = "mozilla.cfg"
$cfgFilePath = "$pathToFirefoxInstall\$cfgFileName"
$autoConfigFile = "$prefsDir\autoconfig.js"

if(Test-Path $cfgFilePath){
    Write-Host "Deleting $cfgFilePath"
    rm $cfgFilePath -Force
}

if(Test-Path $autoConfigFile){
    Write-Host "Deleting $autoConfigFile"
    rm $autoConfigFile -Force
}

if($enableAutoUpdate){
    Write-Host "You have opted to enable Firefox Auto Update, will leave system defaults"
    Exit 0
} 


$cfgContents = "// Disable updater `r`n defaultPref(`"app.update.enabled`", false); `r`n // make absolutely sure it is really off `r`n defaultPref(`"app.update.auto`", false); `r`n defaultPref(`"app.update.mode`", 0); `r`n defaultPref(`"app.update.service.enabled`", false);"
Write-Host "Writing contents to $cfgFilePath"
$cfgContents | Out-File $cfgFilePath -Encoding Default

$autoConfigContents = "pref(`"general.config.filename`", `"" + $cfgFileName + "`"); `r`n pref(`"general.config.obscure_value`", 0);"

Write-Host "Writing contents to $autoConfigFile"
$autoConfigContents | Out-File $autoConfigFile -Encoding Default