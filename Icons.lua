--[[
	Icons.lua
	Icon resolver for UILibrary.

	IMPORTANT — how icons actually work in Roblox:
	Roblox cannot load arbitrary SVGs (Lucide/Geist/Solar are distributed as
	SVG) directly at runtime. To use them you need to:
	  1. Export the icon(s) you want as PNG (white/monochrome, transparent bg,
	     ~256x256 works well) from the icon set's website:
	       Lucide  -> https://lucide.dev
	       Geist   -> https://vercel.com/geist/icons
	       Solar   -> https://www.svgrepo.com/collection/solar-line-icons
	  2. Upload each PNG to Roblox via Studio (Asset Manager) or the
	     create.roblox.com asset uploader. Each upload gives you a
	     rbxassetid://ID you paste below.
	  3. Add an entry to the Icons table below: ["icon-name"] = "rbxassetid://ID"

	Because ImageLabel/ImageButton support ImageColor3, upload icons as
	plain white monochrome PNGs — the library will recolor them per-theme
	automatically (see UILibrary:_register calls using ImageColor3).

	This file ships with a small set of placeholder mappings using Roblox's
	built-in editor icons so the library works out of the box before you've
	uploaded your own set. Replace/extend these with your uploaded IDs.
--]]

local Icons = {}

-- Built-in fallback icons (Roblox Studio's internal icon spritesheet paths
-- won't work at runtime, so these fall back to a blank/generic square).
-- Replace the values below with your own uploaded rbxassetid:// icons.
local registry = {
	-- General UI
	["x"]           = "rbxassetid://0",  -- close
	["sun"]         = "rbxassetid://0",  -- light theme icon
	["moon"]        = "rbxassetid://0",  -- dark theme icon
	["menu"]        = "rbxassetid://0",
	["settings"]    = "rbxassetid://0",
	["search"]      = "rbxassetid://0",
	["home"]        = "rbxassetid://0",
	["check"]       = "rbxassetid://0",
	["chevron-down"]= "rbxassetid://0",
	["chevron-up"]  = "rbxassetid://0",
	["plus"]        = "rbxassetid://0",
	["minus"]       = "rbxassetid://0",
	["trash"]       = "rbxassetid://0",
	["copy"]        = "rbxassetid://0",
	["play"]        = "rbxassetid://0",
	["pause"]       = "rbxassetid://0",
	["info"]        = "rbxassetid://0",
	["alert-triangle"] = "rbxassetid://0",
	["shield"]      = "rbxassetid://0",
	["star"]        = "rbxassetid://0",
	["user"]        = "rbxassetid://0",
	["lock"]        = "rbxassetid://0",
	["unlock"]      = "rbxassetid://0",
	["zap"]         = "rbxassetid://0",
	["folder"]      = "rbxassetid://0",
	["save"]        = "rbxassetid://0",
}

-- Which "set" each icon nominally belongs to — purely informational,
-- useful if you want to keep Lucide/Geist/Solar variants side by side,
-- e.g. registry["lucide/home"], registry["solar/home"], etc.
Icons.Sets = { "lucide", "geist", "solar" }

-- A generic 1x1 transparent-ish fallback so missing icons don't error/hard-crash.
local FALLBACK = "rbxassetid://0"

--[[
	Get(name): returns the rbxassetid:// string for an icon name.
	Accepts either "home" (uses default registry) or "lucide/home",
	"geist/home", "solar/home" if you register set-prefixed variants.
]]
function Icons.Get(name)
	if not name then return FALLBACK end
	if registry[name] then
		return registry[name]
	end
	return FALLBACK
end

--[[
	Register(name, assetId): add or overwrite an icon mapping at runtime.
	Example:
		Icons.Register("home", "rbxassetid://123456789")
		Icons.Register("solar/home", "rbxassetid://987654321")
]]
function Icons.Register(name, assetId)
	registry[name] = assetId
end

--[[
	RegisterBatch(table): bulk-register icons, e.g. after uploading a
	full Lucide export:
		Icons.RegisterBatch({
			["home"] = "rbxassetid://111",
			["search"] = "rbxassetid://222",
		})
]]
function Icons.RegisterBatch(map)
	for k, v in pairs(map) do
		registry[k] = v
	end
end

return Icons
