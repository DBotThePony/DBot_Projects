
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

include 'shared.lua'

import render, Material from _G
import SuppressEngineLighting, ModelMaterialOverride, ResetModelLighting, SetColorModulation from render

debugwtite = Material('models/debug/debugwhite')
ENT.Draw = =>
	SuppressEngineLighting(true)
	ModelMaterialOverride(debugwtite)
	ResetModelLighting(1, 1, 1)
	col = @GetColor()
	SetColorModulation(col.r / 255, col.g / 255, col.b / 255)
	@DrawModel()
	ModelMaterialOverride()
	SuppressEngineLighting(false)
