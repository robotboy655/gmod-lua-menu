
CreateConVar( "cl_maxplayers", "1", FCVAR_ARCHIVE )

local PANEL = {}

surface.CreateFont( "StartNewGame", {
	font = "Roboto",
	size = ScreenScale( 10 ),
} )

surface.CreateFont( "rb655_MapList", {
	size = 12,
	font = "Tahoma"
} )

PANEL.CustomMaps = {}

gMapIcons = {}

local BackgroundColor = Color( 200, 200, 200, 128 )
local BackgroundColor2 = Color( 200, 200, 200, 255 )//Color( 0, 0, 0, 100 )

function PANEL:Init()

	self:Dock( FILL )

	--------------------------------- CATEGORIES ---------------------------------

	local Categories = vgui.Create( "DListLayout", self )
	Categories:Dock( LEFT )
	Categories:DockPadding( 5, 0, 5, 5 )
	Categories:DockMargin( 15, 15, 0, 15 )
	Categories:SetWide( 200 )
	function Categories:Paint( w, h )
		draw.RoundedBoxEx( 4, 0, 0, w, h, BackgroundColor, true, false, true, false )
		draw.RoundedBoxEx( 4, 0, 0, w, h, BackgroundColor2, true, false, true, false )
	end

	self.CategoriesPanel = Categories

	---------------------------- CONTAINER FOR MAPS ----------------------------

	local Scroll = vgui.Create( "DScrollPanel", self )
	Scroll:Dock( FILL )
	Scroll:DockMargin( 0, 15, 0, 15 )
	function Scroll:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, BackgroundColor )
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
	Settings:SetWide( ScrW() / 6 )
	Settings:DockMargin( 0, 15, 15, 10 )
	function Settings:Paint( w, h )
		draw.RoundedBoxEx( 4, 0, 0, w, h, BackgroundColor, false, true, false, true )
		draw.RoundedBoxEx( 4, 0, 0, w, h, BackgroundColor2, false, true, false, true )
	end
	self.Settings = Settings

	--------------------------------- TOP CONTENT ---------------------------------

	local ServerName = vgui.Create( "DTextEntry", Settings )
	ServerName:Dock( TOP )
	ServerName:SetText( GetConVarString( "hostname" ) )
	ServerName:DockMargin( 5, 5, 5, 0 )
	Settings.ServerName = ServerName

	local SvLan = vgui.Create( "DCheckBoxLabel", Settings )
	SvLan:Dock( TOP )
	SvLan:DockMargin( 5, 5, 5, 0 )
	SvLan:SetText( "#lan_server" )
	SvLan:SetDark( true )
	SvLan:SetChecked( GetConVarNumber( "sv_lan" ) == 1 )
	Settings.SvLan = SvLan

	local PlayerCount = vgui.Create( "DNumSlider", Settings )
	PlayerCount:Dock( TOP )
	PlayerCount:DockMargin( 10, 0, 0, 0 )
	PlayerCount:SetMinMax( 1, 32 )
	PlayerCount:SetText( "Max Players" )
	PlayerCount:SetConVar( "cl_maxplayers" )
	PlayerCount:SetDecimals( 0 )
	//PlayerCount:SetValue( GetConVarNumber( "maxplayers" ) )
	PlayerCount:SetDark( true )
	Settings.PlayerCount = PlayerCount

	--------------------------------- MIDDLE CONTENT ---------------------------------

	local GamemodeSettings = vgui.Create( "DScrollPanel", Settings )
	GamemodeSettings:Dock( FILL )
	GamemodeSettings:DockMargin( 0, 0, 0, 5 )
	self.GamemodeSettings = GamemodeSettings
	function GamemodeSettings:Paint( w, h )
		//draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 128 ) )
	end

	--------------------------------- END CONTENT ---------------------------------

	local StartGame = Settings:Add("DMenuButton")
	StartGame:Dock( BOTTOM )
	StartGame:SetFont( "StartNewGame" )
	StartGame:SetText( "Start Game" )
	StartGame:SetTall( 48 )
	StartGame.DoClick = function()
		self:LoadMap()
	end
	StartGame:SetSpecial( true )
	StartGame:DockMargin( 5, 0, 5, 5 )

	--------------------------------- BLEH ---------------------------------

	self:Update()

end

function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 150 ) )
	if ( self.CurrentCategory ) then
		if ( !self.Categories[ self.CurrentCategory ] ) then self:SelectCat( "Sandbox" ) return end
		self.Categories[ self.CurrentCategory ].Depressed = true
	end
end

function PANEL:SelectMap( map )
	self.CurrentMap = map
end

function PANEL:Update()

	---------------------------------- Categories ----------------------------------

	local Categories = self.CategoriesPanel
	Categories:Clear()

	self.Categories = {}

	local pergamemode = Categories:Add( "DLabel" )
	pergamemode:SetText( "GAMEMODES" )
	pergamemode:SetContentAlignment( 5 )
	pergamemode:SetDark( true )

	if ( istable( g_MapListCategorised ) ) then
		local cats = table.GetKeys( g_MapListCategorised )
		for _, cat in SortedPairsByValue( cats ) do
			local button = Categories:Add( "DMenuButton" )
			button:SetText( cat )
			button.DoClick = function()
				self:SelectCat( cat )
			end
			button:DockMargin( 0, 0, 0, 5 )
			self.Categories[ cat ] = button
		end
	end

	local games = Categories:Add( "DLabel" )
	games:SetText( "GAMES" )
	games:SetContentAlignment( 5 )
	games:SetDark( true )

	for cat, nicename in SortedPairsByValue( g_MapsFromGamesCats ) do
		for a, b in SortedPairsByValue( g_MapsFromGames[ cat ] ) do
			if ( nicename == "Left 4 Dead 2" || nicename == "Portal 2"  || nicename == "CS: Global Offensive" ) then
				gMapIcons[ b ] = Material( "html/img/incompatible.png" ) // INCOMPATIBLEEEE
			end
		end

		local button = Categories:Add( "DMenuButton" )
		button:SetText( nicename )

		local cat = ""
		for id, n in pairs( g_MapsFromGamesCats ) do
			if ( n == nicename ) then cat = id end
		end

		button.DoClick = function()
			self:SelectCat( cat )
		end
		button:DockMargin( 0, 0, 0, 5 )
		self.Categories[ cat ] = button

	end

	---------------------------------- SERVER SETTIGNS ----------------------------------

	local GamemodeSettings = self.GamemodeSettings
	GamemodeSettings:Clear()

	local settings_file = file.Read( "gamemodes/" .. engine.ActiveGamemode() .. "/" .. engine.ActiveGamemode() .. ".txt", true )

	if ( settings_file ) then

		local SettingsFile = util.KeyValuesToTable( settings_file )

		if ( SettingsFile.settings ) then
			
			for k, v in pairs( SettingsFile.settings ) do
				if ( v.type == "CheckBox" ) then
					local CheckBox = vgui.Create( "DCheckBoxLabel", GamemodeSettings )
					CheckBox:Dock( TOP )
					CheckBox:DockMargin( 5, 5, 5, 0 )
					CheckBox:SetText( "#" .. v.text )
					CheckBox:SetDark( true )
					CheckBox:SetChecked( GetConVarNumber( v.name ) == 1 )
				elseif ( v.type == "Text" ) then
					local label = vgui.Create( "DLabel", GamemodeSettings )
					label:Dock( TOP )
					label:SetText( language.GetPhrase( v.text ) )
					label:DockMargin( 5, 0, 0, 0 )
					label:SetDark( true )
				
					local DTextEntry = vgui.Create( "DTextEntry", GamemodeSettings )
					DTextEntry:Dock( TOP )
					DTextEntry:SetConVar( v.name )
					DTextEntry:DockMargin( 5, 0, 5, 5 )
				elseif ( v.type == "Numeric" ) then
					local DNumSlider = vgui.Create( "DNumSlider", GamemodeSettings )
					DNumSlider:Dock( TOP )
					DNumSlider:SetConVar( v.name )
					DNumSlider:SetText( language.GetPhrase( v.text ) )
					DNumSlider:SetDecimals( 0 )
					DNumSlider:SetMinMax( 0, 200 )
					DNumSlider:DockMargin( 5, 0, 5, 0 )
					DNumSlider:SetDark( true )
				end
			end
			
			//Hack, to make the bottom 5 px appear
			local label = vgui.Create( "DLabel", GamemodeSettings )
			label:Dock( TOP )
			label:SetText( "" )
			label:SetTall( 1 )

		end

	end

	--------------------------------- LOAD LAST MAP ---------------------------------

	if ( self.CurrentMap && self.CurrentCategory ) then
		self:SelectCat( self.CurrentCategory )
		self:SelectMap( self.CurrentMap )
		return
	end
	
	local t = string.Explode( ";", cookie.GetString( "lastmap", "" ) )

	local map = t[ 1 ] or "gm_construct"
	local cat = t[ 2 ] or "Sandbox"

	local mapinfo = g_MapList[ map .. ".bsp" ]

	if ( !mapinfo ) then map = "gm_flatgrass" end
	if ( !g_MapListCategorised[ cat ] ) then cat = mapinfo and mapinfo.Category or "Sandbox" end

	self:SelectCat( cat )
	self:SelectMap( map )

end

gCSMaps = {}
function PANEL:SelectCat( cat )

	if ( self.CurrentCategory && self.Categories[ self.CurrentCategory ] ) then self.Categories[ self.CurrentCategory ].Depressed = false end
	self.CurrentCategory = cat

	local chld = self.CategoryMaps:GetChildren()
	for k, v in pairs( chld ) do
		v:Remove()
	end

	if ( istable( g_MapListCategorised ) ) then
		
		local maps = table.Copy( g_MapListCategorised )
		local test = table.Merge( maps, g_MapsFromGames )

		for cate, maps in pairs( test ) do
			if ( cate != cat ) then continue end

			for _, map in SortedPairsByValue( maps ) do

				local button = self.CategoryMaps:Add( "DImageButton" )
				button:SetText( map )
				
				if ( !gMapIcons[ map ] ) then
					local mat = Material( "maps/thumb/" .. map .. ".png" )
					/*if ( mat:IsError() ) then mat = Material( "maps/thumb/" .. map .. ".png" ) print("Da", mat, AddonMaterial( "maps/thumb/" .. map .. ".png" ) ) end
					//if ( mat:IsError() ) then mat = Material( "thumb/" .. map .. ".png" ) end*/
					if ( mat:IsError() ) then mat = Material( "maps/" .. map .. ".png" ) end -- Stupid ass addons that didn't update yet
					if ( mat:IsError() ) then mat = Material( "noicon.png", "nocull smooth" ) end

					gMapIcons[ map ] = mat
				end
				button.m_Image:SetMaterial( gMapIcons[ map ] )
	
				if ( cat == "Counter-Strike" || cat == "240maps" ) then // HACK
					if ( !gCSMaps[ map ] ) then
						local mat = Material( "maps/thumb/" .. map .. ".png" )
						if ( mat:IsError() ) then mat = Material( "maps/" .. map .. ".png" ) end -- Stupid ass addons that didn't update yet
						if ( mat:IsError() ) then mat = Material( "noicon.png", "nocull smooth" ) end

						gCSMaps[ map ] = mat
					end
					button.m_Image:SetMaterial( gCSMaps[ map ] )
				end
	
				button:SetSize( 128, 128 )
				button.DoClick = function()
					self:SelectMap( map, cat )
				end
				button.PaintOver = function( button, w, h )
					
					if ( button:GetText() == self.CurrentMap ) then
						surface.SetDrawColor( Color( 255, 255, 255, 128 + math.sin( CurTime() * 2 ) * 80 ) )
						for i=0,1 do surface.DrawOutlinedRect( i, i, w - i * 2, h - i * 2 ) end
					end
	
					if ( button.Hovered ) then return end

					draw.RoundedBox( 0, 0, h - 20, w, 20, Color( 0, 0, 0, 150 ) )
					
					surface.SetFont( "rb655_MapList" )
					
					local tw = surface.GetTextSize( button:GetText() )
					if ( tw > w ) then
						draw.SimpleText( button:GetText(), "rb655_MapList", w / 2 - tw / 2 + ( ( w - tw ) * math.sin( CurTime() ) ), h - 16, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					else
						draw.SimpleText( button:GetText(), "rb655_MapList", w / 2 - tw / 2, h - 16, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					end

				end
				
				button.DoRightClick = function()
					local m = DermaMenu()
					m:AddOption( "Toggle Favourite", function() ToggleFavourite( map ) end )
					m:AddOption( "Cancel", function() end )
					m:Open()
				end

			end

		end
	end
	
	// Scroll back to the top of the map list
	self.CategoryMaps:GetParent():GetParent():GetVBar():SetScroll( 0 )

end

function PANEL:LoadMap()

	local maxplayers = GetConVarNumber( "cl_maxplayers" ) or 1 //self.Settings.PlayerCount:GetValue() or 1
	local sv_lan = 0
	if ( self.Settings.SvLan:GetChecked() ) then sv_lan = 1 end

	SaveLastMap( self.CurrentMap, self.CurrentCategory )

	hook.Run( "StartGame" )
	RunConsoleCommand( "progress_enable" )

	RunConsoleCommand( "disconnect" )

	if ( maxplayers > 0 ) then

		RunConsoleCommand( "sv_cheats", "0" )
		RunConsoleCommand( "commentary", "0" )

	end

	RunConsoleCommand( "sv_lan", sv_lan )
	RunConsoleCommand( "maxplayers", maxplayers )
	RunConsoleCommand( "map", self.CurrentMap )
	RunConsoleCommand( "hostname", self.Settings.ServerName:GetText() )

	pnlMainMenu:Back()

end

vgui.Register( "NewGamePanel", PANEL, "EditablePanel" )
