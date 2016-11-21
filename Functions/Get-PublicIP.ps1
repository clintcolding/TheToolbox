<#
.Synopsis
   A simple function that returns your public IP.
.DESCRIPTION
   A simple function that returns your public IP using the ipify.org API.
.EXAMPLE
   PS C:\bin> Get-PublicIP
   104.21.78.41
#>
function Get-PublicIP
{
    Process
    {
        $IP = Invoke-WebRequest https://api.ipify.org?format=json -Method Get | ConvertFrom-Json

        $IP.ip
    }
}