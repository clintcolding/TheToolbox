Import-Module ".\Test-Service.ps1" -Force

Describe 'Test-Service' {

    Mock -CommandName Write-Verbose -MockWith {
    } -ParameterFilter {
        $Message -eq "[$Server]    Testing $Service service"
    }

    Context 'When service is running' {

        Mock -CommandName Get-Service -MockWith {
            return @{Status='Running'}
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

    Context 'When service is stopped and successfully started' {

        $Script:MockCounter = 0

        Mock -CommandName Get-Service -MockWith {
            $Script:MockCounter++
            if ($Script:MockCounter -eq 0) {
                return @{Status='Stopped'}
            }
            if ($Script:MockCounter -eq 1) {
                return @{Status='Running'}
            }
        }

        Mock -CommandName Write-Warning -MockWith {
            Write-Output "[$Server]    FAILED"
        } -ParameterFilter {
            $Message -eq "[$Server]    FAILED"
        }

        Mock -CommandName Write-Verbose -MockWith {
            Write-Output "[$Server]    PASSED"
        } -ParameterFilter {
            $Message -eq "[$Server]    PASSED"
        }

        Mock -CommandName Write-Warning -MockWith {
        } -ParameterFilter {
            $Message -eq "[$Server]    Starting $Service service"
        }

        Mock -CommandName Invoke-Command -MockWith {}

        $result = Test-Service -ComputerName TEST01 -Service TEST

        It 'should return PASSED' {
            $result | should be "[TEST01]    PASSED"
        }
    }

    Context 'When service is stopped and cannot be started' {

        Mock -CommandName Get-Service -MockWith {
            return @{Status='Stopped'}
        }

        Mock -CommandName Write-Warning -MockWith {
        } -ParameterFilter {
            $Message -eq "[$Server]    FAILED"
        }

        Mock -CommandName Write-Warning -MockWith {
        } -ParameterFilter {
            $Message -eq "[$Server]    Starting $Service service"
        }

        Mock -CommandName Write-Warning -MockWith {
            Write-Output "[$Server]    Cannot start $Service service"
        } -ParameterFilter {
            $Message -eq "[$Server]    Cannot start $Service service"
        }

        Mock -CommandName Invoke-Command -MockWith {}

        $result = Test-Service -ComputerName TEST01 -Service TEST

        It 'should return cannot start service' {
            $result | should be "[TEST01]    Cannot start TEST service"
        }
    }
}