#
# Module 'Dynamite.PowerShell.Toolkit'
# Generated by: GSoft, Team Dynamite.
# Generated on: 10/24/2013
# > GSoft & Dynamite : http://www.gsoft.com
# > Dynamite Github : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
# > Documentation : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
#

<#
    .SYNOPSIS
        Commandlet to create a new Managed Path

    .DESCRIPTION
        Commandlet to create a new Managed Path for a SharePoint Site

    --------------------------------------------------------------------------------------
    Module 'Dynamite.PowerShell.Toolkit'
    by: GSoft, Team Dynamite.
    > GSoft & Dynamite : http://www.gsoft.com
    > Dynamite Github : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    > Documentation : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    --------------------------------------------------------------------------------------
    
    .PARAMETER  RelativeURL
        The Path of the managed path to create relative the the WebApplication.
        Do not include a leading forward slash.

    .PARAMETER  WebApplication
        The Web Application where to create the Managed Path.
        Do not specify this parameter if you wish to create a host header managed path.
    
    .PARAMETER  Wildcard
        Specifies whether the managed path is explicit or wildcard.
        If not provided, the managed path is an explicit path.

    .EXAMPLE
        PS C:\> New-DSPManagedPath -RelativeURL 'mySite' -WebApplication 'http://myWebApp'

    .INPUTS
        System.String,System.String

    .OUTPUTS
        System.String    
    
  .LINK
    GSoft, Team Dynamite on Github
    > https://github.com/GSoft-SharePoint
    
    Dynamite PowerShell Toolkit on Github
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    
    Documentation
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    
#>
function New-DSPManagedPath
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$RelativeURL,
        
        [Parameter(Mandatory=$false, Position=1)]
        [Microsoft.SharePoint.PowerShell.SPWebApplicationPipeBind]$WebApplication,
        
        [Parameter(Mandatory=$false, Position=2)]
        [switch]$Wildcard
    )
    
    if ($WebApplication -ne $null) 
    {
        $webAppName = $WebApplication.Read().DisplayName
        
        $ExistingManagedPath = Get-SPManagedPath -WebApplication $WebApplication | Select-Object Name | Where {$_.Name -eq $RelativeURL}
        if ($ExistingManagedPath -eq $null)
        {
            Write-Host "The managed path '$RelativeURL' is being created for the '$webAppName' Web Application ..."
            New-SPManagedPath -RelativeURL $RelativeURL -WebApplication $WebApplication -Explicit:(-not $Wildcard) -ErrorAction Stop
            Write-Host "Done!"
        }
        else
        {
            Write-Host "The managed path '$RelativeURL' already exists for the '$webAppName' Web Application"
        }
    }
    else
    {
        $ExistingManagedPath = Get-SPManagedPath -HostHeader | Select-Object Name | Where {$_.Name -eq $RelativeURL}
        if ($ExistingManagedPath -eq $null)
        {
            Write-Host "The host header managed path for all host header site collections is being created ..."
            New-SPManagedPath -RelativeURL $RelativeURL -HostHeader -Explicit:(-not $Wildcard) -ErrorAction Stop
            Write-Host "Done"
        }
        else
        {
            Write-Host "The host header managed path '$RelativeURL' already exists"
        }
    }
    
}