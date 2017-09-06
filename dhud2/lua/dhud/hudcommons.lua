
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

local VERSION = 201706251512

if CLIENT then
    _G.HUDCommons = _G.HUDCommons or {}
    if _G.HUDCommons and _G.HUDCommons.VERSION and _G.HUDCommons.VERSION >= VERSION then return end
    _G.HUDCommons.VERSION = VERSION
    include('hudcommons/simple_draw.lua')
    include('hudcommons/advanced_draw.lua')
    include('hudcommons/position.lua')
    include('hudcommons/menu.lua')
    include('hudcommons/functions.lua')
    include('hudcommons/colors.lua')
    include('hudcommons/matrix.lua')
else
    AddCSLuaFile('hudcommons/simple_draw.lua')
    AddCSLuaFile('hudcommons/advanced_draw.lua')
    AddCSLuaFile('hudcommons/position.lua')
    AddCSLuaFile('hudcommons/menu.lua')
    AddCSLuaFile('hudcommons/functions.lua')
    AddCSLuaFile('hudcommons/colors.lua')
    AddCSLuaFile('hudcommons/matrix.lua')
end
