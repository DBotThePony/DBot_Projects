
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

--It meant to be altirely
--But i didn't finished it
ENT.PrintName = 'DBot Artilery Sentry'
ENT.Author = 'DBot'
ENT.Type = 'anim'
ENT.Base = 'dbot_sentry'

function ENT:SetupDataTables()
	self:NetworkVar('Bool', 0, 'IsLocking')
	self:NetworkVar('Entity', 0, 'LockTarget')
	self:NetworkVar('Float', 0, 'LockTime')
end