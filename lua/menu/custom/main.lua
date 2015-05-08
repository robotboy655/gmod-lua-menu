
local PANEL = {}

language.Add( "achievements", "Achievements" )

surface.CreateFont( "MenuButton", {
	font	= "Helvetica",
	size	= ScreenScale( 8 ),
	weight	= 600
} )

function PANEL:Init()
	self:SetFont( "MenuButton" )
	self:SetMouseInputEnabled( true )
	self:SetTextColor( Color( 255, 255, 255 ) )
end

function PANEL:SetText( ... )
	DLabel.SetText( self, ... )
	self:SizeToContents()
end

function PANEL:SetDisabled( b )
	self.Disabled = b
end

function PANEL:Paint()
	if ( self.Disabled == true ) then self:SetFGColor( Color( 120, 120, 120 ) ) return end
	self:SetFGColor( self.Hovered and Color( 255, 255, 128 ) or Color( 255, 255, 255 ) )
end

function PANEL:OnCursorEntered()
	self.Hovered = true
end
function PANEL:OnCursorExited()
	self.Hovered = false
end

vgui.Register( "MenuButton", PANEL, "DLabel" )

local PANEL = {}

function PANEL:Init()

	self:Dock( FILL )

	local mainButtons = vgui.Create( "DPanel", self )
	function mainButtons:Paint( w, h )
		//draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 200 ) )
	end
	mainButtons:SetSize( 250, 350 )
	mainButtons:SetPos( ScrW() / 20, ScrH() / 2 - mainButtons:GetTall() / 2 )
	self.MenuButtons = mainButtons

	local Resume = vgui.Create( "MenuButton", mainButtons )
	Resume:Dock( TOP )
	Resume:DockMargin( 5, 5, 5, 20 )
	Resume:SetText( "#resume_game" )
	Resume.DoClick = function()
		RunGameUICommand( "engine gameui_hide" )
	end
	self.Resume = Resume
	
	local NewGame = vgui.Create( "MenuButton", mainButtons )
	NewGame:Dock( TOP )
	NewGame:DockMargin( 5, 5, 5, 0 )
	NewGame:SetText( "#new_game" )
	NewGame.DoClick = function()
		self:GetParent():OpenNewGameMenu()
	end
	
	local PlayMP = vgui.Create( "MenuButton", mainButtons )
	PlayMP:Dock( TOP )
	PlayMP:DockMargin( 5, 0, 5, 0 )
	PlayMP:SetText( "#find_mp_game" )
	PlayMP.DoClick = function()
		RunGameUICommand( "OpenServerBrowser" )
	end

	local Addons = vgui.Create( "MenuButton", mainButtons )
	Addons:Dock( TOP )
	Addons:DockMargin( 5, 20, 5, 0 )
	Addons:SetText( "#addons" )
	Addons.DoClick = function()
		self:GetParent():OpenAddonsMenu()
	end

	local Saves = vgui.Create( "MenuButton", mainButtons )
	Saves:Dock( TOP )
	Saves:DockMargin( 5, 0, 5, 0 )
	Saves:SetText( "#saves" )
	Saves:SetDisabled( true )
	Saves.DoClick = function()
		//self:GetParent():OpenAddonsMenu()
	end

	local Demos = vgui.Create( "MenuButton", mainButtons )
	Demos:Dock( TOP )
	Demos:DockMargin( 5, 0, 5, 0 )
	Demos:SetText( "#demos" )
	Demos:SetDisabled( true )
	Demos.DoClick = function()
		//self:GetParent():OpenAddonsMenu()
	end

	local Achievements = vgui.Create( "MenuButton", mainButtons )
	Achievements:Dock( TOP )
	Achievements:DockMargin( 5, 0, 5, 0 )
	Achievements:SetText( "#achievements" )
	Achievements.DoClick = function()
		self:GetParent():OpenAchievementsMenu()
	end
	
	local Options = vgui.Create( "MenuButton", mainButtons )
	Options:Dock( TOP )
	Options:SetText( "#options" )
	Options:DockMargin( 5, 20, 5, 20 )
	Options.DoClick = function()
		RunGameUICommand( "OpenOptionsDialog" )
	end

	local Disconnect = vgui.Create( "MenuButton", mainButtons )
	Disconnect:Dock( TOP )
	Disconnect:SetText( "#disconnect" )
	Disconnect:DockMargin( 5, 5, 5, 0 )
	Disconnect.DoClick = function()
		RunGameUICommand( "engine disconnect" )
	end
	self.Disconnect = Disconnect

	local Quit = vgui.Create( "MenuButton", mainButtons )
	Quit:Dock( TOP )
	Quit:SetText( "#quit" )
	Quit:DockMargin( 5, 0, 5, 0 )
	Quit.DoClick = function()
		RunGameUICommand( "quit" )
	end

end

local old = 0
function PANEL:Paint()

	if ScrH() != old then
		//print("da", self:GetWide(), self:GetTall(), self:IsVisible())
		//print(self:GetPos())
		old = ScrH()
	end

	if ( !self.Image || self.Image:GetName() != "../gamemodes/" .. engine.ActiveGamemode() .. "/logo" ) then
		self.Image = Material( "../gamemodes/" .. engine.ActiveGamemode() .. "/logo.png", "nocull smooth" )
	end

	if ( self.Image && !self.Image:IsError() ) then
		surface.SetMaterial( self.Image )
		local x, y = self.MenuButtons:GetPos()
		local w, h = self.Image:GetInt( "$realwidth" ), self.Image:GetInt( "$realheight" )
		surface.DrawTexturedRect( x, y - h, w, h )
	end

	if ( self.IsInGame != IsInGame() ) then
	
		self.IsInGame = IsInGame()

		if ( self.IsInGame ) then
			self.Disconnect:SetVisible( true )
			self.Resume:SetVisible( true )
		else
			self.Disconnect:SetVisible( false )
			self.Resume:SetVisible( false )
		end
		
	end

end

vgui.Register( "MainMenuScreenPanel", PANEL, "EditablePanel" )
