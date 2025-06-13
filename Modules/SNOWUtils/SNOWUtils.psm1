function Get-IPfromTicket {

param(
    [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true)]
        [string]$ticketNumber,
    [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true)]
        [string]$instance,
    [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true)]
        [string]$ticketField,
    [Parameter()][string]$Target = "ServiceNowAPI"
)


$cred = Get-StoredCredential -Target "$Target"
if (-not $cred) {
    throw "No se encontraron credenciales guardadas para '$credName'. Ejecuta Set-SNOWCredential para configurarlas."
}

$uri = "https://$instance.service-now.com/api/now/table/incident?sysparm_query=number=$ticketNumber&sysparm_fields=number,description,state"

try {
    $response = Invoke-RestMethod -Uri $uri -Method Get -Credential $cred -Header @{Accept = 'application/json'}
    if ($response.result) {
            $descriptionText = $response.result.description

	    $descripcion = @{}
	    $descriptionText -split "`n" | ForEach-Object {
                if ($_ -match '^(.*?):\s*(.*)$') {
                    $key = $matches[1].Trim()
                    $value = $matches[2].Trim()
                    $descripcion[$key] = $value
                }   
            }
            if ($descripcion.ContainsKey($ticketField)) {
                return $descripcion[$ticketField]
            }
            else {
                throw "Campo '$ticketField' no encontrado en la descripcion del ticket"
            }
        }
    else{
        throw "Ticket [$ticketNumber] no encontrado"
    }
}
catch {
    throw "Error al obtener el ticket [$ticketNumber]: $($_.Exception.Message)"
}
}

function Set-SNOWCredential {
    param (
        [Parameter(Mandatory)]
        [string]$Usuario
    )
    $credName = "ServiceNowAPI"

    try {
	$cred = Get-StoredCredential -Target "$credName"
	$alreadyExists = $($cred -ne $null)
        $cred = Get-Credential -UserName $Usuario -Message "Ingresa la contraseña de tu cuenta ServiceNow"
        $result = New-StoredCredential -Target "$credName" -Username $cred.UserName -Password $cred.GetNetworkCredential().Password -Persist LocalMachine | Out-Null
        
	$cred = Get-StoredCredential -Target "$credName"
	if ($cred -and (-not $alreadyExists)) {
	        Write-Output "Credencial '$credName' creada."
                Write-Output "`nPuede eliminarla con Remove-StoredCredential -Target [nombreCredencial]"
        }
        elseif ($cred) {
            Write-Output "Credencial '$credName' actualizada."
        }
        else {
            throw "Error desconocido: No se pudo guardar la credencial"
        }
    }
    catch {
        throw "Error al crear la Credencial: $($_.Exception.Message)"
    }
}