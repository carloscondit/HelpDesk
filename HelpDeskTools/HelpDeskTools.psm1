<#
.SYNOPSIS
    Командлет для принудительной очистки каталога с файлами очереди печати.
.DESCRIPTION
    Командлет на локальном или удаленном компьютере останаливает службу печати,
    принудительно очищает каталог с файлами очереди печати и запускает службу печати.
.EXAMPLE
    PS C:\> Reset-Spooler -ComputerName HV-IT -Verbose
    VERBOSE: Начало работы командлета
    VERBOSE: Устанавливаем связь с компьютером HV-IT
    VERBOSE: Выполняем скриптоблок на компьютере HV-IT
    VERBOSE: Прерываем связь с компьютером HV-IT
    VERBOSE: Конец работы командлета
    PS C:\>
    Командлет выполнится на удаленном компьютере с именем HV-IT с выводом подробной информации.
.INPUTS
    System.String
.NOTES

#>
function Reset-Spooler {
    [CmdletBinding()]
    param (
        # Имя компьютера или список имен компьютеров
        [Parameter(Mandatory = $true,
            ValueFromPipeLine = $true,
            Position = 0,
            HelpMessage = "Введите одно или более имен компьютеров.")]
        [String[]]$ComputerName
    )
    
    begin {
        Write-Verbose "Начало работы функции"
        Set-StrictMode –Version 2.0
    }
    
    process {
        Write-Verbose "Устанавливаем связь с компьютером $ComputerName"
        $Session = New-PSSession -ComputerName $ComputerName
        $ScriptBlock = {
            $ServiceName = 'Spooler'
            Stop-Service -Name $ServiceName
            $SpoolerFolder = "$($(Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Print\Printers').DefaultSpoolDirectory)"
            Remove-Item "$SpoolerFolder\*" -Recurse -Force
            Start-Service -Name $ServiceName 
        }
        
        Write-Verbose "Выполняем скриптоблок на компьютере $ComputerName"
        Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock

        Write-Verbose "Прерываем связь с компьютером $ComputerName"
        Remove-PSSession -Session $Session

    }
    
    end {
        Write-Verbose "Конец работы функции" 
    }
}