function Get-AvailableADComputerName
{
    [CmdletBinding()]

    Param
    (
        [Parameter(Mandatory=$true,
                   Position=0)]
        [ValidateSet('100NB','100WK')]
        [string[]]$Type
    )

    Begin
    {
    }
    Process
    {
        # Get all computers starting with the specified descriptor.

        $Computers = Get-ADComputer -Filter * | Where-Object {$_.Name -like "$Type*"} | Select-Object Name

        # Create empty array

        [System.Collections.ArrayList]$ComputerList = @()

        # Cycle through each computer in the $Computers variable and remove the $Type.
        # Then add the remaining value to the $ComputerList array.

        foreach ($Name in $Computers) {
            $ID = $Name.name.replace($Type,'')
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

        # Reconstruct computername using $Type and adding back leading zeros if needed

        if ($AvailableID.Length -eq 1) {$NewName = ("$Type" + "00" + "$AvailableID")}
        if ($AvailableID.Length -eq 2) {$NewName = ("$Type" + "0" + "$AvailableID")}
        if ($AvailableID.Length -eq 3) {$NewName = ("$Type" + "$AvailableID")}

        # Test to ensure $NewName is truly available (it should return an error)
        # If $NewName is availble return $NewName, if it isn't return Write-Output

        try {Get-ADComputer $NewName -ErrorAction Stop | Out-Null
            Write-Output "Cannot find available ID for $Type"}
            catch {$NewName}
    }
    End
    {
    }
}