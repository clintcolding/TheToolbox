### Fixes update names when downloaded from summit-sw.com

$path = "C:\Users\ccolding\Desktop\updates"

$items = Get-ChildItem -Path $path

foreach ($item in $items) {
    if ($item.name -like "*_Downloads_Apex8_*") {
        $newname = ($item.name).replace("_Downloads_Apex8_", "")
        Rename-Item -Path $item.FullName -NewName $newname
    }
    elseif ($item.name -like "*_Downloads_*") {
        $newname = ($item.name).replace("_Downloads_", "")
        Rename-Item -Path $item.FullName -NewName $newname
    }
}