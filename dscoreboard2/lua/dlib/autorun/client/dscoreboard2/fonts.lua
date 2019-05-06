
--
-- Copyright (C) 2016-2019 DBotThePony

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


DScoreBoard2.FONT_SERVERTITLE = 'DScoreBoard2.ServerTitle'
DScoreBoard2.FONT_MOUSENOTIFY = 'DScoreBoard2.MouseNotify'
DScoreBoard2.FONT_TOPINFO = 'DScoreBoard2.TopInfoText'
DScoreBoard2.FONT_BOTTOMINFO = 'DScoreBoard2.BottomInfoText'
DScoreBoard2.FONT_PLAYERINFO = 'DScoreBoard2.PlayerInfoText'
DScoreBoard2.FONT_BUTTONFONT = 'DScoreBoard2.Button'
DScoreBoard2.FONT_RATING = 'DScoreBoard2.Ratings'

surface.CreateFont(DScoreBoard2.FONT_SERVERTITLE, {
    font = 'Roboto',
    size = 50,
    extended = true,
    weight = 800,
})

surface.CreateFont(DScoreBoard2.FONT_MOUSENOTIFY, {
    font = 'Roboto',
    size = 30,
    extended = true,
    weight = 500,
})

surface.CreateFont(DScoreBoard2.FONT_TOPINFO, {
    font = 'Roboto',
    size = 16,
    extended = true,
    weight = 600,
})

surface.CreateFont(DScoreBoard2.FONT_BOTTOMINFO, {
    font = 'Roboto',
    size = 13,
    extended = true,
    weight = 500,
})

surface.CreateFont(DScoreBoard2.FONT_PLAYERINFO, {
    font = 'Roboto',
    size = 16,
    extended = true,
    weight = 500,
})

surface.CreateFont(DScoreBoard2.FONT_BUTTONFONT, {
    font = 'Roboto',
    size = 16,
    extended = true,
    weight = 500,
})

surface.CreateFont(DScoreBoard2.FONT_RATING, {
    font = 'Roboto',
    size = 12,
    extended = true,
    weight = 500,
})