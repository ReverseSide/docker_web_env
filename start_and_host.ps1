Write-Host "Script launched"

#Egro Proxy
Import-Module .\script_powershell\Ergo_Proxy_Windows.ps1

#Create the Ergo file and choose port
Import-Module .\script_powershell\auto-hostname.ps1

cmd.exe /c '.\script_powershell\run_command.bat'