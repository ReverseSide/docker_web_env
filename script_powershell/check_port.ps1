Import-module .\script_powershell\used_port.ps1
$array_port_used = Get-ListeningTCPConnections

[System.Collections.ArrayList]$array_port = @{}

Function Get-FreePorts {                      
    param(  
        [Parameter(Mandatory=$true, Position=0)]
        [int]$1sPort,
        [Parameter(Mandatory=$true, Position=1)]
        [int]$NbOfNeededPorts       
    )      
    
    $port = $1sPort
    $needed_port = $NbOfNeededPorts

    while( $array_port.Count -lt $needed_port)
    {

        If (-not ($array_port_used -contains $port)){
            $array_port.Add($port) | Out-Null
        }
        $port = $port + 1
  
    }

    return $array_port
    
}