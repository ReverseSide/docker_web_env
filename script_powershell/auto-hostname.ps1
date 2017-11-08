Import-module .\script_powershell\check_port.ps1

$linebelow_ports=$false
$array = @{}
[System.Collections.ArrayList]$container_name_array = @{}
[System.Collections.ArrayList]$array_port = @{}
[int]$port_start=8080
[int]$cut_line=0
$AlreayFind=$false

#Create var by reading .env file and delete port part
Get-Content .env | Foreach-Object{
   
   if($_ -like '*Port for each container*' -And $AlreayFind -eq $false ){
    $cut_line = $_.ReadCount -1
    $AlreayFind=$true
   }
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

#Delete row after #Port for each container in the .env file
$content = Get-Content .env -TotalCount $cut_line
Set-Content -path .env $content

Add-Content -path .env "#Port for each container"

#Count Nomber of Container
$FileContent = Get-Content "docker-compose.yml"
$Matches = Select-String -InputObject $FileContent -Pattern "container_name :" -AllMatches
$Nb_Container = $Matches.Matches.Count

#Request Free Port
$array_port = (Get-FreePorts $port_start $Nb_Container)

#Parse the YML
Get-Content docker-compose.yml | ForEach-Object -Begin {} -Process {} -End {}{

    #If line containe the name of container  
    if ($_ -like '*container_name*'){
         #Recontruct the name of container with .env var
         $container_name = $_.Substring($_.IndexOf(':')+2)
         $container_name = $container_name.replace('${Project_Name}',"")
         $container_name = $container_name.Substring(0, $container_name.Length-1)
         $container_name_array.Add($container_name) | Out-Null
         $container_ports = $array_port[$container_name_array.Count -1 ]
         
         Add-Content .env $container_name"_port="$container_ports
    }

    if ((![string]::IsNullOrEmpty($container_ports)) -and (![string]::IsNullOrEmpty($container_name))){
        $array.Add($container_name,$container_ports)
        $container_ports = $null
        $container_name = $null
    }

 }


 #Create or blank the .ergo
 if (!(Test-Path ".ergo"))
{
   New-Item -name .ergo -type "file"
}
else{
    
    Clear-Content -path .ergo

}

 Write-Host ($array | Out-String) 

 #Write the ergo file
 Foreach ($hostdocker in $array.GetEnumerator()){
 
    $ergoadd = $Project_Name +"_"+ $hostdocker.Name  +" http://localhost:" + $hostdocker.Value
    Add-Content .ergo $ergoadd

 }