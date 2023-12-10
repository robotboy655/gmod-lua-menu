
local Errors = {}

local matAlert = Material( "icon16/error.png" )

hook.Add( "DrawOverlay", "MenuErrors", function()

	if ( GetConVarNumber( "mat_dxlevel" ) < 90 ) then
		table.insert( Errors, {
			last	= SysTime(),
			text	= "mat_dxlevel is less than 90!"
		} )
	end

	if ( GetConVarNumber( "lookstrafe" ) >= 1 or GetConVarNumber( "lookstrafe" ) <= -1 ) then
		table.insert( Errors, {
			last	= SysTime(),
			text	= "Console varible \"lookstrafe\" is not 0, expect movement oddities!"
		} )
	end

	if ( table.Count( Errors ) == 0 ) then return end

	local idealy = 32
	local height = 30
	local Recent = SysTime() - 0.5

	for k, v in SortedPairsByMemberValue( Errors, "last" ) do

		surface.SetFont( "DermaDefaultBold" )
		if ( v.y == nil ) then v.y = idealy end
		if ( v.w == nil ) then v.w = surface.GetTextSize( v.text ) + 44 end

		local tw, th = surface.GetTextSize( v.text )
		v.x = ScrW() - tw - 76

		draw.RoundedBox( 2, v.x + 2, v.y + 2, v.w, height, Color( 40, 40, 40, 255 ) )
		draw.RoundedBox( 2, v.x, v.y, v.w, height, Color( 240, 240, 240, 255 ) )

		if ( v.last > Recent ) then

			draw.RoundedBox( 2, v.x, v.y, v.w, height, Color( 255, 200, 0, ( v.last - Recent ) * 510 ) )

		end

		surface.SetTextColor( 90, 90, 90, 255 )
		surface.SetTextPos( v.x + 30, v.y + 8 )
		surface.DrawText( v.text )

		surface.SetDrawColor( 255, 255, 255, 150 + math.sin( v.y + SysTime() * 30 ) * 100 )
		surface.SetMaterial( matAlert )
		surface.DrawTexturedRect( v.x + 6, v.y + 6, 16, 16 )

		v.y = idealy

		idealy = idealy + 40

		Errors[k] = nil

	end

end )
