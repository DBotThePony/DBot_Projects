
--Pic

local function BuildMenuFor(ent)
	local x, y, xs, ys = DLib.GenerateWindow(100, 100)
	local frame = vgui.Create('DFrame')
	frame:SetPos(x, y)
	frame:SetSize(xs, ys)
	frame:SetTitle('Picture selection')
	frame:SetDraggable( true )
	frame:MakePopup()
	
	local Button = vgui.Create('DButton', frame)
	
	Button:SetText('')
	Button.Paint = function() end
	Button:Dock(BOTTOM)
	Button:SetSize(0, 256)
	
	local HTML = vgui.Create('HTML', Button)
	HTML:Dock(FILL)
	
	HTML:SetMouseInputEnabled(false)
	HTML:SetKeyBoardInputEnabled(false)
	
	local currenturl = ''
	
	function Button:DoClick()
		local frame = vgui.Create('DFrame')
		frame:SetPos( x, y )
		frame:SetSize( xs, ys )
		frame:SetTitle( 'Picture view' )
		frame:SetDraggable( true )
		frame:MakePopup()
		
		local HTML = vgui.Create('HTML', frame)
		HTML:Dock(FILL)
		
		local url = currenturl
		
		local width = xs
		local height = ys
		local page = [[
			<html>
			<head>
			<style>
			body {
			  margin: 0;
			  padding: 0;
			  border: 0;
			  background-color: rgba(50%, 50%, 50%, 0.0);
			  overflow: hidden;
			}
			td {
			  text-align: center;
			  vertical-align: middle;
			}
			</style>
			
			<script type='text/javascript'>
			var keepResizing = true;
			function resize(obj) {
			  var ratio = obj.width / obj.height;
			  if (]] .. width .. [[ / ]] .. height .. [[ > ratio) {
				obj.style.width = (]] .. height .. [[ * ratio) + 'px';
			  } else {
				obj.style.height = (]] .. width .. [[ / ratio) + 'px';
			  }
			}
			setInterval(function() {
			  if (keepResizing && document.images[0]) {
				resize(document.images[0]);
			  }
			}, 1000);
			</script>
			</head>
			<body>
				<div style='width: ]] .. width .. [[px; height: ]] .. height .. [[px; overflow: hidden'>
					<table border='0' cellpadding='0' cellmargin='0' style='width: ]] .. width .. [[px; height: ]] .. height .. [[px'>
						<tr>
							<td style='text-align: center'>
							<img src=']] .. url .. [[' alt='' onload='resize(this); keepResizing = false' style='margin: auto' />
						</td>
						</tr>
					</table>
				</div>
			</body>
			</html>
		]]
		
		HTML:SetHTML(page)
	end
	
	local List = vgui.Create('DListView', frame)
	List:Dock(FILL)
	List:AddColumn('URL')
	
	List.DoDoubleClick = function(self, index, row)
		if not IsValid(ent) then
			frame:Remove()
			return
		end
		
		net.Start('DPictureSet')
		net.WriteEntity(ent)
		net.WriteInt(index, 16)
		net.SendToServer()
		
		frame:Remove()
	end
	
	List.OnRowSelected = function(self, index, row)
		local url = row:GetValue(1)
		
		local width = xs
		local height = 256
		local page = [[
			<html>
			<head>
			<style>
			body {
			  margin: 0;
			  padding: 0;
			  border: 0;
			  background-color: rgba(50%, 50%, 50%, 0.0);
			  overflow: hidden;
			}
			td {
			  text-align: center;
			  vertical-align: middle;
			}
			</style>
			
			<script type='text/javascript'>
			var keepResizing = true;
			function resize(obj) {
			  var ratio = obj.width / obj.height;
			  if (]] .. width .. [[ / ]] .. height .. [[ > ratio) {
				obj.style.width = (]] .. height .. [[ * ratio) + 'px';
			  } else {
				obj.style.height = (]] .. width .. [[ / ratio) + 'px';
			  }
			}
			setInterval(function() {
			  if (keepResizing && document.images[0]) {
				resize(document.images[0]);
			  }
			}, 1000);
			</script>
			</head>
			<body>
				<div style='width: ]] .. width .. [[px; height: ]] .. height .. [[px; overflow: hidden'>
					<table border='0' cellpadding='0' cellmargin='0' style='width: ]] .. width .. [[px; height: ]] .. height .. [[px'>
						<tr>
							<td style='text-align: center'>
							<img src=']] .. url .. [[' alt='' onload='resize(this); keepResizing = false' style='margin: auto' />
						</td>
						</tr>
					</table>
				</div>
			</body>
			</html>
		]]
		
		HTML:SetHTML(page)
		
		currenturl = url
	end
	
	for k, v in pairs(__DPicturePics) do
		List:AddLine(v)
	end
end

net.Receive('DPictureSet', function()
	local ent = net.ReadEntity()
	
	if not IsValid(ent) then return end
	
	BuildMenuFor(ent)
end)
