
Set-Variable -Name ErrorActionPreference -Value SilentlyContinue
echo '-------------------------';
echo "[+] INFO: CPU Usage TOP 20"
echo '-------------------------';
Get-Process | Sort CPU -descending | Select -first 20 -Property ID, ProcessName, Description, CPU 
 
echo '-------------------------';
echo "[+] INFO: Installed Software"
echo '-------------------------';
Get-WmiObject -Class Win32_Product | Where-Object { $_.Vendor -notmatch 'Palo|Levi|Adobe|Microsoft|dell|cybersafe|displaylink|VPSX|python|mimecast|forcepoint|google|crowdstrike|Oracle|cisco|ServiceNow|Asmedia' } | Select-Object -ExpandProperty Name
echo '-------------------------';
echo "[+] INFO: Showing Default Chrome Plugins"
echo '-------------------------';

    $UserPaths = (Get-WmiObject win32_userprofile | Where-Object localpath -notmatch 'Windows').localpath
      foreach ($Path in $UserPaths) {
          # Google Chrome extension path
          $ExtPath = $Path + '\' + '\AppData\Local\Google\Chrome\User Data\Default\Extensions'
          if (Test-Path $ExtPath) {
              # Username
              $Username = $Path | Split-Path -Leaf
              # Extension folders
              $ExtFolders = Get-Childitem $ExtPath | Where-Object Name -ne 'Temp'
              foreach ($Folder in $ExtFolders) {
                  # Extension version folders
                  $VerFolders = Get-Childitem $Folder.FullName
                  foreach ($Version in $VerFolders) {
                      # Check for json manifest
                      if (Test-Path -Path ($Version.FullName + '\manifest.json')) {
                          $Manifest = Get-Content ($Version.FullName + '\manifest.json') | ConvertFrom-Json
                          # If extension name looks like an App name
                          if ($Manifest.name -like '__MSG*') {
                              $AppId = ($Manifest.name -replace '__MSG_','').Trim('_')
                              # Check locales folders for additional json
                              @('\_locales\en_US\', '\_locales\en\') | ForEach-Object {
                                  if (Test-Path -Path ($Version.Fullname + $_ + 'messages.json')) {
                                      $AppManifest = Get-Content ($Version.Fullname + $_ +
                                      'messages.json') | ConvertFrom-Json
                                      # Check json for potential app names and save the first one found
                                      @($AppManifest.appName.message, $AppManifest.extName.message,
                                      $AppManifest.extensionName.message, $AppManifest.app_name.message,
                                      $AppManifest.application_title.message, $AppManifest.$AppId.message) |
                                      ForEach-Object {
                                          if (($_) -and (-not($ExtName))) {
                                              $ExtName = $_
                                          }
                                      }
                                  }
                              }
                          }
                          else {
                              # Capture extension name
                              $ExtName = $Manifest.name
                          }
                          # Output formatted string

                          Write-Output (($Path | Split-Path -Leaf) + ": " + [string] $ExtName +
                          " v" + $Manifest.version + " (" + $Folder.name + ")") |Select-String -Pattern "(aapocclcgogkmnckokdopfmhonfmgoek|aohghmighlieiainnegkcijnfilokake|apdfllckaahabafndbhieahigkjlhalf|blpcfgokakmgnkcojhhkbfbldkacnbeo|felcaaldnbdncclmgdcncolpebgiejap|ghbmnnjooekpmoecnnnilnnbdlolhkhi|nmmhkkegccagdldgiimedpiccmgmieda|pjkljhegncpnkpknbcohdijeoejaedia|pkedcjkdefgpdelpbcmbmeomcjbeemfm)" -NotMatch 
                          # Reset extension name for next lookup
                          if ($ExtName) {
                              Remove-Variable -Name ExtName
                          }
                      }
                  }
              }
          }
      }
      
      
    echo '-------------------------';
    echo "[+] INFO: Getting netstat info"
    echo '-------------------------';
    #OLD get-nettcpconnection | select local*,remote*,state,@{Name="Process";Expression={(Get-Process -Id $_.OwningProcess).Path}}  |Select-String -Pattern "(0.0.0.0|127.0.0.1|chrome|RemoteAddress=::;|outlook|msedge|SearchUI|SystemSettings|teams|vpnagent|onedrive)" -NotMatch 
    Get-NetTCPConnection | Where-Object { $_.State -eq 'ESTABLISHED' -and $_.RemoteAddress -notmatch '^10\.|^192\.168\.|^127\.|\b:\b|::|^172\.' } |Sort-Object -Unique -Property RemoteAddress |foreach-object {
    $PROC_PATH = (Get-Process -Id $_.OwningProcess).Path
        if ($PROC_PATH -notmatch 'Teams|chrome|outlook') {
        $REMOTEIP = $_.RemoteAddress
        $LocalPort = $_.LocalPort
        $WHOIS = ((Invoke-Restmethod "http://whois.arin.net/rest/ip/$REMOTEIP"  -ErrorAction stop ).net.orgRef.name) 
        #(Invoke-Restmethod "http://whois.arin.net/rest/ip/$REMOTEIP"  -ErrorAction stop ).net.orgRef.name
        Write-Output "$REMOTEIP,$LocalPort,$WHOIS,$PROC_PATH"
        }

    }

(Get-ChildItem -Path "C:\Users\*").name |ForEach-Object {
echo '-------------------------';
echo "[+] INFO: Displaying recent files for all users .lnk targets and Arguments "
echo '-------------------------';
Get-ChildItem -Path "C:\Users\$_\AppData\Roaming\Microsoft\Windows\Recent" -Filter *.lnk -Recurse -ErrorAction SilentlyContinue -Force  |ForEach-Object {
$WScript = New-Object -ComObject WScript.Shell
$WScript.CreateShortcut($_.FullName).TargetPath
$WScript.CreateShortcut($_.FullName).Arguments 
}
}| sort -Unique | Select-String -Pattern 'WINDOWS|Teams|program files' -NotMatch 


echo '-------------------------';
echo "[+] INFO: Dumping Recycle Bin only 3 paths deep"
echo '-------------------------';

(Get-ChildItem -Path 'C:\$Recycle.Bin' -Force -Recurse -depth 3  ) | select * | ForEach-Object {
    if (($_).Name -match '\$I') {
        $VarMeta = "$((Get-Content ($_).FullName) -replace '.*\u0001.','' -replace '\u0000','')"
        Clear-Variable -Name varPath
    }
    if (($_).Name -match 'S-.-.-.'){
        $VarUser = "$((New-Object System.Security.Principal.SecurityIdentifier(($_).BaseName)).Translate([System.Security.Principal.NTAccount]).value)"
    }
    if (($_).Name -match '\$R'){
        Clear-Variable -Name varPath
    } else {
        $varPath = "$($_.FullName)"
        Write-Output "$($VarUser)`t$($VarMeta)`t$($varPath)" 
        Clear-Variable -Name varPath,VarMeta
    }
    
}

Set-Variable -Name ErrorActionPreference -Value SilentlyContinue

New-Item -Path "C:\windows\Temp\ftech_temp" -ItemType Directory   -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\windows\Temp\ftech_temp\report.csv" -Force 

Invoke-WebRequest -Uri "https://www.nirsoft.net/utils/browsinghistoryview-x64.zip" -OutFile "C:\windows\Temp\ftech_temp\browsinghistoryview-x64.zip"

Expand-Archive  "C:\windows\Temp\ftech_temp\browsinghistoryview-x64.zip"  -DestinationPath "C:\windows\Temp\ftech_temp"  -Force
 
echo "[+] INFO: Fetching Latest 6 Users Chrome,Edge History"

Get-ChildItem -Directory -Path "C:\Users\$_"    -ErrorAction SilentlyContinue -Force | Sort LastWriteTime  -Descending  | Select-Object -First 6  |   ForEach-Object  {
    if (($_).Name -notmatch 'public|default|\$'){
        echo '-------------------------';
		echo "[+] INFO: Displaying History for $_ MSEdge/Chrome "
		echo '-------------------------';
        Start-Process -FilePath "C:\windows\Temp\ftech_temp\BrowsingHistoryView.exe" -ArgumentList  " /HistorySource 4 /HistorySourceFolder `"C:\users\$_\`"  /VisitTimeFilterType 3 /VisitTimeFilterValue 2 /LoadIE 1 /LoadFirefox 1 /LoadChrome 1 /scomma `"C:\windows\Temp\ftech_temp\report.csv`" /sort `"Visit Time`""  -Wait  -Verbose -WindowStyle Hidden   
        
        $CSV = Import-Csv -Path "C:\windows\Temp\ftech_temp\report.csv" 
        $some = $CSV | Group-Object -Property Title 

        $some | ForEach-Object  { 
        $VarTitle = $_.Group.Title | Select-Object -First 1  -Unique
        $VarURL = $_.Group.URL.PadRight(100).Substring(0,100).TrimEnd() | Select-Object -First 1  -Unique 
        Write-Output "$VarTitle,$VarURL" 
        }  | Select-String -Pattern "(newell|crowdstrike|pingidentity)" -NotMatch 

    }

}
