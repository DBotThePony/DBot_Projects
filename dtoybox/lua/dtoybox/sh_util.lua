
-- Copyright (C) 2018-2019 DBotThePony

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

local HTTP = HTTP
local Promise = DLib.Promise
local DToyBox = DToyBox
local DLib = DLib
local util = util
local assert = assert
local type = type

function DToyBox.GetFileInfo(wsid)
	assert(type(wsid) == 'number', 'WorkshopID must be a number!')
	assert(wsid > 0, 'Invalid workshopid')

	return Promise(function(resolve, reject)
		local req = {
			url = VLL2.WSBundle.INFO_URL,
			method = 'POST',
			parameters = {itemcount = '1', ['publishedfileids[0]'] = tostring(wsid)}
		}

		function req.failed(reason)
			reject(reason)
		end

		function req.success(code, body, headers)
			if code ~= 200 then
				reject('Server returned ' .. code)
				return
			end

			local resp = util.JSONToTable(body)

			if not resp or not resp.response or not resp.response.publishedfiledetails or not resp.response.publishedfiledetails[1] then
				reject('Invalid data received')
				return
			end

			resolve({
				item = resp.response.publishedfiledetails[1],
				isCollection = resp.response.publishedfiledetails[1].creator_app_id == 766
			})
		end

		HTTP(req)
	end)
end

function DToyBox.CreateWSObject(wsid)
	assert(type(wsid) == 'number', 'WorkshopID must be a number!')
	assert(wsid > 0, 'Invalid workshopid')

	return Promise(function(resolve, reject)
		DToyBox.GetFileInfo(wsid):Then(function(itemdata)
			if itemdata.isCollection then
				resolve(VLL2.WSCollection)
			else
				resolve(VLL2.WSBundle)
			end
		end):Catch(reject)
	end)
end
