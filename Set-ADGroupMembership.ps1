$user = "ccolding"
$group = "IT"


## Test to ensure the provided Group exists.

if ((Get-ADGroup -Filter {SamAccountName -eq $group}).Name -ne $group) {
    Write-Error -Message "The group $group does not exist. Please check spelling and try again."
}

## Once the Group is validated, test to ensure the provided User is not already a member.

else{
    if ((Get-ADPrincipalGroupMembership -Identity $user).Name -contains $group) {
        Write-Output "$user is already a member of $group"
    }

## If both tests pass, add the User to the Group.

    else {
        Add-ADGroupMember -Identity $group -Members $user

## Test to ensure the User was added to the group successfully. 

        if ((Get-ADPrincipalGroupMembership -Identity $user).Name -contains $group) {
            Write-Output -Message "$user is now a member of $group!"
        }
    }
}