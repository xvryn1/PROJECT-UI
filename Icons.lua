--[[
	Icons.lua
	Icon resolver for UILibrary — backed by WindUI's live icon data
	(Lucide / Geist / Craft / Solar / SF Symbols), sourced from
	https://github.com/Footagesus/Icons via the WindUI runtime.

	WHY THIS APPROACH:
	Roblox can't load SVGs (Lucide/Geist/Solar) directly. Rather than
	hand-copying thousands of icon -> rbxassetid mappings (which would go
	stale and risks wrong/fake IDs), this module pulls WindUI's actual
	Creator module at runtime and reuses its real, maintained icon
	resolver. This means:
	  - Icon coverage always matches what WindUI currently ships.
	  - No manual uploading, no manual copy-pasting of asset ids.
	  - You use the exact same names shown in WindUI's docs, e.g.
	    "lucide:bird", "geist:window", "craft:macbook-stroke",
	    "solar:home-2-bold", "sfsymbols:sunMaxFill".

	FALLBACK:
	If the remote fetch fails (no internet in Studio test, executor
	blocks HttpGet, etc.) you can still register your own icons manually
	with Icons.Register / Icons.RegisterBatch using rbxassetid:// values
	you've uploaded yourself.
--]]

local Icons = {}

local manualRegistry = {}   -- user-registered overrides / fallbacks
local remoteResolver = nil  -- WindUI's Creator module, loaded lazily
local attemptedLoad = false

local WINDUI_SOURCE = "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"

-- Lazily fetches WindUI (only once) purely to reuse its icon resolver.
-- This does NOT create any UI - we only use it to look up icon assets.
local function ensureRemoteResolver()
	if attemptedLoad then return end
	attemptedLoad = true

	local ok, result = pcall(function()
		local WindUI = loadstring(game:HttpGet(WINDUI_SOURCE))()
		-- WindUI exposes icon resolution through its Creator module,
		-- e.g. WindUI.Creator.Icons / WindUI.Creator.AddIcons.
		return WindUI
	end)

	if ok and result then
		remoteResolver = result
	else
		warn("[UILib.Icons] Could not load WindUI icon resolver — " ..
			"falling back to manually registered icons only. " ..
			"Register your own via Icons.Register(name, rbxassetid).")
	end
end

--[[
	Get(name): returns a usable image string for an icon.
	Accepts names in WindUI's format, e.g.:
		"lucide:bird", "geist:window", "craft:macbook-stroke",
		"solar:home-2-bold", "sfsymbols:sunMaxFill"
	or a bare manually-registered name, e.g. "close" if you called
	Icons.Register("close", "rbxassetid://123456789").
]]
function Icons.Get(name)
	if not name or name == "" then
		return "rbxassetid://0"
	end

	-- 1. Manual overrides always take priority.
	if manualRegistry[name] then
		return manualRegistry[name]
	end

	-- 2. Try WindUI's live resolver.
	ensureRemoteResolver()
	if remoteResolver and remoteResolver.Creator and remoteResolver.Creator.GetIcon then
		local ok, asset = pcall(remoteResolver.Creator.GetIcon, name)
		if ok and asset then
			return asset
		end
	end

	-- 3. Nothing found — return a safe blank fallback instead of erroring,
	-- so UI still renders (just without that icon).
	return "rbxassetid://0"
end

-- Register or override a single icon with your own uploaded asset.
function Icons.Register(name, assetId)
	manualRegistry[name] = assetId
end

-- Bulk-register icons.
function Icons.RegisterBatch(map)
	for k, v in pairs(map) do
		manualRegistry[k] = v
	end
end

return Icons
