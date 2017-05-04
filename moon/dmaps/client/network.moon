
--
-- Copyright (C) 2017 DBot
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 

import DMaps, net from _G
net.Receive 'DMaps.AdminEcho', -> DMaps.Message(unpack(DMaps.ReadArray()))
net.Receive 'DMaps.ConsoleMessage', -> DMaps.Message(unpack(DMaps.ReadArray()))
net.Receive 'DMaps.ChatMessage', -> DMaps.ChatPrint(unpack(DMaps.ReadArray()))
net.Receive 'DMaps.Notify', ->
    Type = net.ReadUInt(8)
    Time = net.ReadUInt(8)
    Contents = DMaps.ReadArray()
    DMaps.Notify(Contents, Type, Time)