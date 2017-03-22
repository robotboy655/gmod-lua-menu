
--
-- Favourites
--

local MapFavorites

local function LoadFavorites()

	local cookiestr = cookie.GetString( "favmaps" )
	MapFavorites = MapFavorites || ( cookiestr && string.Explode( ";", cookiestr ) || {} )

end

function IsMapFavorite( map )

	LoadFavorites()

	return table.HasValue( MapFavorites, map )

end

local RefreshMaps

function ToggleFavorite( map )

	LoadFavorites()

	if ( table.HasValue( MapFavorites, map ) ) then -- is favorite, remove it
		table.remove( MapFavorites, table.KeysFromValue( MapFavorites, map )[1] )
	else -- not favorite, add it
		table.insert( MapFavorites, map )
	end

	cookie.Set( "favmaps", table.concat( MapFavorites, ";" ) )

	RefreshMaps( true )

	UpdateMapList()

end

--
-- Categories
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
MapNames[ "dod_" ] = "Day of Defeat"

MapNames[ "halls3" ] = "Deathmatch"

local MapGamemodes = {}

local function UpdateMaps()

	local GamemodeList = engine.GetGamemodes()

	for k, gm in ipairs( GamemodeList ) do

		local name = gm.title or "Unnammed Gamemode"
		local maps = string.Split( gm.maps, "|" )

		if ( maps && gm.maps != "" ) then

			for k, pattern in ipairs( maps ) do
				-- When in doubt, just try to match it with string.find
				MapGamemodes[ string.lower( pattern ) ] = name
			end

		end

	end

end

local IgnorePatterns = {
	"^background",
	"^devtest",
	"^ep1_background",
	"^ep2_background",
	"^styleguide",
}

local IgnoreMaps = {
	-- Prefixes
	sdk_ = true,
	test_ = true,
	vst_ = true,

	-- Maps
	c4a1y = true,
	credits = true,
	d2_coast_02 = true,
	d3_c17_02_camera = true,
	ep1_citadel_00_demo = true,
	intro = true,
	test = true
}

-- Hide single player games, their maps have their own category
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
}

local MapList = {}
local GameMapList = {}

// TODO: convar for hiding bad maps
function RefreshMaps( skip )

	if ( !skip ) then UpdateMaps() end

	MapList = {}
	GameMapList = {}

	local games = engine.GetGames()
	table.insert( games, { title = "Garry's Mod", depot = 4000, folder = "MOD", mounted = true } )

	for id, tab in SortedPairsByMemberValue( games, "title" ) do
		if ( !tab.mounted ) then continue end

		local maps = file.Find( "maps/*.bsp", tab.folder )
		if ( tab.depot == 4000 ) then
			local maps2 = file.Find( "maps/*.bsp", "thirdparty" )
			for id, map in pairs( maps2 ) do table.insert( maps, map ) end

			local maps3 = file.Find( "maps/*.bsp", "DOWNLOAD" )
			for id, map in pairs( maps3 ) do table.insert( maps, map ) end
		end

		for k, v in ipairs( maps ) do
			local name = string.lower( string.gsub( v, "%.bsp$", "" ) )
			local prefix = string.match( name, "^(.-_)" )
			local Ignore = IgnoreMaps[ name ] or IgnoreMaps[ prefix ]

			-- Don't loop if it's already ignored
			if ( Ignore ) then continue end

			for _, ignore in ipairs( IgnorePatterns ) do
				if ( string.find( name, ignore ) ) then
					Ignore = true
					break
				end
			end

			-- Don't add useless maps
			if ( Ignore ) then continue end

			if ( !GameMapList[ tab.title ] ) then GameMapList[ tab.title ] = {} end
			table.insert( GameMapList[ tab.title ], name )

			if ( IgnoreGames[ tab.depot ] ) then continue end
			//print(tab.depot, tab.title )

			-- Check if the map has a simple name or prefix
			local Category = MapNames[ name ] or MapNames[ prefix ]

			-- Check if the map has an embedded prefix, or is TTT/Sandbox
			if ( !Category ) then
				local patterns = table.Merge( table.Copy( MapGamemodes ), MapPatterns )
				for pattern, category in pairs( patterns ) do
					if ( string.find( name, pattern ) ) then
						Category = category
					end
				end
			end

			-- Throw all uncategorised maps into Other
			Category = Category or "Other"

			if ( IsMapFavourite( name ) ) then
				if ( !MapList[ "Favourites" ] ) then MapList[ "Favourites" ] = {} end
				table.insert( MapList[ "Favourites" ], name )
			end

			if ( !MapList[ Category ] ) then MapList[ Category ] = {} end
			table.insert( MapList[ Category ], name )

		end
	end

end

hook.Add( "MenuStart", "FindMaps", RefreshMaps )
hook.Add( "GameContentChanged", "RefreshMaps", RefreshMaps )

function GetMapList()
	return MapList
end

function GetGameMapList()
	return GameMapList
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

	cat = string.gsub( cat, "'", "\\'" )

	if ( !file.Exists( "maps/" .. map .. ".bsp", "GAME" ) ) then return end

	pnlMainMenu:Call( "SetLastMap('" .. map .. "','" .. cat .. "')" )

end
