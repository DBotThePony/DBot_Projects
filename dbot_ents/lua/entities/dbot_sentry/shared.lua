
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

ENT.Type = 'anim'
ENT.Author = 'DBot'
ENT.Category = 'DBot'
ENT.PrintName = 'Sentry'
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.IsDSentry = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true

function ENT:SetupDataTables()
	self:NetworkVar('Int', 0, 'Frags')
	self:NetworkVar('Int', 1, 'PFrags')
end
