$UpdateSession = New-Object -ComObject "Microsoft.Update.Session"

$Downloader = $UpdateSession.CreateUpdateDownloader()

$Installer = $UpdateSession.CreateUpdateInstaller()

$Searcher = $Updatesession.CreateUpdateSearcher()

$Searcher.ServerSelection = 2 #2 is the Const for the Windows Update server

if ((Get-Service -Name wuauserv).Status -eq "Stopped") {Start-Service -Name wuauserv}

$Results = $Searcher.Search("IsHidden=0 and IsInstalled=0 and BrowseOnly=0")

$Results.Updates.count

$Results.Updates | Select-Object Title

$Updates = New-Object -ComObject "Microsoft.Update.UpdateColl"

foreach ($Update in $Results.updates) {
    if ($Update.IsDownloaded -eq $false) {
        $Updates.Add($Update)
    }
}

$Downloader.Updates = $Updates

$Downloader.Updates.Count

$Downloader.Download()

$UpdatesToInstall = New-Object -ComObject "Microsoft.Update.UpdateColl"

foreach ($Update in $Results.updates) {
    if ($Update.IsDownloaded -eq $true) {
        $UpdatesToInstall.Add($Update)
    }
}

$Installer.Updates = $UpdatesToInstall

$Installer.Updates.Count

$Installer.Updates | Select-Object Title

$output = $Installer.Install()