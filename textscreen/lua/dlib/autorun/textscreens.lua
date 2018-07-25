
-- Copyright (C) 2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

_G.DTextScreens = DTextScreens or {}

DLib.CMessage(DTextScreens, 'DTextScreens')

CAMI.RegisterPrivilege({
	Name = 'dtextscreen_new',
	MinLevel = 'superadmin',
	Description = 'Ability to put new permanent screens'
})

CAMI.RegisterPrivilege({
	Name = 'dtextscreen_remove',
	MinLevel = 'superadmin',
	Description = 'Ability to remove existing permanent screens'
})

CAMI.RegisterPrivilege({
	Name = 'dtextscreen_reload',
	MinLevel = 'admin',
	Description = 'Ability to reload existing permanent screens from database'
})

DTextScreens.FONTS = {
	{
		name = 'PT Sans',
		id = 'textscreen.ptsans',
		definition = {
			font = 'PT Sans',
			size = 80,
			weight = 500,
			extended = true
		},
		mult = 0.6
	},
	{
		name = 'PT Sans Italic',
		id = 'textscreen.ptsans_italic',
		definition = {
			font = 'PT Sans',
			italic = true,
			size = 80,
			weight = 500,
			extended = true
		},
		mult = 0.6
	},
	{
		name = 'PT Sans Bold',
		id = 'textscreen.ptsans_bold',
		definition = {
			font = 'PT Sans',
			size = 80,
			weight = 600,
			extended = true
		},
		mult = 0.6
	},
	{
		name = 'PT Sans Bold Italic',
		id = 'textscreen.ptsans_bold_italic',
		definition = {
			font = 'PT Sans',
			italic = true,
			size = 80,
			weight = 600,
			extended = true
		},
		mult = 0.6
	},
	{
		name = 'Roboto',
		id = 'textscreen.roboto',
		definition = {
			font = 'Roboto',
			size = 80,
			weight = 500,
			extended = true
		},
		mult = 0.6
	},
	{
		name = 'Roboto Bold',
		id = 'textscreen.roboto_bold',
		definition = {
			font = 'Roboto',
			size = 80,
			weight = 600,
			extended = true
		},
		mult = 0.6
	},
	{
		name = 'Roboto Black',
		id = 'textscreen.roboto_black',
		definition = {
			font = 'Roboto',
			size = 80,
			weight = 800,
			extended = true
		},
		mult = 0.6
	},
	{
		name = 'GMod Default',
		id = 'Default',
		mult = 4
	},

	{
		name = 'Exo 2',
		id = 'textscreen.exo2',
		definition = {
			font = 'Exo 2',
			size = 80,
			weight = 500,
			extended = true
		},
		mult = 0.6
	},
	{
		name = 'Exo 2 Thin',
		id = 'textscreen.exo2_thin',
		definition = {
			font = 'Exo 2',
			size = 80,
			weight = 400,
			extended = true
		},
		mult = 0.6
	},
	{
		name = 'Exo 2 Slim',
		id = 'textscreen.exo2_slim',
		definition = {
			font = 'Exo 2 Thin',
			size = 80,
			weight = 500,
			extended = true
		},
		mult = 0.6
	},
	{
		name = 'Exo 2 Thin Italic',
		id = 'textscreen.exo2_thin_italic',
		definition = {
			font = 'Exo 2',
			size = 80,
			italic = true,
			weight = 400,
			extended = true
		},
		mult = 0.6
	},
	{
		name = 'Exo 2 Slim Italic',
		id = 'textscreen.exo2_slim_italic',
		definition = {
			font = 'Exo 2 Thin',
			size = 80,
			italic = true,
			weight = 300,
			extended = true
		},
		mult = 0.6
	},
	{
		name = 'Exo 2 Bold',
		id = 'textscreen.exo2_bold',
		definition = {
			font = 'Exo 2',
			size = 80,
			weight = 600,
			extended = true
		},
		mult = 0.6
	},
	{
		name = 'Exo 2 Black',
		id = 'textscreen.exo2_black',
		definition = {
			font = 'Exo 2',
			size = 80,
			weight = 800,
			extended = true
		},
		mult = 0.6
	},
	{
		name = 'Exo 2 Black Italic',
		id = 'textscreen.exo2_black_italic',
		definition = {
			font = 'Exo 2',
			italic = true,
			size = 80,
			weight = 800,
			extended = true
		},
		mult = 0.6
	},
}

local defaults = {
	'DebugFixed',
    'DebugFixedSmall',
    'Marlett',
    'Trebuchet18',
    'Trebuchet24',
    'HudHintTextLarge',
    'HudHintTextSmall',
    'CenterPrintText',
    'HudSelectionText',
    'CloseCaption_Normal',
    'CloseCaption_Bold',
    'CloseCaption_BoldItalic',
    'ChatFont',
    'TargetID',
    'TargetIDSmall',
    'HL2MPTypeDeath',
    'BudgetLabel',
    'HudNumbers',
}

for i, name in ipairs(defaults) do
	table.insert(DTextScreens.FONTS, {
		name = 'GMod Default: ' .. name,
		id = name,
		mult = 4,
	})
end

DTextScreens.ALIGN_CENTER = 0
DTextScreens.ALIGN_LEFT = 1
DTextScreens.ALIGN_RIGHT = 2
DTextScreens.ALIGN_TOP = 4
DTextScreens.ALIGN_BOTTOM = 8

local hook = hook
local IsValid = FindMetaTable('Entity').IsValid
local net = net
local LocalPlayer = LocalPlayer

local VEC, ANG = Vector(0, 0, 32), Angle(0, 0, 0)

properties.Add('dtextscreen_clone', {
	Type = 'simple',
	MenuLabel = 'gui.property.dtextscreens.clone',
	Order = 1919,
	MenuIcon = 'icon16/font_go.png',

	Filter = function(self, ent, ply)
		ply = ply or LocalPlayer()
		if not IsValid(ent) then return false end
		if ent:GetClass() ~= 'dbot_textscreen' then return false end
		if not ply:CheckLimit('dtextscreens') then return false end
		return hook.Run('CanProparty', ply, 'dtextscreen_clone', ent) ~= false
	end,

	Action = function(self, ent, tr)
		self:MsgStart()
		net.WriteEntity(ent)
		self:MsgEnd()
	end,

	Receive = function(self, len, ply)
		local ent = net.ReadEntity()

		if not self:Filter(ent, ply) then return false end

		if not ply:CheckLimit('dtextscreens') then return false end
		if CLIENT then return true end

		local clone = ents.Create('dbot_textscreen')

		local npos, nang = LocalToWorld(VEC, ANG, ent:GetPos(), ent:GetAngles())

		clone:SetPos(npos)
		clone:SetAngles(nang)

		undo.Create('DTextscreen')
		undo.AddEntity(clone)
		undo.SetPlayer(ply)
		undo.Finish()

		ply:AddCleanup('dtextscreen', clone)
		ply:AddCount('dtextscreens', clone)

		ent:CloneInto(clone)

		clone:Spawn()
		clone:Activate()

		return true
	end
})
