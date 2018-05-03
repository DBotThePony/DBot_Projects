
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

gui.dsit.friend = 'DSit Freund'

message.dsit.sit.toofast = 'Du bewegst dich zu schnell!'

message.dsit.check.pitch = 'Ungültiger Sitzwinkel (Neigung ist %i  wenn sollte <> +-20 oder -180)'
message.dsit.check.roll = 'Ungültiger Sitzwinkel (Roll ist %i wenn sollte <> +-20)'
message.dsit.check.unreachable = 'Position ist unerreichbar'

message.dsit.status.entities = 'Das Sitzen auf Entities ist deaktiviert.'
message.dsit.status.npc = 'Du kannst nicht auf NPCs sitzen.'
message.dsit.status.toofast = 'Das Ziel bewegt sich zu schnell!'
message.dsit.status.recursion = 'Du kannst nicht auf einer Person sitzen die auf dir sitzt'
message.dsit.status.nolegs = 'Das Sitzen auf den Beinen des Spielers ist deaktiviert'
message.dsit.status.noplayers = 'Das Sitzen auf Spielern ist deaktiviert'
message.dsit.status.diasallowed = 'Das Sitzen auf diesen Spieler ist nicht erlaubt'
message.dsit.status.friendsonly = 'Einer oder beide Spieler haben cl_dsit_friendsonly auf 1 gesetzt und ihr seid keine Freunde'
message.dsit.status.nonowned = 'Das Sitzen ist nur auf nicht besitzenden entities erlaubt'
message.dsit.status.onlyowned = 'Das Sitzen ist nur auf entities erlaubt die dir gehören'
message.dsit.status.restricted = 'Dieser Spieler hat die Anzahl der sitzenden Spieler beschränkt'
message.dsit.status.hook = 'Du kannst jetzt nicht sitzen'

info.dsit.nopos = 'Es wurde keine Position gefunden, du wirst zur letzten bekannten Position zurückgebracht....'

gui.dsit.menu.author = 'DSit wurde erstellt von DBotThePony'
gui.dsit.menu.sitonme = 'Erlaube auf mich zu setzen'
gui.dsit.menu.friendsonly = 'Erlaube nur für Freunde'
gui.dsit.menu.getoff_check = 'Prüfe auf "get off" Nachrichten im Chat'
gui.dsit.menu.max = 'Max Spieler auf dir'
gui.dsit.menu.getoff = 'Hol den Spieler von Dir runter'
