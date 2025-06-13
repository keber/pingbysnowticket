@{
    RootModule = 'SNOWUtils.psm1'
    ModuleVersion = '0.0.4'
    FunctionsToExport = @('Get-IPfromTicket','Set-SNOWCredential')
    GUID = '00156792-08a0-44cc-b638-7c1d5aa1d192'
    Author = 'Keber Flores'
    Description = 'Herramientas para consultar tickets de ServiceNow y extraer la IP de un ticket de Dispositivo Alarmado'
}