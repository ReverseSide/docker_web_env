$linebelow_ports=$false

$array = @{}

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
      
    }
    
    
    if ($_ -like '*container_name*'){

         $container_name = $_.Substring($_.IndexOf(":")+2)
         $container_name = $container_name.Substring(0, $container_name.IndexOf("_"))
         $container_name = $Project_Name+"."+$container_name
    }

    if ($_ -like '*ports*') {

        if ($_ -like '*-*:*'){

            $container_ports = $_.Substring($_.IndexOf('"')+1)
            $container_ports = $container_ports.Substring(0, $container_ports.IndexOf(":"))


        }
        else {

            $linebelow_ports = $true
   
        }       
    }

    if ((![string]::IsNullOrEmpty($container_ports)) -and (![string]::IsNullOrEmpty($container_name))){
        $array.Add($container_name,$container_ports)
        $container_ports = $null
        $container_name = $null
    }

 }


 if (!(Test-Path ".ergo"))
{
   New-Item -name .ergo -type "file"
}

 Write-Host Write-Host ($array | Out-String) 

 Foreach ($hostdocker in $array.GetEnumerator()){
 
    $ergoadd = $hostdocker.Name  +" http://localhost:" + $hostdocker.Value
    Add-Content .ergo $ergoadd

 }

 $command = '"ergo run"'
iex "& $command"