
-- Copyright (C) 2016-2018 DBot

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

local CurTimeL = CurTimeL

local plyMeta = FindMetaTable('Player')

function plyMeta:TotalTimeConnected()
	return self:SessionTime() + self:GetNW2Float('DConnecttt_Total_OnJoin')
end

function plyMeta:SessionTime()
	return CurTimeL() - self:GetNW2Float('DConnecttt.JoinTime')
end

-- UTime interface
function plyMeta:GetUTimeSessionTime()
	return self:SessionTime()
end

-- ???
function plyMeta:GetUTime()
	return self:TotalTimeConnected()
end
-- ???
function plyMeta:GetUTimeTotalTime()
	return self:TotalTimeConnected()
end
-- ???

function plyMeta:SetUTime()
	-- Do nothing
end

function plyMeta:SetUTimeStart()
	-- Do nothing
end

function plyMeta:GetUTimeStart()
	return self:GetNW2Float('DConnecttt.JoinTime')
end
