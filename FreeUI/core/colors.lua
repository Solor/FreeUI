local F, C = unpack(select(2, ...))
local oUF = F.oUF


local function SetDebuffTypeColors()
	oUF.colors.debuff = {
		['Curse']   = {0.8, 0, 1},
		['Disease'] = {0.8, 0.6, 0},
		['Magic']   = {0, 0.8, 1},
		['Poison']  = {0, 0.8, 0},
		['none']    = {0, 0, 0}
	}
end

local function SetClassColors()
	local colors = FreeADB.colors.class

	for class, value in pairs(colors) do
		oUF.colors.class[class] = {value.r, value.g, value.b}
	end
end

local function SetPowerColors()
	local colors = FreeADB.colors.power

	for type, value in pairs(colors) do
		oUF.colors.power[type] = {value.r, value.g, value.b}
	end
end

local function SetClassPowerColors()
	local colors = FreeADB.colors.class_power

	for type, value in pairs(colors) do
		oUF.colors.power[type] = {value.r, value.g, value.b}
	end
end

local function SetRuneColors()
	local colors = FreeADB.colors.dk_rune

	oUF.colors.runes = {
		{colors.blood.r, colors.blood.g, colors.blood.b},
		{colors.frost.r, colors.frost.g, colors.frost.b},
		{colors.unholy.r, colors.unholy.g, colors.unholy.b},
	}
end

local function SetReactionColors()
	local color = FreeADB.colors.reaction

	oUF.colors.reaction = {
		[1] = {color.hostile.r, color.hostile.g, color.hostile.b},
		[2] = {color.hostile.r, color.hostile.g, color.hostile.b},
		[3] = {color.hostile.r, color.hostile.g, color.hostile.b},
		[4] = {color.neutral.r, color.neutral.g, color.neutral.b},
		[5] = {color.friendly.r, color.friendly.g, color.friendly.b},
		[6] = {color.friendly.r, color.friendly.g, color.friendly.b},
		[7] = {color.friendly.r, color.friendly.g, color.friendly.b},
		[8] = {color.friendly.r, color.friendly.g, color.friendly.b},
	}
end

function F:UpdateColors()
	-- SetDebuffTypeColors()
	-- SetClassColors()
	-- SetPowerColors()
	-- SetClassPowerColors()
	-- SetRuneColors()
	-- SetReactionColors()
end

local function ReplacePowerColor(name, index, color)
	oUF.colors.power[name] = color
	oUF.colors.power[index] = oUF.colors.power[name]
end
ReplacePowerColor("MANA", 0, {87/255, 165/255, 208/255})
ReplacePowerColor("ENERGY", 3, {174/255, 34/255, 45/255})
ReplacePowerColor("COMBO_POINTS", 4, {199/255, 171/255, 90/255})
ReplacePowerColor("RUNIC_POWER", 6, {135/255, 214/255, 194/255})
ReplacePowerColor("SOUL_SHARDS", 7, {151/255, 101/255, 221/255})
ReplacePowerColor("HOLY_POWER", 9, {208/255, 178/255, 107/255})

