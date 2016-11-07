
--[[
Copyright (C) 2016 DBot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

--[[
Select Sort Mode
1: Unsorted
2: Select the nearests to fire point first
3: Select the far to fire point first
4: Select x - X
5: Select X - x
6: Select y - Y
7: Select Y - y

8: Select x+y - X+Y
9: Select X+Y - x+y
10: Select x+Y - X+y
11: Select X+y - x+Y
]]

function MultiTool_Sort(mode, pos, tab)
	if not mode or mode > 11 or mode <= 1 then return tab end
	
	local PosMem = {}
	
	for i, val in ipairs(tab) do
		PosMem[val] = val:GetPos()
	end
	
	if mode == 2 then
		table.sort(tab, function(a, b)
			local pos1, pos2 = PosMem[a], PosMem[b]
			
			return pos1:DistToSqr(pos) > pos2:DistToSqr(pos)
		end)
	elseif mode == 3 then
		table.sort(tab, function(a, b)
			local pos1, pos2 = PosMem[a], PosMem[b]
			
			return pos1:DistToSqr(pos) < pos2:DistToSqr(pos)
		end)
	elseif mode == 4 then
		table.sort(tab, function(a, b)
			local pos1, pos2 = PosMem[a], PosMem[b]
			
			return pos1.x > pos2.x
		end)
	elseif mode == 5 then
		table.sort(tab, function(a, b)
			local pos1, pos2 = PosMem[a], PosMem[b]
			
			return pos1.x < pos2.x
		end)
	elseif mode == 6 then
		table.sort(tab, function(a, b)
			local pos1, pos2 = PosMem[a], PosMem[b]
			
			return pos1.y > pos2.y
		end)
	elseif mode == 7 then
		table.sort(tab, function(a, b)
			local pos1, pos2 = PosMem[a], PosMem[b]
			
			return pos1.y < pos2.y
		end)
	elseif mode == 8 then
		table.sort(tab, function(a, b)
			local pos1, pos2 = PosMem[a], PosMem[b]
			
			return pos1.y + pos1.x > pos2.y + pos2.x
		end)
	elseif mode == 9 then
		table.sort(tab, function(a, b)
			local pos1, pos2 = PosMem[a], PosMem[b]
			
			return pos1.y + pos1.x < pos2.y + pos2.x
		end)
	elseif mode == 10 then
		table.sort(tab, function(a, b)
			local pos1, pos2 = PosMem[a], PosMem[b]
			
			return pos1.x > pos2.x and pos1.y < pos2.y
		end)
	elseif mode == 11 then
		table.sort(tab, function(a, b)
			local pos1, pos2 = PosMem[a], PosMem[b]
			
			return pos1.x < pos2.x and pos1.y > pos2.y
		end)
	end
	
	return tab
end

function MultiTool_AddSorterChoices(pnl)
	pnl:AddChoice('Unsorted', '1')
	pnl:AddChoice('Select the nearests to fire point first', '2')
	pnl:AddChoice('Select the far to fire point first', '3')
	pnl:AddChoice('Select x - X', '4')
	pnl:AddChoice('Select X - x', '5')
	pnl:AddChoice('Select y - Y', '6')
	pnl:AddChoice('Select Y - y', '7')
	
	pnl:AddChoice('Select x+y - X+Y', '8')
	pnl:AddChoice('Select X+Y - x+y', '9')
	pnl:AddChoice('Select x+Y - X+y', '10')
	pnl:AddChoice('Select X+y - x+Y', '11')
end

local function PostDrawTranslucentRenderables(a, b)
	if not LocalPlayer():IsValid() then return end
	local wep = LocalPlayer():GetActiveWeapon()
	if not wep:IsValid() then return end
	
	if wep:GetClass() ~= 'gmod_tool' then return end
	
	hook.Run('PostDrawWorldToolgun', LocalPlayer(), wep, wep:GetMode())
end

if CLIENT then
	hook.Add('PostDrawTranslucentRenderables', 'MultiToolHelpers', PostDrawTranslucentRenderables)
end
