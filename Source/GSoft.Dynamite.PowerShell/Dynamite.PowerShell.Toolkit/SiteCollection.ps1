#
# Module 'Dynamite.PowerShell.Toolkit'
# Generated by: GSoft, Team Dynamite.
# Generated on: 10/24/2013
# > GSoft & Dynamite : http://www.gsoft.com
# > Dynamite Github : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
# > Documentation : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
#

function New-DSPSiteCollectionRecusiveXml()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [System.Xml.XmlElement]$Site,
        
        [Parameter(Mandatory=$true, Position=1)]
        [string]$WebApplicationUrl
    )	
    
    # Remove the trailing slash
    $WebApplicationUrl.Trimend('/')

    [string]$ContentDatabaseName = $Site.ContentDatabase
    [string]$SiteHostNamePath = $Site.HostNamePath
    [string]$SiteManagedPath = $Site.ManagedPath
    [string]$SiteWildcardPath = $Site.WildcardPath
    [string]$Name = $Site.Name
    [string]$OwnerAlias = $Site.OwnerAlias
    [string]$SecondaryOwnerAlias = if ([string]::IsNullOrEmpty($Site.SecondaryOwnerAlias)) { "$env:USERDOMAIN\$env:USERNAME" } else { $Site.SecondaryOwnerAlias }
    [string]$Language = $Site.Language
    [string]$Locale = $Site.Locale	
    [string]$Template = $Site.Template
    [bool]$IsWildCardInclusion = -not [string]::IsNullOrEmpty($SiteWildcardPath)
    [bool]$IsHostNamedSite = -not [string]::IsNullOrEmpty($SiteHostNamePath)
    [bool]$IsAnonymous = [bool]$Site.IsAnonymous
    
    # Construct site relative url
    $SiteRelativeUrl = "/"
    if (-not [string]::IsNullOrEmpty($SiteManagedPath))
    {
        $SiteRelativeUrl += $SiteManagedPath
        
        if (-not [string]::IsNullOrEmpty($SiteWildcardPath))
        {
            $SiteRelativeUrl += "/$SiteWildcardPath"
        }      
      
        # Create the Managed Path if they do not exist
        if ($IsHostNamedSite)
        {
            New-DSPManagedPath -RelativeURL $SiteManagedPath -Wildcard:$IsWildCardInclusion
        }
        else
        {
            New-DSPManagedPath -RelativeURL $SiteManagedPath -WebApplication $WebApplicationUrl -Wildcard:$IsWildCardInclusion
        }
    }
    
    $SiteAbsoluteUrl = if ($IsHostNamedSite) { "$SiteHostNamePath$SiteRelativeUrl" } else { "$WebApplicationUrl$SiteRelativeUrl" }    
    
    # Create the Content Database if they do not exist
    New-DSPContentDatabase -ContentDatabaseName $ContentDatabaseName -WebApplicationUrl $WebApplicationUrl
    
    $spSite = Get-SPSite -Identity $SiteAbsoluteUrl -ErrorAction SilentlyContinue
    if ($spSite -eq $null)
    {
        Write-Verbose "Creating site collection $SiteAbsoluteUrl"
        
        $startTime = Get-Date
        if ($IsHostNamedSite)
        {
            $spSite = New-SPSite -URL $SiteAbsoluteUrl -HostHeaderWebApplication $WebApplicationUrl -OwnerAlias $OwnerAlias -SecondaryOwnerAlias $SecondaryOwnerAlias -Name $Name -Language $Language -Template $Template -ContentDatabase $ContentDatabaseName
        }
        else
        {
            $spSite = New-SPSite -URL $SiteAbsoluteUrl -OwnerAlias $OwnerAlias -SecondaryOwnerAlias $SecondaryOwnerAlias -Name $Name -Language $Language -Template $Template -ContentDatabase $ContentDatabaseName
        }

        $web = $spSite.RootWeb
        
        if ($IsAnonymous)
        {            
            $web.AnonymousState = 2
            $web.AnonymousPermMask64 = "ViewListItems, ViewVersions, ViewFormPages, Open, ViewPages"
            $web.update()
            Write-Verbose "Enable the Site for Anonymous"
        }

        if ((-not [string]::IsNullOrEmpty($Locale)) -and ($Locale -ne $Language)) {
            [int]$LocaleAsInt = $Locale -as [int]
            $culture = New-Object System.Globalization.CultureInfo($LocaleAsInt)
            $web.Locale = $culture
            $web.Update()
        }
        
        $elapsedTime = ($(get-date) - $StartTime).TotalSeconds
        Write-Verbose "Took $elapsedTime sec."
        Write-Verbose "Site $Name Created Successfully!"
    }
    else
    {
        Write-Warning "Another site already exists at $SiteAbsoluteUrl! Use -Force parameter to delete (wiping out its content) and then re-create the site."
    }
    
    $Group = $Site.Groups
    if ($Group -ne $null) 
    {
        $ClearExistingPermissions = [System.Convert]::ToBoolean($Group.ClearExistingPermissions)
        if ($ClearExistingPermissions -eq $true) 
        {
            Clear-DSPWebPermissions -Web $spSite.Url
        }
        
        Add-DSPGroupByXml -Web $spSite.Url -Group $Group
    }
    
    # Create Sub Webs
    if ($Site.Webs -ne $null)
    {
        New-DSPWebXml -Webs $Site.Webs -ParentUrl $spSite.Url -UseParentTopNav
    }
    
    # Create Variations
    if ($Site.Variations -ne $null)
    {
        New-DSPSiteVariations -Config $Site.Variations -Site $spSite
    }

    # Activate Features 
    if($Site.Feature -ne $null)
    {
        Initialize-DSPFeatures $Site $spSite.Url
    }
}

<#
    .SYNOPSIS
        Method to Create multiple Site Collections and Sites structure

    .DESCRIPTION
        Method to Create multiple Site Collections and Sites structure

    --------------------------------------------------------------------------------------
    Module 'Dynamite.PowerShell.Toolkit'
    by: GSoft, Team Dynamite.
    > GSoft & Dynamite : http://www.gsoft.com
    > Dynamite Github : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    > Documentation : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    --------------------------------------------------------------------------------------
    
    .PARAMETER  XmlPath
        Path to the Xml file describing the structure

  .EXAMPLE
        PS C:\> New-DSPStructure "c:\structure.xml"

    .INPUTS
        System.String
        
  .LINK
    GSoft, Team Dynamite on Github
    > https://github.com/GSoft-SharePoint
    
    Dynamite PowerShell Toolkit on Github
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    
    Documentation
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    
  
  .NOTES
  Here is the Structure XML schema.
  
<WebApplication Url="http://myWebApp">
  <Site Name="Site Name" ManagedPath="mySiteUrl" OwnerAlias="ORG\admin" Language="1033" Locale="4105" Template="STS#1" ContentDatabase="CUSTOM_CONTENT_NAME" IsAnonymous="True">
    <Groups>
      <Group Name="Site_Admin" OwnerName="ORG\admin" Description="Admin Group" IsAssociatedOwnerGroup="true">
        <PermissionLevels>
          <PermissionLevel Name="Full Control"/>
          <PermissionLevel Name="Contribute"/>
          <PermissionLevel Name="Read"/>
        </PermissionLevels>
      </Group>
    </Groups>
    <Webs>
      <Web Name="SubSite Name" Path="mySubSiteUrl" Template="STS#0">
        <Groups>
          <Group Name="SubSite_Admin" OwnerName="ORG\admin" Description ="Admin Group for SubSite">
            <PermissionLevels>
              <PermissionLevel Name="Full Control"/>
              <PermissionLevel Name="Contribute"/>
              <PermissionLevel Name="Read"/>
            </PermissionLevels>
          </Group>
        </Groups>
      </Web>
    </Webs>
  </Site>
</WebApplication>
#>
function New-DSPStructure()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$XmlPath
    )
    
    # Get the Xml content and start looping throught Site Collections and generate the structure
    $Config = [xml](Get-Content $XmlPath)
    $Config.WebApplication.Site | ForEach-Object {New-DSPSiteCollectionRecusiveXml -Site $_ -WebApplicationUrl $_.ParentNode.Url}
}

<#
    .SYNOPSIS
        Method to Delete multiple Site Collections and Sites structure

    .DESCRIPTION
        Method to Delete multiple Site Collections and Sites structure

    --------------------------------------------------------------------------------------
    Module 'Dynamite.PowerShell.Toolkit'
    by: GSoft, Team Dynamite.
    > GSoft & Dynamite : http://www.gsoft.com
    > Dynamite Github : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    > Documentation : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    --------------------------------------------------------------------------------------
    
    .PARAMETER  XmlPath
        Path to the Xml file describing the structure

  .EXAMPLE
        PS C:\> New-DSPStructure "c:\structure.xml"

    .INPUTS
        System.String
        
  .LINK
    GSoft, Team Dynamite on Github
    > https://github.com/GSoft-SharePoint
    
    Dynamite PowerShell Toolkit on Github
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    
    Documentation
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    
    
  .NOTES
  Here is the Structure XML schema.
  
<WebApplication Url="http://myWebApp">
  <Site Name="Site Name" ManagedPath="mySiteUrl" OwnerAlias="ORG\admin" Language="1033" Template="STS#1" ContentDatabase="CUSTOM_CONTENT_NAME">
    <Groups>
      <Group Name="Site_Admin" OwnerName="ORG\admin" Description="Admin Group" IsAssociatedOwnerGroup="true">
        <PermissionLevels>
          <PermissionLevel Name="Full Control"/>
          <PermissionLevel Name="Contribute"/>
          <PermissionLevel Name="Read"/>
        </PermissionLevels>
      </Group>
    </Groups>
    <Webs>
      <Web Name="SubSite Name" Path="mySubSiteUrl" Template="STS#0">
        <Groups>
          <Group Name="SubSite_Admin" OwnerName="ORG\admin" Description ="Admin Group for SubSite">
            <PermissionLevels>
              <PermissionLevel Name="Full Control"/>
              <PermissionLevel Name="Contribute"/>
              <PermissionLevel Name="Read"/>
            </PermissionLevels>
          </Group>
        </Groups>
      </Web>
    </Webs>
  </Site>
</WebApplication>
#>
function Remove-DSPStructure()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$XmlPath
    )
    
    $Config = [xml](Get-Content $XmlPath)
    foreach ($site in $Config.WebApplication.Site)
    {
        [bool]$IsHostNamedSite = -not [string]::IsNullOrEmpty($site.HostNamePath)
        $SiteRelativeUrl = "/$($site.ManagedPath)/$($site.WildcardPath)"
        $SiteAbsoluteUrl = if ($IsHostNamedSite) { $site.HostNamePath + $SiteRelativeUrl } else { $site.ParentNode.Url + $SiteRelativeUrl }
        $site = Get-SPSite -Identity $SiteAbsoluteUrl -ErrorAction SilentlyContinue
        
        if($site -ne $null)
        {	
            Write-Verbose "Remove site collection $SiteAbsoluteUrl"
            Remove-SPSite -Identity $SiteAbsoluteUrl
        }
        else
        {
            Write-Warning "No site collection $SiteAbsoluteUrl found"
        }		
    }
}

function Remove-DSPStructureDatabase()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$XmlPath
    )
    
    $Config = [xml](Get-Content $XmlPath)
    foreach ($site in $Config.WebApplication.Site)
    {
        Remove-SPContentDatabase -Identity $Site.ContentDatabase
    }
}

<#
    .SYNOPSIS
        Method to Add Suggested Browser Content Locations 

    .DESCRIPTION
        Method to Suggested Browser Content Locations on a site collection

    --------------------------------------------------------------------------------------
    Module 'Dynamite.PowerShell.Toolkit'
    by: GSoft, Team Dynamite.
    > GSoft & Dynamite : http://www.gsoft.com
    > Dynamite Github : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    > Documentation : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    --------------------------------------------------------------------------------------
    
    .PARAMETER  XmlPath
        Path to the Xml file describing the configuration

  .EXAMPLE
        PS C:\> New-SuggestedBrowserContentLocations "c:\structure.xml"

    .INPUTS
        System.String
        
  .LINK
    GSoft, Team Dynamite on Github
    > https://github.com/GSoft-SharePoint
    
    Dynamite PowerShell Toolkit on Github
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    
    Documentation
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    
    
  .NOTES
  Here is the Structure XML schema.
  
    <Configuration>
      <Site Url="http://yoururl">
        <PublishingLinks>
          <Link DisplayName="Images for content" Url="http://site/LibraryRootFolder" UrlDescription="Images picker" Description="Images for content"/>
        </PublishingLinks>
      </Site>
    </Configuration>
#>
function New-SuggestedBrowserContentLocations
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$XmlPath
    )
    
    $Config = [xml](Get-Content $XmlPath)
    $Config.Configuration.Site | ForEach-Object {
    
        $Site = Get-SPSite $_.Url
        Add-SuggestedBrowserContentLocations $_.PublishingLinks $Site
    }
}

function Add-SuggestedBrowserContentLocations
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [System.Xml.XmlElement]$PublishingLinks,
        
        [Parameter(Mandatory=$true, Position=1)]
        [Microsoft.SharePoint.SPSite]$Site
    )	
    $publishingLinksListUrl = [Microsoft.SharePoint.Utilities.SPUtility]::ConcatUrls($Site.RootWeb.ServerRelativeUrl,"/PublishedLinks")
    $PublishingLinksList = $Site.RootWeb.GetList($publishingLinksListUrl)
    if($PublishingLinksList -ne $null)
    {
        $PublishingLinks.Link | ForEach-Object {
    
                $url = $_.Url

                Write-Verbose "Adding Suggested browser location $url"
                    
                $urlFieldValue = New-Object Microsoft.SharePoint.SPFieldUrlValue
                $urlFieldValue.Url = $url
                $urlFieldValue.Description = $_.UrlDescription
                    
                $listItem = $PublishingLinksList.Items.Add()
                $listItem["Title"] = $_.DisplayName
                $listItem["PublishedLinksDescription"] = $_.Description
                [Microsoft.SharePoint.SPFieldUrlValue]$listItem["PublishedLinksURL"] = $urlFieldValue
                
                $listItem.Update()
        }  
    }
}


