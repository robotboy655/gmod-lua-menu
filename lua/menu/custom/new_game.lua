
include( "new_game_panels.lua" )

CreateConVar( "cl_maxplayers", "1", FCVAR_ARCHIVE )

--[[
TODO:
make sure the text of categories / multiplayer settings does not overflow, especially on lower resolutions
Fix reloading the panels resetting the scrolling for categories and server settings?

Auto scroll to select map on first open or something?

Better map icon visuals?
Allow people to create their own categories?
Figure out fonts? The current ones look neat but blurry
]]

surface.CreateFont( "StartNewGameFont", {
	font = "Roboto Lt",
	size = 18,
} )

surface.CreateFont( "SingleMultiPlayer", {
	font = "Roboto Lt",
	size = 17,
} )

surface.CreateFont( "DermaRobotoDefault", {
	font = "Roboto Lt",
	size = 13
} )

surface.CreateFont( "StartNewGame", {
	font = "Roboto",
	size = 30,
} )

surface.CreateFont( "rb655_MapList", {
	size = 12,
	font = "Tahoma"
} )

surface.CreateFont( "rb655_MapSubCat", {
	size = 30,
	--weight = 900,
	font = "Roboto Lt"
} )

local noise = Material( "gui/noise.png", "nocull noclamp smooth" )
local function DrawHUDBox( x, y, w, h, mat, clr )
	surface.SetDrawColor( clr or Color( 255, 255, 255, 255 ) )

	surface.SetMaterial( mat or noise )
	surface.DrawTexturedRectUV( x, y, w, h, 0, 0, w / 128, h / 128 )
end

local function EnableMouseScroll( s )
	local mousePressed = input.IsMouseDown( MOUSE_RIGHT ) or input.IsMouseDown( MOUSE_LEFT )
	if ( !mousePressed ) then s.start = nil s.EnableMouseScrollEnabled = false return end

	if ( !s.start and s:IsChildHovered() and !s:GetVBar():IsChildHovered() and !s.EnableMouseScrollEnabled ) then
		s.start = s:GetVBar():GetScroll()
		local x, y = input.GetCursorPos()
		s.startY = y
		s.EnableMouseScrollEnabled = true
	end
	s.EnableMouseScrollEnabled = true

	if ( s.start ) then
		local x, y = input.GetCursorPos()
		s:GetVBar():SetScroll( s.start + ( s.startY - y ) )
	end
end

local matGradientUp = Material( "gui/gradient_up" )
local function DrawScrollDarkGradients( self, w, h )
	if ( self.VBar:GetScroll() + self:GetTall() < self.pnlCanvas:GetTall() ) then
		local height = math.min( ( self.pnlCanvas:GetTall() - ( self.VBar:GetScroll() + self:GetTall() ) ) / 3, 30 )
		height = math.floor( height )

		surface.SetMaterial( matGradientUp )
		surface.SetDrawColor( Color( 0, 0, 0, 200 ) )
		surface.DrawTexturedRect( 0, h - height, w, height )
	end

	if ( self.VBar:GetScroll() > 0 ) then
		local height = math.min( self.VBar:GetScroll() / 3, 30 )
		height = math.floor( height )

		surface.SetMaterial( matGradientUp )
		surface.SetDrawColor( Color( 0, 0, 0, 200 ) )
		surface.DrawTexturedRectUV( 0, 0, w, height, 0, 1, 1, 0 )
	end
end

local LocalizedShit = {}
local function SetLocalizedString( self, txt )
	self:SetText( language.GetPhrase( txt ) )
	table.insert( LocalizedShit, { panel = self, text = txt } )
end

local HeaderColor = color_black
local HeaderColor_mid = HeaderColor

local g_CurrentScroll

function GetMapsFromCategorySearch( cat, searchText )
	local maps = GetMapsFromCategory( cat )
	if ( !maps or #maps < 1 ) then return {} end

	local output = {}
	for _, map in SortedPairs( maps ) do
		if ( searchText and !map.name:find( searchText:lower() ) ) then continue end

		table.insert( output, map )
	end

	return output
end

local PANEL = {}

gMapIcons = gMapIcons or {}

local matIncompat = Material( "html/img/incompatible.png" )
local matNoIcon = Material( "gui/noicon.png", "nocull smooth" )

function PANEL:Init()

	g_CurrentScroll = nil
	self.SearchText = nil

	self:Dock( FILL )

	--------------------------------- CATEGORIES ---------------------------------

	local MapCategories = vgui.Create( "DPanel", self )
	MapCategories:Dock( LEFT )
	MapCategories:SetWide( math.Clamp( ScrW() / 6, 150, 200 ) )
	MapCategories:DockMargin( 5, 5, 0, 5 )
	MapCategories:DockPadding( 5, 5, 0, 5 )
	function MapCategories:Paint( w, h )
		DrawHUDBox( 0, 0, w, h )
	end

	local searchBar = vgui.Create( "DFancyTextEntry", MapCategories )
	searchBar:Dock( TOP )
	searchBar:SetFont( "DermaRobotoDefault" )
	searchBar:SetPlaceholderText( "searchbar_placeholer" )
	searchBar:DockMargin( 0, 0, 0, 0 )
	searchBar:SetZPos( -1 )
	searchBar:SetHeight( 24 )
	searchBar:SetUpdateOnType( true )
	searchBar.OnValueChange = function() self:DoSearch( searchBar:GetText() ) end

	self.Categories = {}
	local cat_pnl = self:AddCategoryButton( MapCategories, "Favourites", "Favourites" )
	cat_pnl:SetZPos( 0 )

	local CategoriesScroll = vgui.Create( "DScrollPanel", MapCategories )
	CategoriesScroll:Dock( FILL )
	CategoriesScroll:DockMargin( 0, 5, 0, 0 )
	CategoriesScroll:GetVBar():SetWide( 0 )
	CategoriesScroll.Think = EnableMouseScroll
	CategoriesScroll.PaintOver = DrawScrollDarkGradients

	self.CategoriesPanel = CategoriesScroll

	---------------------------- CONTAINER FOR MAPS ----------------------------

	local Scroll = vgui.Create( "DScrollPanel", self )
	Scroll:Dock( FILL )
	Scroll:DockMargin( 0, 5, 5, 5 )
	function Scroll:Paint( w, h )
		DrawHUDBox( 0, 0, w, h )
	end
	Scroll.Think = EnableMouseScroll

	local sbar = Scroll:GetVBar()
	sbar:SetWide( 8 )
	if ( sbar.SetHideButtons ) then sbar:SetHideButtons( true ) end

	-- HACK!!!!
	sbar.OldSetScroll = sbar.SetScroll
	function sbar:SetScroll( scroll )
		g_CurrentScroll = scroll
		self:OldSetScroll( scroll )
	end

	function sbar:Paint( w, h )
		surface.SetDrawColor( 100, 100, 100, 100 )
		surface.DrawRect( 0, 0, w, h )
	end
	function sbar.btnGrip:Paint( w, h )
		surface.SetDrawColor( 0, 0, 0, 128 )
		surface.DrawRect( 0, 0, w, h )
	end

	local CategoryMaps = vgui.Create( "DIconLayout", Scroll )
	CategoryMaps:SetSpaceX( 5 )
	CategoryMaps:SetSpaceY( 5 )
	CategoryMaps:Dock( TOP )
	CategoryMaps:DockMargin( 5, 5, 5, 5 )
	CategoryMaps:DockPadding( 5, 5, 5, 5 )
	self.CategoryMaps = CategoryMaps

	--------------------------------- SETTINGS ---------------------------------

	local Settings = vgui.Create( "DListLayout", self )
	Settings:Dock( RIGHT )
	Settings:SetWide( math.max( ScrW() / 6, 180 ) )
	Settings:DockMargin( 0, 5, 5, 5 )
	Settings:DockPadding( 5, 5, 5, 5 )
	function Settings:Paint( w, h )
		DrawHUDBox( 0, 0, w, h )
	end
	self.Settings = Settings

	--------------------------------- SINGLE / MULTIPLAYER ---------------------------------

	local SingleMultiPlayer = vgui.Create( "DButton", Settings )
	SingleMultiPlayer:SetFont( "SingleMultiPlayer" )
	SingleMultiPlayer:SetTall( 32 )
	SingleMultiPlayer:SetZPos( -3 )
	SingleMultiPlayer:Dock( TOP )
	SingleMultiPlayer:DockMargin( 0, 0, 0, 5 )
	SingleMultiPlayer:SetColor( color_white )

	SingleMultiPlayer.SetTextGenerated = function( s, n ) s:SetText( language.GetPhrase( "maxplayers_" .. n ) ) end

	SingleMultiPlayer.SetValue = function( s, n ) s.PlayerCount = tonumber( n ) RunConsoleCommand( "cl_maxplayers", n ) s:DoUpdateText() end
	SingleMultiPlayer.GetValue = function( s ) return s.PlayerCount or 1 end

	SingleMultiPlayer.DoUpdateText = function( s )
		s:SetTextGenerated( s:GetValue() )
		s:DoUpdatePanels( Settings )
		if ( self.GamemodeSettings ) then
			s:DoUpdatePanels( self.GamemodeSettings:GetCanvas() )

			-- Hack
			local hasVisibleChildren = false
			for id, pnl in pairs( self.GamemodeSettings:GetCanvas():GetChildren() ) do
				if ( pnl:IsVisible() ) then hasVisibleChildren = true break end
			end
			self.GamemodeSettingsLabel:SetVisible( hasVisibleChildren )
		end
	end
	SingleMultiPlayer.DoUpdatePanels = function( s, parent )
		if ( !IsValid( parent ) ) then return end
		for id, pnl in pairs( parent:GetChildren() ) do
			if ( pnl.Singleplayer == nil ) then continue end

			pnl:SetVisible( ( s:GetValue() < 2 ) == pnl.Singleplayer or pnl.Singleplayer )
			if ( !pnl.OldHeight ) then pnl.OldHeight = pnl:GetTall() end
			pnl:SetHeight( pnl:IsVisible() and pnl.OldHeight or 0 )
		end
		parent:InvalidateLayout( true )
	end
	SingleMultiPlayer.CloseDropDown = function( s )
		if ( s.Butts and #s.Butts > 0 ) then
			for id, p in pairs( s.Butts ) do p:Remove() end
			s.Butts = {}
			return true
		end
	end

	hook.Add( "VGUIMousePressed", "NewGameMenu_FuyckingHack", function( pnl, mc )
		if ( !IsValid( SingleMultiPlayer ) or !SingleMultiPlayer.Butts or vgui.GetHoveredPanel() == SingleMultiPlayer ) then return end
		for id, p in pairs( SingleMultiPlayer.Butts ) do if ( vgui.GetHoveredPanel() == p ) then return end end

		SingleMultiPlayer:CloseDropDown()
	end )

	SingleMultiPlayer.DoClick = function( s )
		if ( s:CloseDropDown() ) then return end

		s.Butts = {}
		local alt = false
		local x, y = s:LocalToScreen( 0, 0 )
		for id, v in pairs( { 1, 2, 4, 8, 16, 32, 64 } ) do
			alt = !alt
			y = y + s:GetTall()
			local but = vgui.Create( "DButton", self )
			but:SetPos( x, y )
			but:SetSize( s:GetSize() )
			s.SetTextGenerated( but, v )
			but.Bottom = (v == 64)
			but.Value = v
			but.Alt = alt
			but:SetFont( "SingleMultiPlayer" )
			but:SetColor( color_white )
			but.DoClick = function( buttt ) s:SetValue( buttt.Value ) s:CloseDropDown() end
			but.Paint = function( buttt, w, h )
				local clr = Color( 30, 190, 30 )
				if ( but.Alt ) then clr = Color( 32, 196, 32 ) end
				if ( but.Hovered ) then clr = Color( 48, 210, 48 ) end
				if ( but.Depressed ) then clr = Color( 24, 180, 24 ) end
				surface.SetDrawColor( clr )
				if ( !buttt.Bottom ) then
					surface.DrawRect( 0, 0, w, h )
				else
					surface.DrawRect( 0, 0, w, h - 1 )
				end

				surface.SetDrawColor( Color( 34, 170, 34 ) )
				if ( !buttt.Bottom ) then
					--surface.DrawLine( 0, 0, 0, h ) -- left
					--surface.DrawLine( w - 1, 0, w - 1, h ) -- right -- Doesn't show bottom pixel??
					surface.DrawRect( 0, 0, 1, h )
					surface.DrawRect( w - 1, 0, 1, h )
				else
					surface.DrawLine( 0, 0, 0, h - 1 ) -- left
					surface.DrawLine( w - 1, 0, w - 1, h - 1 ) -- right

					surface.SetDrawColor( Color( 17, 136, 17 ) )
					surface.DrawLine( 1, h - 1, w - 1, h - 1 ) -- bottom
				end
			end
			table.insert( s.Butts, but )
		end
	end
	SingleMultiPlayer.Paint = function( s, w, h )
		local menuOpen = s.Butts and #s.Butts > 0

		local clr = Color( 82, 204, 82 )
		if ( s.Hovered ) then clr = Color( 86, 210, 86 ) end
		if ( s.Depressed ) then clr = Color( 82, 204, 82 ) end

		surface.SetDrawColor( clr )
		surface.DrawRect( 1, 1, w-2, h-2 )

		surface.SetDrawColor( Color( 30, 190, 30 ) )
		if ( s.Hovered ) then surface.SetDrawColor( Color( 36, 200, 36 ) ) end
		surface.SetMaterial( matGradientUp )
		surface.DrawTexturedRect( 1, 1, w-2, h-2 )

		surface.SetDrawColor( Color( 34, 170, 34 ) )
		surface.DrawLine( 1, 0, w-1, 0 ) -- top
		if ( menuOpen ) then
			surface.DrawRect( 0, 1, 1, h ) -- left
			surface.DrawRect( w - 1, 1, 1, h ) -- right

			surface.SetDrawColor( Color( 30, 190, 30 ) )
			if ( s.Hovered ) then surface.SetDrawColor( Color( 36, 200, 36 ) ) end
			surface.DrawRect( 1, h-2, w-2, 2 )
		else
			surface.DrawLine( 0, 1, 0, h - 1 ) -- left
			surface.DrawLine( w - 1, 1, w - 1, h - 1 ) -- right

		end

		surface.SetDrawColor( Color( 17, 136, 17 ) )
		surface.DrawLine( 1, h - 1, w - 1, h - 1 ) -- bottom

		local clr2 = Color( 118, 214, 118 )
		if ( s.Hovered ) then clr2 = Color( 128, 220, 128 ) end
		--if ( s.Depressed ) then clr2 = Color( 118, 214, 118 ) end
		surface.SetDrawColor( clr2 )
		surface.DrawLine( 1, 1, w - 1, 1 )

		local size = 9
		surface.SetDrawColor( Color( 255, 255, 255 ) )
		draw.NoTexture()
		surface.DrawPoly( {
			{ x = w - ( h / 2 + size / 2 ), y = h / 2 - size / 4 },
			{ x = w - ( h / 2 - size / 2 ), y = h / 2 - size / 4 },
			{ x = w - ( h / 2 ), y = h / 2 + size / 4 }
		} )
	end
	self.SingleMultiPlayer = SingleMultiPlayer

	--------------------------------- TOP CONTENT ---------------------------------

	local ServerName = self:ServerSettings_AddTextEntry( {
		name = "hostname",
		text = "server_name",
		zOrder = -2,
		help = "The name of your server that will appear in the server browser"
	}, Settings )
	Settings.ServerName = ServerName

	self:ServerSettings_AddTextEntry( {
		name = "sv_password",
		text = "server_password",
		zOrder = -1,
		help = "The password for your server that other people have to enter before they can join your server"
	}, Settings )

	local sv_lan = self:ServerSettings_AddCheckbox( {
		text = "lan_server",
		name = "sv_lan",
		help = "Only people on your Local Area Network can connect to the server",
	}, Settings )

	local p2p_enabled = self:ServerSettings_AddCheckbox( {
		text = "p2p_server",
		name = "p2p_enabled",
		help = "Allow people to connect to your Listen Server using Steam P2P networking",
	}, Settings )

	local p2p_friendsonly = self:ServerSettings_AddCheckbox( {
		text = "p2p_server_friendsonly",
		name = "p2p_friendsonly",
		help = "Only allow people on your friends list to join your P2P server",
	}, Settings )

	sv_lan.OnValueChanged = function( pnl, checked )
		if ( checked ) then
			p2p_enabled:SetChecked( false )
			p2p_friendsonly:SetChecked( false )
		end
	end
	p2p_enabled.OnValueChanged = function( pnl, checked )
		if ( checked ) then
			sv_lan:SetChecked( false )
		end
	end
	p2p_friendsonly.OnValueChanged = function( pnl, checked )
		if ( checked ) then
			sv_lan:SetChecked( false )
			p2p_enabled:SetChecked( true )
		end
	end

	--------------------------------- MIDDLE CONTENT - LABEL ---------------------------------

	local GamemodeSettingsLabel = Settings:Add( "DLabel" )
	GamemodeSettingsLabel:Dock( TOP )
	GamemodeSettingsLabel:SetText( "Gamemode Settings" )
	GamemodeSettingsLabel:SetFont( "StartNewGameFont" )
	GamemodeSettingsLabel:SetContentAlignment( 5 )
	GamemodeSettingsLabel:DockMargin( 0, 4, 0, 4 )
	GamemodeSettingsLabel:SetTextColor( HeaderColor )
	self.GamemodeSettingsLabel = GamemodeSettingsLabel

	--------------------------------- MIDDLE CONTENT ---------------------------------

	local GamemodeSettings = vgui.Create( "DScrollPanel", Settings )
	GamemodeSettings:Dock( FILL )
	GamemodeSettings:DockMargin( -5, 0, -5, 5 )
	GamemodeSettings:GetCanvas():DockPadding( 5, 0, 5, 0 )
	GamemodeSettings:GetVBar():SetWide( 0 )
	self.GamemodeSettings = GamemodeSettings
	function GamemodeSettings:Paint( w, h )
		--surface.SetDrawColor( 0, 0, 0, 32 )
		--surface.DrawRect( 0, 0, w, h )
	end
	GamemodeSettings.Think = EnableMouseScroll
	GamemodeSettings.PaintOver = DrawScrollDarkGradients

	--------------------------------- END CONTENT ---------------------------------

	local StartGame = Settings:Add( "DMenuButton" )
	StartGame:Dock( BOTTOM )
	StartGame:SetFont( "StartNewGame" )
	SetLocalizedString( StartGame, "start_game" )
	StartGame:SetTall( 48 )
	StartGame.DoClick = function()
		self:LoadMap()
	end
	StartGame:SetSpecial( true )

	--------------------------------- Update Content ---------------------------------

	self:Update()

end

function PANEL:Paint( w, h )
	surface.SetDrawColor( 0, 0, 0, 150 )
	surface.DrawRect( 0, 0, w, h )

	if ( self.CurrentCategory and IsValid( self.Categories[ self.CurrentCategory ] ) ) then
		--if ( !self.Categories[ self.CurrentCategory ] ) then self:SelectCat( "Sandbox" ) return end
		self.Categories[ self.CurrentCategory ].Depressed = true
	end
end

function PANEL:SelectMap( map )
	self.CurrentMap = map
end

function PANEL:AddCategoryButton( parent, catClass, name )
	local button = parent:Add( "MenuCategoryButton" )
	button:Dock( TOP )
	button:DockMargin( 0, 1, 0, 0 )
	button:SetText( name )
	button.DoClick = function()
		g_CurrentScroll = nil
		self:SelectCat( catClass )
	end
	button:SetContentAlignment( 4 )
	button:SetTextInset( 5, 0 )
	button:SetCategory( catClass )
	--button:SetAlt( alt )
	button.NewGameMenu = self

	self.Categories[ catClass ] = button
	return button
end

function PANEL:DoSearch( txt )
	self.SearchText = txt
	if ( self.SearchText:Trim() == "" ) then self.SearchText = nil end

	self:SelectCat( self.CurrentCategory ) -- Refreshes the map list
end

function PANEL:ServerSettings_AddTextEntry( v, parent )

	local DTextEntry = vgui.Create( "MenuSettingsTextEntry", parent )
	DTextEntry:Dock( TOP )
	DTextEntry:SetFont( "DermaRobotoDefault" )
	DTextEntry:SetTall( 22 )
	DTextEntry:DockMargin( 0, 0, 0, 1 )
	if ( v.text ) then DTextEntry:SetText( v.text ) end
	if ( v.name ) then DTextEntry:SetConVar( v.name ) end
	if ( v.zOrder ) then DTextEntry:SetZPos( v.zOrder + 1 ) end
	if ( v.help ) then DTextEntry:SetTooltip( v.help ) end
	if ( v.singleplayer ) then DTextEntry.Singleplayer = true else DTextEntry.Singleplayer = false end
	return DTextEntry

end

function PANEL:ServerSettings_AddCheckbox( v, parent )

	local CheckBox = vgui.Create( "MenuSettingsCheckbox", parent )
	CheckBox:Dock( TOP )
	CheckBox:SetFont( "DermaRobotoDefault" )
	CheckBox:SetTall( 22 )
	CheckBox:DockMargin( 0, 0, 0, 1 )
	if ( v.name ) then CheckBox:SetConVar( v.name ) end
	if ( v.text ) then CheckBox:SetText( v.text ) end
	if ( v.zOrder ) then CheckBox:SetZPos( v.zOrder ) end
	if ( v.help ) then CheckBox:SetTooltip( v.help ) end
	if ( v.singleplayer ) then CheckBox.Singleplayer = true else CheckBox.Singleplayer = false end

	return CheckBox

end

function PANEL:ServerSettings_AddSlider( v, parent )
	local Slider = vgui.Create( "MenuSettingsSlider", parent )
	Slider:Dock( TOP )
	if ( v.name ) then Slider:SetConVar( v.name ) end
	if ( v.text ) then Slider:SetText( v.text ) end
	Slider:SetFont( "DermaRobotoDefault" )
	Slider:SetTall( 22 )
	Slider:DockMargin( 0, 0, 0, 1 )
	if ( v.zOrder ) then Slider:SetZPos( v.zOrder ) end
	if ( v.help ) then Slider:SetTooltip( v.help ) end
	if ( v.singleplayer ) then Slider.Singleplayer = true else Slider.Singleplayer = false end

	return Slider
end

function PANEL:UpdateLanguage()
	self.SingleMultiPlayer:SetTextGenerated( self.SingleMultiPlayer:GetValue() )

	for id, t in pairs( LocalizedShit ) do
		if ( !IsValid( t.panel ) ) then table.remove( LocalizedShit, id ) continue end -- Not too sure about the removal of the element inside the loop. Is Lua OK with this?
		t.panel:SetText( language.GetPhrase( t.text ) )
	end

	-- Update Favourites?
	-- Update whatever
end

function PANEL:Update()

	---------------------------------- Build Categories ----------------------------------

	local Categories = self.CategoriesPanel
	Categories:Clear()

	--self.Categories = {}

	local pergamemode = Categories:Add( "DLabel" )
	pergamemode:Dock( TOP )
	pergamemode:SetText( "Gamemodes" )
	pergamemode:SetFont( "StartNewGameFont" )
	pergamemode:SetContentAlignment( 5 )
	pergamemode:SetTextColor( HeaderColor )
	pergamemode:DockMargin( 0, 0, 0, 3 )

	for cat, name in SortedPairsByValue( GetMapCategories() ) do
		if ( cat == "Favourites" ) then continue end -- We have custom handling of this category
		self:AddCategoryButton( Categories, cat, name )
	end

	local games = Categories:Add( "DLabel" )
	games:Dock( TOP )
	games:SetText( "Games" )
	games:SetFont( "StartNewGameFont" )
	games:SetContentAlignment( 5 )
	games:SetTextColor( HeaderColor )
	games:DockMargin( 0, 5, 0, 3 )

	for cat, name in SortedPairsByValue( GetMapCategories( "game" ) ) do
		self:AddCategoryButton( Categories, cat, name )
	end

	--for i = 0, 10 do self:AddCategoryButton( Categories, "Filler " .. i, "Filler " .. i, i % 2 ) end

	---------------------------------- Build server settigns ----------------------------------

	local GamemodeSettings = self.GamemodeSettings
	GamemodeSettings:Clear()

	local settings_file = file.Read( "gamemodes/" .. engine.ActiveGamemode() .. "/" .. engine.ActiveGamemode() .. ".txt", true )

	if ( settings_file ) then

		local SettingsFile = util.KeyValuesToTable( settings_file )

		if ( SettingsFile.settings ) then
			local zOrder = 0

			for k, v in pairs( SettingsFile.settings ) do
				if ( v.type == "CheckBox" ) then
					v.zOrder = zOrder
					self:ServerSettings_AddCheckbox( v, GamemodeSettings )
				elseif ( v.type == "Text" ) then
					v.zOrder = zOrder
					self:ServerSettings_AddTextEntry( v, GamemodeSettings )
					zOrder = zOrder + 1 -- Account for the label
				elseif ( v.type == "Numeric" ) then
					v.zOrder = zOrder
					self:ServerSettings_AddSlider( v, GamemodeSettings )
				end

				zOrder = zOrder + 1
			end
		end
	end

	--------------------------------- Update Singleplayer / Multiplayer selector ---------------------------------

	self.SingleMultiPlayer:SetValue( GetConVarNumber( "cl_maxplayers" ) )

	--------------------------------- LOAD LAST MAP ---------------------------------

	local map, cat = LoadLastMap()

	if ( self.CurrentMap and self.CurrentCategory ) then -- We had some map selected, switch back to it!
		map = self.CurrentMap
		cat = self.CurrentCategory
	end

	if ( !DoesCategoryExist( cat ) ) then
		-- Try to find the category the map is in
		cat = GetMapCategory( map )
	end

	if ( !cat or !map ) then
		map = "gm_flatgrass"
		cat = "Sandbox"
	end

	self:SelectCat( cat )
	self:SelectMap( map )

end

function PANEL:BuildIconList()
	self.IconListCache = {}

	local files = file.Find( "maps/thumb/*.png", "GAME" )
	for id, filename in pairs( files ) do
		self.IconListCache[ filename:sub( 0, filename:len() - 4 ) ] = "maps/thumb/" .. filename
	end

	-- Stupid ass addons that didn't update yet
	local files2 = file.Find( "maps/*.png", "GAME" )
	for id, filename in pairs( files2 ) do
		self.IconListCache[ filename:sub( 0, filename:len() - 4 ) ] = "maps/" .. filename
	end
end

function PANEL:CacheIcon( map )
	if ( !self.IconListCache ) then self:BuildIconList() end

	map = map:Trim() -- Duplicate CS:GO maps have spaces on the end! ( When loaded from the HTML menu )
	--[[local mat = Material( "maps/thumb/" .. map .. ".png" )
	if ( mat:IsError() ) then mat = Material( "maps/" .. map .. ".png" ) end -- Stupid ass addons that didn't update yet
	if ( mat:IsError() ) then mat = matNoIcon end]]
	if ( !self.IconListCache[ map ] ) then return matNoIcon end
	return Material( self.IconListCache[ map ] )
end

local border = 4
local border_w = 5
local matHover = Material( "gui/sm_hover.png", "nocull" )
local boxHover = GWEN.CreateTextureBorder( border, border, 64 - border * 2, 64 - border * 2, border_w, border_w, border_w, border_w, matHover )

function PANEL:SelectCat( cat )

	if ( self.CurrentCategory and self.Categories[ self.CurrentCategory ] ) then self.Categories[ self.CurrentCategory ].Depressed = false end
	self.CurrentCategory = cat

	self.CategoryMaps:Clear()

	local maps = GetMapsFromCategorySearch( cat, self.SearchText )
	if ( !maps or #maps < 1 ) then return end

	local subCategories, subCategorieyPatterns = GetMapSubCategories()

	local categories = {}
	for _, map in SortedPairs( maps ) do
		local c = subCategories[ map.name ] or "Other"

		if ( !subCategories[ map.name ] ) then
			for pattern, cate in SortedPairs( subCategorieyPatterns ) do
				if ( string.find( map.name, pattern ) ) then
					if ( c != "Other" ) then print( "Multiple categories for 1 map!!!", map.name, c, cate ) end
					c = cate
				end
			end
		end

		categories[ c ] = categories[ c ] or {}
		table.insert( categories[ c ], map )
	end

	for cat_name, cat_maps in SortedPairs( categories ) do

		local catText = cat_name
		if ( catText:sub( 2, 3 ) == ". " ) then catText = catText:sub( 4 ) end

		local label = self.CategoryMaps:Add( "DLabel" )
		label.OwnLine = true
		label:SetTextColor( HeaderColor_mid )
		label:SetText( catText )
		label:SetFont( "rb655_MapSubCat" )
		label:SizeToContents()
		label:SetBright( true )

		for _, map in SortedPairsByMemberValue( cat_maps, "name" ) do

			local button = self.CategoryMaps:Add( "DImageButton" )
			button:SetText( map.name )

			-- Get rid of the shitty "clicled on" animation
			--button.OnMousePressed = function( s, mc ) DButton.OnMousePressed( s, mc ) end

			-- Handles above stuff too
			Menu_InstallDButtonScrollProtection( button, 2, true )

			if ( map.incompatible ) then
				button.m_Image:SetMaterial( matIncompat )
			else
				if ( !gMapIcons[ map.name ] ) then gMapIcons[ map.name ] = self:CacheIcon( map.name ) end
				button.m_Image:SetMaterial( gMapIcons[ map.name ] )
			end

			button:SetSize( 128, 128 )
			button.DoClick = function()
				self:SelectMap( map.name )
			end
			button.DoDoubleClick = function()
				self:SelectMap( map.name )
				self:LoadMap()
			end
			button.PaintOver = function( pnl, w, h )

				if ( pnl:GetText() == self.CurrentMap ) then
					boxHover( 0, 0, w, h, color_white )
				end

				if ( pnl.Hovered ) then return end

				surface.SetDrawColor( Color( 0, 0, 0, 150 ) )
				surface.DrawRect( 0, h - 20, w, 20 )

				surface.SetFont( "rb655_MapList" )

				local tw = surface.GetTextSize( pnl:GetText() )
				if ( tw > w ) then
					draw.SimpleText( pnl:GetText(), "rb655_MapList", w / 2 - tw / 2 + ( ( w - tw ) * math.sin( CurTime() ) ), h - 16, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				else
					draw.SimpleText( pnl:GetText(), "rb655_MapList", w / 2 - tw / 2, h - 16, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				end

			end

			button.DoRightClick = function()
				local m = DermaMenu()
				m:AddOption( "Toggle Favourite", function() ToggleFavourite( map.name ) end )
				m:AddOption( "Cancel", function() end )
				m:Open()
			end

		end
	end

	-- Scroll back to the top of the map list
	self.CategoryMaps:GetParent():GetParent():GetVBar():SetScroll( g_CurrentScroll or 0 )

end

function PANEL:LoadMap()

	local maxplayers = GetConVarNumber( "cl_maxplayers" ) or 1

	SaveLastMap( self.CurrentMap:Trim(), self.CurrentCategory )

	hook.Run( "StartGame" )
	RunConsoleCommand( "progress_enable" )

	RunConsoleCommand( "disconnect" )

	if ( maxplayers > 0 ) then

		RunConsoleCommand( "sv_cheats", "0" )
		RunConsoleCommand( "commentary", "0" )

	end

	RunConsoleCommand( "maxplayers", maxplayers )
	RunConsoleCommand( "map", self.CurrentMap:Trim() )
	--RunConsoleCommand( "hostname", self.Settings.ServerName.TextEntry:GetText() )

	pnlMainMenu:Back()

end

vgui.Register( "NewGamePanel", PANEL, "EditablePanel" )
