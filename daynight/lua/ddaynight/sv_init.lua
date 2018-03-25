
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
local IsValid = IsValid

net.pool('ddaynight.replicateseed')

local function DDayNight_SeedChanges()
	net.Start('ddaynight.replicateseed')
	net.WriteUInt(DDayNight.SEED_VALID, 64)
	net.Broadcast()
end

net.receive('ddaynight.replicateseed', function(len, ply)
	if not IsValid(ply) then return end

	net.Start('ddaynight.replicateseed')
	net.WriteUInt(DDayNight.SEED_VALID, 64)
	net.Send(ply)
end)

hook.Add('DDayNight_SeedChanges', 'DDayNight_ReplicateSeed', DDayNight_SeedChanges)
