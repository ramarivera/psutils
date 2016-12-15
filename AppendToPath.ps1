[CmdletBinding(SupportsShouldProcess=$true)]
param(    
    [parameter(Mandatory=$true)][string]$Value
)
Begin
{
#Requires -RunAsAdministrator

    # Win32API error codes
    $ERROR_SUCCESS = 0
    $ERROR_DUP_NAME = 34 
    $ERROR_INVALID_DATA = 13

    # CWD of the script, useful for calling auxiliary ps1
    $scriptpath = Split-Path $MyInvocation.MyCommand.Path

    Function AppendToPath([string] $newlocation) 
    {
        [string] $oldpath = & "$scriptpath\GetEnvVar.ps1"
        $parts = $oldPath.split(";")

        If ($parts -contains $newlocation)
        {
            Write-Warning "Location already in PATH"
            Exit $ERROR_DUP_NAME        
        }

        [string] $newPath = $oldPath + ";" + $newlocation
        $newPath = $newPath -replace ";;",""
        $env:path += ";$newlocation"
        & "$scriptpath\SetEnvVar.ps1" "PATH" $newPath -SetPath
    }
}
Process
{

    # Delete trailling whitespace
    $Value = $Value.Trim();
    If ($Value -eq "" -or $Value -eq $null)
    {
        Write-Error "Value cannot be null or empty"
        Exit $ERROR_INVALID_DATA
    }
    
    AppendToPath -newlocation $Value

}
