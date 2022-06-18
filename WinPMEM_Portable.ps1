################################ Please wait for memory dump before running Zipping up files

################################ Downloading obfuscated WinPMEM
Set-Variable -Name ErrorActionPreference -Value SilentlyContinue
Write-Output  (Get-Date -UFormat “%m/%d/%Y %T”) [+] INFO: "Downloading obfuscated WinPMEM"

Stop-process -name robert_mccurdy_winpmem -Force
Stop-process -name 7z -Force

New-Item -Path 'C:\ftech_temp' -ItemType Directory

############################### This is just a obfucasted binary using echo '' >> binary.exe
Invoke-WebRequest -Uri "https://rmccurdy.com/.scripts/.IR/robert_mccurdy_winpmem" -OutFile "C:\ftech_temp\robert_mccurdy_winpmem"

Rename-Item -Path "C:\ftech_temp\robert_mccurdy_winpmem" -NewName "C:\ftech_temp\robert_mccurdy_winpmem.exe"

Get-ChildItem "C:\ftech_temp"  

Start-Process -FilePath "C:\ftech_temp\robert_mccurdy_winpmem.exe" -ArgumentList "C:\ftech_temp\memory.dump" -Verbose   -WindowStyle Maximized

Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] INFO: "Please wait for memory dump to run Zipping up files"
Start-Sleep -s 1
Get-Process -Name robert_mccurdy_winpmem

################################ Please wait for memory dump before running Zipping up files

################################ Zipping up files 
Set-Variable -Name ErrorActionPreference -Value SilentlyContinue
Write-Output  (Get-Date -UFormat “%m/%d/%Y %T”) [+] INFO: Zipping up files

Set-Variable -Name ErrorActionPreference -Value SilentlyContinue
Stop-process -name robert_mccurdy_winpmem -Force
Stop-process -name 7z -Force

mkdir "C:\ftech_temp"
$url = "https://cytranet.dl.sourceforge.net/project/sevenzip/7-Zip/21.07/7z2107-x64.exe"
$dest = "C:\ftech_temp\7z2107-x64.exe"
Invoke-WebRequest -Uri $url -OutFile $dest -verbose
cd "C:\ftech_temp"

Start-Process -FilePath "C:\ftech_temp\7z2107-x64.exe" -ArgumentList "/S /D=C:\ftech_temp\7ZIP" -WindowStyle Maximized

Start-Sleep -s 3

If (Test-Path -Path C:\ftech_temp\memory.dump ) {
Start-Process -FilePath "C:\ftech_temp\7ZIP\7z.exe" -ArgumentList "a -v500m -mx=1  -mmt=4 C:\ftech_temp\memory.zip C:\ftech_temp\memory.dump" -WindowStyle Maximized 
}

Get-ChildItem "C:\ftech_temp\" -recurse -Include *.zip.* | Select-Object Name, @{Name="MegaBytes";Expression={"{0:F2}" -f ($_.length/1MB)}}

########################################### FILE SHARE
Set-Variable -Name ErrorActionPreference -Value SilentlyContinue
New-SmbShare -Name ftech_temp -Description "ftech_temp" -Path C:\ftech_temp
Grant-SmbShareAccess -Name ftech_temp  -AccountName Everyone -AccessRight Read -Force

Remove-Item "C:\ftech_temp\memory.dump"  -Force -Recurse

########################################## WHEN YOU ARE DONE
Set-Variable -Name ErrorActionPreference -Value SilentlyContinue

Revoke-SmbShareAccess -Name ftech_temp -AccountName Everyone -Force
Remove-SmbShare -Name ftech_temp -Force
