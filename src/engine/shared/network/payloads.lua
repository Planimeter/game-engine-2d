--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Payload Definitions
--
--============================================================================--

payload.structs = {}
local structs	= payload.structs

structs[ "authenticate" ] = {
	keys = {
		{ name = "ticket",		   type = "string" }
	}
}

structs[ "kick" ] = {
	keys = {
		{ name = "message",		   type = "string" }
	}
}

structs[ "serverInfo" ] = {
	keys = {
		{ name = "region",		   type = "string" }
	}
}

-- if ( _G._VADVENTURE ) then
	table.insert( structs[ "serverInfo" ].keys,
		{ name = "save",		   type = "string" }
	)
-- end

structs[ "download" ] = {
	keys = {
		{ name = "filename",	   type = "string" }
	}
}

structs[ "upload" ] = {
	keys = {
		{ name = "filename",	   type = "string" },
		{ name = "file",		   type = "string" }
	}
}

structs[ "clientInfo" ] = {
	keys = {
		{ name = "viewportWidth",  type = "number" },
		{ name = "viewportHeight", type = "number" }
	}
}

structs[ "entitySpawned" ] = {
	keys = {
		{ name = "classname",	   type = "string" },
		{ name = "entIndex",	   type = "number" },
		{ name = "networkVars",	   type = "typelenvalues" }
	}
}

structs[ "playerInitialized" ] = {
	keys = {
		{ name = "entIndex",	   type = "number" },
		{ name = "id",			   type = "number" }
	}
}

structs[ "entityRemoved" ] = {
	keys = {
		{ name = "entIndex",	   type = "number" },
	}
}

structs[ "chat" ] = {
	keys = {
		{ name = "entIndex",	   type = "number" },
		{ name = "message",		   type = "string" }
	}
}

structs[ "networkVarChanged" ] = {
	keys = {
		{ name = "entIndex",	   type = "number" },
		{ name = "networkVars",	   type = "typelenvalues" }
	}
}

structs[ "concommand" ] = {
	keys = {
		{ name = "name",		   type = "string" },
		{ name = "argString",	   type = "string" }
	}
}

structs[ "playerMove" ] = {
	keys = {
		{ name = "position",	   type = "vector" },
	}
}
