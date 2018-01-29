
util.AddNetworkString("DPictureSet")

net.Receive("DPictureSet",function(bits,ply)
	local pic = net.ReadEntity()
	local id = net.ReadInt(16)
	
	if not IsValid(pic) then return end
	if not __DPicturePics[id] then return end
	if not pic.IsPicure then return end
	
	pic:SetURL(__DPicturePics[id])
end)
