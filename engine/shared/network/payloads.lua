--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Payload Definitions
--
--==========================================================================--

class "payload" ( "typelenvalues" )

payload.structs = payload.structs or {}
local structs   = payload.structs

structs[ "kick" ] = {
    keys = {
        { name = "message",        type = "string" }
    }
}

structs[ "serverInfo" ] = {
    keys = {
        { name = "map",            type = "string" }
    }
}

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
        { name = "graphicsWidth",  type = "number" },
        { name = "graphicsHeight", type = "number" }
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
        { name = "entity",         type = "entity" }
    }
}

structs[ "chat" ] = {
    keys = {
        { name = "entity",         type = "entity" },
        { name = "message",        type = "string" }
    }
}

structs[ "sayText" ] = {
    keys = {
        { name = "text",           type = "string" }
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
        { name = "position",       type = "vector" }
    }
}

structs[ "usercmd" ] = {
    keys = {
        { name = "commandNumber",  type = "number" },
        { name = "buttons",        type = "number" }
    }
}

structs[ "playerUse" ] = {
    keys = {
        { name = "entity",         type = "entity" },
        { name = "value",          type = "string" }
    }
}

-- if ( _G._VADVENTURE ) then
    structs[ "playerPickup" ] = {
        keys = {
            { name = "item",       type = "entity" }
        }
    }

    structs[ "playerGotItem" ] = {
        keys = {
            { name = "item",       type = "string" },
            { name = "count",      type = "number" }
        }
    }

    structs[ "playerDrop" ] = {
        keys = {
            { name = "item",       type = "string" }
        }
    }

    structs[ "playerRemovedItem" ] = {
        keys = {
            { name = "item",       type = "string" }
        }
    }

    structs[ "playerUseItem" ] = {
        keys = {
            { name = "item",       type = "string" },
            { name = "value",      type = "string" }
        }
    }

    structs[ "playerUseItemWithEntity" ] = {
        keys = {
            { name = "item",       type = "string" },
            { name = "entity",     type = "entity" }
        }
    }

    structs[ "npcTalkTo" ] = {
        keys = {
            { name = "npc",        type = "entity" },
            { name = "dialogue",   type = "string" }
        }
    }

    structs[ "playerTradeRequest" ] = {
        keys = {
            { name = "player",     type = "entity" },
            { name = "request",    type = "string" }
        }
    }
-- end
