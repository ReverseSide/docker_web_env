$nbline=0

#Create var by reading .env file

Get-Content .env | Foreach-Object{
   $var = $_.Split('=')
   New-Variable -Name $var[0] -Value $var[1]
}

Write-Host $Project_Name

Get-Content docker-compose.yml | ForEach-Object -Begin {} -Process {} -End {}{

    if ($_ -like '*container_name*'){

         $container_name = $_.Substring($_.IndexOf(":")+2)
         Write-Host $container_name.Substring(0, $_.IndexOf("_"))
    }

}