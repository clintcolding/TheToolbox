[DSCLocalConfigurationManager()]
Configuration LCM_HTTPPULL 
{
    param
        (
            [Parameter(Mandatory=$true)]
            [string[]]$ComputerName,

            [Parameter(Mandatory=$true)]
            [string]$guid
        )      	
	Node $ComputerName
	{
		Settings
		{
			AllowModuleOverwrite = $True
            ConfigurationMode = 'ApplyAndAutoCorrect'
			RefreshMode = 'Pull'
			ConfigurationID = $guid
        }

        ConfigurationRepositoryWeb PullServer 
        {
            ServerURL = 'http://ps:8080/PSDSCPullServer.svc'
            AllowUnsecureConnection = $true
        }
	}
}

$computername = 's5'

LCM_HTTPPULL -ComputerName $computername -GUID $([GUID]::NEWGUID()) -OutputPath C:\DSC\HTTP\LCM
#Set-DscLocalConfigurationManager -Path C:\DSC\HTTP\LCM -ComputerName $computername