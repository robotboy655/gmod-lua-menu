
local PANEL = {}

surface.CreateFont( "rb655_AddonName", {
	size = ScreenScale( 12 ),
	font = "Tahoma"
} )

surface.CreateFont( "rb655_AddonDesc", {
	size = ScreenScale( 8 ),
	font = "Tahoma"
} )

function PANEL:Init()
	self:SetTall( 128 )
	
	self.ToggleBut = self:Add( "DButton" )
	self.ToggleBut:SetText( "Toggle Mounted" )
	self.ToggleBut.DoClick = function()
		if ( !self.Addon ) then return end
		steamworks.SetShouldMountAddon( self.Addon.wsid, !steamworks.ShouldMountAddon( self.Addon.wsid ) )
		steamworks.ApplyAddons()
	end
	
	self.UninstallBut = self:Add( "DButton" )
	self.UninstallBut:SetText( "Uninstall" )
	self.UninstallBut.DoClick = function()
		if ( !self.Addon ) then return end
		steamworks.Unsubscribe( self.Addon.wsid )
		steamworks.ApplyAddons()
	end
	
	self.WorkshopBut = self:Add( "DButton" )
	self.WorkshopBut:SetText( "View On Workshop" )
	self.WorkshopBut.DoClick = function()
		if ( !self.Addon ) then return end
		steamworks.ViewFile( self.Addon.wsid )
		steamworks.ApplyAddons()
	end
end

function PANEL:Toggle()
end

gDataTable = {}
function PANEL:SetAddon( data )
	self.Addon = data
	
	if ( gDataTable[ data.wsid ] ) then self.AdditionalData = gDataTable[ data.wsid ] return end

	steamworks.FileInfo( data.wsid, function( result )
		if ( !IsValid( self ) ) then return end

		self.AdditionalData = result
		
		gDataTable[ data.wsid ] = result
		
		//tooltip
		/*if ( self.AdditionalData ) then
			local s = self.AdditionalData.description
			local t = ""
			s=string.Replace( s, "[/h1]","\n")
			for i,s in pairs( string.Explode( "\n", s ) ) do
				s=s:gsub("(%b[])","")
				t = t .. s .. "\n"
			end
			
			self:SetToolTip( t )
		end*/
		
		if ( file.Exists( 'cache/workshop/' .. result.previewid .. '.cache',"GAME" ) ) then
			return
		end

		steamworks.Download( result.previewid, false, function( name )

			if ( !name ) then return end -- Download failed
			//self.Image = Material( 'asset://garrysmod/' .. name )

		end )
	end )
	steamworks.VoteInfo( data.wsid, function( result ) self.VoteData = result end )
end

function PANEL:Paint( w, h )

	if ( IsValid( self.ToggleBut ) ) then
		self.ToggleBut:SetWide( 128 )
		self.ToggleBut:SetPos( self:GetWide() - self.ToggleBut:GetWide() - 5, 5 )
	end
	
	if ( IsValid( self.UninstallBut ) ) then
		self.UninstallBut:SetWide( 128 )
		self.UninstallBut:SetPos( self:GetWide() - self.UninstallBut:GetWide() - 5, 30 )
	end

	if ( IsValid( self.WorkshopBut ) ) then
		self.WorkshopBut:SetWide( 128 )
		self.WorkshopBut:SetPos( self:GetWide() - self.WorkshopBut:GetWide() - 5, 55 )
	end
	
	if ( !self.Image && self.AdditionalData && file.Exists( 'cache/workshop/' .. self.AdditionalData.previewid .. '.cache',"GAME" ) ) then
		//self.Image = Material( "../cache/workshop/" .. self.AdditionalData.previewid .. ".cache", "nocull smooth" )
		self.Image = AddonMaterial( "cache/workshop/" .. self.AdditionalData.previewid .. ".cache" )
	end

	if ( self.Addon && steamworks.ShouldMountAddon( self.Addon.wsid ) ) then
		draw.RoundedBox( 4, 0, 0, w, h, Color( 200, 255, 200, 200 ) )
	else
		draw.RoundedBox( 4, 0, 0, w, h, Color( 255, 255, 255, 200 ) )
	end
	
	local h = 5
	if ( self.Addon ) then
		local a, b = draw.SimpleText( self.Addon.title, "rb655_AddonName", 118 + 10, h, Color( 0, 0, 0 ) )
		h=h + b
	end
	
	if ( self.Image ) then
		surface.SetDrawColor( color_white )
		surface.SetMaterial( self.Image )
		surface.DrawTexturedRect( 5, 5, 118, 118 )
	else
		surface.SetMaterial( Material( "../html/img/addonpreview.png", "nocull smooth" ) )
		surface.DrawTexturedRect( 5, 5, 118, 118 )
	end
	
	if ( self.AdditionalData ) then
		local s = self.AdditionalData.description
		s=string.Replace( s, "[/h1]","\n")
		for i,s in pairs( string.Explode( "\n", s ) ) do
			if ( i > 3 ) then return end
			s=s:gsub("(%b[])","")
			local a,b = draw.SimpleText( s, "rb655_AddonDesc", 118 + 10, h, Color( 0, 0, 0 ) )
			h=h+b
		end
	end
end

vgui.Register( "MenuAddon", PANEL, "Panel" )

local PANEL = {}

function PANEL:Init()

	self:Dock( FILL )

	local Categories = vgui.Create( "DListLayout", self )
	Categories:DockPadding( 5, 5, 5, 5 )
	Categories:Dock( LEFT )
	Categories:SetWide( 200 )
	
	local ToggleMounted = vgui.Create( "DButton", Categories )
	ToggleMounted:Dock( TOP )
	ToggleMounted:SetText( "#Toggle Selected" )
	ToggleMounted:SetTall( 30 )
	ToggleMounted:SetDisabled( true )
	ToggleMounted.DoClick = function()
		self:ToggleSelected()
	end
	
	local UnmountAll = vgui.Create( "DButton", Categories )
	UnmountAll:Dock( TOP )
	UnmountAll:SetText( "#Disable All" )
	UnmountAll:SetTall( 30 )
	UnmountAll:DockMargin( 0, 5, 0, 0 )
	UnmountAll.DoClick = function()
		self:UnmountAll()
	end
	
	local MountAll = vgui.Create( "DButton", Categories )
	MountAll:Dock( TOP )
	MountAll:SetText( "#Enable All" )
	MountAll:SetTall( 30 )
	MountAll:DockMargin( 0, 5, 0, 0 )
	MountAll.DoClick = function()
		self:MountAll()
	end
	
	local MountAll = vgui.Create( "DButton", Categories )
	MountAll:Dock( TOP )
	MountAll:SetText( "#Open Workshop" )
	MountAll:SetTall( 30 )
	MountAll:DockMargin( 0, 50, 0, 0 )
	MountAll.DoClick = function()
		steamworks.OpenWorkshop()
	end
	
	------------------- Addon List
	
	local Scroll = vgui.Create( "DScrollPanel", self )
	Scroll:Dock( FILL )
	Scroll:DockMargin( 0, 5, 5, 5 )
	
	local AddonList = vgui.Create( "DListLayout", Scroll )
	AddonList:Dock( FILL )
	self.AddonList = AddonList
	self:RefreshAddons()

end

function PANEL:ToggleSelected()
	for id, line in pairs( self.AddonList:GetChildren() ) do
		if ( !line:IsSelected() ) then continue end
		steamworks.SetShouldMountAddon( line.Addon.wsid, !steamworks.ShouldMountAddon( line.Addon.wsid ) )
	end
	steamworks.ApplyAddons()
end

function PANEL:UnmountAll()
	for id, line in pairs( self.AddonList:GetChildren() ) do
		steamworks.SetShouldMountAddon( line.Addon.wsid, false )
	end
	steamworks.ApplyAddons()
end

function PANEL:MountAll()
	for id, line in pairs( self.AddonList:GetChildren() ) do
		steamworks.SetShouldMountAddon( line.Addon.wsid, true )
	end
	steamworks.ApplyAddons()
end

function PANEL:RefreshAddons()

	self.AddonList:Clear()
	for id, addon in SortedPairsByMemberValue( engine.GetAddons(), "title" ) do
		local pnl = self.AddonList:Add( "MenuAddon" )
		pnl:SetAddon( addon )
		pnl:DockMargin( 0, 0, 5, 5 )
	end

end

vgui.Register( "AddonsPanel", PANEL, "EditablePanel" )
