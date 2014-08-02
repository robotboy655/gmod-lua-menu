
local PANEL = {}

function PANEL:Init()

	self:Dock( FILL )
	
	--------------------------------- CATEGORIES ---------------------------------
	
	local Categories = vgui.Create( "DListLayout", self )
	Categories:DockPadding( 5, 5, 5, 5 )
	Categories:Dock( LEFT )
	Categories:SetWide( 200 )

	self.Categories = {}
	if ( istable( g_MapListCategorised ) ) then
		local cats = table.GetKeys( g_MapListCategorised )
		table.sort( cats )
		for _, cat in pairs( cats ) do
			local button = Categories:Add( "DButton" )
			button:SetText( cat )
			button.DoClick = function()
				self:SelectCat( cat )
			end
			button:DockMargin( 0, 0, 0, 5 )
			self.Categories[ cat ] = button
		end
	end
	
	local Scroll = vgui.Create( "DScrollPanel", self )
	Scroll:Dock( FILL )
	Scroll:DockMargin( 0, 5, 0, 5 )
	
	local CategoryMaps = vgui.Create( "DIconLayout", Scroll )
	CategoryMaps:SetSpaceX( 5 )
	CategoryMaps:SetSpaceY( 5 )
	CategoryMaps:Dock( TOP )
	self.CategoryMaps = CategoryMaps
	
	--------------------------------- SETTINGS ---------------------------------
	
	local Settings = vgui.Create( "DListLayout", self )
	Settings:Dock( RIGHT )
	Settings:SetWide( ScrW() / 5 )
	Settings:DockMargin( 5, 5, 5, 0 )
	function Settings:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 200, 200, 150 ) )
	end
	self.Settings = Settings
	
	---------------------------------
	
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
	
	----------------------------------------------------------------------
	
	local GamemodeSettings = vgui.Create( "DScrollPanel", Settings )
	GamemodeSettings:Dock( FILL )
	GamemodeSettings:DockMargin( 0, 0, 0, 5 )
	function GamemodeSettings:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 128 ) )
	end
	
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
					CheckBox:SetChecked( GetConVarNumber( v.name ) == 1 )
				elseif ( v.type == "Text" ) then
					local label = vgui.Create( "DLabel", GamemodeSettings )
					label:Dock( TOP )
					label:SetText( language.GetPhrase( v.text ) )
					label:DockMargin( 5, 0, 0, 0 )
				
					local DTextEntry = vgui.Create( "DTextEntry", GamemodeSettings )
					DTextEntry:Dock( TOP )
					DTextEntry:SetConVar( v.name )
					DTextEntry:DockMargin( 5, 0, 5, 5 )
				elseif ( v.type == "Numeric" ) then
					local DTextEntry = vgui.Create( "DNumSlider", GamemodeSettings )
					DTextEntry:Dock( TOP )
					DTextEntry:SetConVar( v.name )
					DTextEntry:SetText( language.GetPhrase( v.text ) )
					DTextEntry:SetMinMax( 0, 200 )
					DTextEntry:DockMargin( 5, 0, 5, 0 )
				end
			end
			
			//Hack, to make the bottom 5 px appear
			local label = vgui.Create( "DLabel", GamemodeSettings )
			label:Dock( TOP )
			label:SetText( "" )
			label:SetTall( 1 )

		end

	end

	---------------------------------

	local StartGame = Settings:Add("DButton")
	StartGame:Dock( BOTTOM )
	StartGame:SetText( "Start Game" )
	StartGame:SetTall( 32 )
	StartGame.DoClick = function()
		self:LoadMap()
	end
	StartGame:DockMargin( 5, 0, 5, 5 )

	--------------------------------- LOAD LAST MAP ---------------------------------
	
	local t = string.Explode( ";", cookie.GetString( "lastmap", "" ) )

	local map = t[ 1 ] or "gm_construct"
	local cat = t[ 2 ] or "Sandbox"

	local mapinfo = g_MapList[ map .. ".bsp" ]

	if ( !mapinfo ) then map = "gm_flatgrass" end
	if ( !g_MapListCategorised[ cat ] ) then cat = mapinfo and mapinfo.Category or "Sandbox" end
	
	self:SelectCat( cat )
	self:SelectMap( map )

end

function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 150 ) )
	if ( self.CurrentCategory ) then
		self.Categories[ self.CurrentCategory ].Depressed = true
	end
end

surface.CreateFont( "rb655_MapList", {
	size = ScreenScale( 6 ),
	font = "Tahoma",
	outline = true,
} )

function PANEL:SelectMap( map )
	self.CurrentMap = map
end

gMapIcons = {}

function PANEL:SelectCat( cat )
	if ( self.CurrentCategory ) then self.Categories[ self.CurrentCategory ].Depressed = false end
	self.CurrentCategory = cat

	local chld = self.CategoryMaps:GetChildren()
	for k, v in pairs( chld ) do
		v:Remove()
	end

	if ( istable( g_MapListCategorised ) ) then
		for cate, t in pairs( g_MapListCategorised ) do
			if ( cate != cat ) then continue end
			local maps = table.GetKeys( t )
			table.sort( maps )
			for _, map in pairs( maps ) do

				local button = self.CategoryMaps:Add( "DImageButton" )
				button:SetText( map )
				
				if ( !gMapIcons[ map ] ) then
					local mat = Material( "../maps/thumb/" .. map .. ".png" )
					if ( mat:IsError() ) then mat = Material( "thumb/" .. map .. ".png" ) end
					if ( mat:IsError() ) then mat = Material( "vgui/avatar_default" ) end
					gMapIcons[ map ] = mat
				end
				button.m_Image:SetMaterial( gMapIcons[ map ] )
	
				button:SetSize( 128, 128 )
				button.DoClick = function()
					self:SelectMap( map, cat )
				end
				button.PaintOver = function( button, w, h )
					if ( button:GetText() == self.CurrentMap ) then
						draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 64 + math.sin( CurTime() * 2 ) * 32 ) )
					end

					surface.SetFont( "rb655_MapList" )
					
					local tw = surface.GetTextSize( button:GetText() )
					draw.SimpleText( button:GetText(), "rb655_MapList", w / 2 - tw / 2, h - 16, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

				end

			end

		end
	end

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

