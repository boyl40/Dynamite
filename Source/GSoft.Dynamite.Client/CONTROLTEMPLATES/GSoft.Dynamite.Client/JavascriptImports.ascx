﻿<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>
<%@ Assembly Name="Microsoft.Web.CommandUI, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=3.5.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>
<%@ Import Namespace="Microsoft.SharePoint" %> 
<%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="JavascriptImports.ascx.cs" Inherits="GSoft.Dynamite.Client.CONTROLTEMPLATES.GSoft.Dynamite.Client.JavascriptImports" %>

<%-- 3rd party JS libraries --%>
<SharePoint:ScriptLink ID="JqueryScriptLink" Language="javascript" Name="~sitecollection/_layouts/GSoft.Dynamite.Client/Lib/jquery-1.10.2.min.js" Localizable="false" OnDemand="false" runat="server" />
<SharePoint:ScriptLink ID="JqueryPlaceHolderShim" Language="javascript" Name="~sitecollection/_layouts/GSoft.Dynamite.Client/Lib/jquery.html5-placeholder-shim.js" Localizable="false" OnDemand="false" runat="server" />
<SharePoint:ScriptLink ID="JqueryNoConflictScriptLink" Language="javascript" Name="~sitecollection/_layouts/GSoft.Dynamite.Client/Lib/jquery-noconflict.js" Localizable="false" OnDemand="false" runat="server" />

<SharePoint:ScriptLink ID="KnockOutScriptLink" Language="javascript" Name="~sitecollection/_layouts/GSoft.Dynamite.Client/Lib/knockout-3.0.0.js" Localizable="false" OnDemand="false" runat="server"/>
<SharePoint:ScriptLink ID="MomentScriptLink" Language="javascript" Name="~sitecollection/_layouts/GSoft.Dynamite.Client/Lib/moment-with-langs.min.js" Localizable="false" OnDemand="false" runat="server"/>
<SharePoint:ScriptLink ID="UnderscoreScriptLink" Language="javascript" Name="~sitecollection/_layouts/GSoft.Dynamite.Client/Lib/underscore-min.js" Localizable="false" OnDemand="false" runat="server"/>

<%-- Dynamite JS libraries --%>
<SharePoint:ScriptLink ID="DynamiteCoreScriptLink" Language="javascript" Name="~sitecollection/_layouts/GSoft.Dynamite.Client/GSoft.Dynamite.Client.Core.js" Localizable="false" OnDemand="false" runat="server" />
<SharePoint:ScriptLink ID="KnockoutBindingHandlersScriptLink" Language="javascript" Name="~sitecollection/_layouts/GSoft.Dynamite.Client/GSoft.Dynamite.Client.Knockout.BindindHandlers.js" Localizable="false" OnDemand="false" runat="server" />
<SharePoint:ScriptLink ID="KnockoutExtensionsScriptLink" Language="javascript" Name="~sitecollection/_layouts/GSoft.Dynamite.Client/GSoft.Dynamite.Client.Knockout.Extensions.js" Localizable="false" OnDemand="false" runat="server" />

<%-- Reusable Knockout.js HTML templates --%>
<script type="text/html" id="tabs-template">
    <ul class="edit-mode-tabs float-left full-width">
        <!-- ko foreach: tabs -->
        <li class="edit-mode-tab-title float-left" data-bind="
            text: resourceString,
            click: function (data) { $root.toggleTab(data) }, 
            css: { 'edit-mode-tab-title-selected': isSelected }">
        </li>
        <!-- /ko -->
        <li class="minimize" data-bind="click: $root.toggleAllTabs">
            -
        </li>
    </ul>
</script>

<%-- Global JS initialization --%>

<script type="text/javascript">
    GSoft.Dynamite.Client.Utils.CurrentWebUrl = "<asp:Literal ID="CurrentWebUrlLiteral" runat="server" />";
    GSoft.Dynamite.Client.Utils.ParentFolderUrl = "<asp:Literal ID="ParentFolderUrlLiteral" runat="server" />";
    GSoft.Dynamite.Client.Utils.initializeParentFolderLink();
</script>
