Set-Variable -Name ErrorActionPreference -Value SilentlyContinue

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
get-nettcpconnection | select local*,remote*,state,@{Name="Process";Expression={(Get-Process -Id $_.OwningProcess).Path}}  |Select-String -Pattern "(0.0.0.0|127.0.0.1|chrome|RemoteAddress=::;|outlook|msedge|SearchUI|SystemSettings|teams|vpnagent|onedrive)" -NotMatch 



echo '-------------------------';
echo "[+] INFO: Displaying recent files for all users"
echo '-------------------------';
Set-Variable -Name ErrorActionPreference -Value SilentlyContinue
$WScript = New-Object -ComObject WScript.Shell
Get-ChildItem -Path "C:\Users\*" -Filter *.lnk -Recurse -ErrorAction SilentlyContinue -Force  | ForEach-Object {
$WScript.CreateShortcut($_.FullName).TargetPath
$WScript.CreateShortcut($_.FullName).Arguments}| sort -Unique | Select-String -Pattern 'WINDOWS|Teams|program files' -NotMatch 

function Get-BrowserData {
    <#
    .SYNOPSIS
      Dumps Browser Information
      Original Author: u/424f424f
      Modified by: 51Ev34S
      License: BSD 3-Clause
      Required Dependencies: None
      Optional Dependencies: None
    .DESCRIPTION
      Enumerates browser history or bookmarks for a Chrome, Edge (Chromium) Internet Explorer,
      and/or Firefox browsers on Windows machines.
    .PARAMETER Browser
      The type of browser to enumerate, 'Chrome', 'Edge', 'IE', 'Firefox' or 'All'
    .PARAMETER Datatype
      Type of data to enumerate, 'History' or 'Bookmarks'
    .PARAMETER UserName
      Specific username to search browser information for.
    .PARAMETER Search
      Term to search for
    .EXAMPLE
      PS C:\> Get-BrowserData
      Enumerates browser information for all supported browsers for all current users.
    .EXAMPLE
      PS C:\> Get-BrowserData -Browser IE -Datatype Bookmarks -UserName user1
      Enumerates bookmarks for Internet Explorer for the user 'user1'.
    .EXAMPLE
      PS C:\> Get-BrowserData -Browser All -Datatype History -UserName user1 -Search 'github'
      Enumerates bookmarks for Internet Explorer for the user 'user1' and only returns
      results matching the search term 'github'.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0)]
        [String[]]
        [ValidateSet('Chrome', 'EdgeChromium', 'IE', 'FireFox', 'All')]
        $Browser = 'All',
        [Parameter(Position = 1)]
        [String[]]
        [ValidateSet('History', 'Bookmarks', 'All')]
        $DataType = 'All',
        [Parameter(Position = 2)]
        [String]
        $UserName = '',
        [Parameter(Position = 3)]
        [String]
        $Search = ''
    )

    function ConvertFrom-Json20([object] $item) {
        #http://stackoverflow.com/a/29689642
        Add-Type -AssemblyName System.Web.Extensions
        $ps_js = New-Object System.Web.Script.Serialization.JavaScriptSerializer
        return , $ps_js.DeserializeObject($item)
    }

    function Get-ChromeHistory {
        $Path = "$Env:systemdrive\Users\$UserName\AppData\Local\Google\Chrome\User Data\Default\History"
        if (-not (Test-Path -Path $Path)) {
            Write-Verbose "[!] Could not find Chrome History for username: $UserName"
        }
        $Regex = '(htt(p|s))://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?'
        $Value = Get-Content -Path "$Env:systemdrive\Users\$UserName\AppData\Local\Google\Chrome\User Data\Default\History" | Select-String -AllMatches $regex | ForEach-Object { ($_.Matches).Value } | Sort-Object -Unique
        $Value | ForEach-Object {
            $Key = $_
            if ($Key -match $Search) {
                New-Object -TypeName PSObject -Property @{
                    User     = $UserName
                    Browser  = 'Chrome'
                    DataType = 'History'
                    Data     = $_
                }
            }
        }
    }
    
    function Get-ChromeBookmarks {
        $Path = "$Env:systemdrive\Users\$UserName\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"
        if (-not (Test-Path -Path $Path)) {
            Write-Verbose "[!] Could not find FireFox Bookmarks for username: $UserName"
        }
        else {
            $Json = Get-Content $Path
            $Output = ConvertFrom-Json20($Json)
            $Jsonobject = $Output.roots.bookmark_bar.children
            $Jsonobject.url | Sort-Object -Unique | ForEach-Object {
                if ($_ -match $Search) {
                    New-Object -TypeName PSObject -Property @{
                        User     = $UserName
                        Browser  = 'Chrome'
                        DataType = 'Bookmark'
                        Data     = $_
                    }
                }
            }
        }
    }
    
    function Get-EdgeChromiumHistory {
        $Path = "$Env:systemdrive\Users\$UserName\AppData\Local\Microsoft\Edge\User Data\Default\History"
        if (-not (Test-Path -Path $Path)) {
            Write-Verbose "[!] Could not find Chrome History for username: $UserName"
        }
        $Regex = '(htt(p|s))://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?'
        $Value = Get-Content -Path "$Env:systemdrive\Users\$UserName\AppData\Local\Microsoft\Edge\User Data\Default\History" | Select-String -AllMatches $regex | ForEach-Object { ($_.Matches).Value } | Sort-Object -Unique
        $Value | ForEach-Object {
            $Key = $_
            if ($Key -match $Search) {
                New-Object -TypeName PSObject -Property @{
                    User     = $UserName
                    Browser  = 'Edge(Chromium)'
                    DataType = 'History'
                    Data     = $_
                }
            }
        }
    }
    
    function Get-EdgeChromiumBookmarks {
        $Path = "$Env:systemdrive\Users\$UserName\AppData\Local\Microsoft\Edge\User Data\Default\Bookmarks"
        if (-not (Test-Path -Path $Path)) {
            Write-Verbose "[!] Could not find FireFox Bookmarks for username: $UserName"
        }
        else {
            $Json = Get-Content $Path
            $Output = ConvertFrom-Json20($Json)
            $Jsonobject = $Output.roots.bookmark_bar.children
            $Jsonobject.url | Sort-Object -Unique | ForEach-Object {
                if ($_ -match $Search) {
                    New-Object -TypeName PSObject -Property @{
                        User     = $UserName
                        Browser  = 'Edge(Chromium)'
                        DataType = 'Bookmark'
                        Data     = $_
                    }
                }
            }
        }
    }
    
    function Get-InternetExplorerHistory {
        #https://crucialsecurityblog.harris.com/2011/03/14/typedurls-part-1/
        $Null = New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS
        $Paths = Get-ChildItem 'HKU:\' -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'S-1-5-21-[0-9]+-[0-9]+-[0-9]+-[0-9]+$' }
        
        ForEach ($Path in $Paths) {
            $User = ([System.Security.Principal.SecurityIdentifier] $Path.PSChildName).Translate( [System.Security.Principal.NTAccount]) | Select-Object -ExpandProperty Value
            $Path = $Path | Select-Object -ExpandProperty PSPath
            $UserPath = "$Path\Software\Microsoft\Internet Explorer\TypedURLs"
            if (-not (Test-Path -Path $UserPath)) {
                Write-Verbose "[!] Could not find IE History for SID: $Path"
            }
            else {
                Get-Item -Path $UserPath -ErrorAction SilentlyContinue | ForEach-Object {
                    $Key = $_
                    $Key.GetValueNames() | ForEach-Object {
                        $Value = $Key.GetValue($_)
                        if ($Value -match $Search) {
                            New-Object -TypeName PSObject -Property @{
                                User     = $UserName
                                Browser  = 'IE'
                                DataType = 'History'
                                Data     = $Value
                            }
                        }
                    }
                }
            }
        }
    }
   
    function Get-InternetExplorerBookmarks {
        $URLs = Get-ChildItem -Path "$Env:systemdrive\Users\" -Filter "*.url" -Recurse -ErrorAction SilentlyContinue
        ForEach ($URL in $URLs) {
            if ($URL.FullName -match 'Favorites') {
                $User = $URL.FullName.split('\')[2]
                Get-Content -Path $URL.FullName | ForEach-Object {
                    try {
                        if ($_.StartsWith('URL')) {
                            # parse the .url body to extract the actual bookmark location
                            $URL = $_.Substring($_.IndexOf('=') + 1)
                            ​
                            if ($URL -match $Search) {
                                New-Object -TypeName PSObject -Property @{
                                    User     = $User
                                    Browser  = 'IE'
                                    DataType = 'Bookmark'
                                    Data     = $URL
                                }
                            }
                        }
                    }
                    catch {
                        Write-Verbose "Error parsing url: $_"
                    }
                }
            }
        }
    }

    function Get-FireFoxHistory {
        $Path = "$Env:systemdrive\Users\$UserName\AppData\Roaming\Mozilla\Firefox\Profiles\"
        if (-not (Test-Path -Path $Path)) {
            Write-Verbose "[!] Could not find FireFox History for username: $UserName"
        }
        else {
            $Profiles = Get-ChildItem -Path "$Path\*.default\" -ErrorAction SilentlyContinue
            $Regex = '(htt(p|s))://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?'
            $Value = Get-Content $Profiles\places.sqlite | Select-String -Pattern $Regex -AllMatches | Select-Object -ExpandProperty Matches | Sort-Object -Unique
            $Value.Value | ForEach-Object {
                if ($_ -match $Search) {
                    ForEach-Object {
                        New-Object -TypeName PSObject -Property @{
                            User     = $UserName
                            Browser  = 'Firefox'
                            DataType = 'History'
                            Data     = $_
                        }
                    }
                }
            }
        }
    }

    if (!$UserName) {
        $UserName = "$ENV:USERNAME"
    }
    if (($Browser -Contains 'All') -or ($Browser -Contains 'Chrome')) {
        if (($DataType -Contains 'All') -or ($DataType -Contains 'History')) {
            Get-ChromeHistory
        }
        if (($DataType -Contains 'All') -or ($DataType -Contains 'Bookmarks')) {
            Get-ChromeBookmarks
        }
    }
    if (($Browser -Contains 'All') -or ($Browser -Contains 'Edge')) {
        if (($DataType -Contains 'All') -or ($DataType -Contains 'History')) {
            Get-EdgeChromiumHistory
        }
        if (($DataType -Contains 'All') -or ($DataType -Contains 'Bookmarks')) {
            Get-EdgeChromiumBookmarks
        }
    }
    if (($Browser -Contains 'All') -or ($Browser -Contains 'IE')) {
        if (($DataType -Contains 'All') -or ($DataType -Contains 'History')) {
            Get-InternetExplorerHistory
        }
        if (($DataType -Contains 'All') -or ($DataType -Contains 'Bookmarks')) {
            Get-InternetExplorerBookmarks
        }
    }
    if (($Browser -Contains 'All') -or ($Browser -Contains 'FireFox')) {
        if (($DataType -Contains 'All') -or ($DataType -Contains 'History')) {
            Get-FireFoxHistory
        }
    }
}


(Get-ChildItem "c:\Users" | Sort-Object LastWriteTime -Descending | Select-Object Name -first 2).Name |ForEach-Object {
echo '-------------------------';
echo "[+] INFO: Displaying History for $_"
echo '-------------------------';
Get-BrowserData  -UserName $_
}
