
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
		local w = surface.GetTextSize( text ) + 4

		draw.RoundedBox( 0, self:GetTall(), self:GetTall() - 24, self:GetWide() - self:GetTall() - 4 - w, 20, Color( 64, 64, 64, 255 ) )
		draw.RoundedBox( 0, self:GetTall(), self:GetTall() - 24, ( self:GetWide() - self:GetTall() - 4 - w ) * ( count / goal ), 20, Color( 201, 185, 149, 255 ) )
		draw.SimpleText( text, "Default", self:GetWide() - w, self:GetTall() - 22, text_col )
	end
end

vgui.Register( "RAchievement", PANEL, "Panel" )

language.Add( "achievements", "Achievements" )
language.Add( "rb655.achievement_viewer.my", "My Achievements" )
language.Add( "rb655.achievement_viewer.total", "Total Achievements Earned" )
