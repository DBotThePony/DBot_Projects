
--[[
Copyright (C) 2016-2019 DBotThePony


-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

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
