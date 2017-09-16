
--[[
Copyright (C) 2015 DBot

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
]]

function ulx.bloodmoon( calling_ply )
	if !GetGlobalBool("BloodMoon") then 
		BloodMoon.Start()
		ulx.fancyLogAdmin( calling_ply, "#A Started Bloodmoon" )
	else
		BloodMoon.End()
		ulx.fancyLogAdmin( calling_ply, "#A Stopped Bloodmoon" )
	end
end
local bloodmoon = ulx.command( "DFun", "ulx bloodmoon", ulx.bloodmoon, "!bloodmoon" )
bloodmoon:defaultAccess( ULib.ACCESS_ADMIN )
bloodmoon:help( "BLOODMOON IS RISING" )

function ulx.Eclipse( calling_ply )
	if !GetGlobalBool("Eclipse") then 
		BloodMoon.StartEclipse()
		ulx.fancyLogAdmin( calling_ply, "#A Started Eclipse" )
	else
		BloodMoon.EndEclipse()
		ulx.fancyLogAdmin( calling_ply, "#A Stopped Eclipse" )
	end
end
local Eclipse = ulx.command( "DFun", "ulx eclipse", ulx.Eclipse, "!eclipse" )
Eclipse:defaultAccess( ULib.ACCESS_ADMIN )
Eclipse:help( "A SOLAR EXLIPSE IS HAPPENING" )

