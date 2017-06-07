
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

-- Target color - 237, 233, 70

CriticalHitLabel = CreateMaterial('effects/minicrit_unlit', 'UnlitGeneric', {
    '$basetexture': 'effects/minicrit'
    '$ignorez': 1
    '$vertexcolor': 1
    '$vertexalpha': 1
    '$nolod': 1
})

EFFECT.Init = (effData) =>
    @realpos = Vector(effData\GetOrigin())
    @pos = Vector(effData\GetOrigin())
    @size = 2
    @r = 255
    @g = 255
    @b = 255
    @a = 255
    @shift = 0

EFFECT.Think = =>
    @size -= FrameTime() * 2 if @size > 1
    @shift += FrameTime() * 60 if @size <= 1
    delta = math.max(@size - 1, 0)
    @r = 237 + 18 * delta
    @g = 233 + 22 * delta
    @b = 70 + 185 * delta
    @pos.z = @realpos.z + @shift
    return @shift < 200

EFFECT.Render = =>
    render.SetMaterial(CriticalHitLabel)
    render.DrawSprite(@pos, 24 * @size, 24 * @size, Color(@r, @g, @b, @a))
