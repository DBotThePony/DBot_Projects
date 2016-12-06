
--[[
Copyright (C) 2016 DBot

Licensed under the Apache License, Version 2.0 (the 'License');
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an 'AS IS' BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

local function CommandClick(self)
	if not IsValid(self.target) then return end
	RunConsoleCommand('fadmin', unpack(self.args))
end

local function TopPaint(self, w, h)
	surface.SetDrawColor(DScoreBoard2.Colors.bg)
	surface.DrawRect(0, 0, w, h)
	draw.DrawText('FAdmin Commands', 'DScoreBoard2.TopInfoText', 4, 3, DScoreBoard2.Colors.textcolor)
end

local function CreateButton(parent, args)
	local button = parent:Add('DScoreBoard2_Button')
	button.args = args
	button.DoClick = CommandClick
	button:SetText(args[1]:sub(1, 1):upper() .. args[1]:sub(2))
	button:SetWide(80)
	
	return button
end

local function Populate(canvas, self, ply)
	if not FAdmin then return end
	
	local top = canvas:Add('EditablePanel')
	top:DockMargin(0, 4, 0, 0)
	top.Paint = TopPaint
	top:Dock(TOP)
	
	local grid = self:CreateGrid(100)
	local lply = LocalPlayer()
	
	-- Replicating FAdmin code
	
	local Controls = FAdmin.ScoreBoard.Player.Controls
	local PlayerControls = FAdmin.ScoreBoard.Player
	
	for k, v in ipairs(PlayerControls.ActionButtons) do
        if v.Visible == true or (type(v.Visible) == 'function' and v.Visible(PlayerControls.Player) == true) then
			local ActionButton = canvas:Add('DScoreBoard2_Button')
			grid:AddItem(ActionButton)
			ActionButton:SetWide(100)

			local name = v.Name
			
			if type(name) == 'function' then
				name = name(PlayerControls.Player)
			end
			
			ActionButton:SetText(name)

			function ActionButton:DoClick()
				if not IsValid(PlayerControls.Player) then return end
				return v.Action(PlayerControls.Player, self)
			end
			
			if v.OnButtonCreated then
				v.OnButtonCreated(PlayerControls.Player, ActionButton)
			end
        end
    end
end

hook.Add('DScoreBoard2_PlayerInfo', 'FAdmin', Populate)
hook.Add('DScoreBoard2_PlayerRow', 'FAdmin', Row)
