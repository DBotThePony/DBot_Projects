
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

gui.dsit.friend = 'DSit Friend'

message.dsit.sit.toofast = 'You are moving too fast!'

message.dsit.check.pitch = 'Invalid sitting angle (pitch is %i when should <> +-20 or -180)'
message.dsit.check.roll = 'Invalid sitting angle (roll is %i when should <> +-20)'
message.dsit.check.unreachable = 'Position is unreachable'

message.dsit.status.entities = 'Sitting on entities is disabled'
message.dsit.status.npc = 'You cant sit on NPCs'
message.dsit.status.toofast = 'Target is moving too fast!'
message.dsit.status.recursion = 'You cant sit on a person who sits on you'
message.dsit.status.nolegs = 'Sitting on players legs is disabled'
message.dsit.status.noplayers = 'Sitting on players is disabled'
message.dsit.status.diasallowed = 'Target player disallowed sitting on him'
message.dsit.status.friendsonly = 'One or both of players has cl_dsit_friendsonly set to 1 and you are not friends'
message.dsit.status.nonowned = 'Sitting is allowed only on non owned entities'
message.dsit.status.onlyowned = 'Sitting is allowed only on entities owned by you'
message.dsit.status.restricted = 'Target player restricted amount of sitting on him'
message.dsit.status.hook = 'You can not sit right now'

info.dsit.nopos = 'No position were detected, returning you to last known position...'

gui.dsit.menu.author = 'DSit done by DBotThePony'
gui.dsit.menu.sitonme = 'Allow to sit on me'
gui.dsit.menu.friendsonly = 'Allow only for friends'
gui.dsit.menu.getoff_check = 'Check for "get off" message in chat'
gui.dsit.menu.max = 'Max players on you'
gui.dsit.menu.getoff = 'Get off player on you'
