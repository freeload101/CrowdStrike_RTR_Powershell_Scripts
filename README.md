# More Stuff:

https://github.com/freeload101/SCRIPTS/tree/master/CrowdStrike%20Threat%20Hunting

https://github.com/freeload101/SCRIPTS/tree/master/Bash/CS_BADGER

# CrowdStrike_RTR_Powershell_Scripts

RTR_browsinghistoryview.ps1
![image](https://user-images.githubusercontent.com/4307863/182012315-44fd283d-8219-491d-8d61-c4d5d27bbf13.png)

Getting into RTR scripting


* add my Rekall / yara scrtipts ( full powershell )
* search / find a IR powershell script ( I have url some place ... I just can't find it .. )
* https://github.com/KurtDeGreeff/PlayPowershell ( add anything cool from here )
* RTR to zip all the info up and pull it down ( some code I saw for this some place .. ? )

Reference:

https://github.com/meirwah/awesome-incident-response

https://github.com/rshipp/awesome-malware-analysis


https://github.com/KurtDeGreeff/PlayPowershell

https://github.com/PolarBearGod/CrowdStrike-RTR-Scripts

https://github.com/bk-CS/PSFalcon

https://github.com/bk-cs/PSFalcon/tree/master/real-time-response


-----------


https://github.com/freeload101/CrowdStrike_RTR_Powershell_Scripts/blob/main/PSFalcon_Runscript_loop_PUBLIC.ps1


auto retry

hostname input

string "ALL DONE" to verify scripts completed

add to RTR group


---


```
foreach ($Property in (Get-CimInstance Win32_Process  )) { 
if (((Invoke-CimMethod -InputObject $Property -MethodName GetOwner).User) -eq "USERNAMEHERE" ) {
Write-Output  Killing $Property.ProcessId
Stop-Process -Id $Property.ProcessId   -Force
}
}
Write-Output  "ALL DONE"```
