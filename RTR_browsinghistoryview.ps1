Set-Variable -Name ErrorActionPreference -Value SilentlyContinue

New-Item -Path "C:\windows\Temp\ftech_temp" -ItemType Directory   -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\windows\Temp\ftech_temp\report.csv" -Force 

Invoke-WebRequest -Uri "https://www.nirsoft.net/utils/browsinghistoryview-x64.zip" -OutFile "C:\windows\Temp\ftech_temp\browsinghistoryview-x64.zip"

Expand-Archive  "C:\windows\Temp\ftech_temp\browsinghistoryview-x64.zip"  -DestinationPath "C:\windows\Temp\ftech_temp"  -Force
 
echo "[+] INFO: Fetching Latest 6 Users Chrome,Edge History"

Get-ChildItem -Directory -Path "C:\Users\$_"    -ErrorAction SilentlyContinue -Force | Sort LastWriteTime  -Descending  | Select-Object -First 6  |   ForEach-Object  {
    if (($_).Name -notmatch 'public|default|\$'){
        echo '-------------------------';
		echo "[+] INFO: Displaying History for HostName: $env:computername User: $_ MSEdge/Chrome  "
		echo '-------------------------';
        Start-Process -FilePath "C:\windows\Temp\ftech_temp\BrowsingHistoryView.exe" -ArgumentList  " /HistorySource 4 /HistorySourceFolder `"C:\users\$_\`"  /VisitTimeFilterType 3 /VisitTimeFilterValue 2 /LoadIE 1 /LoadFirefox 1 /LoadChrome 1 /scomma `"C:\windows\Temp\ftech_temp\report.csv`" /sort `"Visit Time`""  -Wait  -Verbose -WindowStyle Hidden   
        Import-Csv "C:\windows\Temp\ftech_temp\report.csv" | Select -ExpandProperty  URL |Get-Unique -AsString
    }
}
