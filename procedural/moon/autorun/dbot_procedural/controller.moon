
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

class DungeonMainRoom extends DProcedural.BasicRoom
    new: (...) => super(...)

class DungeonGeneratorController
    new: (seed = math.random(1, 1000), pos = Vector(), skin = DProcedural.BuildingSkin(@)) =>
        @seed = seed
        @skin = skin
        @random = DProcedural.Random(@seed)
        @rooms = {DungeonMainRoom(pos)}
        @CPPIOwner = NULL
        @entities = {}
    
    SetOwner: (val = NULL) =>
        @CPPIOwner = val
        for room in *@rooms
            room\SetOwner(val)
    GetOwner: => @CPPIOwner
    
    Spawn: =>
        for room in *@rooms
            room\SpawnInWorld(@entities)
        return @entities
    
    SetSeed: (val = @seed) =>
        @random\SetSeed(val)
        @seed = val

    GetSeed: => @seed
    GetSkin: => @skin

DProcedural.Generator = DungeonGeneratorController
