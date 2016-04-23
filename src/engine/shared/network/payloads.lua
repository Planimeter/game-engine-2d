--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Payload Definitions
--
--============================================================================--

payload.structs = {}
local structs   = payload.structs

structs[ "authenticate" ] = {
    keys = {
        { name = "ticket",         type = "string" }
    }
}

structs[ "kick" ] = {
    keys = {
        { name = "message",        type = "string" }
    }
}

structs[ "serverInfo" ] = {
    keys = {
        { name = "region",         type = "string" }
    }
}

-- if ( _G._VADVENTURE ) then
    table.insert( structs[ "serverInfo" ].keys,
        { name = "save",           type = "string" }
    )
-- end

structs[ "download" ] = {
    keys = {
        { name = "filename",       type = "string" }
    }
}

structs[ "upload" ] = {
    keys = {
        { name = "filename",       type = "string" },
        { name = "file",           type = "string" }
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
        { name = "classname",      type = "string" },
        { name = "entIndex",       type = "number" },
        { name = "networkVars",    type = "typelenvalues" }
    }
}

structs[ "playerInitialized" ] = {
    keys = {
        { name = "player",         type = "entity" },
        { name = "id",             type = "number" }
    }
}

structs[ "entityRemoved" ] = {
    keys = {
        { name = "entity",         type = "entity" },
    }
}

structs[ "chat" ] = {
    keys = {
        { name = "entity",         type = "entity" },
        { name = "message",        type = "string" }
    }
}

structs[ "networkVarChanged" ] = {
    keys = {
        { name = "entity",         type = "entity" },
        { name = "networkVars",    type = "typelenvalues" }
    }
}

structs[ "concommand" ] = {
    keys = {
        { name = "name",           type = "string" },
        { name = "argString",      type = "string" }
    }
}

structs[ "playerMove" ] = {
    keys = {
        { name = "position",       type = "vector" },
    }
}

-- if ( _G._VADVENTURE ) then
    structs[ "playerPickup" ] = {
        keys = {
            { name = "item",       type = "entity" },
        }
    }

    structs[ "playerCast" ] = {
        keys = {
            { name = "spell",      type = "string" },
            { name = "target",     type = "entity" },
            { name = "position",   type = "vector" }
        }
    }

    structs[ "dialogue" ] = {
        keys = {
            { name = "entity",     type = "entity" },
            { name = "type",       type = "string" },
            { name = "message",    type = "string" }
        }
    }
-- end
