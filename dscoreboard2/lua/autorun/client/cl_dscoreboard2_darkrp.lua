
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

local function DUpdateUserLabels(self, ply)
	if not DarkRP then return end
	self.pnls.team:SetText('Job: ' .. team.GetName(ply:Team()))
	self.pnls.job:SetText('Job Title: ' .. (ply:getDarkRPVar('job') or team.GetName(ply:Team())))
	
	if LocalPlayer():IsAdmin() then
		self.pnls.money:SetText('Money: ' .. DarkRP.formatMoney(ply:getDarkRPVar('money') or 0))
		self.pnls.salary:SetText('Salary: ' .. DarkRP.formatMoney(ply:getDarkRPVar('salary') or 0))
		self.pnls.hunger:SetText('Hunger: ' .. (ply:getDarkRPVar('Energy') and (math.ceil(ply:getDarkRPVar('Energy')) .. '%') or 'Hungermod is not installed'))
	end
end

local function DPopulateUserLabels(self)
	if not DarkRP then return end
	self:CreateInfoLabel('job', 'Job:')
	
	if LocalPlayer():IsAdmin() then
		self:CreateInfoLabel('money', 'Wallet:')
		self:CreateInfoLabel('salary', 'Salary:')
		self:CreateInfoLabel('hunger', 'Hunger:')
	end
end

local function DRUpdateUserLabels(self, ply, vars)
	vars.teamname = ply:getDarkRPVar('job') or team.GetName(vars.team)
end

hook.Add('DPopulateUserLabels', 'DarkRP', DPopulateUserLabels)
hook.Add('DUpdateUserLabels', 'DarkRP', DUpdateUserLabels)
hook.Add('DRUpdateUserLabels', 'DarkRP', DRUpdateUserLabels)
