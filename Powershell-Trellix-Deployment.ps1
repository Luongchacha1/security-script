############################Function############################
function Caculate-RAM{
    $RamFilter = (systeminfo | Select-String 'Total Physical Memory:').ToString().Split(':')[1].Trim()
    $RamValue = $RamFilter.ToString().Split(' ')[0].Trim()
    try{
        [int]$RamValue = $RamValue.Replace("," , "")
    }
    catch{
    }
    $RAM = $RamValue/1024
    return $RAM
}

function Install-TrellixAgent{
    Param(
        [String]$AgentURL,
        [String]$TrellixFilePath
    )
    $TrellixAgentStatus = (Get-Service -Name masvc -ErrorAction SilentlyContinue | Select Status).Status
    if ($TrellixAgentStatus -ne "Running") {
        # Skip SSL Certificate Checking
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
        #Download file, if fail, finish script!
        try{
            (New-Object System.Net.WebClient).DownloadFile($AgentURL, $TrellixFilePath)
        } catch {
            Write-Output $Error[0]
            break
        }
        #Install trellix agent silently and write logs into this path file <Documents and Settings>\<User>\Local\Temp\McAfeeLogs.
        & $TrellixFilePath -g -s
        $Solan =  60 # Cho 60*3 giay
        $TrellixAgentStatus = (Get-Service -Name masvc -ErrorAction SilentlyContinue | Select Status).Status
        while($Solan -ne 0){
            $TrellixAgentStatus = (Get-Service -Name masvc -ErrorAction SilentlyContinue | Select Status).Status
            Start-Sleep -Seconds 3
            $Solan -= 1
            if($TrellixAgentStatus -eq "Running"){
                & $Env:Programfiles\McAfee\Agent\cmdagent.exe -c > null
                start-sleep -Seconds 3
                & $Env:Programfiles\McAfee\Agent\cmdagent.exe -p > null
                start-sleep -Seconds 3
                break
            }
        }
    }
    else{
            write-output "Trellix Agent is installed, script will install ENS!"
        }
}

function Install-TrellixENS{
    Param(
        [String]$ENS_URL,
        [String]$TrellixENSZipPath,
        [String]$TrellixENSFilePath
    )
    $TrellixTP = (get-process -ProcessName mcshield -ErrorAction SilentlyContinue).Id
    if($TrellixTP -eq $null){
        #Download file, if fail, finish script!
        try{
        (New-Object System.Net.WebClient).DownloadFile($ENS_URL, $TrellixENSZipPath)
        } catch {
            Write-Output $Error[0]
            break
        }
        Set-Location $ENV:TEMP
        Expand-Archive -Path $TrellixENSZipPath -Force
        cmd.exe /c $TrellixENSFilePath ADDLOCAL="tp" INSTALLDIR="C:\Program Files\McAfee\Endpoint Security" /l"C:\windows\Temp\McAfeeLogs"
        & $Env:Programfiles\McAfee\Agent\cmdagent.exe -c > null
        start-sleep -Seconds 3
        & $Env:Programfiles\McAfee\Agent\cmdagent.exe -p > null
        start-sleep -Seconds 3
    }
}

########################### Trellix Agent and ENS Installation ####################################
# Chay cau lenh Set-ExecutionPolicy -Scope CurrentUser Unrestricted -Force truoc khi chay cau len
# Variable that contain URL and exe path file

$8GB_URL = ""
$4GB_URL = ""
$2GB_URL = ""

$ENS_URL = "http://192.168.111.149:8000/Trellix/TrellixENS.zip"

$TrellixENSZipPath = "$ENV:TEMP\TrellixENS.zip"

$TrellixFilePath = "$ENV:TEMP\TrellixSmartInstall.exe"

$TrellixENSFilePath = "$ENV:TEMP\TrellixENS\setupEP.exe"

# Tinh Ram
$RAM = Caculate-RAM

# Cai Agent va ENS
if ($RAM -ge 6) {
    Install-TrellixAgent $8GB_URL $TrellixFilePath
    Install-TrellixENS $ENS_URL $TrellixENSZipPath $TrellixENSFilePath
}
elseif (($RAM -lt 6) -AND ($RAM -ge 3)) {
    Install-TrellixAgent $4GB_URL $TrellixFilePath
    Install-TrellixENS $ENS_URL $TrellixENSZipPath $TrellixENSFilePath
}
else{
    Install-TrellixAgent $2GB_URL $TrellixFilePath
    Install-TrellixENS $ENS_URL $TrellixENSZipPath $TrellixENSFilePath
}