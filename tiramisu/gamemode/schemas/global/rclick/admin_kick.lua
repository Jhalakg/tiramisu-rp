RCLICK.Name = "Kick"
RCLICK.SubMenu = "Admin"

function RCLICK.Condition(target)

	if target:IsPlayer() and LocalPlayer():GetNWInt( "TiramisuAdminLevel", 0 ) > 1 then return true end

end

function RCLICK.Click(target,ply)

	CAKE.StringRequest( "Kick A Player", "Give a reason to kick " .. target:Nick(), "Bye.", function( text )
		ply:ConCommand("rp_admin kick \"" .. target:Nick() .. "\" \"" .. text .. "\"" )
	end,
	function() end, "Accept", "Cancel")

end