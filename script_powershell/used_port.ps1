[System.Collections.ArrayList]$array_port_used = @{}

Function Get-ListeningTCPConnections {            
[cmdletbinding()]            
param(            
)            
            
try {            
    $TCPProperties = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()            
    $Connections = $TCPProperties.GetActiveTcpListeners()            
    foreach($Connection in $Connections) {            
        if($Connection.address.AddressFamily -eq "InterNetwork" ) { $IPType = "IPv4" } else { $IPType = "IPv6" }            
            $array_port_used.Add($Connection.Port)  
    }            
            
} catch {            
    Write-Error "Failed to get listening connections. $_"            
}  

Write-Host "Report used port OK"
return $array_port_used
         
}