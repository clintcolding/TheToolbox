# The Toolbox

The Toolbox is a catch all for my miscellaneous functions.

## Module Overview

* Active Directory
    - Test-ADComputer - Returns online/offline status of AD computers.
    - Update-UPN - Updates the UserPrincipleName for a selection of AD users.
+ Desired State Configuration
    - Compile-DSCConfiguration - Compiles your DSC configuration MOFs and copies them to your pull server.
- Exchange
    - Remove-AutoMapping - Removes automapped Exchange 2013 mailboxes from Outlook while preserving the underlying access rights.
* Utilities
    - Get-FreeSpace - Displays available free space on local and remote computers.
    - Get-LastUpdate - Gets the last update installed on a computer.
    - Get-LoggedOnUser - Gets the current logged on user account.
    - Get-PublicIP - A simple function that returns your public IP.
    - Get-SysInfo - Gathers local and/or remote system information.
    - New-Password - Generates a random password using ASCII printable characters.
    - Update-ComputerDescription - Updates the description of specified remote computers.
+ VMware
    - Create-VM - Creates a VMware virtual machine based on environment specific values.
    - Map-Datastore - Maps a VMware datastore to a PSDrive.