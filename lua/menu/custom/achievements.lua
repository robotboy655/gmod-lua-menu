
local PANEL = {}

function PANEL:Init()
	self.AchID = 0

	self:SetTall( 72 )

	self.Icon = vgui.Create( "AchievementIcon", self )
	self.Icon:SetPos( 4, 4 )
	self.Icon:SetSize( 64, 64 )
end

function PANEL:SetAchievementID( num )
	self.AchID = num
	self.Icon:SetAchievement( num )
end

function PANEL:Paint()
	local text_col = Color( 217, 217, 217 )
	if ( achievements.IsAchieved( self.AchID ) ) then
		draw.RoundedBox( 4, 0, 0, self:GetWide(), self:GetTall(), Color( 78, 78, 78 ) )
	else
		draw.RoundedBox( 4, 0, 0, self:GetWide(), self:GetTall(), Color( 52, 52, 52 ) )
		text_col = Color( 131, 131, 131 )
	end

	draw.SimpleText( achievements.GetName( self.AchID ), "Default", self:GetTall(), 4, text_col )
	draw.SimpleText( achievements.GetDesc( self.AchID ), "Default", self:GetTall(), 20, text_col )

	local goal = achievements.GetGoal( self.AchID )
	local count = achievements.GetCount( self.AchID )
	if ( goal > 1 ) then
		local text = count .. "/" .. goal

		surface.SetFont( "Default" )
		local h = 16

		draw.RoundedBox( 0, self:GetTall(), self:GetTall() - h - 4, self:GetWide() - self:GetTall() - 4, h, Color( 64, 64, 64, 255 ) )
		draw.RoundedBox( 0, self:GetTall(), self:GetTall() - h - 4, ( self:GetWide() - self:GetTall() - 4 ) * ( count / goal ), h, Color( 201, 185, 149, 255 ) )
		draw.SimpleText( text, "Default", self:GetWide() - surface.GetTextSize( text ) - 4, self:GetTall() - h * 2 - 4, text_col )
	end
end

vgui.Register( "RAchievement", PANEL, "Panel" )

language.Add( "rb655.achievement_viewer.total", "Total Achievements Earned" )

--------------------------------- --------------------------------- --------------------------------- ---------------------------------

local PANEL = {}

function PANEL:Init()

	self:Dock( FILL )

	--------------------------------- CATEGORIES ---------------------------------

	local frame = vgui.Create( "DPanel", self )
	self.frame = frame

	local achieved = 0
	local count = achievements.Count() - 1

	for achid = 1, count do
		if ( achievements.IsAchieved( achid ) ) then
			achieved = achieved + 1
		end
	end

	local ach_total = vgui.Create( "DPanel", frame )
	ach_total:Dock( TOP )
	ach_total:SetTall( 40 )
	ach_total:DockMargin( 5, 5, 5, 5 )
	function ach_total:Paint()
		draw.RoundedBox( 4, 0, 0, self:GetWide(), self:GetTall(), Color( 26, 26, 26, 255 ) )

		local text = achieved .. " / " .. count .. " ( " .. math.floor( ( achieved / count ) * 100 ) .. "% )"
		surface.SetFont( "Default" )
		local w = surface.GetTextSize( text ) + 4

		draw.SimpleText( "#rb655.achievement_viewer.total", "Default", 4, 4, Color( 217, 217, 217 ) )
		draw.SimpleText( text, "Default", self:GetWide() - w, 4, Color( 217, 217, 217 ) )

		draw.RoundedBox( 0, 4, 20, self:GetWide() - 8, 16, Color( 78, 78, 78 ) )
		draw.RoundedBox( 0, 4, 20, math.floor( ( achieved / count ) * self:GetWide() ) - 8, 16, Color( 158, 195, 79, 255 ) )
	end

	local ach_list = vgui.Create( "DPanelList", frame )
	ach_list:Dock( FILL )
	ach_list:DockMargin( 5, 0, 5, 5 )
	ach_list:SetSpacing( 5 )
	ach_list:SetPadding( 5 )
	ach_list:EnableHorizontal( false )
	ach_list:EnableVerticalScrollbar()
	function ach_list:Paint()
		draw.RoundedBox( 4, 0, 0, self:GetWide(), self:GetTall(), Color( 16, 16, 16, 255 ) )
	end

	for achid = 1, count do
		local ach = vgui.Create( "RAchievement", ach_list )
		ach:SetAchievementID( achid )
		ach_list:AddItem( ach )
	end

end

function PANEL:Paint( w, h )
	self.frame:SetSize( self:GetWide() / 2, self:GetTall() / 1.5 )
	self.frame:SetPos( self:GetWide() / 2 - self.frame:GetWide() / 2, self:GetTall() / 2 - self.frame:GetTall() / 2 )

	draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 150 ) )
end

vgui.Register( "AchievementsPanel", PANEL, "EditablePanel" )

