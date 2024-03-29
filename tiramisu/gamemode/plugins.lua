CAKE.Plugins = {  };
CAKE.CurrencyData = {  };

function CAKE.RegisterCurrency( currency )
	
	CAKE.CurrencyData[ currency.Name ] = currency
	
end

function CAKE.LoadRClick( schema, filename )

	local path = "schemas/" .. schema .. "/rclick/" .. filename;
	AddResource("lua", path)
	
end

--Plugins on Tiramisu are really no different from a regular lua file. It is automatically included, and doesn't stop the loading of all other plugins if an error is detected in one. The file prefix is important, a cl_ file will be sent to the player, while a sh_ file will be included both client and serverside

function CAKE.LoadPlugin( schema, filename )

	local filename = filename or ""
	local path = CAKE.Name .. "/gamemode/schemas/" .. schema .. "/plugins/" .. filename
	local list = file.FindInLua( path .. "*" ) or {}

	for k, v in pairs( list ) do
		PLUGIN = {}
		if v != "." and v != ".." and v != filename then
			if string.GetExtensionFromFilename( v ) and string.GetExtensionFromFilename( v ) == "lua" then
				if v:sub( 1, 3 ) == "cl_" then --It's a clientside file, send it to the client
					AddResource("lua", "schemas/" .. schema .. "/plugins/" .. filename .. v )
				elseif v:sub( 1,3 ) == "sh_" then --It's a shared file, so we add it and include it serverside.
					AddResource("lua", "schemas/" .. schema .. "/plugins/" .. filename .. v )
					CAKE.DayLog( "script.txt", "Loading Shared File: " .. schema .. "/plugins/" .. filename .. v )
					include( "schemas/" .. schema .. "/plugins/" .. filename .. v )
				else --It doesn't have a prefix so we default it to be serverside only
					CAKE.DayLog( "script.txt", "Loading Serverside File: " .. schema .. "/plugins/" .. filename .. v )
					include( "schemas/" .. schema .. "/plugins/" .. filename .. v )
				end
			else --It's a folder
				CAKE.LoadPlugin( schema, filename .. v .. "/" )
			end
		end
		table.insert( CAKE.Plugins, PLUGIN )
	end
	
end

--Initializes plugins. This is the equivalent of hooking something to the Initialize hook
function CAKE.InitPlugins( )

	for _, PLUGIN in pairs( CAKE.Plugins ) do
		
		PLUGIN.Name = PLUGIN.Name or "Unnamed Plugin-" .. SysTime()

		CAKE.DayLog("script.txt", "Initializing " .. PLUGIN.Name );
		
		if PLUGIN.Init then
			PLUGIN.Init()
		elseif PLUGIN.Initialize then
			PLUGIN.Initialize()
		end
		
	end
	
end