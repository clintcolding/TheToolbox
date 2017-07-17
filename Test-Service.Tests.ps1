Import-Module ".\Test-Service.ps1" -Force

Describe 'Test-Service' {

    Mock -CommandName Get-Service -MockWith {
        return @{Status='Running'}
    }

    Mock -CommandName Write-Verbose -MockWith {
    } -ParameterFilter {
        $Message -eq "[$Server]    Testing $Service service"
    }
    
    Mock -CommandName Write-Verbose -MockWith {
        Write-Output "[$Server]    PASSED"
    } -ParameterFilter {
        $Message -eq "[$Server]    PASSED"
    }

    $result = Test-Service -ComputerName TEST01 -Service TEST

    it 'should return PASSED' {
        $result | should be "[TEST01]    PASSED"
    }
}