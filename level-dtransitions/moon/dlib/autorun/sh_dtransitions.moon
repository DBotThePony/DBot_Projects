
-- Copyright (C) 2019 DBot

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

export DTransitions
DTransitions = DTransitions or {}

DLib.CMessage(DTransitions, 'DTransitions')

if SERVER
	include('dtransitions/serialize.lua')
	include('dtransitions/serializer_base.lua')
	include('dtransitions/entity_serialize.lua')
	include('dtransitions/serializers/player.lua')
	include('dtransitions/serializers/prop.lua')
	include('dtransitions/serializers/weapon.lua')
	include('dtransitions/serializers/npc.lua')
	include('dtransitions/serializers/vehicle.lua')
	local sertest

	concommand.Add 'serialize_test', (ply) ->
		sertest = DTransitions.SaveInstance()\Serialize()
		return

	concommand.Add 'deserialize_test', (ply) ->
		return if not sertest
		sertest\Deserialize()

return
