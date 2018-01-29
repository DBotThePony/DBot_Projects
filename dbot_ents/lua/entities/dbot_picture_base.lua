
--[[
Copyright (C) 2016 DBot

Licensed under the Apache License, Version 2.0 (the 'License');
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an 'AS IS' BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

AddCSLuaFile()

ENT.Type = 'anim'
ENT.PrintName = 'Picture Base'
ENT.Author = 'DBot'
ENT.Category = 'RoboDerpy'
ENT.Spawnable = false
ENT.AdminSpawnable = false
--ENT.AdminOnly = true
ENT.RenderGroup = RENDERGROUP_BOTH

local framelimit = 400

ENT.IWidth = 64
ENT.IHeight = 64
ENT.Model = 'models/hunter/plates/plate1x1.mdl'

function ENT:SetupDataTables()
	self:NetworkVar('String', 0, 'URL')
end

local NextPanelCreate = 0

function ENT:CreateHTMLPanel()
	self.LastHTMLTry = self.LastHTMLTry or 0
	self.Tries = self.Tries or 0
	
	if NextPanelCreate > CurTime() then return end
	if self.LastHTMLTry > CurTime() then return end
	
	if self.Tries > 3 then return end
	
	if IsValid(self.HTMLPanel) then return elseif self.HTMLPanel then self.HTMLPanel:Remove() end
	
	if self.HTMLPanel then self.HTMLPanel:Remove() end
	
	self.HTMLPanel = vgui.Create('DHTML')
	NextPanelCreate = CurTime() + 4
	self.HTMLPanel:SetVisible(false)
	self.HTMLPanel:SetMouseInputEnabled(false)
	self.HTMLPanel:SetKeyBoardInputEnabled(false)
	self.HTMLPanel:Dock(FILL)
	
	self:OpenURL(self:GetURL() or '')
	self.HTMLPanel:UpdateHTMLTexture()
	self.Texture = self.HTMLPanel:GetHTMLMaterial()
	
	self.LastMatID = self.Texture and surface.GetTextureID(self.Texture:GetName()) or 0
	
	self.LastHTMLTry = CurTime() + 3
	self.Tries = self.Tries + 1
	
	if self.Tries > 3 then
		chat.AddText(Color(0, 200, 0), '[DPicture] ', Color(200, 200, 200), 'Something wrong with HTML panels... I will try to create HTML Panel again in 60 seconds')
		timer.Simple(60, function()
			if not IsValid(self) then return end
			
			self.Tries = 0
		end)
	end
end

function ENT:SpawnFunction( ply, tr, ClassName )
	if not tr.Hit then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 64
	local Vec = tr.HitPos - ply:GetPos()

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent.SpawnedByFunction = true
	ent:Spawn()
	ent:SetAngles(Vec:Angle() + Angle(0,-90, 90))
	ent:Activate()
	
	return ent
end

function ENT:Initialize()
	self:SetModel(self.Model)
	
	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		
		local phys = self:GetPhysicsObject()
		
		if IsValid(phys) then
		--	phys:EnableMotion(false)
		end
		
		if not self.SpawnedByFunction then
			self:SetAngles(Angle(0,-90, 90))
		end
		
		self:SetUseType(SIMPLE_USE)
		
		self:SetURL(table.Random(__DPicturePics))
	else
		self:CreateHTMLPanel()
		
		self.LastTextThink = CurTime()
		
		self:DrawShadow(false)
	end
end

function ENT:Use(ply)
	if not IsValid(ply) then return end
	if not ply:IsPlayer() then return end
	
	net.Start('DPictureSet')
	net.WriteEntity(self)
	net.Send(ply)
end

function ENT:OpenURL(url)
	if not IsValid(self.HTMLPanel) then self:CreateHTMLPanel() end
	
	url = url or ''

	local width = 512
	local height = 512
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
	
	self.HTMLPanel:SetHTML(page)
end

function ENT:Draw()
	if not system.HasFocus() then return end
	
	--[==[
	if not DLib.CanLocalPlayerSee(self) then 
		self.InactiveFrames = (self.InactiveFrames or 0) + 1
		
		--[[if self.InactiveFrames > framelimit then
			if IsValid(self.HTMLPanel) then
				self.HTMLPanel:Remove()
			end
		end]]
		return
	else
		self.InactiveFrames = 0
	end
	]==]
	
	self:DrawModel()
	
	if not IsValid(self.HTMLPanel) then self:CreateHTMLPanel() return end
	
	if not self.Texture then return end
	if not self.LastMatID then 
		local mat = surface.GetTextureID(self.Texture:GetName())
		self.LastMatID = mat
		return 
	end
	
	local pos = self:GetPos()
	local ang = self:GetAngles()
	
	local newang = ang - Angle(0, 90, 0)
	
	cam.Start3D2D(pos + newang:Forward() * 4 + newang:Up() * (self.IHeight / 2) - newang:Right() * (self.IHeight / 2), ang, 1)
	
	surface.SetDrawColor(255, 255, 255, 255)
	
	surface.SetTexture(self.LastMatID)
	surface.DrawTexturedRect(0, 0, self.IWidth, self.IHeight)
	
	cam.End3D2D()
end

function ENT:Think()
	if not CLIENT then return end
	self.InactiveFrames = (self.InactiveFrames or 0)
	
	if not system.HasFocus() then return end
	local url = self:GetURL()
	
	if not url then return end

	if self.InactiveFrames < framelimit then
		if self.LastTextThink < CurTime() then
			if not IsValid(self.HTMLPanel) then self:CreateHTMLPanel() end
			if not IsValid(self.HTMLPanel) then return end --Even we recreated panel, it don't work
			
			self.HTMLPanel:UpdateHTMLTexture()
			self.Texture = self.HTMLPanel:GetHTMLMaterial()
			
			self.LastTextThink = CurTime() + 3
		end
		
		if self.LastURL ~= url then
			self:OpenURL(url)
			self.HTMLPanel:UpdateHTMLTexture()
			self.Texture = self.HTMLPanel:GetHTMLMaterial()
			
			self.LastMatID = surface.GetTextureID(self.Texture:GetName())
			
			self.LastTextThink = CurTime() + 1
			self.LastURL = url
		end
	end
end

function ENT:IsPicure()
	return true
end

hook.Add('PhysgunPickup', 'DPicture', function(ply, ent)
	if ent.IsPicure then return true end
end)

function ENT:OnRemove()
	if IsValid(self.HTMLPanel) then
		self.HTMLPanel:Remove()
	end
end
