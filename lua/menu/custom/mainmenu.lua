
ScreenScale = function( size ) return size * ( ScrW() / 640 ) end

include( 'addons.lua' )
include( 'new_game.lua' )
include( 'main.lua' )
include( '../background.lua' )
//include( 'enumdump.lua' )

pnlMainMenu = nil

local PANEL = {}

function PANEL:Init()

	self:Dock( FILL )
	self:SetKeyboardInputEnabled( true )
	self:SetMouseInputEnabled( true )

	local lowerPanel = vgui.Create( "DPanel", self )
	function lowerPanel:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 220 ) )
	end
	lowerPanel:SetTall( 50 )
	lowerPanel:Dock( BOTTOM )

	local BackButton = vgui.Create( "DButton", lowerPanel )
	BackButton:Dock( LEFT )
	BackButton:SetText( "#back_to_main_menu" )
	//BackButton:SetIcon( "icon16/arrow_left.png" )
	BackButton:SetVisible( false )
	BackButton:SizeToContents()
	BackButton:DockMargin( 5, 5, 5, 5 )
	BackButton:SetWide( BackButton:GetWide() + 10 )
	BackButton.DoClick = function()
		self:Back()
	end
	self.BackButton = BackButton

	local Gamemodes = vgui.Create( "DButton", lowerPanel )
	Gamemodes:Dock( RIGHT )
	Gamemodes:DockMargin( 5, 5, 5, 5 )
	Gamemodes:SetContentAlignment( 6 )
	Gamemodes.DoClick = function()
		self:OpenGamemodesList( Gamemodes )
	end
	function Gamemodes:PerformLayout()
		if ( IsValid( self.m_Image ) ) then
			self.m_Image:SetPos( 5, (self:GetTall() - self.m_Image:GetTall()) * 0.5 )
			self:SetTextInset( 10, 0 )
		end
		DLabel.PerformLayout( self )
	end
	self.GamemodeList = Gamemodes
	self:RefreshGamemodes()

	local MountedGames = vgui.Create( "DButton", lowerPanel )
	MountedGames:Dock( RIGHT )
	MountedGames:DockMargin( 5, 5, 0, 5 )
	MountedGames:SetText( "" )
	MountedGames:SetWide( 48 )
	MountedGames:SetIcon( "../html/img/back_to_game.png" )
	MountedGames.DoClick = function()
		self:OpenMountedGamesList( MountedGames )
	end
	function MountedGames:PerformLayout()
		if ( IsValid( self.m_Image ) ) then
			self.m_Image:SetPos( ( self:GetWide() - self.m_Image:GetWide() ) * 0.5, ( self:GetTall() - self.m_Image:GetTall() ) * 0.5 )
		end
		DLabel.PerformLayout( self )
	end
	self.MountedGames = MountedGames
	
	local Languages = vgui.Create( "DButton", lowerPanel )
	Languages:Dock( RIGHT )
	Languages:DockMargin( 5, 5, 0, 5 )
	Languages:SetText( "" )
	Languages:SetWide( 40 )
	self.Languages = Languages
	
	Languages:SetIcon( "../resource/localization/" .. GetConVarString( "gmod_language" ) .. ".png" )
	Languages.DoClick = function()
		self:OpenLanguages( Languages )
	end
	function Languages:PerformLayout()
		if ( IsValid( self.m_Image ) ) then
			self.m_Image:SetSize( 16, 11 )
			self.m_Image:SetPos( ( self:GetWide() - self.m_Image:GetWide() ) * 0.5, ( self:GetTall() - self.m_Image:GetTall() ) * 0.5 )
		end
		DLabel.PerformLayout( self )
	end

	self:MakePopup()
	self:SetPopupStayAtBack( true )

	self:OpenMainMenu()
	
end

function PANEL:Paint()

	if ( !IsValid( self.NewGameFrame ) && !IsValid( self.AddonsFrame ) ) then
		self.BackButton:SetVisible( false )
	else
		self.BackButton:SetVisible( true )
	end

	if ( self.IsInGame != IsInGame() ) then
	
		self.IsInGame = IsInGame()
		
		self:OpenMainMenu() -- To update the buttons

	end

	DrawBackground()

end

function PANEL:ClosePopups( b )
	if ( IsValid( self.LanguageList ) ) then self.LanguageList:Remove() end
	if ( !b && IsValid( self.MountedGamesList ) ) then self.MountedGamesList:Remove() end // The ugly 'b' hack
	if ( IsValid( self.GamemodesList ) ) then self.GamemodesList:Remove() end
end

function PANEL:Back()
	if ( IsValid( self.MainMenuPanel ) ) then self.MainMenuPanel:Remove() end
	if ( IsValid( self.NewGameFrame ) ) then self.NewGameFrame:Remove() end
	if ( IsValid( self.AddonsFrame ) ) then self.AddonsFrame:Remove() end
	self:OpenMainMenu()
end

function PANEL:OpenMainMenu( b )
	if ( IsValid( self.MainMenuPanel ) ) then self.MainMenuPanel:Remove() end
	if ( IsValid( self.NewGameFrame ) ) then self.NewGameFrame:Remove() end
	if ( IsValid( self.AddonsFrame ) ) then self.AddonsFrame:Remove() end
	self:ClosePopups( b )

	local frame = vgui.Create( "MainMenuScreenPanel", self )
	self.MainMenuPanel = frame
end

function PANEL:OpenAddonsMenu( b )
	if ( IsValid( self.MainMenuPanel ) ) then self.MainMenuPanel:Remove() end
	if ( IsValid( self.NewGameFrame ) ) then self.NewGameFrame:Remove() end
	if ( IsValid( self.AddonsFrame ) ) then self.AddonsFrame:Remove() end
	self:ClosePopups( b )

	local frame = vgui.Create( "AddonsPanel", self )
	self.AddonsFrame = frame
end

function PANEL:OpenNewGameMenu( b )
	if ( IsValid( self.MainMenuPanel ) ) then self.MainMenuPanel:Remove() end
	if ( IsValid( self.NewGameFrame ) ) then self.NewGameFrame:Remove() end
	if ( IsValid( self.AddonsFrame ) ) then self.AddonsFrame:Remove() end
	self:ClosePopups( b )

	local frame = vgui.Create( "NewGamePanel", self )
	self.NewGameFrame = frame

	hook.Run( "MenuStart" )
end

function PANEL:OpenLanguages( pnl )
	if ( IsValid( self.LanguageList ) ) then self.LanguageList:Remove() return end
	self:ClosePopups()
	
	local panel = vgui.Create( "DScrollPanel", self )
	panel:SetSize( 157, 90 )
	panel:SetPos( pnl:GetPos() - panel:GetWide() / 2 + pnl:GetWide() / 2, ScrH() - 55 - panel:GetTall() )
	self.LanguageList = panel

	function panel:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w - 5, h, Color( 0, 0, 0, 220 ) )
	end

	local p = vgui.Create( "DIconLayout", panel )
	p:Dock( FILL )
	p:SetBorder( 5 )
	p:SetSpaceY( 5 )
	p:SetSpaceX( 5 )

	for id, flag in pairs( file.Find( "resource/localization/*.png", "GAME" ) ) do
		local f = p:Add( "DImageButton" )
		f:SetImage( "../resource/localization/" .. flag )
		f:SetSize( 16, 12 )
		f.DoClick = function() RunConsoleCommand( "gmod_language", string.StripExtension( flag ) ) /*LanguageChanged( string.StripExtension( flag ) )*/ end
	end

end


function PANEL:OpenMountedGamesList( pnl )
	if ( IsValid( self.MountedGamesList ) ) then self.MountedGamesList:Remove() return end
	self:ClosePopups()

	local p = vgui.Create( "DPanelList", self )
	p:EnableVerticalScrollbar( true )
	p:SetSize( 276, 256 )
	p:SetPos( math.min( pnl:GetPos() - p:GetWide() / 2 + pnl:GetWide() / 2, ScrW() - p:GetWide() - 5 ), ScrH() - 55 - p:GetTall() )
	p:SetSpacing( 5 )
	p:SetPadding( 5 ) 
	self.MountedGamesList = p
	
	function p:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 220 ) )
	end
	
	for id, t in SortedPairsByMemberValue( engine.GetGames(), "title" ) do
		local a = p:Add( "DCheckBoxLabel" )
		a:SetText( t.title )
		if ( !t.installed ) then a:SetText( t.title .. " ( not installed )" ) end
		if ( !t.owned ) then a:SetText( t.title .. " ( not owned )" ) end
			
		p:AddItem( a )
		a:SetChecked( t.mounted )
		a.OnChange = function( panel ) engine.SetMounted( t.depot, a:GetChecked() ) end
		if ( !t.owned || !t.installed ) then
			a:SetDisabled( true )
		end
	end
	
end

function PANEL:OpenGamemodesList( pnl )
	if ( IsValid( self.GamemodesList ) ) then self.GamemodesList:Remove() return end
	self:ClosePopups()

	local p = vgui.Create( "DPanelList", self )
	p:EnableVerticalScrollbar( true )
	p:SetSpacing( 5 )
	p:SetPadding( 5 ) 
	self.GamemodesList = p

	function p:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 220 ) )
	end

	local w = 100
	local h = 5

	for id, t in SortedPairsByMemberValue( engine.GetGamemodes(), "title" ) do
		if ( !t.menusystem ) then continue end
		local Gamemode = p:Add( "DButton" )
		Gamemode:SetContentAlignment( 6 )
		Gamemode:SetText( t.title )
		Gamemode:SetIcon( "../gamemodes/" .. t.name .. "/icon24.png" )
		Gamemode:SetTextInset( Gamemode.m_Image:GetWide() + 25, 0 )
		Gamemode:SizeToContents()
		Gamemode:SetTall( 40 )
		Gamemode.DoClick = function()
			RunConsoleCommand( "gamemode", t.name )
		end
		function Gamemode:PerformLayout()
			if ( IsValid( self.m_Image ) ) then
				self.m_Image:SetPos( 5, ( self:GetTall() - self.m_Image:GetTall() ) * 0.5 )
				self:SetTextInset( 10, 0 )
			end
			DLabel.PerformLayout( self )
		end
		
		p:AddItem( Gamemode )
		
		w = math.max( w, Gamemode:GetWide() + 20 )
		h = h + 45
	end
	
	//p:SetWide( w, h )
	
	p:SetSize( w, math.min( h, 256 ) )
	p:SetPos( math.min( pnl:GetPos() - p:GetWide() / 2 + pnl:GetWide() / 2, ScrW() - p:GetWide() - 5 ), ScrH() - 55 - p:GetTall() )
end

function PANEL:RefreshGamemodes( b )

	for id, gm in pairs( engine.GetGamemodes() ) do
		if ( gm.name == engine.ActiveGamemode() ) then self.GamemodeList:SetText( gm.title ) end
	end
	self.GamemodeList:SetIcon( "../gamemodes/"..engine.ActiveGamemode().."/icon24.png" )
	self.GamemodeList:SetTextInset( self.GamemodeList.m_Image:GetWide() + 25, 0 )
	self.GamemodeList:SizeToContents()

	self:UpdateBackgroundImages()

	local yes = IsValid( self.MountedGamesList ) // Intelligent variable names

	if ( IsValid( self.NewGameFrame ) ) then self:OpenNewGameMenu( b ) end
	if ( IsValid( self.AddonsFrame ) ) then self:OpenAddonsMenu( b ) end
	if ( IsValid( self.MainMenuPanel ) ) then self:OpenMainMenu( b ) end

	if ( IsValid( self.MountedGamesList ) ) then self.MountedGamesList:MoveToFront() end

end

function PANEL:RefreshAddons()
	if ( !IsValid( self.AddonsFrame ) ) then return end

	self.AddonsFrame:RefreshAddons()

end

function PANEL:RefreshContent()

	self:RefreshGamemodes( true )
	self:RefreshAddons()

end

function PANEL:ScreenshotScan( folder )

	local bReturn = false

	local Screenshots = file.Find( folder .. "*.jpg", "GAME" )
	for k, v in RandomPairs( Screenshots ) do

		AddBackgroundImage( folder .. v )
		bReturn = true
	
	end

	return bReturn

end


function PANEL:UpdateBackgroundImages()

	ClearBackgroundImages()

	--
	-- If there's screenshots in gamemodes/<gamemode>/backgrounds/*.jpg use them
	--
	if ( !self:ScreenshotScan( "gamemodes/" .. engine.ActiveGamemode() .. "/backgrounds/" ) ) then
	
		--
		-- If there's no gamemode specific here we'll use the default backgrounds
		--
		self:ScreenshotScan( "backgrounds/" )

	end

	ChangeBackground( engine.ActiveGamemode() )

end

vgui.Register( "MainMenuPanel", PANEL, "EditablePanel" )
/*
function UpdateSteamName( id, time )

	if ( !id ) then return end

	if ( !time ) then time = 0.2 end

	local name = steamworks.GetPlayerName( id )
	if ( name != "" && name != "[unknown]" ) then

		pnlMainMenu:Call( "SteamName( \""..id.."\", \""..name.."\" )" )
		return

	end

	steamworks.RequestPlayerInfo( id )
	timer.Simple( time, function() UpdateSteamName( id, time + 0.2 ) end )

end

--
-- Called from JS when starting a new game
--
function UpdateMapList()

	if ( !istable( g_MapListCategorised ) ) then return end

	json = util.TableToJSON( g_MapListCategorised )
	if ( !isstring( json ) ) then return end

	//pnlMainMenu:Call( "UpdateMaps("..json..")" )

end

--
-- Called from JS when starting a new game
--
function UpdateServerSettings()

	local array =
	{
		hostname	= GetConVarString( "hostname" ),
		sv_lan		= GetConVarString( "sv_lan" )
	}

	local settings_file = file.Read( "gamemodes/"..engine.ActiveGamemode().."/"..engine.ActiveGamemode()..".txt", true )
		
	if ( settings_file ) then

		local Settings = util.KeyValuesToTable( settings_file )

		if ( Settings.settings ) then

			array.settings = Settings.settings

			for k, v in pairs( array.settings ) do
				v.Value = GetConVarString( v.name )
			end

		end

	end

	local json = util.TableToJSON( array )
	//pnlMainMenu:Call( "UpdateServerSettings("..json..")" )

end

--
-- Get the player list for this server
--
function GetPlayerList( serverip )

	serverlist.PlayerList( serverip, function( tbl )

		local json = util.TableToJSON( tbl )
		//pnlMainMenu:Call( "SetPlayerList( '"..serverip.."', "..json..")" )

	end )

end

local Servers = {}

function GetServers( type, id )


	local data =
	{
		Finished = function()
			
		end,

		Callback = function( ping , name, desc, map, players, maxplayers, botplayers, pass, lastplayed, address, gamemode, workshopid )

			name	= string.JavascriptSafe( name )
			desc	= string.JavascriptSafe( desc )
			map		= string.JavascriptSafe( map )
			address = string.JavascriptSafe( address )
			gamemode = string.JavascriptSafe( gamemode )
			workshopid = string.JavascriptSafe( workshopid )
			
			if ( pass ) then pass = "true" else pass = "false" end

			//pnlMainMenu:Call( "AddServer( '"..type.."', '"..id.."', "..ping..", \""..name.."\", \""..desc.."\", \""..map.."\", "..players..", "..maxplayers..", "..botplayers..", "..pass..", "..lastplayed..", \""..address.."\", \""..gamemode.."\", \""..workshopid.."\" )" )

		end,

		Type = type,
		GameDir = 'garrysmod',
		AppID = 4000,
	}

	serverlist.Query( data )	

end
*/

--
-- Called from the engine any time the language changes
--
function LanguageChanged( lang )
	if ( !IsValid( pnlMainMenu ) ) then return end

	local self = pnlMainMenu
	if ( IsValid( self.NewGameFrame ) ) then self:OpenNewGameMenu() end
	if ( IsValid( self.AddonsFrame ) ) then self:OpenAddonsMenu() end
	if ( IsValid( self.MainMenuPanel ) ) then self:OpenMainMenu() end
	
	self.Languages:SetIcon( "../resource/localization/" .. lang .. ".png" )

end

hook.Add( "GameContentChanged", "RefreshMainMenu", function()
	if ( !IsValid( pnlMainMenu ) ) then return end

	pnlMainMenu:RefreshContent()
end )

timer.Simple( 0, function()

	if ( IsValid( pnlMainMenu ) ) then pnlMainMenu:Remove() end

	pnlMainMenu = vgui.Create( "MainMenuPanel" )

	hook.Run( "GameContentChanged" )

end )
