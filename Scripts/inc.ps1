[CmdletBinding()]
param (
	$incidentNumber
)
$ConfigPath  = "$PSScriptRoot\..\Config"
$ScriptsPath = "$PSScriptRoot\..\Scripts"
$ModulesPath = "$PSScriptRoot\..\Modules"

$Config = Import-PowerShellDataFile -Path "$ConfigPath\settings.psd1"
Import-Module "$ModulesPath\SNOWUtils" -Force

$IP = Get-IPfromTicket -ticketNumber $incidentNumber -instance $Config.SNOWInstance -ticketField $Config.SNOWField -Target $Config.SNOWCredsName

if ($IP -ne $null) {
    $IPisReachable = Test-Connection $IP -Count 1 -Quiet

    $dailyServiceLogBasePath = $Config.DailyServiceLogBasePath
    $templatePath = $Config.TemplatePath
    $templateFile = Join-Path $Config.TemplatePath $Config.TemplateFileName

    $yearPath = Join-Path $dailyServiceLogBasePath $(Get-Date -Format "yyyy")
    $monthPath = Join-Path $yearPath $(Get-Date -Format "MM")
    $dayPath = Join-Path $monthPath $(Get-Date -Format "dd")

    New-Item -ItemType Directory -Path $yearPath -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $monthPath -ErrorAction SilentlyContinue  
    New-Item -ItemType Directory -Path $dayPath -ErrorAction SilentlyContinue  


    $folderName = "{0}" -f $incidentNumber
    $destinationPath = Join-Path $dayPath $folderName

    New-Item -ItemType Directory -Path $destinationPath -Force > $null

    clear
    $startTime = Get-Date

    Write-Host $startTime

    ping $IP

    $endTime = Get-Date
    Write-Host ""
    Write-Host $endTime


    & "$ScriptsPath\Get-Screenshot.ps1" -destinationPath "$destinationPath"

    if($IPisReachable) {
        $template = Get-Content "$templateFile"
        $modifiedTemplate = ($template).replace("{Fecha_y_Hora}",$(Get-Date -Format "dd-MM-yyy - HH:mm"))

        $modifiedTemplateFile = Join-Path $destinationPath $incidentNumber".txt"
        Set-Content -Path "$modifiedTemplateFile" -Value $modifiedTemplate

        start notepad "$modifiedTemplateFile"
    }
    else {
        Write-Host "No hay conectividad con la IP $IP. Intente más tarde."
    }
}
else {
    Write-Host "No se pudo obtener la IP del ticket $incidentNumber"
}