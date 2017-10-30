function NumberGame {
    $number = Get-Random -Minimum 1 -Maximum 100
    $guessattempts = 1

    Write-Output "I've chosen a random number from 1 to 100, can you guess it?"

    while ($true) {
        $guess = Read-Host -Prompt "What's your guess?"

        if ($guess -eq $number) {
            if ($guessattempts -ne 1) {
                Write-Output "After $guessattempts guesses, you win!"
                break
            }
            else {
                Write-Output "After $guessattempts guess, you win!"
                break
            }
        }
        if ($guess -lt $number) {
            Write-Output "Higher!"
            $guessattempts += 1
        }
        else {
            Write-Output "Lower!"
            $guessattempts += 1
        }
    }
}