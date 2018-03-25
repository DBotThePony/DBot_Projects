
-- Copyright (C) 2017-2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local DDayNight = DDayNight
local DLib = DLib
local net = net
local hook = hook

net.receive('ddaynight.replicateseed', function()
	local old = DDayNight.SEED_VALID
	DDayNight.SEED_VALID = net.ReadUInt(64)

	if old ~= DDayNight.SEED_VALID then
		hook.Run('DDayNight_SeedChanges', old, DDayNight.SEED_VALID)
	end
end)

if IsValid(LocalPlayer()) then
	net.Start('ddaynight.replicateseed')
	net.SendToServer()
else
	local frame = 0
	hook.Add('Think', 'DDayNight_RequestSeed', function()
		if not IsValid(LocalPlayer()) then return end

		frame = frame + 1
		if frame < 200 then return end

		hook.Remove('Think', 'DDayNight_RequestSeed')
		net.Start('ddaynight.replicateseed')
		net.SendToServer()
	end)
end
