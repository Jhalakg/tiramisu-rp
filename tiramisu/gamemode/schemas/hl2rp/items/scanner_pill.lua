ITEM.Name = "Scanner Pill";
ITEM.Class = "scanner_pill";
ITEM.Description = "Use this to become a scanner";
ITEM.Model = "models/props_lab/jar01b.mdl";
ITEM.Purchaseable = false;
ITEM.Price = 3;
ITEM.ItemGroup = 1;

function ITEM:Drop(ply)

end

function ITEM:Pickup(ply)

	self:Remove();

end

function ITEM:UseItem(ply)

	ply:RemoveClothing()
	CAKE.RemoveAllGear( ply )
	ply:SetSpecialModel( "models/Combine_Scanner.mdl" )
	ply:SetMoveType( MOVETYPE_FLY )
	ply:GiveItem( "antlion_pill" )
	self:Remove();

end
