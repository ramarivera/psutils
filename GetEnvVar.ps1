[CmdletBinding(SupportsShouldProcess=$true)]
param(    
    [parameter(Mandatory=$false)][string]$Name = "PATH"
)
Begin
{
#Requires -RunAsAdministrator

    # Win32API error codes
    $ERROR_SUCCESS = 0
    $ERROR_DUP_NAME = 34 
    $ERROR_INVALID_DATA = 13

    # Sort of constants useful for reg handling
    $regPath = "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
    $hklm = [Microsoft.Win32.Registry]::LocalMachine

    # CWD of the script, useful for calling auxiliary ps1
    $scriptpath = Split-Path $MyInvocation.MyCommand.Path

    Function GetEnvVar([string]$envname)
    {     
        $regKey = $hklm.OpenSubKey($regPath, $FALSE)
        $envvalue = $regKey.GetValue($envname, "", [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
        return $envvalue
    }
}
Process
{
    [string]$result = GetEnvVar $Name
    
    return $result     
}
