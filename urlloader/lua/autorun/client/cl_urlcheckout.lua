
--[[
Copyright (C) 2016 DBot

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
	if LastCall == CurTime() then return end --If something calling OnPlayerChat twice, ignore. Also prevents link DDoS attack
	LastCall = CurTime()
	
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