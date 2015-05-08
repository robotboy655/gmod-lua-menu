
surface.CreateFont( "rb655_AddonName", {
	size = ScreenScale( 12 ),
	font = "Tahoma"
} )

surface.CreateFont( "rb655_AddonDesc", {
	size = ScreenScale( 8 ),
	font = "Tahoma"
} )

local PANEL = {}

function PANEL:Init()
	self:SetTall( 200 )
	self:SetWide( 200 )
	
	self.Selected = false
	
	local DermaCheckbox = vgui.Create( "DCheckBox", self )
	DermaCheckbox:SetPos( 10, 10 )
	DermaCheckbox:SetValue( 0 )
	self.DermaCheckbox = DermaCheckbox

end

function PANEL:OnMouseReleased( mousecode )

	if ( mousecode == MOUSE_RIGHT ) then

		local m = DermaMenu()

		if ( !self.panel.ToggleMounted:GetDisabled() ) then
			m:AddOption( "Toggle Selected", function() self.panel:ToggleSelected() end )
			
			m:AddSpacer()
		end
		
		m:AddOption( "Open Workshop Page", function() steamworks.ViewFile( self.Addon.wsid ) end )
		m:AddOption( "Toggle Mounted", function() steamworks.SetShouldMountAddon( self.Addon.wsid, !steamworks.ShouldMountAddon( self.Addon.wsid ) ) steamworks.ApplyAddons() end )
		m:AddOption( "Uninstall", function() steamworks.Unsubscribe( self.Addon.wsid ) steamworks.ApplyAddons() end ) -- Do we need ApplyAddons here?
		m:AddOption( "Cancel", function() end )
		m:Open()
	end

end

function PANEL:Toggle()
end

function PANEL:SetSelected( b )
	self.DermaCheckbox:SetChecked( b )
end

function PANEL:GetSelected()
	return self.DermaCheckbox:GetChecked()
end

gDataTable = gDataTable or {}
function PANEL:SetAddon( data )
	self.Addon = data
	if ( gDataTable[ data.wsid ] ) then self.AdditionalData = gDataTable[ data.wsid ] return end

	steamworks.FileInfo( data.wsid, function( result )
		gDataTable[ data.wsid ] = result

		if ( !IsValid( self ) ) then return end

		self.AdditionalData = result

		steamworks.VoteInfo( data.wsid, function( result )
			if ( gDataTable[ data.wsid ] ) then
				gDataTable[ data.wsid ].VoteData = result
			end
		end )
		
		if ( file.Exists( 'cache/workshop/' .. result.previewid .. '.cache',"GAME" ) ) then
			return
		end

		steamworks.Download( result.previewid, false, function( name )

			if ( !name ) then return end -- Download failed

		end )

	end )
end

function PANEL:Paint( w, h )

	if ( IsValid( self.DermaCheckbox ) ) then
		self.DermaCheckbox:SetVisible( self.Hovered || self.DermaCheckbox.Hovered || self:GetSelected() )
	end
	
	if ( !self.Image && self.AdditionalData && file.Exists( 'cache/workshop/' .. self.AdditionalData.previewid .. '.cache',"GAME" ) ) then
		//self.Image = Material( "../cache/workshop/" .. self.AdditionalData.previewid .. ".cache", "nocull smooth" )
		self.Image = AddonMaterial( "cache/workshop/" .. self.AdditionalData.previewid .. ".cache" )
	end

	if ( self:GetSelected() ) then
		draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 150, 255, 200 ) )
	elseif ( self.Addon && steamworks.ShouldMountAddon( self.Addon.wsid ) ) then
		draw.RoundedBox( 4, 0, 0, w, h, Color( 255, 255, 255, 200 ) )
	else
		draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 255 ) )
	end

	local imageSize = self:GetTall() - 10
	if ( self.Image ) then
		surface.SetDrawColor( color_white )
		surface.SetMaterial( self.Image )
		surface.DrawTexturedRect( 5, 5, imageSize, imageSize )
	else
		surface.SetMaterial( Material( "../html/img/addonpreview.png", "nocull smooth" ) )
		surface.DrawTexturedRect( 5, 5, imageSize, imageSize )
	end
	
	//size,created,ownername, title
	if ( gDataTable[ self.Addon.wsid ] && gDataTable[ self.Addon.wsid ].VoteData ) then
		local ratio = gDataTable[ self.Addon.wsid ].VoteData.score
		local w = math.floor( ( self:GetWide() - 10 ) * ratio )
	
		for i=-5,-1 do
			surface.SetDrawColor( Color( 255, 0, 0, 128 ) )
			surface.DrawLine( 5 + w, self:GetTall() - 5 + i, 4 + ( self:GetWide() - 10 ), self:GetTall() - 5 + i )
		
			surface.SetDrawColor( Color( 0, 255, 0, 128 ) )
			surface.DrawLine( 5, self:GetTall() - 5 + i, 5 + w, self:GetTall() - 5 + i )
		end
	end

	if ( self.Addon && !steamworks.ShouldMountAddon( self.Addon.wsid ) ) then
		draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 180 ) )
	end

	if ( self.Addon && self.Hovered ) then
		draw.RoundedBox( 0, 5, h - 25, w - 10, 15, Color( 0, 0, 0, 180 ) )
		draw.SimpleText( self.Addon.title,"Default", 10, h - 25, Color( 255, 255, 255 ))
	end

end

vgui.Register( "MenuAddon", PANEL, "Panel" )

--------------------------------------------------------------------------------------------------------------------------------

local Grouping = {
	none = {
		label = "None",
		func = function( addons )
			return { { addons = addons } }
		end
	},
	enabled = {
		label = "Enabled",
		func = function( addons )
			local t = {
				enabled = {
					title = "Enabled",
					addons = {}
				},
				disabled = {
					title = "Disabled",
					addons = {}
				}
			}
		
			for id, addon in pairs( engine.GetAddons() ) do
				if ( addon.mounted ) then
					table.insert( t.enabled.addons, addon )
				else
					table.insert( t.disabled.addons, addon )
				end
			end
		
			return t
		end
	}
}

local BackgroundColor = Color( 200, 200, 200, 128 )
local BackgroundColor2 = Color( 200, 200, 200, 255 )//Color( 0, 0, 0, 100 )

local PANEL = {}

function PANEL:Init()

	self:Dock( FILL )

	local Categories = vgui.Create( "DListLayout", self )
	Categories:DockPadding( 5, 200, 5, 5 )
	Categories:Dock( LEFT )
	Categories:SetWide( 200 )

	local Groups = vgui.Create( "DComboBox", Categories )
	Groups:Dock( TOP )
	Groups:SetTall( 30 )
	Groups:DockMargin( 0, 0, 0, 40 )
	for id, group in pairs( Grouping ) do Groups:AddChoice( "Group by: " .. group.label, id, !Groups:GetSelectedID() ) end
	Groups.OnSelect = function( index, value, data ) self:RefreshAddons() end
	self.Groups = Groups

	local ToggleMounted = vgui.Create( "DButton", Categories )
	ToggleMounted:Dock( TOP )
	ToggleMounted:SetText( "#Toggle Selected" )
	ToggleMounted:SetTall( 30 )
	ToggleMounted:DockMargin( 0, 0, 0, 40 )
	ToggleMounted.DoClick = function() self:ToggleSelected() end
	self.ToggleMounted = ToggleMounted

	local UnmountAll = vgui.Create( "DButton", Categories )
	UnmountAll:Dock( TOP )
	UnmountAll:SetText( "#Disable All" )
	UnmountAll:SetTall( 30 )
	UnmountAll:DockMargin( 0, 5, 0, 0 )
	UnmountAll.DoClick = function() self:UnmountAll() end

	local MountAll = vgui.Create( "DButton", Categories )
	MountAll:Dock( TOP )
	MountAll:SetText( "#Enable All" )
	MountAll:SetTall( 30 )
	MountAll:DockMargin( 0, 5, 0, 0 )
	MountAll.DoClick = function() self:MountAll() end

	local MountAll = vgui.Create( "DButton", Categories )
	MountAll:Dock( TOP )
	MountAll:SetText( "#Open Workshop" )
	MountAll:SetTall( 30 )
	MountAll:DockMargin( 0, 40, 0, 0 )
	MountAll.DoClick = function() steamworks.OpenWorkshop() end

	------------------- Addon List

	local Scroll = vgui.Create( "DScrollPanel", self )
	Scroll:Dock( FILL )
	Scroll:DockMargin( 0, 5, 5, 5 )

	local AddonList = vgui.Create( "DIconLayout", Scroll )
	AddonList:SetSpaceX( 5 )
	AddonList:SetSpaceY( 5 )
	AddonList:Dock( FILL )
	AddonList:DockMargin( 5, 5, 5, 5 )
	AddonList:DockPadding( 5, 5, 5, 10 )
	
	function Scroll:Paint( w, h )
		draw.RoundedBoxEx( 4, 0, 0, w, h, BackgroundColor, false, true, false, true )
		draw.RoundedBoxEx( 4, 0, 0, w, h, BackgroundColor2, false, true, false, true )
	end
	
	self.AddonList = AddonList
	self:RefreshAddons()

end

function PANEL:Think()
	local anySelected = false
	for id, pnl in pairs( self.AddonList:GetChildren() ) do
		if ( pnl.GetSelected && pnl:GetSelected() ) then anySelected = true end
	end
	self.ToggleMounted:SetDisabled( !anySelected )
end

function PANEL:ToggleSelected()
	for id, pnl in pairs( self.AddonList:GetChildren() ) do
		if ( !pnl.GetSelected || !pnl:GetSelected() ) then continue end
		steamworks.SetShouldMountAddon( pnl.Addon.wsid, !steamworks.ShouldMountAddon( pnl.Addon.wsid ) )
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

function PANEL:Update()
	self:RefreshAddons()
end

function PANEL:RefreshAddons()

	self.AddonList:Clear()

	local group = self.Groups:GetOptionData( self.Groups:GetSelectedID() )

	local addons = Grouping[ group ].func( engine.GetAddons() )

	for id, group in SortedPairsByMemberValue( addons, "title" ) do
	
		if ( group.title ) then
			local pnl = self.AddonList:Add( "DLabel" )
			pnl.OwnLine = true
			pnl:SetFont( "rb655_AddonName" )
			pnl:SetText( group.title )
			pnl:SetDark( true )
			pnl:SizeToContents()
		end
		
		for id, add in SortedPairsByMemberValue( group.addons, "title" ) do

			local pnl = self.AddonList:Add( "MenuAddon" )
			pnl.panel = self
			pnl:SetAddon( add )
			pnl:DockMargin( 0, 0, 5, 5 )
	
		end
		
	end

	/*for id, add in SortedPairsByMemberValue( engine.GetAddons(), "title" ) do

		local pnl = self.AddonList:Add( "MenuAddon" )
		//if ( id==1 ) then pnl.OwnLine = true end
		pnl:SetAddon( add )
		pnl:DockMargin( 0, 0, 5, 5 )
	
	end*/

end

vgui.Register( "AddonsPanel", PANEL, "EditablePanel" )
