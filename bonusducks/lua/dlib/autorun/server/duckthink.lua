
-- Copyright (C) 2016-2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

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
