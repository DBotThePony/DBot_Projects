
-- Copyright (C) 2016-2019 DBot

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


local DBOT_ACTIVE_DUCKS
local DBOT_ACTIVE_BEER
local player = player
local IsValid = IsValid
local ipairs = ipairs

local function Think()
	DBOT_ACTIVE_DUCKS = DBOT_ACTIVE_DUCKS or _G.DBOT_ACTIVE_DUCKS
	DBOT_ACTIVE_BEER = DBOT_ACTIVE_BEER or _G.DBOT_ACTIVE_BEER
	if #DBOT_ACTIVE_DUCKS == 0 and #DBOT_ACTIVE_BEER == 0 then return end
	local plys = player.GetAll()

	local positions = {}
	local toRemoveDucks, toRemoveBeer

	for k, v in pairs(plys) do
		if v:Alive() then
			table.insert(positions, {v, v:GetPos()})
		end
	end

	for i, self in ipairs(DBOT_ACTIVE_DUCKS) do
		if IsValid(self) then
			local lpos = self:GetPos()

			if self.CreatedAt + 0.4 < CurTimeL() then
				local hit = false

				for i2, data in ipairs(positions) do
					local ply, pos = data[1], data[2]
					if pos:Distance(lpos) < 70 then
						local can = hook.Run('CanCollectDuck', ply, self, pos, lpos)
						if can ~= false then
							self:Collect(ply)
							hit = true
							break
						end
					end
				end

				if not hit and self.Expires < CurTimeL() then
					self:Remove()
					toRemoveDucks = toRemoveDucks or {}
					table.insert(toRemoveDucks, i)
				end
			end
		else
			toRemoveDucks = toRemoveDucks or {}
			table.insert(toRemoveDucks, i)
		end
	end

	for i, self in ipairs(DBOT_ACTIVE_BEER) do
		if IsValid(self) then
			local lpos = self:GetPos()

			if self.CreatedAt + 0.4 < CurTimeL() then
				local hit = false

				for i2, data in ipairs(positions) do
					local ply, pos = data[1], data[2]
					if pos:Distance(lpos) < 70 then
						local can = hook.Run('CanCollectBeer', ply, self, pos, lpos)
						if can ~= false then
							self:Collect(ply)
							hit = true
							break
						end
					end
				end

				if not hit and self.Expires < CurTimeL() then
					self:Remove()
					toRemoveBeer = toRemoveBeer or {}
					table.insert(toRemoveBeer, i)
				end
			end
		else
			toRemoveBeer = toRemoveBeer or {}
			table.insert(toRemoveBeer, i)
		end
	end

	if toRemoveDucks then
		table.removeValues(DBOT_ACTIVE_DUCKS, toRemoveDucks)
	end

	if toRemoveBeer then
		table.removeValues(DBOT_ACTIVE_BEER, toRemoveBeer)
	end
end

hook.Add('Think', 'DBot_BONUS_DUCKS', Think)
