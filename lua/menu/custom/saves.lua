
local PANEL = {}

function PANEL:Init()
	self:Dock( FILL )

	local Scroll = vgui.Create( "DScrollPanel", self )
	Scroll:Dock( FILL )

	local List = vgui.Create( "DIconLayout", Scroll )
	List:Dock( FILL ) //74, 231
	List:SetSpaceY( 5 )
	List:SetSpaceX( 5 )

	// dopijopaijfoiwjfoiwejfiowfjoiapwfjoipwafjwaoipfjwaoifjawoif
	local f = file.Find( "saves/*.gms", "MOD", "datedesc" )

	local saves = {}

	for k, v in pairs( f ) do

		local ListItem = List:Add( "DImageButton" )
		ListItem:SetSize( 128, 128 )
		ListItem:SetImage( "saves/" .. v:StripExtension() .. ".jpg" )
		ListItem.DoDoubleClick = function()
			RunConsoleCommand( "gm_load", "saves/" .. v )
		end
	
		/*local entry = {
			file	= "saves/" .. v,
			name	= v:StripExtension(),
			preview	= "saves/" .. v:StripExtension() .. ".jpg"
		}*/

	end

end

function PANEL:Paint( w, h )
	surface.SetDrawColor( 0, 0, 0, 150 )
	surface.DrawRect( 0, 0, w, h )
end

vgui.Register( "SavesPanel", PANEL, "EditablePanel" )
