return {
	image = "images/player.png",
	width = 16,
	height = 32,
	frametime = 0.25,
	animations = {
		idlenorth = { 1 },
		idleeast = { 2 },
		idlesouth = { 3 },
		idlewest = { 4 },
		-- idlenorth
		idlenortheast = { 5 },
		-- idlesouth
		idlesoutheast = { 3 },
		-- idlesouth
		idlesouthwest = { 3 },
		-- idlenorth
		idlenorthwest = { 1 },
		walknorth = { { from = 33, to = 36 } },
		walkeast = { { from = 65, to = 68 } },
		walksouth = { { from = 97, to = 100 } },
		walkwest = { { from = 129, to = 132 } },
		walknortheast = { { from = 161, to = 164 } },
		walksoutheast = { { from = 193, to = 196 } },
		walksouthwest = { { from = 225, to = 228 } },
		walknorthwest = { { from = 257, to = 260 } }
	},
	events = {
		-- walknorth
		[ 33 ] = "rightfootstep",
		[ 35 ] = "leftfootstep",
		-- walkeast
		[ 65 ] = "rightfootstep",
		[ 67 ] = "leftfootstep",
		-- walksouth
		[ 96 ] = "rightfootstep",
		[ 98 ] = "leftfootstep",
		-- walkwest
		[ 129 ] = "leftfootstep",
		[ 131 ] = "rightfootstep",
		-- walknortheast
		[ 161 ] = "rightfootstep",
		[ 163 ] = "leftfootstep",
		-- walksoutheast
		[ 193 ] = "rightfootstep",
		[ 195 ] = "leftfootstep",
		-- walksouthwest
		[ 224 ] = "leftfootstep",
		[ 226 ] = "rightfootstep",
		-- walknorthwest
		[ 257 ] = "leftfootstep",
		[ 259 ] = "rightfootstep"
	}
}
