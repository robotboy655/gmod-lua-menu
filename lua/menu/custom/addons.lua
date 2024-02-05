
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
			m:AddOption( "Invert Selection", function() self.panel:InvertSelection() end )

			m:AddSpacer()
		end

		m:AddOption( "Open Workshop Page", function() steamworks.ViewFile( self.Addon.wsid ) end )
		m:AddSpacer()
		if ( steamworks.ShouldMountAddon( self.Addon.wsid ) ) then
			m:AddOption( "Disable", function() steamworks.SetShouldMountAddon( self.Addon.wsid, false ) steamworks.ApplyAddons() end )
		else
			m:AddOption( "Enable", function() steamworks.SetShouldMountAddon( self.Addon.wsid, true ) steamworks.ApplyAddons() end )
		end
		m:AddOption( "Uninstall", function() steamworks.Unsubscribe( self.Addon.wsid ) steamworks.ApplyAddons() end ) -- Do we need ApplyAddons here?
		m:AddSpacer()
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

		if ( !file.Exists( "cache/workshop/" .. result.previewid .. ".cache", "MOD" ) ) then
			steamworks.Download( result.previewid, false, function( name ) end )
		end

		if ( !IsValid( self ) ) then return end

		self.panel:RefreshAddons()
		self.AdditionalData = result

	end )
end

local missingMat = Material( "../html/img/addonpreview.png", "nocull smooth" )
local lastBuild = 0
local imageCache = {}
function PANEL:Paint( w, h )

	if ( IsValid( self.DermaCheckbox ) ) then
		self.DermaCheckbox:SetVisible( self.Hovered or self.DermaCheckbox.Hovered or self:GetSelected() )
	end

	if ( self.AdditionalData and imageCache[ self.AdditionalData.previewid ] ) then
		self.Image = imageCache[ self.AdditionalData.previewid ]
	end

	if ( !self.Image and self.AdditionalData and file.Exists( "cache/workshop/" .. self.AdditionalData.previewid .. ".cache", "MOD" ) and CurTime() - lastBuild > 0.1 ) then
		self.Image = AddonMaterial( "cache/workshop/" .. self.AdditionalData.previewid .. ".cache" )
		imageCache[ self.AdditionalData.previewid ] = self.Image
		lastBuild = CurTime()
	end

	if ( self:GetSelected() ) then
		draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 150, 255, 200 ) )
	elseif ( self.Addon and steamworks.ShouldMountAddon( self.Addon.wsid ) ) then
		draw.RoundedBox( 4, 0, 0, w, h, Color( 255, 255, 255, 200 ) )
	else
		draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 255 ) )
	end

	if ( self.Image ) then
		surface.SetMaterial( self.Image )
	else
		surface.SetMaterial( missingMat )
	end
	local imageSize = self:GetTall() - 10
	surface.SetDrawColor( color_white )
	surface.DrawTexturedRect( 5, 5, imageSize, imageSize )

	if ( gDataTable[ self.Addon.wsid ] ) then
		local ratio = gDataTable[ self.Addon.wsid ].score
		local x = math.floor( ( self:GetWide() - 10 ) * ratio )

		for i = -5, -1 do
			surface.SetDrawColor( Color( 255, 0, 0, 128 ) )
			surface.DrawLine( 5 + x, self:GetTall() - 5 + i, 4 + ( self:GetWide() - 10 ), self:GetTall() - 5 + i )

			surface.SetDrawColor( Color( 0, 255, 0, 128 ) )
			surface.DrawLine( 5, self:GetTall() - 5 + i, 5 + x, self:GetTall() - 5 + i )
		end
	end

	--[[if ( self.Addon and !steamworks.ShouldMountAddon( self.Addon.wsid ) ) then
		draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 180 ) )
	end]]

	if ( self.Addon and self.Hovered ) then
		draw.RoundedBox( 0, 5, h - 25, w - 10, 15, Color( 0, 0, 0, 180 ) )
		draw.SimpleText( self.Addon.title, "Default", 8, h - 24, Color( 255, 255, 255 ) )
	end

end

vgui.Register( "MenuAddon", PANEL, "Panel" )

--------------------------------------------------------------------------------------------------------------------------------

local AddonFilters = {
	none = {
		label = "None",
		func = function( mod )
			return true
		end
	},
	enabled = {
		label = "Enabled",
		func = function( mod )
			return mod.mounted
		end
	},
	disabled = {
		label = "Disabled",
		func = function( mod )
			return !mod.mounted
		end
	},
}

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

			for _, addon in pairs( engine.GetAddons() ) do
				if ( addon.mounted ) then
					table.insert( t.enabled.addons, addon )
				else
					table.insert( t.disabled.addons, addon )
				end
			end

			return t
		end
	},
	ptags = {
		label = "Primary Tags",
		func = function( addons )
			local t = {
				noinfo = {
					title = "Information not loaded yet!",
					addons = {}
				}
			}

			for _, addon in pairs( engine.GetAddons() ) do
				if ( !gDataTable[ addon.wsid ] ) then
					table.insert( t.noinfo.addons, addon )
				else
					local Ptags = { servercontent = "Server Content", effects = "Effects", model = "Model", gamemode = "Gamemode", npc = "NPC", tool = "Tool", vehicle = "Vehicle", weapon = "Weapon", map = "Map" }
					local tags = string.Explode( ",", gDataTable[ addon.wsid ].tags )
					for _, tag in pairs( tags ) do
						if ( tag == "Addon" ) then continue end -- Don't duplicate ALL addons
						if ( !Ptags[ tag:lower() ] ) then tag = "Other" end
						tag = Ptags[ tag:lower() ] or tag
						if ( !t[ tag ] ) then t[ tag ] = { title = tag, addons = {} } end

						table.insert( t[ tag ].addons, addon )
						break
					end
				end
			end

			return t
		end
	},
	--[[models = {
		label = "Models",
		func = function( addons )
			local t = {
				models = {
					title = "Has Models",
					addons = {}
				},
				nomodels = {
					title = "Doesn't Have Models",
					addons = {}
				}
			}

			for _, addon in pairs( engine.GetAddons() ) do
				if ( addon.models > 0 ) then
					table.insert( t.models.addons, addon )
				else
					table.insert( t.nomodels.addons, addon )
				end
			end

			return t
		end
	}]] -- Disabled models are reported as "no models" :(
}

local BackgroundColor = Color( 200, 200, 200, 128 )
local BackgroundColor2 = Color( 200, 200, 200, 255 ) --Color( 0, 0, 0, 100 )

local PANEL = {}

function PANEL:Init()

	self:Dock( FILL )

	local Categories = vgui.Create( "DListLayout", self )
	Categories:DockPadding( 5, 200, 5, 5 )
	Categories:Dock( LEFT )
	Categories:SetWide( 200 )

	--[[ ------------------------------------------------------------------------- ]]

	local Groups = vgui.Create( "DComboBox", Categories )
	Groups:Dock( TOP )
	Groups:SetTall( 30 )
	Groups:DockMargin( 0, 0, 0, 5 )
	for id, group in pairs( Grouping ) do Groups:AddChoice( "Group by: " .. group.label, id, !Groups:GetSelectedID() ) end
	Groups.OnSelect = function( index, value, data ) self:RefreshAddons() end
	self.Groups = Groups

	local Filters = vgui.Create( "DComboBox", Categories )
	Filters:Dock( TOP )
	Filters:SetTall( 30 )
	Filters:DockMargin( 0, 0, 0, 40 )
	for id, f in pairs( AddonFilters ) do Filters:AddChoice( "Filter by: " .. f.label, id, !Filters:GetSelectedID() ) end
	Filters.OnSelect = function( index, value, data ) self:RefreshAddons() end
	self.Filters = Filters

	--[[ ------------------------------------------------------------------------- ]]

	local ToggleMounted = vgui.Create( "DButton", Categories )
	ToggleMounted:Dock( TOP )
	ToggleMounted:SetText( "#Toggle Selected" )
	ToggleMounted:SetTall( 30 )
	ToggleMounted:DockMargin( 0, 0, 0, 5 )
	ToggleMounted.DoClick = function() self:ToggleSelected() end
	self.ToggleMounted = ToggleMounted

	local EnableSelection = vgui.Create( "DButton", Categories )
	EnableSelection:Dock( TOP )
	EnableSelection:SetText( "#Enable Selected" )
	EnableSelection:SetTall( 30 )
	EnableSelection:DockMargin( 0, 0, 0, 5 )
	EnableSelection.DoClick = function() self:EnableSelected() end
	self.EnableSelection = EnableSelection

	local DisableSelection = vgui.Create( "DButton", Categories )
	DisableSelection:Dock( TOP )
	DisableSelection:SetText( "#Disable Selected" )
	DisableSelection:SetTall( 30 )
	DisableSelection:DockMargin( 0, 0, 0, 5 )
	DisableSelection.DoClick = function() self:DisableSelected() end
	self.DisableSelection = DisableSelection

	--[[ ------------------------------------------------------------------------- ]]

	local SelectAll = vgui.Create( "DButton", Categories )
	SelectAll:Dock( TOP )
	SelectAll:SetText( "#Select All" )
	SelectAll:SetTall( 16 )
	SelectAll:DockMargin( 0, 0, 0, 5 )
	SelectAll.DoClick = function() self:SelectAll() end
	self.SelectAllButton = SelectAll

	local DeselectAll = vgui.Create( "DButton", Categories )
	DeselectAll:Dock( TOP )
	DeselectAll:SetText( "#Deselect All" )
	DeselectAll:SetTall( 16 )
	DeselectAll:DockMargin( 0, 0, 0, 5 )
	DeselectAll.DoClick = function() self:DeselectAll() end
	self.DeselectAllButton = DeselectAll

	local InvertAll = vgui.Create( "DButton", Categories )
	InvertAll:Dock( TOP )
	InvertAll:SetText( "#Invert Selection" )
	InvertAll:SetTall( 16 )
	InvertAll:DockMargin( 0, 0, 0, 40 )
	InvertAll.DoClick = function() self:InvertSelection() end

	--[[ ------------------------------------------------------------------------- ]]

	local OpenWorkshop = vgui.Create( "DButton", Categories )
	OpenWorkshop:Dock( TOP )
	OpenWorkshop:SetText( "#Open Workshop" )
	OpenWorkshop:SetTall( 30 )
	OpenWorkshop:DockMargin( 0, 40, 0, 0 )
	OpenWorkshop.DoClick = function() steamworks.OpenWorkshop() end

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
	local allSelected = true
	local onlyEnabled = true
	local onlyDisabled = true
	for id, pnl in pairs( self.AddonList:GetChildren() ) do
		if ( pnl.GetSelected and pnl:GetSelected() ) then anySelected = true end
		if ( pnl.GetSelected and !pnl:GetSelected() ) then allSelected = false end
		if ( pnl.Addon and !steamworks.ShouldMountAddon( pnl.Addon.wsid ) ) then onlyEnabled = false end
		if ( pnl.Addon and steamworks.ShouldMountAddon( pnl.Addon.wsid ) ) then onlyDisabled = false end
	end
	self.ToggleMounted:SetDisabled( !anySelected )
	self.EnableSelection:SetDisabled( !anySelected or onlyEnabled )
	self.DisableSelection:SetDisabled( !anySelected or onlyDisabled )

	self.SelectAllButton:SetDisabled( allSelected )
	self.DeselectAllButton:SetDisabled( !anySelected )
end

function PANEL:ToggleSelected()
	for id, pnl in pairs( self.AddonList:GetChildren() ) do
		if ( !pnl.GetSelected or !pnl:GetSelected() ) then continue end
		steamworks.SetShouldMountAddon( pnl.Addon.wsid, !steamworks.ShouldMountAddon( pnl.Addon.wsid ) )
	end
	steamworks.ApplyAddons()
end

function PANEL:DisableSelected()
	for id, pnl in pairs( self.AddonList:GetChildren() ) do
		if ( !pnl.GetSelected or !pnl:GetSelected() ) then continue end
		steamworks.SetShouldMountAddon( pnl.Addon.wsid, false )
	end
	steamworks.ApplyAddons()
end

function PANEL:EnableSelected()
	for id, pnl in pairs( self.AddonList:GetChildren() ) do
		if ( !pnl.GetSelected or !pnl:GetSelected() ) then continue end
		steamworks.SetShouldMountAddon( pnl.Addon.wsid, true )
	end
	steamworks.ApplyAddons()
end

function PANEL:InvertSelection()
	for id, pnl in pairs( self.AddonList:GetChildren() ) do
		if ( !pnl.GetSelected ) then continue end
		pnl:SetSelected( !pnl:GetSelected() )
	end
end

function PANEL:DeselectAll()
	for id, pnl in pairs( self.AddonList:GetChildren() ) do
		if ( !pnl.GetSelected ) then continue end
		pnl:SetSelected( false )
	end
end

function PANEL:SelectAll()
	for id, pnl in pairs( self.AddonList:GetChildren() ) do
		if ( !pnl.GetSelected ) then continue end
		pnl:SetSelected( true )
	end
end

function PANEL:Update()
	self:RefreshAddons()
end

function PANEL:RefreshAddons()

	self.AddonList:Clear()

	local grp = self.Groups:GetOptionData( self.Groups:GetSelectedID() )
	local filter = self.Filters:GetOptionData( self.Filters:GetSelectedID() )

	local addons = Grouping[ grp ].func( engine.GetAddons() )

	for id, group in SortedPairsByMemberValue( addons, "title" ) do
		if ( #group.addons < 1 ) then continue end

		local addns = {}
		for k, mod in pairs( group.addons ) do
			if ( !AddonFilters[ filter ].func( mod ) ) then continue end
			table.insert( addns, mod )
		end

		if ( #addns < 1 ) then continue end

		if ( group.title ) then
			local pnl = self.AddonList:Add( "DLabel" )
			pnl.OwnLine = true
			pnl:SetFont( "rb655_AddonName" )
			pnl:SetText( group.title )
			pnl:SetDark( true )
			pnl:SizeToContents()
		end

		for k, mod in SortedPairsByMemberValue( addns, "title" ) do

			local pnl = self.AddonList:Add( "MenuAddon" )
			pnl.panel = self
			pnl:SetAddon( mod )
			pnl:DockMargin( 0, 0, 5, 5 )

		end

	end

end

vgui.Register( "AddonsPanel", PANEL, "EditablePanel" )
