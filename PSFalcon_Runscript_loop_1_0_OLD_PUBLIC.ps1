#ChangeLog:
# 2020/11/24: inital pre-alpha:
#    *added count of hostsname in filter so you can get an idea of how may host are vvalid from the target list
#    *added script name as argument

#Todo:
# sort out oneoff aid lookup issue..
# increase timeout on error and retry aid ? 
# return if host is online via aid
# all scripts must output "ALL DONE" as the last step
# set isolate true/false flag .... ??????
# set debug flag for all DEBUG lines
# logging of output/error to uniq file name along with input file hostnames
# sort out if offline_que is possible 
# check auth
# check script name
# check script for "ALL DONE" as last few lines
# change [+] to MSF style for error output etc .. 


# timout for runscript to complete/connect ?
$VARTIMEOUT=90
# keys to auth for API
$key = "731e9XXXXXXXXXXXXXXXXXX774"
$secret = "0GXXXXXXXXXXXXXXXXXXXXXXXAQ"
# Scriptname to execute on hosts
$SCRIPTNAME="WeXXXXXXXXXXXXXXXXXXser"
# RTR group to be added (this can take upto 20min to apply even if host is online )
$RTRGROUPID="2580XXXXXXXXXXXXXXXXXXXXX29efa1"



# resetting Variables
Clear-Variable Request -Scope Global
Clear-Variable HostId -Scope Global
Clear-Variable Batch -Scope Global
Clear-Variable filter -Scope Global




# FUNCTIONS ##############################################################################################

function CHECKER {
foreach ($AID in $HostId) {
$HOSTNAME = (Get-CsHostInfo -Id $AID).resources.hostname
# DEBUG Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] INFO: Hostname of $AID is $HOSTNAME
    if (($Request.combined.resources.$AID.stdout)  -match "ALL DONE") { 
            # DEBUG Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] INFO: Removing aid: $AID  host: $HOSTNAME from the list$
            $global:HostId = $HostId | Where-Object { $_ –ne "$AID" }
            Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] INFO: Showing output of command for hostname: $HOSTNAME `t aid: $AID  
            Write-Host  $Request.combined.resources.$AID.stdout  -ForegroundColor Green |  out-string -Width 9999 
        } ELSE {
            Write-Host (Get-Date -UFormat “%m/%d/%Y %T”) [+] ERROR: Hostname: $HOSTNAME `t output is null host likly not online or in RTR group stderr: ($Request.combined.resources.$AID.stderr)  -ForegroundColor Red
                }
    }
}

function RUNIT {

Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] INFO: Batch initializing a RTR session on ($HostId |  Measure-Object -Line).Lines hostnames for script $SCRIPTNAME ...
$global:Batch = Start-RtrBatch -Id $HostId 

if (($Batch.batch_id).Length -eq "" ) {
    Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] WARNING: Unable to get any sessions -ForegroundColor Yellow
    } ELSE {
    Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] INFO: Batch id is: $Batch.batch_id
    Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] INFO: Attempting to run scripts on (($HostId |  Measure-Object -Line).Lines) HostIds with a $VARTIMEOUT second timeout...  -ForegroundColor Green
    # WARNING WARNING WARNING WARNING  !!!!! IF YOU ADD -verbose -debug it breaks the output of the $Request it would seem!
    $global:Request = Send-RtrCommand -Id $Batch.batch_id -Command runscript -String "-CloudFile='$SCRIPTNAME'" -Timeout $VARTIMEOUT

    #return
}

 

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





# MAIN ##############################################################################################
Out-Default; Clear-Host;

Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] INFO: All uploaded scripts must have '''echo "ALL DONE"''' at the end to ensure they run properly -ForegroundColor Yellow
Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] INFO: Geting auth token
Get-CsToken -Id "$key" -Secret "$secret"
 

Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] INFO: Opening input file for hostsnames
cd "$env:TEMP"
Start-Process notepad.exe input.txt -NoNewWindow -Wait
[string[]]$INPUTFILE = Get-Content -Path 'input.txt'

foreach($i in $INPUTFILE) {
$filter = $filter + "hostname:'$i',"
}


Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] INFO: Resolving ([regex]::Matches($filter, "hostname" )).count Ids of hostnames


$global:Batch

$global:HostId = (Get-CsHostId -Filter "$filter" -OutVariable Batch ).resources

Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] INFO: Got (($HostId |  Measure-Object -Line).Lines) HostIds   

Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] INFO: Unhiding Ids from UI  
Show-CsHost -Id $HostId | Out-Null

Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] INFO: Adding hostnames to INVESTIGATE group
Add-CsGroupMember -Id $RTRGROUPID  -Hosts $HostId  | Out-Null


#Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] INFO: Isolating hostnames until script is done!
#Start-CsContain -Id $HostId


if  ((([regex]::Matches($filter, "hostname" )).count) -eq  (($HostId |  Measure-Object -Line).Lines)) { Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] INFO: Resolved all hostnames successfully -ForegroundColor Green 
} ELSE {
    Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] ERROR: Unable to resolve all hostnames in input file be sure hostnames are in CS and not hidden -ForegroundColor Red
    Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] WARNING: Looking up ([regex]::Matches($filter, "hostname" )).count hostnames -ForegroundColor Yellow
    foreach($i in $INPUTFILE) {
    $AIDLOOKUP = (Get-CsHostId -Filter "hostname:'$i',").resources 
    #Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] INFO: Hostname: $i aid: $AIDLOOKUP
    if ($AIDLOOKUP.Length -eq 0) {
    Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] ERROR: Hostname: $i faild aid lookup this host may be hidden -ForegroundColor Red
        }
    }
}







While($HostId.count -ne 0){
RUNIT
CHECKER

    if ($HostId.count -eq 0) {
    Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] INFO: ($HostId).count hostnames to run process complete! -ForegroundColor Green
    break
    } ELSE {
    Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] WARNING: Waiting $VARTIMEOUT seconds to retry ($HostId).count hostnames -ForegroundColor Yellow
    Start-Sleep -Seconds $VARTIMEOUT
    }
} 

 

# Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] INFO: Running Confirm-RtrBatch to get status of job  
# Confirm-RtrBatch  -Id $Batch.batch_id

# Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] INFO: Removing Ids from INVESTIGATE group
#Remove-CsGroupMember  -Id $RTRGROUPID  -Hosts $HostId 
   
# Write-Host  (Get-Date -UFormat “%m/%d/%Y %T”) [+] INFO: UnIsolating hostnames
#Stop-CsContain  -Id $HostId  -Verbose -Debug
 
# use Enumerate-ObjectProperties functoin to sort out any issues with object/varables etc...
#Enumerate-ObjectProperties -Object $Request 
 
