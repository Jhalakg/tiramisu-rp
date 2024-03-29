PLUGIN.Name = "Clothing"; -- What is the plugin name
PLUGIN.Author = "Big Bang"; -- Author of the plugin
PLUGIN.Description = "Enables you to wear fucking clothes :D"; -- The description or purpose of the plugin

--Removes a player's clothing on death
hook.Add( "PlayerDeath", "TiramisuRemoveClothingOnDeath", function( Victim, Inflictor, Attacker )

	if( Victim.Clothing ) then
		for k, v in pairs( Victim.Clothing ) do
			if( ValidEntity( v ) ) then
				if ValidEntity( Victim.deathrag ) then
					v:SetParent( Victim.deathrag )
				else
					v:SetParent( Victim:GetRagdollEntity() )
				end
				v:Initialize()
			end
		end
	end

end )

hook.Add( "PlayerSetModel", "TiramisuSpawnClothing", function( ply )

	--This is a kinda ridiculous override I use for gear that uses bonemerge. It's the only way to allow gear with bones to be rendered manually.
	if !ply.BonemergeGearEntity or ply.BonemergeGearEntity:GetParent() != ply then
		ply.BonemergeGearEntity = ents.Create( "player_gearhandler" )
		ply.BonemergeGearEntity:SetPos( ply:GetPos() + ply:GetUp() * 80 )
		ply.BonemergeGearEntity:SetAngles( ply:GetAngles() )
		ply.BonemergeGearEntity:SetModel("models/tiramisu/gearhandler.mdl")
		ply.BonemergeGearEntity:SetParent( ply )
		ply.BonemergeGearEntity:SetNoDraw( true )
		ply.BonemergeGearEntity:SetSolid( SOLID_NONE )
		ply.BonemergeGearEntity:Spawn()
		ply.BonemergeGearEntity:DrawShadow( false )
		ply.BonemergeGearEntity.Think = function()
			if ( ply.BonemergeGearEntity:IsOnFire() ) then
				ply.BonemergeGearEntity:Extinguish()
			end
		end
	end

	if ply:IsCharLoaded() then
		timer.Simple( 0.4, function() 
			CAKE.RestoreClothing( ply )
		end)
	end


end)

--Removes all of a player's clothing.
function CAKE.RemoveClothing( ply )

	if ply.Clothing then
		for k, v in pairs( ply.Clothing ) do
			if type( v ) != "table" then
				if ValidEntity( v ) then
					v:Remove()
					v = nil
				end
			end
		end
	end

	ply.Clothing = {}	

end

--Removes only the helmet of a player, if wearing any.
function CAKE.RemoveHelmet( ply )
	
	CAKE.SetClothing( ply, CAKE.GetCharField( ply, "clothing" ) )
		
end
	
--Main function to set a player's clothing based on at least one item. Helmet is not a necessary argument.
function CAKE.SetClothing( ply, clothing, helmet )

	CAKE.RemoveClothing( ply )

	if ( clothing and ply:HasItem( clothing )) or helmet then

		local item
		if helmet and helmet != clothing then
			if ply:ItemHasFlag( body, "nogloves" ) then --Head, body and hands are 
				CAKE.HandleClothing( ply, clothing, 1 )
				CAKE.HandleClothing( ply, helmet, 2 )
				CAKE.HandleClothing( ply, "none", 3 )
			else --Head and hands are the same, so we just make the head and the body.
				CAKE.HandleClothing( ply, clothing , 5 )
				CAKE.HandleClothing( ply, helmet, 2 )
			end
			item = helmet
		else
			if ply:ItemHasFlag( body, "nogloves" ) then --If the head is the same as the body, you only have to make the hands.
				CAKE.HandleClothing( ply, clothing , 4 )
				CAKE.HandleClothing( ply, "none", 3 )
			else --If body, head and hands are all the same, make a single clothing entity.
				CAKE.HandleClothing( ply, clothing , 0 )
			end
			item = clothing
		end

		if CAKE.ItemData[ item ] then
			if ply:GetGender() == "Female" and CAKE.ItemData[ item ].FemaleModel then
				ply:SetNWString( "model", CAKE.ItemData[ item ].FemaleModel )
			else
				ply:SetNWString( "model", CAKE.ItemData[ item ].Model )
			end
		else
			ply:SetNWString( "model", CAKE.GetCharField( ply, "model" ) )
		end

	elseif !clothing or clothing == "none" then

		CAKE.HandleClothing( ply, "none" , 0 )
		ply:SetNWString( "model", CAKE.GetCharField( ply, "model" ) )

	end
	
	CAKE.CalculateEncumberment( ply )
	CAKE.SendClothingToClient( ply )
		
end

--Allows you to try a set of clothes without actually owning the item.
function CAKE.TestClothing( ply, model, clothing, helmet)

	CAKE.RemoveClothing( ply )

	if ( clothing and clothing != "none" ) or helmet then
		local item
		if helmet and helmet != clothing then
			if ply:ItemHasFlag( body, "nogloves" ) then --Head, body and hands are 
				CAKE.HandleClothing( ply, clothing, 1, model )
				CAKE.HandleClothing( ply, helmet, 2, model )
				CAKE.HandleClothing( ply, "none", 3, model )
			else --Head and hands are the same, so we just make the head and the body.
				CAKE.HandleClothing( ply, clothing , 5, model )
				CAKE.HandleClothing( ply, helmet, 2, model)
			end
			item = helmet
		else
			if ply:ItemHasFlag( body, "nogloves" ) then --If the head is the same as the body, you only have to make the hands.
				CAKE.HandleClothing( ply, clothing , 4, model )
				CAKE.HandleClothing( ply, "none", 3 , model )
			else --If body, head and hands are all the same, make a single clothing entity.
				CAKE.HandleClothing( ply, clothing , 0, model)
			end
			item = clothing
		end

		if CAKE.ItemData[ item ] then
			if ply:GetGender() == "Female" and CAKE.ItemData[ item ].FemaleModel then
				ply:SetNWString( "model", CAKE.ItemData[ item ].FemaleModel )
			else
				ply:SetNWString( "model", CAKE.ItemData[ item ].Model )
			end
		else
			ply:SetNWString( "model", model )
		end
			
	elseif !clothing or clothing == "none" then

		CAKE.HandleClothing( ply, "none" , 0, model )
		ply:SetNWString( "model", model )

	end


	CAKE.SendClothingToClient( ply )
		
end

--Internal function to handle clothing creation.
function CAKE.HandleClothing( ply, item, type, modeloverride )
	
	local model

	if CAKE.ItemData[ item ] then
		if ply:GetGender() == "Female" and CAKE.ItemData[ item ].FemaleModel then
			model = CAKE.ItemData[ item ].FemaleModel
		else
			model = CAKE.ItemData[ item ].Model
		end
	else
		model = modeloverride or CAKE.GetCharField( ply, "model" )
	end

	if !ply.Clothing then
		ply.Clothing = {}
	end
		
	if ValidEntity( ply.Clothing[ type ] ) and ply.Clothing[ type ]:GetParent() == ply then
		ply.Clothing[ type ]:Remove()
	end
	
	ply.Clothing[ type ] = ents.Create( "player_part" )
	ply.Clothing[ type ]:SetDTInt( 1, type )
	ply.Clothing[ type ]:SetDTInt( 2, ply:EntIndex() )
	ply.Clothing[ type ]:SetDTInt( 3, 1 )
	ply.Clothing[ type ]:SetModel( model )
	ply.Clothing[ type ]:SetParent( ply )
	ply.Clothing[ type ]:SetPos( ply:GetPos() )
	ply.Clothing[ type ]:SetAngles( ply:GetAngles() )
	if ValidEntity( ply.Clothing[ type ]:GetPhysicsObject( ) ) then
		ply.Clothing[ type ]:GetPhysicsObject( ):EnableCollisions( false )
	end
	ply.Clothing[ type ]:Spawn()
	ply.Clothing[ type ].item = item
	
		
end

--Restores a character's clothing based on it's clothing, helmet and gloves fields. Also handles if the player is using a special model.
function CAKE.RestoreClothing( ply )

	CAKE.RemoveClothing( ply )

	local clothes = CAKE.GetCharField( ply, "clothing" )
	if !ply:HasItem( clothes ) then
		CAKE.SetCharField( ply, "clothing", "none" )
		clothes = none
	end

	local helmet = CAKE.GetCharField( ply, "helmet" )
	if !ply:HasItem( helmet ) then
		CAKE.SetCharField( ply, "helmet", "none" )
		helmet = none
	end

	local gloves = CAKE.GetCharField( ply, "gloves" )
	local special = CAKE.GetCharField( ply, "specialmodel" )

	if special == "none" or special == "" then
		ply:SetNWBool( "specialmodel", false )
		CAKE.SetClothing( ply, clothes, helmet, gloves )
	else
		ply:SetNWBool( "specialmodel", true )
		ply:SetNWString( "model", tostring( special ) )
		ply:SetModel( tostring( special ) )
	end

end

local function ccSetClothing( ply, cmd, args )
	
	local body = ""
	local helmet = ""
	local gloves = ""
	
	if( args[1] == "" or args[1] == "none" )then
		body = "none"
	else
		body = args[1]
	end
	
	if( args[2] == "" or args[2] == "none" )then
		helmet = "none"
	else
		helmet = args[2]
	end
	
	if args[3] then
		if( args[3] == "" or args[3] == "none" )then
			gloves = "none"
		else
			gloves = args[3]
		end
	else
		gloves = body
	end
	
	CAKE.SetClothing( ply, body, helmet )
	CAKE.SetCharField( ply, "clothing", body )
	CAKE.SetCharField( ply, "helmet", helmet )

end
concommand.Add( "rp_setclothing", ccSetClothing );

--Sends the clothing entity indexes, in order to use them clientside.
function CAKE.SendClothingToClient( ply )
	
	if ply.Clothing then
		umsg.Start( "clearclothing", ply )
		umsg.End()
		timer.Simple( ply:Ping() / 100 + 0.5, function()
			for k, v in pairs( ply.Clothing ) do
				if ValidEntity( v ) then
					umsg.Start( "addclothing", ply )
						umsg.Short( v:EntIndex() )
						umsg.String( v.item or "none" )
					umsg.End()
				end
			end
		end)
	end

end

function PLUGIN.Init()
	
	CAKE.AddDataField( 2, "gloves", "none" ); --What you're wearing on your hands
	CAKE.AddDataField( 2, "clothing", "none" ); --What you're wearing on your body
	CAKE.AddDataField( 2, "helmet", "none" ); --What you're wearing on your head
	CAKE.AddDataField( 2, "headratio", 1 ); --for those bighead guys.
	CAKE.AddDataField( 2, "specialmodel", "none" );
	
end