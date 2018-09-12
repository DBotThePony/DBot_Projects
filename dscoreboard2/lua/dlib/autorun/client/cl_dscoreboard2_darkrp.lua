
--[[
Copyright (C) 2016-2018 DBot


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
    if not DarkRP then return end
    vars.teamname = ply:getDarkRPVar('job') or team.GetName(vars.team)
end

local function Row(self, ply)
    if not DarkRP then return end
    local wanted = self:Add('DLabel')
    wanted:Dock(RIGHT)
    wanted:SetTextColor(color_white)
    wanted:SetText('Wanted!')
    wanted:SetFont('DScoreBoard2.Button')

    wanted.Think = function()
        if not IsValid(ply) then return end

        if not ply.isWanted or not ply:isWanted() then
            wanted:SetText('')
        else
            wanted:SetText('Wanted!')
        end
    end
end

hook.Add('DScoreBoard2_PlayerRow', 'DarkRP', Row)
hook.Add('DPopulateUserLabels', 'DarkRP', DPopulateUserLabels)
hook.Add('DUpdateUserLabels', 'DarkRP', DUpdateUserLabels)
hook.Add('DRUpdateUserLabels', 'DarkRP', DRUpdateUserLabels)
