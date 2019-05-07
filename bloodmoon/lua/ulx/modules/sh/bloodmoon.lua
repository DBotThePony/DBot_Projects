-- public domain - DBotThePony

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

