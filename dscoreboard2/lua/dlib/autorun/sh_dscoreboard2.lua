
--[[
Copyright (C) 2016-2018 DBot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

DScoreBoard2Ratings = {}

DScoreBoard2Ratings.Ratings = {
    'emoticon_smile',
    'group',
    'user_comment',
    'award_star_gold_1',
    'box',
    'emoticon_tongue',
    'gun',
    'heart',
    'lightning',
    'spellcheck',
    'group_error',
    'wrench',
    'information',
    'bricks',
    'bug',
    'exclamation',
    'music',
    'palette',
    'shield',
    'rainbow',
    'pill',
    'tux',
    'page_white_code',
    'eye',
    'cup',
    'coins',
    'accept',
    'arrow_redo',
}

DScoreBoard2Ratings.Help = {
    'I like this player',
    'This player is very friendly!',
    'This player is very communicative!',
    'Award for you!',
    'Player-in-a-box',
    ':P',
    'Knows how to shoot',
    'Luvs',
    'ZAP!',
    'Bad spelling',
    'This player is very aggresive!',
    'Great builder',
    'Informative person',
    'Constructs things',
    'The best bug catcher',
    'This player is very bad!',
    'The best music',
    'The best pictures',
    'This player protects me!',
    'RAINBOWS AND UNICORNS',
    'PILLS HERE',
    'I wish to give you a Linux...',
    'The best coder',
    'This player see everywhere and see everyone',
    'Cup of warm fresh tea',
    'Rich',
    'Good player in overall',
    'Easy to confuse',
}

DScoreBoard2Ratings.Names = {
    'Smile',
    'Friendly',
    'Communicative',
    'Award',
    'Box',
    ':P',
    'Gunner',
    'Love',
    'Zap!',
    'Bad spelling',
    'Not Friendly',
    'Builder',
    'Informative',
    'Constructor',
    'Bug catcher',
    'Bad player',
    'Musician',
    'Artist',
    'Protector',
    'Imagination',
    'Pills',
    'TUX',
    'Coder',
    'All seeking eye',
    'Cup of tea',
    'Coins',
    'Good Player',
    'Confused',
}

DScoreBoard2Ratings.Icons = {}

for k, v in ipairs(DScoreBoard2Ratings.Ratings) do
    DScoreBoard2Ratings.Icons[v] = 'icon16/' .. v .. '.png'
end

if CLIENT then
    DScoreBoard2Ratings.IconsCache = {}

    for k, v in pairs(DScoreBoard2Ratings.Icons) do
        DScoreBoard2Ratings.IconsCache[k] = Material(v)
    end
end

function DScoreBoard2Ratings.Register(strid, name, help, icon)
    local id = table.insert(DScoreBoard2Ratings.Ratings, strid)
    DScoreBoard2Ratings.Help[id] = help
    DScoreBoard2Ratings.Names[id] = name
    DScoreBoard2Ratings.Icons[id] = icon

    if CLIENT then
        DScoreBoard2Ratings.IconsCache[id] = Material(icon)
    end
end

timer.Simple(0, function()
    hook.Run('RegisterDScoreBoard2Ratings', DScoreBoard2Ratings.Register)
end)
