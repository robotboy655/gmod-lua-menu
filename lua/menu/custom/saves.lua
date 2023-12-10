
local PANEL = {}

function PANEL:Init()
	self:Dock( FILL )
end

function PANEL:SetType( typ )
	self.Type = typ

	self:UpdateList()
end

function PANEL:UpdateList()
	self:Clear()

	local Scroll = vgui.Create( "DScrollPanel", self )
	Scroll:Dock( FILL )
	Scroll:DockMargin( 5, 5, 5, 5 )

	local List = vgui.Create( "DIconLayout", Scroll )
	List:Dock( FILL )
	List:SetSpaceY( 5 )
	List:SetSpaceX( 5 )

	local f = nil
	if ( self.Type == "saves" ) then
		f = file.Find( "saves/*.gms", "MOD", "datedesc" )
	elseif ( self.Type == "demos" ) then
		f = file.Find( "demos/*.dem", "MOD", "datedesc" )
	elseif ( self.Type == "dupes" ) then
		f = file.Find( "dupes/*.dupe", "MOD", "datedesc" )
	end

	for k, v in pairs( f ) do
		local ListItem = List:Add( "DImageButton" )
		ListItem:SetSize( 128, 128 )
		ListItem:SetImage( self.Type .. "/" .. v:StripExtension() .. ".jpg" )
		ListItem.DoDoubleClick = function()
			if ( self.Type == "saves" ) then
				RunConsoleCommand( "gm_load", "saves/" .. v )
			elseif ( self.Type == "demos" ) then
				RunConsoleCommand( "playdemo", "demos/" .. v )
			end
		end
		ListItem.DoRightClick = function()
			local m = DermaMenu()

			if ( self.Type == "saves" ) then
				m:AddOption( "Load", function() RunConsoleCommand( "gm_load", "saves/" .. v ) end )
			elseif ( self.Type == "demos" ) then
				m:AddOption( "Play", function() RunConsoleCommand( "playdemo", "demos/" .. v ) end )
			end

			if ( self.Type == "demos" ) then
				m:AddOption( "Demo To Video", function() RunConsoleCommand( "gm_demo_to_video", "demos/" .. v ) end )
			end
			m:AddOption( "Delete", function()
				file.Delete( self.Type .. "/" .. v, "MOD" )
				file.Delete( self.Type .. "/" .. v:StripExtension() .. ".jpg", "MOD" )
				self:UpdateList()
			end )
			m:AddOption( "Cancel" )
			m:Open()
		end
	end
end

function PANEL:Paint( w, h )
	surface.SetDrawColor( 0, 0, 0, 150 )
	surface.DrawRect( 0, 0, w, h )
end

vgui.Register( "SavesPanel", PANEL, "EditablePanel" )
