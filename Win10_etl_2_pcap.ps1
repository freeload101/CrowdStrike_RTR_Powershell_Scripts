#Set-Variable -Name ErrorActionPreference -Value SilentlyContinue


function Write-Message  {
    <#
    .SYNOPSIS
        Prints colored messages depending on type
    .PARAMETER TYPE
        Type of error message to be prepended to the message and sets the color
    .PARAMETER MESSAGE
        Message to be output
    #>
    [CmdletBinding()]
    param (
        [string]
        $Type,
        
        [string]
        $Message
        )

if  (($TYPE) -eq  ("INFO")) { $Tag = "INFO"  ; $Color = "Green"}
if  (($TYPE) -eq  ("WARNING")) { $Tag = "WARNING"  ; $Color = "Yellow"}
if  (($TYPE) -eq  ("ERROR")) { $Tag = "ERROR"  ; $Color = "Red"}
$date1=(Get-Date -UFormat “%m/%d/%Y %T”) 

Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] "$Tag" : "$Message" -ForegroundColor $Color
echo  "$date1 [+] $Tag : $Message" 
}


Write-Message -Message  "Stopping trace..." -Type "INFO" 
Start-Process -FilePath "C:\Windows\System32\netsh.exe" -WorkingDirectory "$env:TEMP" -ArgumentList " trace stop " 



Write-Message -Message  "Removing old capture files..." -Type "INFO" 
del capture..*
Start-Sleep -s 2
Write-Message -Message  "Starting packet trace..." -Type "INFO" 
#netsh trace start capture=yes tracefile="$env:TEMP\capture.etl" maxsize=512 filemode=circular overwrite=yes report=no correlation=no Ethernet.Type=IPv4
Start-Process -FilePath "C:\Windows\System32\netsh.exe" -WorkingDirectory "$env:TEMP" -ArgumentList " trace start capture=yes tracefile=`"$env:TEMP\capture.etl`" maxsize=512 filemode=circular overwrite=yes report=no correlation=no Ethernet.Type=IPv4 " 


Write-Message -Message  "Capturing packets for 15 seconds..." -Type "INFO" 
Start-Sleep -s 15

Write-Message -Message  "Stopping trace...This can take a 1-5min " -Type "INFO" 
#netsh trace stop
Start-Process -FilePath "C:\Windows\System32\netsh.exe" -WorkingDirectory "$env:TEMP" -ArgumentList " trace stop  " -Wait -NoNewWindow -

Write-Message -Message  "Sleeping for 5 seconds..." -Type "INFO" 
Start-Sleep -s 5

# Full path of the file
$file = "$env:TEMP\etl2pcapng\x64\etl2pcapng.exe"
 
Write-Message -Message  "Downloading etl2pcapng for converting etl captures to pcap" -Type "INFO" 
(New-Object Net.WebClient).DownloadFile('https://github.com/microsoft/etl2pcapng/releases/download/v1.3.0/etl2pcapng.zip', "$env:TEMP\etl2pcapng.zip")

Write-Message -Message  "Extracting etl2pcapng..." -Type "INFO" 
Expand-Archive "$env:TEMP\etl2pcapng.zip" -DestinationPath "$env:TEMP\" -Force -Verbose

Write-Message -Message  "Converting etl packet trace to pcap using etl2pcapng..." -Type "INFO" 
Start-Process -FilePath "$env:TEMP\etl2pcapng\x64\etl2pcapng.exe" -ArgumentList "$env:TEMP\capture.etl $env:TEMP\capture.etl.pcap" -Verbose 
$PCap = "$env:TEMP\capture.etl.pcap"
Write-Message -Message  "Run get $PCap to download pcap file" -Type "INFO" 

echo "ALL DONE"
