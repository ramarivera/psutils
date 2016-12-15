[CmdletBinding(SupportsShouldProcess=$true)]
param(    
    [parameter(Mandatory=$true)][string]$Name,
    [parameter(Mandatory=$true)][string]$Value, 
    [parameter(Mandatory=$false)][switch]$Force,
    [parameter(Mandatory=$false)][switch]$SetPath
)
Begin
{
#Requires -RunAsAdministrator

    # Win32API error codes
    $ERROR_SUCCESS = 0
    $ERROR_DUP_NAME = 34 
    $ERROR_INVALID_DATA = 13

    # Some env vars already defined for my os at least
    $SYSTEM_ENV_VARS = @(
        "ComSpec",
        "NUMBER_OF_PROCESSORS", 
        "OS",
        "PATHEXT",
        "PROCESSOR_ARCHITECTURE",
        "PROCESSOR_IDENTIFIER",
        "PROCESSOR_LEVEL",
        "PROCESSOR_REVISION",
        "PSModulePath",
        "TEMP",
        "TMP",
        "USERNAME",
        "VBOX_MSI_INSTALL_PATH",
        "windir")

    # Should ask for confirmation before overwriting an already existing env var?
    $continue = $Force

    # Sort of constants useful for reg handling
    $regPath = "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
    $hklm = [Microsoft.Win32.Registry]::LocalMachine

    # CWD of the script, useful for calling auxiliary ps1
    $scriptpath = Split-Path $MyInvocation.MyCommand.Path


    Function SetEnvVar([string]$envname, [string]$envvalue)
    {     
        $regKey = $hklm.OpenSubKey($regPath, $True)
        $regKey.SetValue($envname, $envvalue, [Microsoft.Win32.RegistryValueKind]::ExpandString)
    }

}
Process
{
    If ($Name -eq "" -or $Name -eq $null)
    {       
        Write-Error "Name cannot be null or empty"
        Exit $ERROR_INVALID_DATA
    }

    # Delete trailling whitespace
    $Value = $Value.Trim();
    If ($Value -eq "" -or $Value -eq $null)
    {       
        Write-Error "Value cannot be null or empty"
        Exit $ERROR_INVALID_DATA
    }

    If ($SYSTEM_ENV_VARS -contains $Name) 
    {
        Write-Error "Cannot overwrite the $Name Environment Variable, do it manually"
        Exit $ERROR_INVALID_DATA
    }
    
    If ($Name -eq "PATH" -and !$SetPath) 
    {
        Write-Error "Cannot overwrite the PATH Environment Variable, use 'AppendToPath.ps1 -Value $Value'"
        Exit $ERROR_INVALID_DATA   
    } 
    elseif ($Name -eq "PATH" -and $SetPath) {
        $continue = $True
    } 

    If (!$continue) 
    {
        [string] $oldvalue = & "$scriptpath\GetEnvVar.ps1" -Name $Name
        If ($oldvalue -ne "" -or $oldvalue -ne $null)
        {
            $ans = ""
            while ($ans -notmatch "[y|n]")
            {
                $ans = Read-Host "Environment Variable '$Name' is already set. Do you wish to overwrite it? (Y/N)"
            }
            if ($ans -eq "y")
            {
                $continue = $True
            }
        } 
        else 
        {
             $continue = $True
        }
    }
    If ($continue) 
    {
        SetEnvVar $Name $Value
        Write-Output "Operation was succesfull"
    } 
    else 
    {
        Write-Output "Aborted"
    }
}
