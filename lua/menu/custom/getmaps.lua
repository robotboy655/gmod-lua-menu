
local RefreshMaps

--
-- Favourites
--

local MapFavourites

local function LoadFavourites()

	local cookiestr = cookie.GetString( "favmaps" )
	MapFavourites = MapFavourites or ( cookiestr and string.Explode( ";", cookiestr ) or {} )

end

function IsMapFavourite( map )

	LoadFavourites()

	return table.HasValue( MapFavourites, map )

end

function ToggleFavourite( map )

	LoadFavourites()

	if ( table.HasValue( MapFavourites, map ) ) then -- is favourite, remove it
		table.remove( MapFavourites, table.KeysFromValue( MapFavourites, map )[ 1 ] )
	else -- not favourite, add it
		table.insert( MapFavourites, map )
	end

	cookie.Set( "favmaps", table.concat( MapFavourites, ";" ) )

	RefreshMaps( true )

	UpdateMapList()

end

--
-- Map Gamemodes
--

local MapPatterns = {}

local MapNames = {}
MapNames[ "bhop_" ] = "Bunny Hop"
MapNames[ "cinema_" ] = "Cinema"
MapNames[ "theater_" ] = "Cinema"
MapNames[ "xc_" ] = "Climb"
MapNames[ "deathrun_" ] = "Deathrun"
MapNames[ "dr_" ] = "Deathrun"
MapNames[ "fm_" ] = "Flood"
MapNames[ "gmt_" ] = "GMod Tower"
MapNames[ "gg_" ] = "Gun Game"
MapNames[ "scoutzknivez" ] = "Gun Game"
MapNames[ "ba_" ] = "Jailbreak"
MapNames[ "jail_" ] = "Jailbreak"
MapNames[ "jb_" ] = "Jailbreak"
MapNames[ "mg_" ] = "Minigames"
MapNames[ "pw_" ] = "Pirate Ship Wars"
MapNames[ "ph_" ] = "Prop Hunt"
MapNames[ "rp_" ] = "Roleplay"
MapNames[ "slb_" ] = "Sled Build"
MapNames[ "sb_" ] = "Spacebuild"
MapNames[ "slender_" ] = "Stop it Slender"
MapNames[ "gms_" ] = "Stranded"
MapNames[ "surf_" ] = "Surf"
MapNames[ "ts_" ] = "The Stalker"
MapNames[ "zm_" ] = "Zombie Master"
MapNames[ "zombiesurvival_" ] = "Zombie Survival"
MapNames[ "zs_" ] = "Zombie Survival"
MapNames[ "ze_" ] = "Zombie Escape"
MapNames[ "gd_" ] = "Guardian"
MapNames[ "dz_" ] = "Danger Zone"
MapNames[ "cm_" ] = "Custom"
MapNames[ "gt_" ] = "Ghost Town"
MapNames[ "tp_" ] = "Team Play"
MapNames[ "vs_" ] = "Versus"
MapNames[ "coop_" ] = "Cooperative"
MapNames[ "vsh_" ] = "Versus Saxton Hale"
MapNames[ "zi_" ] = "Zombie Infection"

MapNames[ "am_" ] = "Aim Multi (1v1)"
MapNames[ "de_" ] = "Bomb Defuse"
MapNames[ "cs_" ] = "Hostage Rescue"
MapNames[ "dm_" ] = "Deathmatch"
MapNames[ "ar_" ] = "Arms Race"
MapNames[ "aim_" ] = "Aim Arena"
MapNames[ "awp_" ] = "AWP Arena"
MapNames[ "arena_" ] = "Arena"
MapNames[ "ctf_" ] = "Capture The Flag"
MapNames[ "cp_" ] = "Control Point"
MapNames[ "koth_" ] = "King Of The Hill"
MapNames[ "mvm_" ] = "Mann Versus Machine"
MapNames[ "pass_" ] = "PASS time"
MapNames[ "pl_" ] = "Payload"
MapNames[ "plr_" ] = "Payload Race"
MapNames[ "pd_" ] = "Player Destruction"
MapNames[ "rd_" ] = "Robot Destruction"
MapNames[ "kz_" ] = "Kreedz Climbing"
MapNames[ "sd_" ] = "Special Delivery"
MapNames[ "tc_" ] = "Territorial Control"
MapNames[ "tr_" ] = "Training"
MapNames[ "dod_" ] = "Day of Defeat" -- Technically this IS control points
MapNames[ "fof_" ] = "Fistful of Frags"
MapNames[ "bm_" ] = "Black Mesa"
-- MapNames[ "phys_" ] = "Physics Sandbox" -- Defined by Sandbox gamemode

MapNames[ "halls3" ] = "Deathmatch"

-- HL1: DM
MapNames[ "boot_camp" ] = "Deathmatch"
MapNames[ "bounce" ] = "Deathmatch"
MapNames[ "crossfire" ] = "Deathmatch"
MapNames[ "datacore" ] = "Deathmatch"
MapNames[ "frenzy" ] = "Deathmatch"
MapNames[ "lambda_bunker" ] = "Deathmatch"
MapNames[ "rapidcore" ] = "Deathmatch"
MapNames[ "snarkpit" ] = "Deathmatch"
MapNames[ "stalkyard" ] = "Deathmatch"
MapNames[ "subtransit" ] = "Deathmatch"
MapNames[ "undertow" ] = "Deathmatch"

local MapGamemodes = {}

local function UpdateGamemodeMaps()

	local GamemodeList = engine.GetGamemodes()

	for id, gm in ipairs( GamemodeList ) do

		local name = gm.title or "Unnammed Gamemode"
		local maps = string.Split( gm.maps, "|" )

		if ( maps and gm.maps != "" ) then

			for k, pattern in ipairs( maps ) do
				-- When in doubt, just try to match it with string.find
				MapGamemodes[ string.lower( pattern ) ] = name
			end

		end

	end

end

--
-- Sub Categories ( For single player games )
--

local MapSubCategories = {

	-- HL1:S
	[ "c1a0c" ] = "c. Unforeseen Consequences",
	[ "c2a4d" ] = "k. Questionable Ethics",
	[ "c2a4e" ] = "k. Questionable Ethics",
	[ "c2a4f" ] = "k. Questionable Ethics",
	[ "c2a4g" ] = "k. Questionable Ethics",
	[ "c4a1" ] = "o. Xen",
	[ "c4a1z" ] = "z. Other",
	[ "c4a1y" ] = "z. Other",

	-- HL2: LC
	[ "d2_lostcoast" ] = "Lost Coast",

	-- L4D
	[ "l4d_sv_lighthouse" ] = "f. The Last Stand",

}

local MapPatternSubCategories = {

	-- Random, TODO: Move to Gamemode list?
	[ "^hns_" ] = "Hide and Seek",
	[ "^pf_" ] = "Parkour Fortress",
	[ "^fy_" ] = "Fight Yard",
	[ "^hg_" ] = "Hunger Games",
	[ "^trade_" ] = "Trade",
	[ "^35hp" ] = "35HP Knife Only",

	-- Left 4 Dead 1
	[ "^l4d_hospital0" ] = "No Mercy",
	[ "^l4d_garage0" ] = "Crash Course",
	[ "^l4d_smalltown0" ] = "Death Toll",
	[ "^l4d_airport0" ] = "Dead Air",
	[ "^l4d_farm0" ] = "Blood Harvest",
	[ "^l4d_river0" ] = "The Sacrifice",
	[ "^l4d_vs_" ] = "Versus",

	-- Left 4 Dead 2
	[ "^c1m" ] = "Dead Center",
	[ "^c2m" ] = "Dark Carnival",
	[ "^c3m" ] = "Swamp Fever",
	[ "^c4m" ] = "Hard Rain",
	[ "^c5m" ] = "The Parish",
	[ "^c6m" ] = "The Passing",
	[ "^c7m" ] = "The Sacrifice (L4D1)",
	[ "^c8m" ] = "No Mercy (L4D1)",
	[ "^c9m" ] = "Crash Course (L4D1)",
	[ "^c10m" ] = "Death Toll (L4D1)",
	[ "^c11m" ] = "Dead Air (L4D1)",
	[ "^c12m" ] = "Blood Harvest (L4D1)",
	[ "^c13m" ] = "Cold Stream",

	-- Portal
	[ "^testchmb_a_(%d+)$" ] = "a. Test Chambers",
	[ "^testchmb_(.*)_advanced$" ] = "c. Advanced Test Chambers",
	[ "^escape_" ] = "b. GLaDOS Escape",

	-- Portal 2, TODO: Most of these should be moved up
	[ "^sp_a1_intro" ] = "a. The Courtesy Call",
	[ "sp_a1_wakeup" ] = "a. The Courtesy Call",
	[ "sp_a2_intro" ] = "a. The Courtesy Call",

	[ "sp_a2_laser_intro" ] = "b. The Cold Boot",
	[ "sp_a2_laser_stairs" ] = "b. The Cold Boot",
	[ "sp_a2_dual_lasers" ] = "b. The Cold Boot",
	[ "sp_a2_laser_over_goo" ] = "b. The Cold Boot",
	[ "sp_a2_catapult_intro" ] = "b. The Cold Boot",
	[ "sp_a2_trust_fling" ] = "b. The Cold Boot",
	[ "sp_a2_pit_flings" ] = "b. The Cold Boot",
	[ "sp_a2_fizzler_intro" ] = "b. The Cold Boot",

	[ "sp_a2_sphere_peek" ] = "c. The Return",
	[ "sp_a2_ricochet" ] = "c. The Return",
	[ "sp_a2_bridge_intro" ] = "c. The Return",
	[ "sp_a2_bridge_the_gap" ] = "c. The Return",
	[ "sp_a2_turret_intro" ] = "c. The Return",
	[ "sp_a2_laser_relays" ] = "c. The Return",
	[ "sp_a2_turret_blocker" ] = "c. The Return",
	[ "sp_a2_laser_vs_turret" ] = "c. The Return",
	[ "sp_a2_pull_the_rug" ] = "c. The Return",

	[ "sp_a2_column_blocker" ] = "d. The Surprise",
	[ "sp_a2_laser_chaining" ] = "d. The Surprise",
	[ "sp_a2_triple_laser" ] = "d. The Surprise",
	[ "sp_a2_bts1" ] = "d. The Surprise",
	[ "sp_a2_bts2" ] = "d. The Surprise",

	[ "sp_a2_bts3" ] = "e. The Escape",
	[ "sp_a2_bts4" ] = "e. The Escape",
	[ "sp_a2_bts5" ] = "e. The Escape",
	[ "sp_a2_bts6" ] = "e. The Escape",
	[ "sp_a2_core" ] = "e. The Escape",

	[ "^sp_a3_0" ] = "f. The Fall",
	[ "sp_a3_jump_intro" ] = "f. The Fall",
	[ "sp_a3_bomb_flings" ] = "f. The Fall",
	[ "sp_a3_crazy_box" ] = "f. The Fall",
	[ "sp_a3_transition01" ] = "f. The Fall",

	[ "sp_a3_speed_ramp" ] = "g. The Reunion",
	[ "sp_a3_speed_flings" ] = "g. The Reunion",
	[ "sp_a3_portal_intro" ] = "g. The Reunion",
	[ "sp_a3_end" ] = "g. The Reunion",

	[ "sp_a4_intro" ] = "h. The Itch",
	[ "sp_a4_tb_intro" ] = "h. The Itch",
	[ "sp_a4_tb_trust_drop" ] = "h. The Itch",
	[ "sp_a4_tb_wall_button" ] = "h. The Itch",
	[ "sp_a4_tb_polarity" ] = "h. The Itch",
	[ "sp_a4_tb_catch" ] = "h. The Itch",
	[ "sp_a4_stop_the_box" ] = "h. The Itch",
	[ "sp_a4_laser_catapult" ] = "h. The Itch",
	[ "sp_a4_laser_platform" ] = "h. The Itch",
	[ "sp_a4_speed_tb_catch" ] = "h. The Itch",
	[ "sp_a4_jump_polarity" ] = "h. The Itch",

	[ "^sp_a4_finale" ] = "i. The Part Where...",
	[ "sp_a5_credits" ] = "i. The Part Where...",

	[ "e1912" ] = "j. Promotional",

	[ "mp_coop_start" ] = "k. Portal 2 CO-OP Calibration",

	[ "^mp_coop_lobby_" ] = "k. Portal 2 CO-OP Hubs",
	[ "^mp_coop_" ] = "k. Portal 2 CO-OP",

	-- Half-Life: Source
	[ "^t0a0" ] = "_. Hazard Course",
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

	[ "^c2a5" ] = "l. Surface Tension",
	[ "^c3a1" ] = "m. \"Forget About Freeman!\"",
	[ "^c3a2" ] = "n. Lambda Core",
	[ "^c4a2" ] = "p. Gonarch's Lair",
	[ "^c4a1(.+)$" ] = "r. Interloper",
	[ "^c4a3" ] = "s. Nihilanth",
	[ "^c5a1" ] = "t. Endgame",

	-- Half-Life 2
	[ "^d1_trainstation_0[1-4]" ] = "a. Point Insertion",
	[ "^d1_trainstation_0[5-6]" ] = "b. \"A Red Letter Day\"",

	[ "^d1_canals_0[1-5]" ] = "c. Route Kanal",

	[ "^d1_canals_0[6-9]" ] = "d. Water Hazard",
	[ "^d1_canals_1[0-3]" ] = "d. Water Hazard",

	[ "^d1_eli" ] = "e. Black Mesa East",
	[ "^d1_town" ] = "f. \"We Don't Go To Ravenholm...\"",
	[ "^d2_coast_0[1-8]" ] = "g. Highway 17",

	[ "^d2_coast_09" ] = "h. Sandtraps",
	[ "^d2_coast_1" ] = "h. Sandtraps",
	[ "^d2_prison_01" ] = "h. Sandtraps",

	[ "^d2_prison_0[2-5]" ] = "i. Nova Prospekt",
	[ "^d2_prison_0[6-8]" ] = "j. Entaglement",

	[ "^d3_c17_01" ] = "j. Entaglement",

	[ "^d3_c17_0[2-8]" ] = "k. Anticitizen One",

	[ "^d3_c17_09" ] = "l. \"Follow Freeman!\"",
	[ "^d3_c17_1" ] = "l. \"Follow Freeman!\"",

	[ "^d3_citadel" ] = "m. Our Benefactors",
	[ "^d3_breen" ] = "n. Dark Energy",

	[ "^background" ] = "Backgrounds",
	[ "^ep1_background" ] = "Backgrounds",
	[ "^ep2_background" ] = "Backgrounds",

	-- Half-Life 2: Episode 1
	[ "^ep1_citadel_0[0-2]" ] = "a. Undue Alarm",
	[ "^ep1_citadel_0[3-4]" ] = "b. Direct Intervention",
	[ "^ep1_c17_00" ] = "c. Lowlife",
	[ "^ep1_c17_0[1-2]" ] = "d. Urban Flight",
	[ "^ep1_c17_0[5-6]" ] = "e. Exit 17",

	-- Half-Life 2: Episode 2
	[ "^ep2_outland_01" ] = "a. To the White Forest",
	[ "^ep2_outland_0[2-4]" ] = "b. This Vortal Coil",
	[ "^ep2_outland_0[5-6]$" ] = "c. Freeman Pontifex",
	[ "^ep2_outland_06a" ] = "d. Riding Shotgun",
	[ "^ep2_outland_0[7-8]" ] = "d. Riding Shotgun",

	[ "^ep2_outland_09" ] = "e. Under the Radar",
	[ "^ep2_outland_10" ] = "e. Under the Radar",
	[ "^ep2_outland_1[1-2]$" ] = "f. Our Mutual Fiend",
	[ "^ep2_outland_12a" ] = "g. T-Minus One",
}

--
-- Hidden maps
--

local IgnorePatterns = {
	"^background",
	"^devtest",
	"^ep1_background",
	"^ep2_background",
	"^styleguide",
	"^sdk_",
	"^test_",
	"^vst_",
}

local IgnoreMaps = {
	c4a1y = true,
	credits = true,
	d2_coast_02 = true,
	d3_c17_02_camera = true,
	ep1_citadel_00_demo = true,
	intro = true,
	test = true,
}

-- Hide single player games from gamemode map list, their maps have their own game category
local IgnoreGames = {
	[ 220 ] = true, -- HL2
	[ 280 ] = true, -- HL:S
	[ 340 ] = true, -- HL2:LC
	[ 380 ] = true, -- HL2:EP1
	[ 400 ] = true, -- P
	[ 420 ] = true, -- HL2:EP2
	[ 500 ] = true, -- L4D
	[ 550 ] = true, -- L4D2
	[ 620 ] = true, -- P2
	[ 251110 ] = true, -- INFRA
	[ 221910 ] = true, -- Stanley Parable
	[ 362890 ] = true, -- Black Mesa
}

-- Maps from these games cannot be loaded in Garry's Mod
local IncompatibleGames = {
	--[ 550 ] = true, -- L4D2
	--[ 620 ] = true, -- P2
	--[ 730 ] = true, -- CSGO
}

--
-- Map lists
--

local MapList = {}
local GameMapList = {}

-- TODO: ConVar for hiding bad maps

local function IsUselessMap( map_name )
	local Ignore = IgnoreMaps[ map_name ]
	if ( Ignore ) then return true end

	for _, ignore in ipairs( IgnorePatterns ) do
		if ( string.find( map_name, ignore ) ) then
			return true
		end
	end

	return false
end

local function AddMapInfo( map_info, cat, cat_name, cat_table )
	if ( !cat_table[ cat ] ) then cat_table[ cat ] = { name = cat_name, maps = {} } end

	-- I hate this, I hate that CS:GO and CS:S have same map names!
	for id, t in pairs( cat_table[ cat ].maps ) do
		if ( t.name == map_info.name ) then return end
	end

	table.insert( cat_table[ cat ].maps, map_info ) -- TODO: Perhaps make the key the map name?
end

RefreshMaps = function( skip )

	if ( !skip ) then UpdateGamemodeMaps() end

	MapList = {}
	GameMapList = {}
	local ExistingMaps = {}

	local games = engine.GetGames()
	table.insert( games, { title = "Garry's Mod", depot = 4000, folder = "MOD", mounted = true } )
	table.insert( games, { title = "Addons", depot = 0, folder = "thirdparty", mounted = true } )
	table.insert( games, { title = "Downloaded Maps", depot = -1, folder = "DOWNLOAD", mounted = true } )
	table.insert( games, { title = "mount.cfg", depot = -2, folder = "GAME", mounted = true } ) -- Must be last!
	-- Note: "Games" map categories are bundled by depotID, not folder/title!

	-- Can't do this unfortunately
	--[[for pathid, path in pairs( util.KeyValuesToTable( file.Read( "cfg/mount.cfg", "MOD" ) ) ) do
		print( pathid, path )
		PrintTable( file.Find( "maps/*.bsp", pathid ) )
		table.insert( games, { title = pathid .. " (mount.cfg)", depot = 0, folder = pathid, mounted = true } )
	end]]

	for id, tab in pairs( games ) do
		if ( !tab.mounted ) then continue end

		local maps = file.Find( "maps/*.bsp", tab.folder )

		for k, v in ipairs( maps ) do
			local map_name = string.gsub( v, "%.bsp$", "" ):lower()
			local prefix = string.match( map_name, "^(.-_)" )

			if ( tab.folder == "GAME" ) then
				if ( ExistingMaps[ map_name ] ) then continue end
			else
				ExistingMaps[ map_name ] = true
			end

			-- Don't add useless maps
			if ( IsUselessMap( map_name ) ) then continue end

			-- Map info
			local map_info = {
				name = map_name,
				incompatible = IncompatibleGames[ tab.depot ], -- Ideally this should be replaced with BSP version numbers
				--useless = IsUselessMap( map_name ) -- Maybe it should be done like this instead?
			}

			-- Add map to the game list
			AddMapInfo( map_info, tab.depot, tab.title, GameMapList )

			-- Ignore maps from certain games
			if ( IgnoreGames[ tab.depot ] ) then continue end

			-- For a full list of maps we don't want to process already processed maps
			--[[if ( tab.folder == "GAME" ) then
				if ( ExistingMaps[ map_name ] ) then continue end
			end]]

			-- Give the map a category
			local Category = MapNames[ map_name ] or MapNames[ prefix ]
			if ( !Category ) then
				local patterns = table.Merge( table.Copy( MapGamemodes ), MapPatterns )
				for pattern, category in pairs( patterns ) do
					if ( string.find( map_name, pattern ) ) then
						Category = category
					end
				end
			end

			-- Throw all uncategorised maps into "Other"
			Category = Category or "Other"

			-- Favourite maps
			if ( IsMapFavourite( map_name ) ) then
				AddMapInfo( map_info, "Favourites", "Favourites", MapList )
			end

			AddMapInfo( map_info, Category, Category, MapList )
		end
	end

end

hook.Add( "MenuStart", "FindMaps", RefreshMaps )
hook.Add( "GameContentChanged", "RefreshMaps", RefreshMaps )

function GetMapCategories( catType )
	local output = {}

	-- This could be done better, but I will leave it like this for now
	if ( catType == "game" ) then
		for cat, tab in pairs( GameMapList ) do
			if ( !tab or !tab.maps or #tab.maps < 1 ) then continue end
			output[ cat ] = tab.name
		end
	else
		for cat, tab in pairs( MapList ) do
			if ( !tab or !tab.maps or #tab.maps < 1 ) then continue end
			output[ cat ] = tab.name
		end
	end

	return output
end

local function map_cat_helper( map, search_t )
	for cat, tab in pairs( search_t ) do
		if ( !tab or !tab.maps or #tab.maps < 1 ) then continue end

		for _, map_t in pairs( tab.maps ) do
			if ( map_t.name == map:lower() ) then
				return cat
			end
		end
	end
end

function GetMapCategory( map )
	local r = map_cat_helper( map, MapList )
	if ( !r ) then r = map_cat_helper( map, GameMapList ) end
	return r
end

function GetMapsFromCategory( cat )
	if ( !DoesCategoryExist( cat ) ) then return {} end

	local maps = MapList[ cat ] and MapList[ cat ].maps or {}
	if ( #maps < 1 ) then maps = GameMapList[ tonumber( cat ) ] and GameMapList[ tonumber( cat ) ].maps or {} end
	return maps
end

function DoesCategoryExist( cat )
	if ( !MapList[ cat ] and !GameMapList[ tonumber( cat ) ] ) then return false end
	return true
end

function DoesMapExist( map )
	return file.Exists( "maps/" .. map .. ".bsp", "GAME" )
end

function GetMapSubCategories()
	local subCats = table.Copy( MapSubCategories )
	local subCatPatterns = table.Copy( MapPatternSubCategories )

	for pattern, catName in pairs( MapPatterns ) do
		subCatPatterns[ pattern ] = catName
	end

	for pattern, catName in pairs( MapGamemodes ) do
		subCatPatterns[ pattern ] = catName
	end

	for prefix, catName in pairs( MapNames ) do
		if ( prefix:EndsWith( "_" ) ) then
			if ( subCatPatterns[ "^" .. prefix ] ) then print( "Prefix " .. prefix .. " has 2 categories '" .. subCatPatterns[ "^" .. prefix ] .. "' and '" .. catName .. "'!" ) end
			subCatPatterns[ "^" .. prefix ] = catName
		else
			if ( subCatPatterns[ prefix ] ) then print( "Map " .. prefix .. " has 2 categories '" .. subCatPatterns[ prefix ] .. "' and '" .. catName .. "'!" ) end
			subCats[ prefix ] = catName
		end
	end

	return subCats, subCatPatterns
end

--
-- Last Map
--

function SaveLastMap( map, cat )

	local t = string.Explode( ";", cookie.GetString( "lastmap", "" ) )
	if ( !map ) then map = t[ 1 ] or "gm_flatgrass" end
	if ( !cat ) then cat = t[ 2 ] or "Sandbox" end

	cookie.Set( "lastmap", map .. ";" .. cat )

end

function LoadLastMap()

	local t = string.Explode( ";", cookie.GetString( "lastmap", "" ) )

	local map = t[ 1 ] or "gm_flatgrass"
	local cat = t[ 2 ] or "Sandbox"

	-- Game categories are stored as numbers!
	cat = tonumber( cat ) or cat

	if ( !DoesMapExist( map ) ) then
		map = "gm_flatgrass"
		cat = "Sandbox"
	end

	return map, cat

end
