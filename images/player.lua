return {
	image = "images/player.png",
	width = 16,
	height = 32,
	frametime = 0.2,
	animations = {
		idle = {
			from = 1,
			to = 1
		},
		walknorth = {
			from = 32,
			to = 35
		},
		walknortheast = {
			from = 64,
			to = 67,
		},
		walkeast = {
			from = 96,
			to = 99,
		},
		walksoutheast = {
			from = 128,
			to = 131,
		},
		walksouth = {
			from = 160,
			to = 163,
		},
		walksouthwest = {
			from = 192,
			to = 195,
		},
		walkwest = {
			from = 224,
			to = 227,
		},
		walknorthwest = {
			from = 256,
			to = 259,
		}
	},
	events = {
		-- walknorth
		[ 33 ] = "rightfootstep",
		[ 35 ] = "leftfootstep",
		-- walknortheast
		[ 65 ] = "rightfootstep",
		[ 67 ] = "leftfootstep",
		-- walkeast
		[ 96 ] = "rightfootstep",
		[ 98 ] = "leftfootstep",
		-- walksoutheast
		[ 129 ] = "leftfootstep",
		[ 131 ] = "rightfootstep",
		-- walksouth
		[ 161 ] = "rightfootstep",
		[ 163 ] = "leftfootstep",
		-- walksouthwest
		[ 193 ] = "rightfootstep",
		[ 195 ] = "leftfootstep",
		-- walkwest
		[ 224 ] = "leftfootstep",
		[ 226 ] = "rightfootstep",
		-- walknorthwest
		[ 257 ] = "leftfootstep",
		[ 259 ] = "rightfootstep"
	}
}
