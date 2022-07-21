Set-Variable -Name ErrorActionPreference -Value SilentlyContinue


echo '-------------------------';
echo "[+] INFO: Fetching All Users Chrome History (MSEdge)"
echo '-------------------------';
New-Item -Path 'C:\windows\Temp\ftech_temp' -ItemType Directory | Out-Null
Invoke-WebRequest -Uri "https://github.com/obsidianforensics/hindsight/releases/download/v2021.12/hindsight.exe" -OutFile "C:\windows\Temp\ftech_temp\hindsight.exe"

Get-ChildItem -Directory -Path "C:\Users\$_"   -ErrorAction SilentlyContinue -Force |Select-String -Pattern "(All|Default|default|Public|desktop)" -NotMatch | ForEach-Object {
Echo "[+] INFO: Crawling $_"
Start-Process -FilePath "C:\windows\Temp\ftech_temp\hindsight.exe" -ArgumentList  "   -i `"c:\Users\$_\AppData\Local`" -o `"C:\windows\Temp\ftech_temp\hindsight_$_`"  " -WorkingDirectory "C:\windows\Temp\ftech_temp\"  -Verbose   -WindowStyle Hidden -Wait 
}

Get-ChildItem  C:\windows\Temp\ftech_temp\ -filter *.xlsx |
Compress-Archive -Destination C:\windows\Temp\ftech_temp\hindsight.zip -Force

echo "type: "
echo "get C:\windows\Temp\ftech_temp\hindsight.zip"
echo "When Download is complete the password is infected type:"
echo "rm C:\windows\Temp\ftech_temp -force"
