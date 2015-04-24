# DownloadFirefoxScript

Usage:

[More description can be found in this blog post.](http://agilesoftwaretesting.com/firefox-silent-install-script/)

## Windows

Download the PowerShell script [Here](blob/master/download_firefox.ps1)

1.	Download the script to the node(s) that you want to use it on.
2.	Open Powershell as Administrator. (You do not have to use it as Administrator but will save trouble of dealing with multiple permission pop-ups)
3.	Make sure Powershell is allowed to execute scripts. This command will allow any script to be executed on the node Set-ExecutionPolicy Unrestricted
4.	Type in following command in Powershell path_to_script\download_firefox.ps1 –version XX
a.	Where path_to_script is the relative path to the script
b.	XX is the version number of Firefox such as 37.0 or 38.0b2
5.	Check that correct version of Firefox was installed

### Parameters

**-version** (Required) version of Firefox to download and install

**-enableAutoUpdate** By default the script will disable Firefox’s auto update feature. This flag will tell the script to leave auto update turned on.

**-doNotUninstallPreviousVersionBeforeInstall** By default, the script will uninstall Firefox and all dependencies before installing new version (aka clean install). Using this flag will skip the uninstall section and will install the new version of Firefox on top of existing one.

**-doNotDownloadInstallerIfAlreadyDownloaded** This flag will check if the installer for specified version is already downloaded. If it is, it will skip the download step and run existing installer.



