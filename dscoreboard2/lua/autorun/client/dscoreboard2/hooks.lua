
--
-- Copyright (C) 2016-2017 DBot
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

local board = DScoreBoard2

local function Create(force)
	if force and IsValid(board.Board) then board.Board:Remove() end 
	if IsValid(board.Board) then return end
	
	local status, board2 = pcall(vgui.Create, 'DScoreBoard2')
	if status then
		board.Board = board2
	end
end

local function Open()
	Create()
	board.Board:DoShow()
	return true
end

local function Close()
	Create()
	board.Board:DoHide()
	return true
end

local function KeyPress(ply, key)
	if key ~= IN_ATTACK2 then return end
	if not IsValid(board.Board) then return end
	if not board.Board:IsVisible() then return end
	if board.Board.FOCUSED then return end
	board.Board:Focus()
end

board.ServerMem = 0
board.ServerTime = 0

timer.Simple(0, function()
	net.Start('DScoreBoard2.Flags')
	net.WriteString(system.GetCountry())
	net.SendToServer()
end)

concommand.Add('dscoreboard_rebuild', function() 
	Create(true)
	board.Board:DoShow()
	board.Board:Focus()
end)

concommand.Add('dscoreboard_rebuildplys', function() 
	Create()
	board.Board.list:BuildPlayerList()
end)

hook.Add('ScoreboardShow', 'DScoreBoard2', Open)
hook.Add('ScoreboardHide', 'DScoreBoard2', Close)
hook.Add('KeyPress', 'DScoreBoard2', KeyPress)

board.Connecting = board.Connecting or {}
board.Disconnected = board.Disconnected or {}
