local infoServerName    = ""
local infoMapName       = ""
local infoServerURL     = ""
local infoMaxPlayers    = ""
local infoSteamID       = ""
local infoGameMode      = ""

local mat_BgLight     = Material( "html/img/bg.png", "nocull smooth" )
local mat_BgDark      = Material( "html/img/bg_dark.png", "nocull smooth" )
local mat_Logo        = Material( "html/img/gmod_logo_brave.png", "nocull smooth" )
local mat_Walk        = Material( "gui/walk.png", "nocull smooth" )
local mat_NoIcon      = Material( "gui/noicon.png", "nocull smooth" )
local mat_Gradient    = Material( "gui/gradient" )

local PANEL = {}
local newGamePanel = nil
local spinnerStart = 0

function PANEL:CheckDarkMode()
    local today = os.date("*t")
    
    local isHalloween = ( today.month == 10 ) and ( today.day >= 15 ) or ( today.month == 11 and today.day <= 5 )
    
    local darkMode = ( today.hour >= 19 ) or ( today.hour <= 7 )
   
    local bgIsDark = ( darkMode or isHalloween )

    self.PanelServerName:SetTextColor( bgIsDark and Color( 255, 255, 255 ) or Color( 0, 0, 0 ) )
    self.PanelServerMap:SetTextColor( bgIsDark and Color( 255, 255, 255 ) or Color( 0, 0, 0 ) )
    self.PanelServerGameMode:SetTextColor( bgIsDark and Color( 255, 255, 255 ) or Color( 0, 0, 0 ) )
    self.PanelBG:SetMaterial( bgIsDark and mat_BgDark or mat_BgLight )
end

function PANEL:UpdateServerInfo()

    self.PanelMapImg:SetMaterial( newGamePanel and newGamePanel:CacheIcon( infoMapName ) or mat_NoIcon )
    self.PanelServerName:SetText( infoServerName )
    self.PanelServerMap:SetText( infoMapName )
    self.PanelServerGameMode:SetText( infoGameMode )
    
    local panels = { self.PanelServerName, self.PanelServerMap, self.PanelServerGameMode }
    local maxWide = 0
    for i, pnl in pairs( panels ) do
        surface.SetFont( pnl:GetFont() )
        local textWide = surface.GetTextSize( pnl:GetText() )
        if textWide > maxWide then maxWide = textWide end
    end

    self.PanelServerInfoLayout:SetWide( maxWide )
    self.PanelServerInfo:SetVisible( true )
end

function PANEL:Init()
	self:Dock( FILL )
    
    -- Background
    local pnlBG = vgui.Create( "DImage", self )
    pnlBG:SetMaterial( mat_BgLight )
    pnlBG:Dock( FILL )
    pnlBG.PerformLayout = PANEL.PerformLayout
    self.PanelBG = pnlBG
    
    -- Logo
    local pnlContainer = vgui.Create( "DPanel", self )
    pnlContainer:SetPaintBackground( false )
    pnlContainer:SetSize( 240, 240 )
    pnlContainer.PerformLayout = function( pnl )
        pnl:CenterHorizontal( 0.5 )
        pnl:CenterVertical( 0.45 )
    end
    
    local pnlLogo = vgui.Create( "DImage", pnlContainer )
    pnlLogo:SetMaterial( mat_Logo )
    pnlLogo:SetSize( mat_Logo:Width(), mat_Logo:Height() )
    pnlLogo:CenterHorizontal()
    
    local pnlWalk = vgui.Create( "DPanel", pnlContainer )
    pnlWalk:SetSize( 40, 40 )
    pnlWalk:SetX( pnlLogo:GetWide() / 2 )
    pnlWalk:SetY( pnlLogo:GetTall() + 15 )
    pnlWalk.Paint = function( pnl, w, h )
        local ang = ( ( CurTime() - spinnerStart ) % 10 ) * 36
    
        surface.SetMaterial( mat_Walk )
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.DrawTexturedRectRotated( pnl:GetWide() / 2, pnl:GetTall() / 2, 28, 28, -ang )
    end

    -- Server info
    local marginServerInfo = 20
    local pnlServerInfo = vgui.Create( "DPanel", self )
    pnlServerInfo:SetPos( 0, 0 )
    pnlServerInfo:SetPaintBackground( false )
    
    local pnlServerInfoBg = vgui.Create( "DImage", pnlServerInfo )
    pnlServerInfoBg:SetMaterial( mat_Gradient )
    pnlServerInfoBg:SetImageColor( Color( 0, 0, 0, 102 ) )
    pnlServerInfoBg:Dock( FILL )
    
    local pnlMapImg = vgui.Create( "DImage", pnlServerInfo )
    pnlMapImg:SetSize( 128, 128 )
    pnlMapImg:SetPos( marginServerInfo, marginServerInfo )
    pnlMapImg:SetMaterial( mat_NoAddonLogo )
    
    local pnlServerInfoLayout = vgui.Create( "DListLayout", pnlServerInfo )
    pnlServerInfoLayout:SetPos( pnlMapImg:GetX() + pnlMapImg:GetWide() + 16, marginServerInfo )
    pnlServerInfoLayout:SetSize( 0, 128 )
    pnlServerInfoLayout:SetPaintBackground( false )
    pnlServerInfoLayout:SetBackgroundColor( Color( 0, 100, 100 ) )
    pnlServerInfoLayout.PerformLayout = function( pnl, w, h )
        pnlServerInfo:SetSize( pnl:GetX() + w + 180, pnl:GetY() + h + 20 )
    end
    
    local lineHeight = 42
    local pnlServerName = vgui.Create( "DLabel" )
    pnlServerName:SetFont( "DermaLarge" )
    pnlServerName:SetTextColor( bgIsDark or Color( 255, 255, 255 ) or Color( 0, 0, 0 ) )
    pnlServerName:SetText( infoServerName )
    pnlServerName:SetTall( lineHeight )
    pnlServerInfoLayout:Add( pnlServerName )
    
    local pnlServerMap = vgui.Create( "DLabel" )
    pnlServerMap:SetFont( "DermaLarge" )
    pnlServerMap:SetTextColor( bgIsDark or Color( 255, 255, 255 ) or Color( 0, 0, 0 ) )
    pnlServerMap:SetText( infoMapName )
    pnlServerMap:SetTall( lineHeight )
    pnlServerInfoLayout:Add( pnlServerMap )
    
    local pnlServerGameMode = vgui.Create( "DLabel" )
    pnlServerGameMode:SetFont( "DermaLarge" )
    pnlServerGameMode:SetTextColor( bgIsDark or Color( 255, 255, 255 ) or Color( 0, 0, 0 ) )
    pnlServerGameMode:SetText( infoGameMode )
    pnlServerGameMode:SetTall( lineHeight )
    pnlServerInfoLayout:Add( pnlServerGameMode )
    
    self.PanelServerInfo        = pnlServerInfo
    self.PanelMapImg            = pnlMapImg
    self.PanelServerInfoLayout  = pnlServerInfoLayout
    self.PanelServerName        = pnlServerName
    self.PanelServerMap         = pnlServerMap
    self.PanelServerGameMode    = pnlServerGameMode
end

function PANEL:Paint( w, h )
	surface.SetDrawColor( 30, 30, 30, 255 )
	surface.DrawRect( 0, 0, w, h )
end

function PANEL:OnActivate()
	infoServerName  = ""
	infoMapName     = ""
	infoServerURL   = ""
	infoMaxPlayers  = ""
	infoSteamID	    = ""
    infoGameMode    = ""
    
    if not self.Active then
        self:CheckDarkMode()
        spinnerStart = CurTime()
        self.Active = true
    end
end

function PANEL:OnDeactivate()
	system.FlashWindow()
    
    self.Active = false
    self.PanelServerInfo:SetVisible( false )
end

function PANEL:OnScreenSizeChanged( oldW, oldH, newW, newH )
	self:InvalidateLayout( true )
end

function PANEL:Think()

end

vgui.Register( "LoadingPanel", PANEL, "EditablePanel" )

g_PanelLoading = nil
function GetLoadPanel()
    
	if ( !IsValid( g_PanelLoading ) ) then
		g_PanelLoading = vgui.Create( "LoadingPanel" )
        newGamePanel = vgui.GetControlTable( "NewGamePanel" )
	end

	return g_PanelLoading

end
function IsInLoading()
    
	if ( !IsValid( g_PanelLoading ) ) then
		return false
	end
    
	return g_PanelLoading.Active

end

function GameDetails( servername, serverurl, mapname, maxplayers, maxplayers_visible, steamid, gamemode )
    if ( engine.IsPlayingDemo() ) then return end

	infoServerName  = servername
	infoMapName     = mapname
	infoServerURL   = serverurl
	infoMaxPlayers  = maxplayers
	infoSteamID     = steamid
	infoGameMode    = gamemode
    
	for k, v in pairs( engine.GetGamemodes() ) do
		if ( infoGameMode == v.name ) then
			infoGameMode = v.title
			break
		end
	end
    
    g_PanelLoading:UpdateServerInfo()
end