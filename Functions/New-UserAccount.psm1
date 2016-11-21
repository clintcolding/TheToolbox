<#
.Synopsis
   This is a helper function for New-UserAccount.
.DESCRIPTION
   New-TempPassword creates a random 20 character string and then converts it to a secure string to be passed to CreateADUser.
#>
Function NewTempPassword{

    Param(
        [int]$length=20)

    Process{
    
        $ascii=$null
    
        for($a=33; $a –le 126; $a++){
            $ascii+=,[char][byte]$a
        }

        for($i=1; $i –le $length; $i++){
            $TempPassword+=($ascii | Get-Random)
        }

        $SecurePassword=ConvertTo-SecureString -String $TempPassword -AsPlainText -Force

        $SecurePassword
    }
}

<#
.Synopsis
   This is a helper function for New-UserAccount.
.DESCRIPTION
   CreateADUser creates a new AD user account with parameters supplied by the New-UserAccount function. CreateADUser is not meant to be invoked directly.
#>
function CreateADUser{

    # Create initial user account with base attributes.

    New-ADUser -Name $Displayname -DisplayName $Displayname -GivenName $User.firstname -Surname $User.lastname -SamAccountName $Username -UserPrincipalName "$Username@mydomain.com" -AccountPassword $SecurePassword -Description $User.title -Title $User.title -Department $User.department -Manager $User.manager -Company "My Company" -HomeDrive "H:" -HomeDirectory "\\mydomain.local\shares\Home Folders\$Username" -Enabled $true

    # Set address location attributes.

    $User.office=$UserOffice

    switch ($UserOffice)  
    { 
        "Redmond"           {$Street="1 Microsoft Way"
                             $State="WA"
                             $Zip="98052"
                             $Country="US"}

        "Palo Alto"         {$Street="3401 Hillview Ave"
                             $State="CA"
                             $Zip="94304"
                             $Country="US"}

        "New York"          {$Street="405 Madison Ave"
                             $State="NY"
                             $Zip="10017"
                             $Country="US"}

        "North Platte"      {$Street="211 W 3rd St"
                             $State="NE"
                             $Zip="69101"
                             $Country="US"}

        "Default"           {Write-Host "Could not find "$UserOffice" office."}
    }
    
    Set-ADUser $Username -Office $UserOffice -StreetAddress $Street -City $UserOffice -State $State -PostalCode $Zip -Country $Country

    # Add user to global company AD group.

    Add-AdGroupMember -Identity "My Company" -Members $Username

    # Add department based AD group and logon script.

    switch ($User.department)  
    { 
        "Accounting"        {$ADGroup="Accounting"
                             $OU="OU=Accounting,OU=$UserOffice Users,OU=$UserOffice,OU=Sites,DC=A1,DC=local"}

        "Benefits"          {$ADGroup="Benefits"
                             $OU="OU=Benefits,OU=$UserOffice Users,OU=$UserOffice,OU=Sites,DC=A1,DC=local"}

        "Design"            {$ADGroup="Design"
                             $OU="OU=Design,OU=$UserOffice Users,OU=$UserOffice,OU=Sites,DC=A1,DC=local"}

        "HR"                {$ADGroup="HR"
                             $OU="OU=HR,OU=$UserOffice Users,OU=$UserOffice,OU=Sites,DC=A1,DC=local"}
		
        "IT"                {$ADGroup="IT"
                             $OU="OU=IT,OU=$UserOffice Users,OU=$UserOffice,OU=Sites,DC=A1,DC=local"}

        "Manufacturing"     {$ADGroup="Manufacturing"
                             $OU="OU=Manufacturing,OU=$UserOffice Users,OU=$UserOffice,OU=Sites,DC=A1,DC=local"}

        "QA"                {$ADGroup="QA"
                             $OU="OU=QA,OU=$UserOffice Users,OU=$UserOffice,OU=Sites,DC=A1,DC=local"}

        "Default"           {Write-Host "No department match found for "$User.department"."}
    }
    
    # Assign department based AD group.

    Add-ADGroupMember -Identity $ADGroup -Members $Username
    
    # Move user account to department OU.

    Move-ADObject -Identity "CN=$Displayname,CN=Users,DC=A1,DC=local" -TargetPath "$OU"            
}

<#
.Synopsis
   This is a helper function for New-UserAccount.
.DESCRIPTION
   CreateUserMailbox enables an Exchange mailbox for a user previously created by CreateADUser. CreateUserMailbox is not meant to be invoked directly.
#>
function CreateUserMailbox{
                
    # Load Exchange PSSnapin and create mailbox for existing user.

    Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
            
    Enable-Mailbox -Identity $Username -ErrorAction Stop | Out-Null
}

<#
.Synopsis
   Creates an AD account and Exchange mailbox for a new user.
.DESCRIPTION
   New-UserAccount creates an AD account based on parameters specified in a configuration file. After the AD account is created an Exchange mailbox is enabled for the user.
.PARAMETER Path
   This mandatory parameter is the full path to your CSV configuration file.
.PARAMETER SMTPAddress
   The SMTP Address(es) to send success/error log on completion.
.PARAMETER DeletePath
   Use the DeletePath parameter to remove the configuration file after completion.
.EXAMPLE
   Create-A1User -Path C:\newusers.txt -SMTPAddresses ccolding@a1hr.com -SendLog
#>
function New-UserAccount{

    [CmdletBinding()]
    Param(

        # Path to CSV configuration file.

        [Parameter(Mandatory=$true,
                   Position=0)]
        $Path,

        # SMTP Address(es) to send success/error log on completion.

		[Parameter()]$SMTPAddress,

        # Delete configuration file on completion.

        [Switch]$DeletePath)

    Process{
        
        # Test to ensure the path is valid.

        if(Test-Path -Path $Path){
            $ConfigData=Import-Csv -Path $Path
        }
        else{
            Write-Warning "File not found!"
            Exit
        }

        $CreateUsers=foreach($User in $ConfigData){
            
            # Convert firstname lastname into username. IE: Joe Test > jtest

            $Username=(($User.firstname).substring(0,1)+$User.lastname).ToLower()
            
            # Combine firstname and lastname with a space.

            $Displayname=$User.firstname + " " + $User.lastname

            # Initial retry count for CreateUserMailbox exception.

            $Retrycount = 0
        
            # Create the temp password for new user account.
                
            $SecurePassword=NewTempPassword
                
                # Create the AD user account.

                Try{
                    CreateADUser
                }

                Catch{
                    $ADUserError="Unable to complete AD account creation for $Username."
				    Write-Warning $ADUserError
                        if($SMTPAddress){
                            Send-MailMessage -To $SMTPAddress -From PowerShell@mycompany.com -SmtpServer mail.mycompany.com -Subject "Account Creation Error" -Body $ADUserError
                        }
                }
            
                # Enable mailbox for created users. Retry 3 times upon failure.

                Do{
                    Try{
                        CreateUserMailbox
                        break
                    }

                    # Cannot find AD user exception.

                    Catch [Microsoft.Exchange.Configuration.Tasks.ManagementObjectNotFoundException]{
                        
                        # Retry 3 times, after third, write/send error.

                        if ($RetryCount -gt 2){
                            $EmailAccountError="Could not enable mailbox for $Username after 3 attempts."
						    Write-Warning $EmailAccountError
                                if($SMTPAddress){
								    Send-MailMessage -To $SMTPAddress -From PowerShell@mycompany.com -SmtpServer mail.mycompany.com -Subject "Email Creation Error" -Body $EmailAccountError
							    }
                            break}
                        else{
                            Write-Warning "Could not execute Enable-Mailbox for $Username, attempting retry..."
                    
                            Start-Sleep -Seconds 15
                            $RetryCount++}
                    }
                }
            
                While ($true)
        
            # Final test to ensure both AD and Email account has been created.

            $ADUser=Get-Aduser -Identity $Username
            $Mailbox=Get-Mailbox -Identity $Username

            $Prop=[ordered]@{
                'Username'      = $ADUser.SamAccountName
                'Email Address' = $Mailbox.UserPrincipalName}

            $Obj=New-Object -TypeName PSObject -Property $Prop

            $Obj
        }

        # Sending optional log or writing to console.

        if($SMTPAddress){
            $Body=$CreateUsers | ConvertTo-Html | Out-String

            Send-MailMessage -To $SMTPAddress -From PowerShell@mycompany.com -SmtpServer mail.mycompany.com -Subject "New Accounts Successfully Created" -Body $Body -BodyAsHtml
        }
            
        else{    
            Write-Output $CreateUsers}
        
        # Removes source file is DeletePath switch is used.

        if($DeletePath){
        Remove-Item -Path $Path -Force
        }
    }
}