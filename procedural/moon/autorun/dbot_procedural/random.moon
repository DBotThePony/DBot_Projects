
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

-- Just a very simple number generator.

class Random
    @MAX_STATE_VALUE = 2 ^ 31 - 1
    new: (seed = 1) =>
        error('Seed == 0!') if seed == 0
        @seed = seed
        @state = 0
    
    SetSeed: (val = @seed) =>
        error('Seed == 0!') if val == 0
        @seed = val
    
    Reset: => @state = 0
    
    NextInt: (min = 0, max = 1) =>
        delta = max - min
        error('Delta < 0') if delta < 0
        @state += ((@seed + min * 2 * max - max * .5 * min) % @seed + @seed * 242 - delta * 1.5 + max * delta) % @@MAX_STATE_VALUE
        return math.floor(@state % delta + min)
    
    NextBoolean: => @NextInt(1, 100) > 50
    
    NextFloat: (min = 0, max = 1, points = 4) =>
        delta = max - min
        error('Delta < 0') if delta < 0
        error('points < 0') if points < 0
        @state += ((@seed * (1 / points) + min * points - max * (points ^ .5) + points * points) % @seed + @seed * 123 - delta * 2.25 + points * 5) % @@MAX_STATE_VALUE
        pointVal = 10 * (points + 1)
        return math.floor(@state % (delta * pointVal) + min) / pointVal
    
DProcedural.Random = Random
