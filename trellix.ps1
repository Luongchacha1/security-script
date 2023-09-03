Write-Output "Dam bao may co ket noi den ePO Server. Trong truong hop su dung Trellix Product Removal thi can reboot lai may neu khong se gay loi"
# Chay cau lenh Set-ExecutionPolicy -Scope CurrentUser Unrestricted -Force truoc khi chay cau len
# Variable that contain URL and exe path file

$8GB_URL = "https://mcafeeav.vietsov.com.vn:8443/ComputerMgmt/agentPackageDownload/TrellixSmartInstall.download?token=fdc492ea51218317133d86f41af86e5b1ba0265b"
$4GB_URL = "https://mcafeeav.vietsov.com.vn:8443/ComputerMgmt/agentPackageDownload/TrellixSmartInstall.download?token=456779a2b313c54a5461b5f79437d8368289a238"
$2GB_URL = "https://mcafeeav.vietsov.com.vn:8443/ComputerMgmt/agentPackageDownload/TrellixSmartInstall.download?token=1d6ea560f84ea9aac19d04e9b93f79961d93d17a"

$trellixfile = "C:\TEMP\trellix.exe"
$trellixfolder = "C:\TEMP"
$TrellixAgentStatus = (Get-Service -Name masvc -ErrorAction SilentlyContinue | Select Status).Status
#Change location
$TestTEMP = Test-Path -Path $trellixfolder
if(-Not $TestTEMP){
    mkdir C:\TEMP > null
}
# check memory of computer
$RamFilter = (systeminfo | Select-String 'Total Physical Memory:').ToString().Split(':')[1].Trim()
$RamValue = $RamFilter.ToString().Split(' ')[0].Trim()
try{
    [int]$RamValue = $RamValue.Replace("," , "")
}
catch {
}


$RAM = $RamValue/1024

# Skip SSL Certificate Checking

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

# Install  Trellix Agent and Check

if ($TrellixAgentStatus -eq "Running") {
    write-output "Trellix Agent is installed, script will be end!"
    break
}
elseif ($RAM -ge 6) {

    #Download file, if fail, finish script!
    try{
        (New-Object System.Net.WebClient).DownloadFile($8GB_URL, $trellixfile)
    } catch {
        Write-Output $Error[0]
        break
    }

    #Install trellix agent silently and write logs into this path file <Documents and Settings>\<User>\Local\Temp\McAfeeLogs.
    & $trellixfile -g -s
    $Solan =  20 # Cho 20*3 giay
    $TrellixAgentStatus = (Get-Service -Name masvc -ErrorAction SilentlyContinue | Select Status).Status
    while($Solan -ne 0){
        $TrellixAgentStatus = (Get-Service -Name masvc -ErrorAction SilentlyContinue | Select Status).Status
        Start-Sleep -Seconds 3
        $Solan -= 1
        if($TrellixAgentStatus -eq "Running"){break}
    }
    
    $TrellixTP = (get-process -ProcessName mcshield -ErrorAction SilentlyContinue).Id
    $Sogio = 1800
    & $Env:Programfiles\McAfee\Agent\cmdagent.exe -c > null
    start-sleep -Seconds 3
    & $Env:Programfiles\McAfee\Agent\cmdagent.exe -p > null
    start-sleep -Seconds 3
    while($TrellixTP -eq $null){
        $TrellixTP = (get-process -ProcessName mcshield -ErrorAction SilentlyContinue).Id
        if($Sogio -gt 0){
            & $Env:Programfiles\McAfee\Agent\cmdagent.exe -c > null
               start-sleep -Seconds 15
            & $Env:Programfiles\McAfee\Agent\cmdagent.exe -p > null
            start-sleep -Seconds 45
            $Sogio -=  60
            if($TrellixTP -ne $null){break}
        }
    }
}
elseif (($RAM -lt 6) -AND ($RAM -ge 3)) {

    #Download file, if fail, finish script!
    try{
        (New-Object System.Net.WebClient).DownloadFile($4GB_URL, $trellixfile)
    } catch {
        Write-Output $Error[0]
        break
    }

    #Install trellix agent silently and write logs into this path file <Documents and Settings>\<User>\Local\Temp\McAfeeLogs.
    & $trellixfile -g -s
    $Solan =  20 # Cho 20*3 giay
    $TrellixAgentStatus = (Get-Service -Name masvc -ErrorAction SilentlyContinue | Select Status).Status
    while($Solan -ne 0){
        $TrellixAgentStatus = (Get-Service -Name masvc -ErrorAction SilentlyContinue | Select Status).Status
        Start-Sleep -Seconds 3
        $Solan -= 1
        if($TrellixAgentStatus -eq "Running"){break}
    }
    
    $TrellixTP = (get-process -ProcessName mcshield -ErrorAction SilentlyContinue).Id
    $Sogio = 1800
    & $Env:Programfiles\McAfee\Agent\cmdagent.exe -c > null
    start-sleep -Seconds 3
    & $Env:Programfiles\McAfee\Agent\cmdagent.exe -p > null
    start-sleep -Seconds 3
    while($TrellixTP -eq $null){
        $TrellixTP = (get-process -ProcessName mcshield -ErrorAction SilentlyContinue).Id
        if($Sogio -gt 0){
            & $Env:Programfiles\McAfee\Agent\cmdagent.exe -c > null
               start-sleep -Seconds 15
            & $Env:Programfiles\McAfee\Agent\cmdagent.exe -p > null
            start-sleep -Seconds 45
            $Sogio -=  60
            if($TrellixTP -ne $null){break}
        }
    }
}
else{

    #Download file, if fail, finish script!
    try{
        (New-Object System.Net.WebClient).DownloadFile($2GB_URL, $trellixfile)
    } catch {
        Write-Output $Error[0]
        break
    }

    #Install trellix agent silently and write logs into this path file <Documents and Settings>\<User>\Local\Temp\McAfeeLogs.
    & $trellixfile -g -s
    $Solan =  20 # Cho 20*3 giay
    $TrellixAgentStatus = (Get-Service -Name masvc -ErrorAction SilentlyContinue | Select Status).Status
    while($Solan -ne 0){
        $TrellixAgentStatus = (Get-Service -Name masvc -ErrorAction SilentlyContinue | Select Status).Status
        Start-Sleep -Seconds 3
        $Solan -= 1
        if($TrellixAgentStatus -eq "Running"){break}
    }
    
    $TrellixTP = (get-process -ProcessName mcshield -ErrorAction SilentlyContinue).Id
    $Sogio = 1800
    & $Env:Programfiles\McAfee\Agent\cmdagent.exe -c > null
    start-sleep -Seconds 3
    & $Env:Programfiles\McAfee\Agent\cmdagent.exe -p > null
    start-sleep -Seconds 3
    while($TrellixTP -eq $null){
        $TrellixTP = (get-process -ProcessName mcshield -ErrorAction SilentlyContinue).Id
        if($Sogio -gt 0){
            & $Env:Programfiles\McAfee\Agent\cmdagent.exe -c > null
               start-sleep -Seconds 15
            & $Env:Programfiles\McAfee\Agent\cmdagent.exe -p > null
            start-sleep -Seconds 45
            $Sogio -=  60
            if($TrellixTP -ne $null){break}
        }
    }
}