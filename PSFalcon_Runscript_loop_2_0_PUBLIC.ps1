#██╗    ██╗ █████╗ ██████╗ ███╗   ██╗██╗███╗   ██╗ ██████╗
#██║    ██║██╔══██╗██╔══██╗████╗  ██║██║████╗  ██║██╔════╝
#██║ █╗ ██║███████║██████╔╝██╔██╗ ██║██║██╔██╗ ██║██║  ███╗
#██║███╗██║██╔══██║██╔══██╗██║╚██╗██║██║██║╚██╗██║██║   ██║
#╚███╔███╔╝██║  ██║██║  ██║██║ ╚████║██║██║ ╚████║╚██████╔╝
# ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝ ╚═════╝
### DO NOT SHARE THIS SCRIPT IT HAS PA$$WORDS IN IT !!!!



# Refrence: https://www.reddit.com/r/PowerShell/comments/867755/function_to_write_to_global_variable/
# https://www.reddit.com/r/crowdstrike/comments/l6yed2/psfalcon2_run_script/
# https://www.reddit.com/r/crowdstrike/comments/n46um7/psfalcon_20_queueoffline/

# INIT  ##############################################################################################

# timout for runscript to complete/connect ?
$VARTIMEOUT = 600
# keys to auth for API
$key = "#################################"
$secret = "#################################"
# Scriptname to execute on hosts
$SCRIPTNAME = "RTR_TEST"
# RTR group to be added (this can take upto 20min to apply even if host is online )
$RTRGROUPID = "25##################################1"

# Destination cloud 
$CLOUD = "us-1"

#   Child environment to use for authentication in multi-CID configurations 
$MEMBERCID = "#################################"

 


# FUNCTIONS ##############################################################################################
 
function Get-CSInputFile {
    <#
    .SYNOPSIS
        Opens input file for list of hostnames separated by new lines
    .PARAMETER CSFILEPATH
        File Path of input file
    #>
    [CmdletBinding()]
    param (
        [string]
        $CSFilePath
    )
    Write-Message -Message "Opening input file $CSFilePath  for hostsnames" -Type  "INFO"
    Start-Process notepad.exe "$CSFilePath" -NoNewWindow -Wait
    [string[]]$CSFilePath = Get-Content -Path "$CSFilePath"
    foreach($i in $CSFilePath) {
    $filter = $filter + "hostname:'$i',"
    }
    return $filter
}


  

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
Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] "$Tag" : "$Message" -ForegroundColor $Color
}




function Critical-Error {
Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] ERROR: There has been a Critical Error -ForegroundColor Red
exit
}




function Enumerate-ObjectProperties {

$script:Level = 1

param (

[psobject] $Object,

[int32] $Depth = 10,

[string] $Root

)



Write-Output $($Object.PSObject.Properties | Format-Table @{ Label = 'Type'; Expression = { "[$($($_.TypeNameOfValue).Split('.')[-1])]" } }, Name, Value -AutoSize -Wrap | Out-String)



foreach ($Property in $Object.PSObject.Properties) {

# Strings always have a single property "Length". Do not enumerate this.

if (($Property.TypeNameOfValue -ne 'System.String') -and ($($Object.$($Property.Name).PSObject.Properties)) -and ($Level -le $Depth)) {

$NewRoot = $($($Root + '.' + $($Property.Name)).Trim('.'))

$Level++

Write-Output "Property: $($NewRoot) (Level: $Level)"

Enumerate-ObjectProperties -Object $($Object.$($Property.Name)) -Root $NewRoot

$Level--

}

}

}



function Get-CSIds {
    <#
    .SYNOPSIS
        Gets a list of Ids from a filter input
    .PARAMETER CSHOSTS
        List of host in filter format 
    #>
    [CmdletBinding()]
    param (        
        [string]
        $CSHOSTS
        )

        
$CSHostList = Get-FalconHost -Filter "$CSHOSTS"
  foreach($i in $CSHostList) {

    $CSIds = $CSIds + "$i,"
    }
    # trim trailing , in list of AIDs
    $CSIds = $CSIds -replace ',$',''
return $CSIds
}




# MAIN ##############################################################################################


Out-Default

# want to keep scroll back
Clear-Host


#bug in Clear-Host to sleep to let screen clear properly
Start-Sleep -s 1

Write-Message  -Message  "All uploaded scripts must have  echo ALL DONE at the end to ensure they run properly" -Type "WARNING" 

# IMPORT MODULE

Write-Message -Message "Loading PSFalcon Module" -Type "INFO" 

try {
    Import-Module -Name PSFalcon  -ErrorAction Stop 
    } catch {
    Write-Message -Message "import-Module -Name PSFalcon failed please install PSFalcon and dependencies" -Type "ERROR"  
    Write-Error $_
}


# REQUEST TOKEN

Write-Message -Message "Requesting Authentication Token" -Type "INFO"

try {
    Request-FalconToken -ClientId "$key" -ClientSecret "$secret"  -Cloud "$CLOUD"  -ErrorAction Stop 
    } catch {
    Write-Message -Message "Requesting Authentication Token failed trying with CID $MEMBERCID" -Type "WARNING"
        try {
        Request-FalconToken -ClientId "$key" -ClientSecret "$secret"  -Cloud "$CLOUD"   -ClientSecret "$MEMBERCID"
            } catch { Write-Message -Message "Requesting Authentication Token failed with CID $MEMBERCID" -Type "ERROR"
            Write-Error $_
            Critical_Error;
            }
            }


# TEST CONNECTIVITY
try {
    Get-FalconCCID | Out-Null
    } catch {
    Write-Message -Message "Token Test Failed" -Type "ERROR"
    Write-Error $_
    Critical_Error;
    }


# OPEN INPUT FILE

$GetCSInputFileOutput  = Get-CSInputFile -CSFilePath "$env:TEMP\input.txt"

# get host count
$HostCount = ([regex]::Matches($GetCSInputFileOutput, "hostname" )).count

Write-Message -Message "Resolving $HostCount ids " -Type  "INFO" 

# trim trailing , in list of AIDs
$GetCSInputFileOutput  = $GetCSInputFileOutput -replace ',$','


$CSIdsOut = Get-CSIds -CSHOSTS "$GetCSInputFileOutput"


#convert CSIdsOut to an array 
$CSIdsOut = $CSIdsOut -split ','

#count resolved  CSIdsOut and compare

$CSIdsOutCount = $CSIdsOut.count

if  (($CSIdsOutCount) -eq  ($HostCount)) { 
    Write-Message -Message "Resolved all hostnames successfully" -Type  "INFO" 
} ELSE {
    Write-Message -Message "Unable to resolve all hostnames in input file be sure hostnames are in CS and not hidden. Resolved $CSIdsOutCount of $HostCount hosts" -Type  "WARNING" 
        }
Invoke-FalconRTR -Command runscript -Arguments "-CloudFile=$SCRIPTNAME" -HostIds $CSIdsOut -QueueOffline  $True

#Get-FalconQueue

exit
