Set-Variable -Name ErrorActionPreference -Value SilentlyContinue


echo '-------------------------';
echo 'BE SURE TO ADD -Timeout=600 in the runscript options before you run this script';
echo 'Example :';
echo 'runscript -CloudFile="Browser_History_Hindsight" -Timeout=600';
echo '-------------------------';
echo "[+] INFO: Fetching Latest 4 Users Chrome,Edge History"

Stop-process -name hindsight -Force

New-Item -Path 'C:\windows\Temp\ftech_temp' -ItemType Directory | Out-Null
Invoke-WebRequest -Uri "https://github.com/obsidianforensics/hindsight/releases/download/v2021.12/hindsight.exe" -OutFile "C:\windows\Temp\ftech_temp\hindsight.exe"


Get-ChildItem -Directory -Path "C:\Users\$_"   -ErrorAction SilentlyContinue -Force | Sort LastWriteTime  -Descending | Select-Object -First 4 | ForEach-Object {
echo "[+] INFO: Dumping $_ MSEdge/Chrome"
New-Item -Path "C:\windows\Temp\ftech_temp\$_ Chrome"  -ItemType Directory | Out-Null
New-Item -Path "C:\windows\Temp\ftech_temp\$_ Edge"  -ItemType Directory | Out-Null
Start-Process -FilePath "C:\windows\Temp\ftech_temp\hindsight.exe" -ArgumentList  " -i `"c:\Users\$_\AppData\Local\Microsoft\Edge\User Data\Default`" -o `"C:\windows\Temp\ftech_temp\$_ Edge`"  " -WorkingDirectory "C:\windows\Temp\ftech_temp\$_ Edge"  -Verbose -WindowStyle Hidden 
Start-Process -FilePath "C:\windows\Temp\ftech_temp\hindsight.exe" -ArgumentList  " -i `"c:\Users\$_\AppData\Local\Google\Chrome\User Data\Default`" -o `"C:\windows\Temp\ftech_temp\$_ Chrome`"  " -WorkingDirectory "C:\windows\Temp\ftech_temp\$_ Chrome"  -Verbose -WindowStyle Hidden  

} 

echo "[+] INFO: Waiting upto 5 minutes for Hindsight to complete"
Wait-Process -Name hindsight -Timeout 300


Get-ChildItem   -Path "C:\windows\Temp\ftech_temp" -filter *.xlsx

Get-ChildItem  C:\windows\Temp\ftech_temp\ -filter *.xlsx |
Compress-Archive -Destination C:\windows\Temp\ftech_temp\hindsight.zip -Force

echo "type: "
echo "get C:\windows\Temp\ftech_temp\hindsight.zip"
echo "Password is infected. When Download is complete the  type:"
echo "rm C:\windows\Temp\ftech_temp -force"
