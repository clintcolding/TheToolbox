<#
.Synopsis
   Finds available computer name in AD
.DESCRIPTION
   Finds the first available computer name in AD based on a set naming scheme. The scheme must end with a three digit unique ID.
.EXAMPLE
   PS C:\bin> Get-AvailableADComputerName Desktop
   100WK054
.EXAMPLE
   PS C:\bin> Get-AvailableADComputerName Laptop
   100NB004
#>

function Get-AvailableADComputerName
{
    [CmdletBinding()]

    Param
    (
        [Parameter(Mandatory=$true,
                   Position=0)]
        [ValidateSet('Desktop','Laptop')]
        [string[]]$Type
    )

    Begin
    {
        # Declare naming convention for machine types

        switch ($Type) {
            'Desktop' { $NameConvention = '100WK' }
            'Laptop'  { $NameConvention = '100NB' }
        }
    }
    Process
    {
        # Get all computers starting with the specified descriptor.

        $Computers = Get-ADComputer -Filter * | Where-Object {$_.Name -like "$NameConvention*"} | Select-Object Name

        # Create empty array

        [System.Collections.ArrayList]$ComputerList = @()

        # Cycle through each computer in the $Computers variable and remove the $NameConvention.
        # Then add the remaining value to the $ComputerList array.

        foreach ($Name in $Computers) {
            $ID = $Name.name.replace($NameConvention,'')
            $ComputerList.add($id) | Out-Null
        }

        # Sort the array

        $ComputerList = $ComputerList | Sort-Object

        # Initialize an iteration counter

        $Counter = 0

        # Determine if the current ID + 1 is equal or not equal to the next ID
        # If equal, continue to next ID and add 1 to $Counter
        # If not equal, store ID in $availableID and break loop

        foreach ($ID in $ComputerList) {
            if (([int]$ID + 1) -ne ($ComputerList[$Counter + 1])) {
                [string]$AvailableID = ([int]$ID + 1)
                break
            }
            else {
                $Counter++
            }
        }

        # Reconstruct computername using $NameConvention and adding back leading zeros if needed

        if ($AvailableID.Length -eq 1) {$NewName = ("$NameConvention" + "00" + "$AvailableID")}
        if ($AvailableID.Length -eq 2) {$NewName = ("$NameConvention" + "0" + "$AvailableID")}
        if ($AvailableID.Length -eq 3) {$NewName = ("$NameConvention" + "$AvailableID")}

        # Test to ensure $NewName is truly available (it should return an error)
        # If $NewName is availble return $NewName, if it isn't return Write-Output

        try {Get-ADComputer $NewName -ErrorAction Stop | Out-Null
            Write-Output "Cannot find available $Type name..."}
            catch {$NewName}
    }
    End
    {
    }
}