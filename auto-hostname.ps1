$nbline=0
$linebelow_ports=false as boolean
#Create var by reading .env file

Get-Content .env | Foreach-Object{
   $var = $_.Split('=')
   New-Variable -Name $var[0] -Value $var[1]
}

Write-Host $Project_Name

Get-Content docker-compose.yml | ForEach-Object -Begin {} -Process {} -End {}{

    if ($linebelow_ports -eq $true){
    
        
        if($_ -like '*-*:*'){

            $container_ports = $_.Substring($_.IndexOf('"')+1)
            $container_ports = $container_ports.Substring(0, $container_ports.IndexOf(":"))

        }

        $linebelow_ports = $false
        Write-Host $container_ports
    }
    
    
    
    if ($_ -like '*container_name*'){

         $container_name = $_.Substring($_.IndexOf(":")+2)
         $container_name = $container_name.Substring(0, $container_name.IndexOf("_"))
         Write-Host $Project_Name"."$container_name".dev"
    }

    if ($_ -like '*ports*') {

        if ($_ -like '*-*:*'){

            $container_ports = $_.Substring($_.IndexOf('"')+1)
            $container_ports = $container_ports.Substring(0, $container_ports.IndexOf(":"))

             Write-Host $container_ports

        }
        else {

            $linebelow_ports = $true
   
        }

      
       
    }

    
   
 }
