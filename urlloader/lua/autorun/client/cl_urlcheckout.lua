
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

local ENABLE = CreateConVar('cl_urlcheck_enable', '1', FCVAR_ARCHIVE, 'Enable URL checkout')

local LastCall = 0
local Grey = Color(200, 200, 200)
local PrefixColor = Color(0, 200, 0)
local Prefix = '[DURL] '

local mb = 2^20
local kb = 2^10

local MAX_SIZE = 2^20

local function CheckPage(URL)
	local req = {}
	req.method = 'get'
	req.url = URL

	function req.success(code, body, headers)
		local title

		--<(t|T)(i|I)(t|T)(l|L)(e|E)>(.*)</(t|T)(i|I)(t|T)(l|L)(e|E)>
		string.gsub(body, '<title>(.*)</title>', function(w)
			title = w
		end)

		if not title then
			chat.AddText(Grey, 'Page is not titled')
		else
			chat.AddText(Grey, 'Page title: ' .. title)
		end
	end

	HTTP(req)
end

local function Checkout(URL)
	if LastCall == CurTimeL() then return end --If something calling OnPlayerChat twice, ignore. Also prevents link DDoS attack
	LastCall = CurTimeL()

	chat.AddText(Grey, 'Checking out URL...')

	local req = {}
	req.method = 'head'
	req.url = URL

	function req.success(code, body, headers)
		for k, v in pairs(headers) do
			headers[string.lower(k)] = v
		end

		if not headers['content-type'] then
			chat.AddText(Grey, 'URL failed to load: server reply is invalid!')
			MsgC(PrefixColor, Prefix, Grey, 'Invalid header: Content-Type, expected string, got nothing\n')
			return
		end

		local isText = string.find(headers['content-type'], 'text/') ~= nil

		if not isText then
			chat.AddText(Grey, 'URL is not a html page. MIME type of file is: ' .. headers['content-type'])
			return
		end

		if headers['content-length'] and tonumber(headers['content-length']) >= MAX_SIZE then
			chat.AddText(Grey, 'URL would not be loaded, file size is too big!')
			MsgC(PrefixColor, Prefix, Grey, 'Filesize is more than 1MB, size in bytes: ' .. headers['content-length'] .. ' \n')
			return
		end

		CheckPage(URL)
	end

	function req.failed(reason)
		chat.AddText(Grey, 'URL ' .. URL .. ' failed to load: ' .. reason)
	end

	HTTP(req)
end

local function Proceed(text)
	--For some reason regexp ( |$) does not work
	string.gsub(text, 'http://(.*)$', function(w)
		Checkout('http://' .. w)
	end)

	string.gsub(text, 'http://(.*) ', function(w)
		Checkout('http://' .. w)
	end)

	string.gsub(text, 'https://(.*)$', function(w)
		Checkout('https://' .. w)
	end)

	string.gsub(text, 'https://(.*) ', function(w)
		Checkout('https://' .. w)
	end)
end

local function OnPlayerChat(ply, text)
	if not ENABLE:GetBool() then return end

	timer.Simple(0, function() --Next frame
		Proceed(text)
	end)
end

hook.Add('OnPlayerChat', '!DCheckoutURL', OnPlayerChat, -2)