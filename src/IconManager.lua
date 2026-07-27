--!strict

local IconManager = {}
IconManager.__index = IconManager

export type IconObject = {
	_name: string,
	_id: string,
	_image: string,
}

local ICON_CACHE: { [string]: string } = {}

local BUILTIN_ICONS = {
	["Settings"] = "rbxasset://textures/Cursor.png",
	["Close"] = "rbxasset://textures/Cursor.png",
	["Menu"] = "rbxasset://textures/Cursor.png",
	["Search"] = "rbxasset://textures/Cursor.png",
	["Home"] = "rbxasset://textures/Cursor.png",
	["Back"] = "rbxasset://textures/Cursor.png",
	["Next"] = "rbxasset://textures/Cursor.png",
	["Delete"] = "rbxasset://textures/Cursor.png",
	["Add"] = "rbxasset://textures/Cursor.png",
	["Edit"] = "rbxasset://textures/Cursor.png",
	["Info"] = "rbxasset://textures/Cursor.png",
	["Warning"] = "rbxasset://textures/Cursor.png",
	["Error"] = "rbxasset://textures/Cursor.png",
	["Success"] = "rbxasset://textures/Cursor.png",
	["Star"] = "rbxasset://textures/Cursor.png",
	["Heart"] = "rbxasset://textures/Cursor.png",
	["Share"] = "rbxasset://textures/Cursor.png",
	["Download"] = "rbxasset://textures/Cursor.png",
	["Upload"] = "rbxasset://textures/Cursor.png",
	["Refresh"] = "rbxasset://textures/Cursor.png",
}

function IconManager.Register(name: string, imageId: string): IconObject
	local icon: IconObject = {
		_name = name,
		_id = name,
		_image = imageId,
	}

	ICON_CACHE[name] = imageId

	return icon
end

function IconManager.Get(name: string): string?
	if ICON_CACHE[name] then
		return ICON_CACHE[name]
	end

	if BUILTIN_ICONS[name] then
		return BUILTIN_ICONS[name]
	end

	return nil
end

function IconManager.RegisterBatch(icons: { [string]: string }): ()
	for name, imageId in pairs(icons) do
		IconManager.Register(name, imageId)
	end
end

function IconManager.Exists(name: string): boolean
	return ICON_CACHE[name] ~= nil or BUILTIN_ICONS[name] ~= nil
end

function IconManager.GetOrDefault(name: string, default: string?): string
	return IconManager.Get(name) or default or "rbxasset://textures/Cursor.png"
end

function IconManager.Clear(): ()
	table.clear(ICON_CACHE)
end

return IconManager
