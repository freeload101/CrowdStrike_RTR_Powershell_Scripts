Set-Variable -Name ErrorActionPreference -Value SilentlyContinue

echo '-------------------------';
echo 'BE SURE TO ADD -Timeout=600 in the runscript options before you run this script';
echo 'Example :';
echo 'runscript -CloudFile="srum_dump2" -Timeout=600';
echo '-------------------------';

New-Item -Path 'C:\windows\Temp\ftech_temp' -ItemType Directory | Out-Null
echo "[+] INFO: Downloading srum_dump2.exe"
Invoke-WebRequest -Uri "https://github.com/MarkBaggett/srum-dump/releases/download/2.4/srum_dump2.exe" -OutFile "C:\windows\Temp\ftech_temp\srum_dump2.exe"

echo "[+] INFO: Downloading srum_dump2 SRUM_TEMPLATE2.xlsx "
Invoke-WebRequest -Uri "https://github.com/MarkBaggett/srum-dump/blob/master/SRUM_TEMPLATE2.xlsx?raw=true" -OutFile "C:\windows\Temp\ftech_temp\SRUM_TEMPLATE2.xlsx"

Start-Process  -FilePath "C:\windows\Temp\ftech_temp\srum_dump2.exe" -ArgumentList  " -i `"c:\windows\system32\sru\SRUDB.dat`" -t `"C:\windows\Temp\ftech_temp\SRUM_TEMPLATE2.xlsx`"  " -WorkingDirectory "C:\windows\Temp\ftech_temp\"  -Verbose -WindowStyle Hidden   # -RedirectStandardOutput output.txt -RedirectStandardError err.txt  

echo "type: "
echo "get C:\windows\Temp\ftech_temp\SRUM_DUMP_OUTPUT.xlsx"
echo "Password is infected. When Download is complete the  type:"
echo "rm C:\windows\Temp\ftech_temp -force"
