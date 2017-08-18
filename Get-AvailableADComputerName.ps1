$Type = "100NB"

$Computers = Get-ADComputer -Filter * | Select Name

$Computers = $Computers | Where-Object {$_.Name -like "$Type*"}

[System.Collections.ArrayList]$ComputerList = @()

foreach ($name in $Computers) {
    $id = $name.name.replace('100NB','')
    
    $computerlist.add($id) | Out-Null
}

$computerlist = $computerlist | sort

$counter = 0

foreach ($id in $ComputerList) {
    if (([int]$id + 1) -ne ($ComputerList[$counter+1])) {
        [string]$availableid = ([int]$id + 1)
        break
    }
    else {
        $counter++
    }
}

if ($availableid.Length -eq 1) {Write-Output ($Type + "00" + $availableid)}
if ($availableid.Length -eq 2) {Write-Output ($Type + "0" + $availableid)}
if ($availableid.Length -eq 3) {Write-Output ($Type + $availableid)}

### Create test to ensure new ID is truly available before returning!