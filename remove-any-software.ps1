# Objective: Uninstall Any Software
# Author: Fábio Santos
# Date: 13/03/2024 



# Define os diretórios onde os programas podem ser encontrados
$programFilesDirs = @("C:\Program Files", "C:\Program Files (x86)", "C:\")

# Define a lista de softwares a serem removidos, cada entrada contém o nome do programa e os nomes dos executáveis de desinstalação
$programsToUninstall = @(
    @{
        Name = "Driver Booster"
        UninstallExeNames = @("unins000.exe")
        SilentArgs = @("/VERYSILENT")
    },
    @{
        Name = "Driver Easy"
        UninstallExeNames = @("unins000.exe")
        SilentArgs = @("/VERYSILENT")
    },
    @{
        Name = "WinRAR"
        UninstallExeNames = @("uninstall.exe")
        SilentArgs = @("/S")
    },
    @{
        Name = "Steam"
        UninstallExeNames = @("uninstall.exe")
        SilentArgs = @("/S")
    },
    @{
        Name = "CCleaner"
        UninstallExeNames = @("uninst.exe")
        SilentArgs = @("/S")
    },
    @{
        Name = "Defraggler"
        UninstallExeNames = @("uninst.exe")
        SilentArgs = @("/S")
    },
    @{
        Name = "EditPad Pro 8"
        UninstallExeNames = @("UnDeploy64.exe")
        SilentArgs = @("/SILENT")
    },
    @{
        Name = "LDPlayer" # Obs.: No momento, não encontrei um parâmetro silent para esse software
        UninstallExeNames = @("uninstall.exe", "uninst.exe", "UnDeploy64.exe", "dnuninst.exe")
        SilentArgs = @("/VERYSILENT", "/SILENT", "/SUPPRESSMSGBOXES")
    },
    @{
        Name = "010 Editor"
        UninstallExeNames = @("unins000.exe")
        SilentArgs = @("/silent")
    }
    # Adicione mais programas conforme necessário
)

# Loop através de cada programa
foreach ($programInfo in $programsToUninstall) {
    $programName = $programInfo.Name
    $uninstallExeNames = $programInfo.UninstallExeNames
    $silentArgs = $programInfo.SilentArgs

    $programDir = $null
    $uninstallExePath = $null

    # Procura o diretório do programa
    foreach ($dir in $programFilesDirs) {
        $programDir = Get-ChildItem -Path $dir -Filter $programName -Recurse -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($programDir) {
            Write-Output "Diretório do $programName encontrado: $($programDir.FullName)"
            break
        }
    }

    # Verifica se o diretório do programa foi encontrado
    if (-not $programDir) {
        Write-Output "Diretório do $programName não encontrado."
        continue
    }

    # Procura pelos arquivos de desinstalação dentro do diretório do programa
    foreach ($exeName in $uninstallExeNames) {
        $uninstallExePath = Get-ChildItem -Path $programDir.FullName -Filter $exeName -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($uninstallExePath) {
            Write-Output "Arquivo $exeName encontrado em: $($uninstallExePath.FullName)"
            break
        }
    }

    # Verifica se o arquivo de desinstalação foi encontrado
    if (-not $uninstallExePath) {
        Write-Output "Nenhum arquivo de desinstalação encontrado para $programName dentro do diretório."
        continue
    }

    # Loop através de cada conjunto de argumentos silenciosos
    foreach ($arg in $silentArgs) {
        # Executa o desinstalador de forma silenciosa
        $process = Start-Process -FilePath $uninstallExePath.FullName -ArgumentList $arg -PassThru -Wait
        if ($process.ExitCode -eq 0) {
            Write-Output "$programName desinstalado com sucesso usando o argumento: $arg."
            break
        } else {
            Write-Output "Erro ao desinstalar o $programName com o argumento $arg. Código de saída: $($process.ExitCode)"
        }
    }
}
