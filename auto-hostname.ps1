Import-module .\check_port.ps1

$linebelow_ports=$false
$array = @{}
[System.Collections.ArrayList]$container_name_array = @{}
[int]$port_start=8080

#Create var by reading .env file
Get-Content .env | Foreach-Object{
   $var = $_.Split('=')
   #If var exist (re)set the value 
   if (Get-Variable -Name $var[0] -ErrorAction SilentlyContinue){
    Set-Variable -Name $var[0] -Value $var[1]
   }
   #Else create the var
   else{
    New-Variable -Name $var[0] -Value $var[1]
   }
}


#Count Nomber of Container
$FileContent = Get-Content "docker-compose.yml"
$Matches = Select-String -InputObject $FileContent -Pattern "container_name :" -AllMatches
$Nb_Container = $Matches.Matches.Count

#Request Free Port
$array_port = (Get-FreePorts $port_start $Nb_Container)

#Parse the YML
Get-Content docker-compose.yml | ForEach-Object -Begin {} -Process {} -End {}{

    #If port seems to be on the second line
    if ($linebelow_ports -eq $true){
        if($_ -like '*-*:*'){
            #String manipulation for extract port
            $container_ports = $_.Substring($_.IndexOf('"')+1)
            $container_ports = $container_ports.Substring(0, $container_ports.IndexOf(":"))
        }
        $linebelow_ports = $false
    }

    #If line containe the name of container  
    if ($_ -like '*container_name*'){
         #Recontruct the name of container with .env var
         $container_name = $_.replace('${Project_Name}',$Project_Name)
         $container_name = $container_name.Substring($_.IndexOf(':')+1)
         $container_name_array.Add($container_name) | Out-Null
         $port_container = $array_port[$container_name_array.Count -1 ]
         
         Add-Content .env $container_name"_port="$port_container
    }
    #If line containe ports of container
    if ($_ -like '*ports*') {
        if ($_ -like '*-*:*'){
            $container_ports = $_.Substring($_.IndexOf('"')+1)
            $container_ports = $container_ports.Substring(0, $container_ports.IndexOf(":"))
        }
        else {
            #If port is not on the same line
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