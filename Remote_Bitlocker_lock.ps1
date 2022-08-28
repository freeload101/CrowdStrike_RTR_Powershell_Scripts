# run this on RTR powershell session  
 
# Wipe existing BitLocker protections
manage-bde -protectors -delete C:
# Create new, randomly generated recovery password 
manage-bde -protectors -add C: -RecoveryPassword
# Verify new recovery password will be required on next reboot
manage-bde -protectors -enable C:
# Force the user to be prompted for new recovery password
manage-bde -forcerecovery C:
 
#############################################################
####################### WARNING #############################
#############################################################
# YOU MUST COPY THE KEY (PASSWORD) TO UNLOCK THE DRIVE IF YOU LOSE THE KEY YOU WILL NOT BE ABLE TO RECOVER ANYTHING FROM THE C: DRIVE !!!
# EXAMPLE 713438-591129-666237-608498-028864-058685-409024-701756
 
Write-Output "$([regex]::Matches($NewPassword, 'Key\sProtectors\sAdded:(?:.*\n)*?.*ID:\s{(?<ID>[^}]+)}\s*Password:\s*(?<Password>[^\s]+)'))"
 
 
# force Reboot system to trigger recovery prompt 
# Restart-Computer -Force
