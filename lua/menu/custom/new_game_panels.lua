
function Menu_InstallDButtonScrollProtection( pnl, depth, allowM2 )
	depth = depth or 1
	allowM2 = allowM2 or false

	function pnl:OnMousePressed( mc )
		DLabel.OnMousePressed( self, mc ) -- Should use baseclass here tbh

		-- Only left mouse button can cause the animations and shit
		if ( mc != MOUSE_LEFT and !allowM2 ) then
			self.Depressed = nil
		end

		-- This is a shitty hack, but I dont see another way
		local parent = self
		for i = 1, depth do parent = parent:GetParent() end
		self.ClickStartX, self.ClickStartY = parent:GetPos()
	end

	function pnl:Think()
		local parent = self
		for i = 1, depth do parent = parent:GetParent() end
		local x, y = parent:GetPos()
		if ( self.ClickStartY and ( self.Hovered or self.Depressed ) and math.abs( self.ClickStartY - y ) > self:GetTall() / 2 ) then
			self.Depressed = nil -- Disable animations, stop DoClick from working
			self.ClickStartX, self.ClickStartY = nil, nil
		end
	end

	function pnl:OnMouseReleased( mc )
		self.ClickStartX, self.ClickStartY = nil, nil

		DLabel.OnMouseReleased( self, mc ) -- Should use baseclass here tbh
	end
end

-- TODO: Localisation
local function DrawToolTip( self, w, h )
	if ( !self:GetTooltip() ) then return end
	if ( !( self.Hovered or self.IsHovered and self:IsHovered() ) ) then return end

	local font = self.GetFont and self:GetFont() or "DermaRobotoDefault"
	surface.SetFont( font )

	local texts = { tostring( self:GetTooltip() ) }

	local tW, tH = surface.GetTextSize( texts[ #texts ] )
	local x = -tW - 25
	local screenX = self:LocalToScreen( x, 0 )
	local minX = ScrW() / 4
	while ( screenX < minX ) do -- Probably could do with caching
		local LastText = texts[ #texts ]

		local LastSpace = 0
		for i = 1, #LastText do
			if ( LastText:sub( i, i ) == " " ) then LastSpace = i end

			local txtW, txtH = surface.GetTextSize( LastText:sub( 0, i ) )
			local tempX = self:LocalToScreen( -txtW - 25, 0 )
			if ( tempX < minX ) then -- This is probably wrong. But it works in my tests
				if ( LastSpace == 0 ) then LastSpace = i end

				texts[ #texts ] = LastText:sub( 0, LastSpace )
				table.insert( texts, LastText:sub( LastSpace + 1 ) )

				local txtW2, txtH2 = surface.GetTextSize( texts[ #texts ] )
				screenX = self:LocalToScreen( -txtW2 - 25, 0 )
				break
			end
		end
	end

	DisableClipping( true )
	draw.NoTexture()
	surface.SetDrawColor( 0, 128, 255 )
	surface.DrawPoly( {
		{ x = -15, y = 0 },
		{ x = -5, y = h / 2 },
		{ x = -15, y = h }
	} )

	local targetW = 0
	for id, txt in pairs( texts ) do
		local txtW, txtH = surface.GetTextSize( txt )
		targetW = math.max( targetW, txtW )
	end
	local targetX = -targetW - 25

	local boxH = math.max( h, ( h - tH ) + tH * #texts )
	surface.DrawRect( targetX, 0, -15 - targetX, boxH )
	for id, txt in pairs( texts ) do
		draw.SimpleText( txt, font, targetX + 5, h / 2 + ( id - 1 ) * tH, color_white, 0, 1 )
	end
	DisableClipping( false )
end

---------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------- MenuCategoryButton ------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------

local PANEL = {}

-- ColorStates acts as a 'cache', and we use these exact instances of Color within Paint(), instead of constructing new
-- instances every time Paint() is called (every frame).
-- The table's keys represent state, among other things.
-- I believe it's per-instance of MenuCategoryButton, so the Color initializers below will be called for each new
-- MenuCategoryButton, but that's much, MUCH better than it being called for every Paint()!
PANEL.ColorStates = {
	[ "defaultCategory" ] = Color( 255, 255, 255 ), -- BG color for the category name
	[ "defaultCounter" ] = Color( 245, 245, 245 ), -- BG color for the counter portion

	[ "hoveredCategory" ] = Color( 240, 240, 240 ),
	[ "hoveredCounter" ] = Color( 230, 230, 230 ),

	[ "depressedCategory" ] = Color( 35, 150, 255 ),
	[ "depressedCounter" ] = Color( 26, 112, 191 ),

	[ "text" ] = Color( 85, 85, 85 ),
}

function PANEL:GetMapCount()
	if ( !self.Category ) then return -1 end

	if ( !self.LastCache or self.LastCache < CurTime() or self.NewGameMenu.SearchText != self.SearchText ) then
		self.CachedMapCount = #GetMapsFromCategorySearch( self.Category, self.NewGameMenu.SearchText )
		self.LastCache = CurTime() + 1
		self.SearchText = self.NewGameMenu.SearchText
	end

	return self.CachedMapCount
end

--[[function PANEL:SetAlt( b )
	self.Alt = b
end]]

Menu_InstallDButtonScrollProtection( PANEL )

function PANEL:SetCategory( cat )
	self.Category = cat
	self:SetFont( "DermaRobotoDefault" )
	self:SetTextInset( 5, 1 )
end

function PANEL:Paint( w, h )
	local count = self:GetMapCount()

	local clr = self.ColorStates[ "defaultCategory" ]
	local clr2 = self.ColorStates[ "defaultCounter" ]
	local clr_t = self.ColorStates[ "text" ]
	--[[if ( self.Alt ) then
		clr = Color( 253, 253, 253 )
	end]]
	if ( self.Hovered ) then
		clr2 = self.ColorStates[ "hoveredCounter" ]
		clr = self.ColorStates[ "hoveredCategory" ]
	end
	if ( self.Depressed ) then
		clr_t = color_white
		clr = self.ColorStates[ "depressedCategory" ]
		clr2 = self.ColorStates[ "depressedCounter" ]
	end
	self:SetFGColor( clr_t )

	if ( count and count > 0 ) then
		surface.SetFont( self:GetFont() )
		local tW, tH = surface.GetTextSize( tostring( count ) )
		local bW = math.max( tW, 30 ) + 6
		local tX = w - bW + bW / 2

		surface.SetDrawColor( clr )
		surface.DrawRect( 0, 0, w - bW, h )

		surface.SetDrawColor( clr2 )
		surface.DrawRect( w - bW, 0, bW, h )

		draw.SimpleText( count, self:GetFont(), tX, h / 2, clr_t, 1, 1 )
	else
		surface.SetDrawColor( clr )
		surface.DrawRect( 0, 0, w, h )
	end
end

vgui.Register( "MenuCategoryButton", PANEL, "DButton" )

---------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------- MenuSettingsCheckbox ----------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------

local PANEL = {}

-- See MenuCategoryButton for ramblings about this table
PANEL.ColorStates = {
	-- BG colors of the setting descriptor (default is white)
	[ "hoveredDescriptor" ] = Color( 253, 253, 253 ),

	-- BG colors of the check "box"
	[ "defaultCheckbox" ] = Color( 245, 245, 245 ),
	[ "checkedCheckbox" ] = Color( 240, 255, 240, 200 ),
	[ "hoveredCheckbox" ] = Color( 230, 230, 230 ), -- Applies to checked and unchecked states
	[ "depressedCheckbox" ] = Color ( 210, 210, 210 ), -- Applies to checked and unchecked states

	-- Color states of the check
	[ "unchecked" ] = Color( 0, 0, 0, 10 ),
	[ "checked" ] = Color( 0, 200, 0 ),
}

AccessorFunc( PANEL, "m_bChecked", "Checked", FORCE_BOOL )
AccessorFunc( PANEL, "m_sConVar", "ConVar", FORCE_STRING )
AccessorFunc( PANEL, "m_sText", "Text", FORCE_STRING )
AccessorFunc( PANEL, "m_sFont", "Font", FORCE_STRING )
AccessorFunc( PANEL, "m_sToolTip", "Tooltip", FORCE_STRING )

function PANEL:Init()
	self:SetMouseInputEnabled( true )
	self:SetChecked( false )

	self.ThinkBlock = 0 -- HACK
end

local width = 40
function PANEL:OnMousePressed( mcode )
	if ( mcode != MOUSE_LEFT ) then return end

	local x, y = self:LocalCursorPos()
	if ( self:GetWide() - width > x ) then return end

	self.Depressed = true
end

function PANEL:OnMouseReleased( mcode )
	if ( mcode != MOUSE_LEFT ) then return end

	local x, y = self:LocalCursorPos()
	if ( self:GetWide() - width > x ) then return end

	self.Depressed = false

	self:SetChecked( !self:GetChecked() )
end

function PANEL:Think()
	if ( self:GetConVar() and self.ThinkBlock < CurTime() ) then
		if ( GetConVarNumber( self:GetConVar() ) > 0 ) then self:SetChecked( true ) else self:SetChecked( false ) end
	end
end

function PANEL:SetChecked( b )
	if ( self.m_bChecked == b ) then return end

	self.m_bChecked = b
	if ( self:GetConVar() ) then
		RunConsoleCommand( self:GetConVar(), self:GetChecked() and "1" or "0" )
		self.ThinkBlock = CurTime() + 1 -- HACK: we gotta let the command buffer to go through..
	end

	if ( self.OnValueChanged ) then self:OnValueChanged( b ) end
end

local checkboxMat = Material( "gui/check.png" )
function PANEL:Paint( w, h )
	local x, y = self:LocalCursorPos()

	-- Drawing the setting descriptor background
	surface.SetDrawColor( color_white )
	if ( self.Hovered and self:GetWide() - width > x ) then surface.SetDrawColor( self.ColorStates[ "hoveredDescriptor" ] ) end
	surface.DrawRect( 0, 0, w - width - 1, h )

	-- Drawing the checkbox background
	surface.SetDrawColor( self.ColorStates[ "defaultCheckbox" ] )
	if ( self:GetChecked() ) then surface.SetDrawColor( self.ColorStates[ "checkedCheckbox" ] ) end

	if ( self.Hovered and self:GetWide() - width < x ) then surface.SetDrawColor( self.ColorStates[ "hoveredCheckbox" ] ) end
	if ( self.Depressed and self:GetWide() - width < x ) then surface.SetDrawColor( self.ColorStates[ "depressedCheckbox" ] ) end

	surface.DrawRect( w - width, 0, width, h )

	-- Drawing the check
	surface.SetDrawColor( self.ColorStates[ "unchecked" ] )
	if ( self:GetChecked() ) then surface.SetDrawColor( self.ColorStates[ "checked" ] ) end
	surface.SetMaterial( checkboxMat )
	surface.DrawTexturedRect( w - width / 2- h / 2, 0, h, h )

	-- Drawing the descriptor text
	if ( self:GetText() ) then
		draw.SimpleText( language.GetPhrase( self:GetText() ), self:GetFont(), 5, h / 2, color_black, 0, 1 )
	end

	DrawToolTip( self, w, h )
end

vgui.Register( "MenuSettingsCheckbox", PANEL, "Panel" )

---------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------- MenuSettingsSlider -----------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------

local PANEL = {}

-- See MenuCategoryButton for ramblings about this table
PANEL.ColorStates = {
	-- BG colors of the setting descriptor (default is white)
	[ "hoveredDescriptor" ] = Color( 253, 253, 253 ),

	-- BG colors of the textbox
	[ "defaultTextbox" ] = Color( 245, 245, 245 ),
	[ "hoveredTextbox" ] = Color( 230, 230, 230 ),
}

AccessorFunc( PANEL, "m_sConVar", "ConVar", FORCE_STRING )
AccessorFunc( PANEL, "m_sText", "Text", FORCE_STRING )
AccessorFunc( PANEL, "m_sFont", "Font", FORCE_STRING )
AccessorFunc( PANEL, "m_sToolTip", "Tooltip", FORCE_STRING )
AccessorFunc( PANEL, "m_nMin", "Min", FORCE_NUMBER )
AccessorFunc( PANEL, "m_nMax", "Max", FORCE_NUMBER )

function PANEL:Init()
	self:SetMouseInputEnabled( true )
	self:SetKeyboardInputEnabled( true )

	self.TextEntry = vgui.Create( "DTextEntry", self )
	self.TextEntry:Dock( RIGHT )
	self.TextEntry:SetUpdateOnType( true )
	self.TextEntry:SetNumeric( true )
	self.TextEntry:SetWide( 40 )
	self.TextEntry.OnValueChange = function( s )
		if ( self:GetConVar() ) then RunConsoleCommand( self:GetConVar(), s:GetText() ) end
	end
	self.TextEntry.m_defaultBackground = self.ColorStates[ "defaultTextbox" ]
	self.TextEntry.m_hoveredBackground = self.ColorStates[ "hoveredTextbox" ]
	function self.TextEntry:Paint( w, h )
		surface.SetDrawColor( self.m_defaultBackground )
		if ( self.Hovered ) then surface.SetDrawColor( self.m_hoveredBackground ) end
		surface.DrawRect( 0, 0, w, h )

		self:DrawTextEntryText( self:GetTextColor(), self:GetHighlightColor(), self:GetCursorColor() )
	end
end

function PANEL:IsHovered()
	return self.Hovered or self.TextEntry:IsHovered()
end

function PANEL:SetFont( font )
	self.m_sFont = font
	self.TextEntry:SetFont( font )
end
function PANEL:SetMinMax( min, max ) self:SetMin( min ) self:SetMax( max ) end
function PANEL:Think()
	if ( !self.TextEntry:IsEditing() and self:GetConVar() and GetConVarNumber( self:GetConVar() ) and GetConVarNumber( self:GetConVar() ) != tonumber( self.TextEntry:GetText() ) ) then
		self.TextEntry:SetText( GetConVarNumber( self:GetConVar() ) )
	end
end

function PANEL:Paint( w, h )
	local x, y = self:LocalCursorPos()
	surface.SetDrawColor( color_white )
	if ( self.Hovered and self:GetWide() - width > x ) then surface.SetDrawColor( self.ColorStates[ "hoveredDescriptor" ] ) end
	surface.DrawRect( 0, 0, w - self.TextEntry:GetWide() - 1, h )

	if ( self:GetText() ) then
		draw.SimpleText( language.GetPhrase( self:GetText() ), self:GetFont(), 5, h / 2, color_black, 0, 1 )
	end

	DrawToolTip( self, w, h )
end

vgui.Register( "MenuSettingsSlider", PANEL, "Panel" )

---------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------ MenuSettingsTextEntry ----------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------

local PANEL = {}

-- See MenuCategoryButton for ramblings about this table
PANEL.ColorStates = {
	-- BG colors of the setting descriptor (default is white)
	[ "hoveredDescriptor" ] = Color( 253, 253, 253 ),

	-- BG colors of the textbox
	[ "defaultTextbox" ] = Color( 245, 245, 245 ),
	[ "hoveredTextbox" ] = Color( 230, 230, 230 ),
}

AccessorFunc( PANEL, "m_sConVar", "ConVar", FORCE_STRING )
AccessorFunc( PANEL, "m_sText", "Text", FORCE_STRING )
AccessorFunc( PANEL, "m_sFont", "Font", FORCE_STRING )
AccessorFunc( PANEL, "m_sToolTip", "Tooltip", FORCE_STRING )

function PANEL:Init()
	self:SetMouseInputEnabled( true )

	self.TextEntry = vgui.Create( "DTextEntry", self )
	self.TextEntry:Dock( RIGHT )
	self.TextEntry:SetUpdateOnType( true )
	self.TextEntry.OnValueChange = function( s )
		if ( self:GetConVar() ) then RunConsoleCommand( self:GetConVar(), s:GetText() ) end
	end
	self.TextEntry.m_defaultBackground = self.ColorStates[ "defaultTextbox" ]
	self.TextEntry.m_hoveredBackground = self.ColorStates[ "hoveredTextbox" ]
	function self.TextEntry:Paint( w, h )
		surface.SetDrawColor( self.m_defaultBackground )
		if ( self.Hovered ) then surface.SetDrawColor( self.m_hoveredBackground ) end
		surface.DrawRect( 0, 0, w, h )

		self:DrawTextEntryText( self:GetTextColor(), self:GetHighlightColor(), self:GetCursorColor() )
	end
end

function PANEL:IsHovered()
	return self.Hovered or self.TextEntry:IsHovered()
end

function PANEL:SetFont( font )
	self.m_sFont = font
	self.TextEntry:SetFont( font )
end

function PANEL:Think()
	if ( !self.TextEntry:IsEditing() and self:GetConVar() and GetConVarString( self:GetConVar() ) and GetConVarString( self:GetConVar() ) != self.TextEntry:GetText() ) then
		self.TextEntry:SetText( GetConVarString( self:GetConVar() ) )
	end
end

function PANEL:Paint( w, h )
	local x, y = self:LocalCursorPos()
	surface.SetDrawColor( color_white )
	if ( self.Hovered and self:GetWide() - width > x ) then surface.SetDrawColor( self.ColorStates[ "hoveredDescriptor" ] ) end
	surface.DrawRect( 0, 0, w - self.TextEntry:GetWide() - 1, h )

	if ( self:GetText() ) then
		local tW = draw.SimpleText( language.GetPhrase( self:GetText() ), self:GetFont(), 5, h / 2, color_black, 0, 1 )
		self.TextEntry:SetWide( self:GetWide() - tW - 12 )
	end

	DrawToolTip( self, w, h )
end

vgui.Register( "MenuSettingsTextEntry", PANEL, "Panel" )

---------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------- DFancyTextEntry --------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------

local PANEL = {}

-- See MenuCategoryButton for ramblings about this table
PANEL.ColorStates = {
	[ "highlight" ] = Color( 35, 150, 255 ), -- Color of text selection; Don't really need to cache this one, but for the sake of consistency...

	[ "placeholderText" ] = Color( 150, 150, 150 ),

	[ "defaultTextbox" ] = Color( 245, 245, 245 ),
	[ "hoveredTextbox" ] = Color( 230, 230, 230 ),
}

AccessorFunc( PANEL, "m_sPlaceholder", "PlaceholderText", FORCE_STRING )
AccessorFunc( PANEL, "m_sToolTip", "Tooltip", FORCE_STRING )

function PANEL:Init()
	self:SetHighlightColor( self.ColorStates[ "highlight" ] )
end

function PANEL:Paint( w, h )
	surface.SetDrawColor( self.ColorStates[ "defaultTextbox" ] )
	if ( self.Hovered ) then surface.SetDrawColor( self.ColorStates[ "hoveredTextbox" ] ) end
	surface.DrawRect( 0, 0, w, h )

	self:DrawTextEntryText( self:GetTextColor(), self:GetHighlightColor(), self:GetCursorColor() )

	if ( !self:GetText() or self:GetText():Trim():len() < 1 ) then
		draw.SimpleText( language.GetPhrase( self:GetPlaceholderText() ), self:GetFont(), 5, h / 2, self.ColorStates[ "placeholderText" ], nil, 1 )
	end

	DrawToolTip( self, w, h )
end

vgui.Register( "DFancyTextEntry", PANEL, "DTextEntry" )
