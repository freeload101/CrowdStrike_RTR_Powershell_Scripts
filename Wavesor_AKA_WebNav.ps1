Get-ScheduledTask -TaskName *Wavesor* | Disable-ScheduledTask
Get-ScheduledTask -TaskName *Wavesor* | Export-ScheduledTask

echo Killing Browsers
cmd /c taskkill.exe /F /IM chrome.exe
cmd /c taskkill.exe /F /IM outlook.exe
cmd /c taskkill.exe /F /IM IEXPLORE.EXE
cmd /c taskkill.exe /F /IM msedge.exe
cmd /c taskkill.exe /F /IM firefox.exe

echo Forcing Loggoff for locked files
logoff 1
logoff 2
logoff 3
logoff 4
logoff 5
logoff 6
logoff 7



Remove-Item "c:\Users\*\Wavesor Software” -Force -Recurse -Verbose

echo "ALL DONE"
