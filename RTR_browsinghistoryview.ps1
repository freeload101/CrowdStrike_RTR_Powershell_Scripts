Set-Variable -Name ErrorActionPreference -Value SilentlyContinue

New-Item -Path "C:\windows\Temp\ftech_temp" -ItemType Directory   -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\windows\Temp\ftech_temp\report.csv" -Force 

Invoke-WebRequest -Uri "https://www.nirsoft.net/utils/browsinghistoryview-x64.zip" -OutFile "C:\windows\Temp\ftech_temp\browsinghistoryview-x64.zip"

Expand-Archive  "C:\windows\Temp\ftech_temp\browsinghistoryview-x64.zip"  -DestinationPath "C:\windows\Temp\ftech_temp"  -Force

$CurrentUser = ((Get-WMIObject -ClassName Win32_ComputerSystem).Username).Split('\')[1]
echo "ComputerName $env:COMPUTERNAME UserName $CurrentUser "  
Start-Process -FilePath "C:\windows\Temp\ftech_temp\BrowsingHistoryView.exe" -ArgumentList  " /HistorySource 4 /HistorySourceFolder `"C:\users\$CurrentUser\`"  /VisitTimeFilterType 3 /VisitTimeFilterValue 2 /LoadIE 1 /LoadFirefox 1 /LoadChrome 1 /scomma `"C:\windows\Temp\ftech_temp\report.csv`" /sort `"Visit Time`""  -Wait  -Verbose -WindowStyle Hidden   
$users = Import-Csv -Path C:\windows\Temp\ftech_temp\report.csv
echo $users.URL
