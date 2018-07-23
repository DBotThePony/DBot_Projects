
-- Copyright (C) 2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

if not TEXT_SCREEN_AVALIABLE_FONTS then
	DLib.Message('FATAL: Unable to find TEXT_SCREEN_AVALIABLE_FONTS for textscreens!')
	return
end

DLib.RegisterAddonName('TextScreens')

for k, font in pairs(TEXT_SCREEN_AVALIABLE_FONTS) do
	if font.definition then
		surface.CreateFont(font.id, font.definition)
	end
end
