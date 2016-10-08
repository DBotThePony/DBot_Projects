
--[[
This file is just a web downloader. You can use it to download a DHUD2 to player or server
Easy way to load DHUD2 on server: Run Lua string: http.Fetch('http://80.83.200.79/dhud2/webloader.lua',function(b)CompileString(b,'DHUD2')()end)
ulx luarun "http.Fetch('http://80.83.200.79/dhud2/webloader.lua',function(b)CompileString(b,'DHUD2')()end)"
lua_run_cl http.Fetch("http://80.83.200.79/dhud2/webloader.lua",function(b)CompileString(b,"DHUD2")()end)
]]

local LOAD_MEM = {}

function DHUD2_DoInclude(File)
	File = File:gsub('dhud/', '')
	if not LOAD_MEM[File] then MsgC('[DHUD2 Web Loader] No such file: ' .. File .. '\n') return end
	local Contents = LOAD_MEM[File]
	Contents = Contents:gsub('include', 'DHUD2_DoInclude')
	
	RunString(Contents, '[DHUD2 Web Loader: ' .. File .. ']')
end

local URL = 'http://80.83.200.79/dhud2/'
local Files = {
	'cl_init.lua',
	'cl_crosshair.lua',
	'cl_default.lua',
	'cl_freecam.lua',
	'cl_highlight.lua',
	'cl_history.lua',
	'cl_minimap.lua',
	'cl_playericon.lua',
	'cl_playerinfo.lua',
	'cl_radar.lua',
	'cl_view.lua',
	'sh_init.lua',
	'sv_init.lua',
}

for k, v in pairs(Files) do
	if CLIENT and string.sub(v, 1, 3) == 'sv_' then Files[k] = nil end
	if SERVER and string.sub(v, 1, 3) == 'cl_' then Files[k] = nil end
end

local Total = table.Count(Files)
local Done = 0

local function Try(File, Tries)
	http.Fetch(URL .. File, function(body)
		print('[DHUD2 WebLoader] File received: ', File)
		
		LOAD_MEM[File] = body
		
		Done = Done + 1
		if Done == Total then
			print('[DHUD2 WebLoader] Loading')
			DHUD2_DoInclude('sh_init.lua')
		end
	end, function(...)
		print('[DHUD2 WebLoader] Error: ', File, ...)
		if Tries > 2 then return end
		timer.Simple(4, function() Try(File, Tries + 1) end)
	end)
end

for k, v in pairs(Files) do
	timer.Simple(k * 0.2, function() Try(v, 0) end)
end

if SERVER then
	hook.Add('PlayerInitialSpawn', 'DHUD2.WebLoader', function(ply)
		timer.Simple(10, function() ply:SendLua([[http.Fetch('http://80.83.200.79/dhud2/webloader.lua',function(b)CompileString(b,'DHUD2')()end)]]) end)
	end)
	
	for k, v in pairs(player.GetAll()) do
		v:SendLua([[http.Fetch('http://80.83.200.79/dhud2/webloader.lua',function(b)CompileString(b,'DHUD2')()end)]])
	end
	
	concommand.Add('dhud_disableweb', function(ply)
		if IsValid(ply) and not ply:IsSuperAdmin() then return end
		hook.Remove('PlayerInitialSpawn', 'DHUD2.WebLoader')
	end)
end
