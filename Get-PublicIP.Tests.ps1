Import-Module ".\Get-PublicIP.ps1" -Force

describe 'Get-PublicIP' {

    Mock -CommandName Invoke-WebRequest -MockWith {
        $null
    }

    Mock -CommandName ConvertFrom-Json -MockWith {
        return @{IP='0.0.0.0'}
    }

    $result = Get-PublicIP

    it 'should return 0.0.0.0' {
        $result | should be '0.0.0.0'
    }
}