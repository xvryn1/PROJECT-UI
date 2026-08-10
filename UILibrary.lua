--[[
	UILibrary.lua
	A lightweight, modern UI library for Roblox script hubs.
	Features: Light/Dark theming, draggable windows, buttons, sliders,
	toggles, text inputs, and icon support (Lucide / Geist / Solar).

	Usage:
		local UILib = require(path.to.UILibrary)
		local Window = UILib:CreateWindow({ Title = "My Hub" })
		...

	This module is self-contained (no external Roblox packages required).
	Icons are resolved through Icons.lua (place it next to this file).
--]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Icons = require(script.Parent:FindFirstChild("Icons") or script.Icons)

local UILib = {}
UILib.__index = UILib

-- ============================================================
-- THEME DEFINITIONS
-- ============================================================

UILib.Themes = {
	Dark = {
		Background      = Color3.fromRGB(24, 24, 27),
		Surface         = Color3.fromRGB(32, 32, 36),
		SurfaceAlt      = Color3.fromRGB(40, 40, 45),
		Border          = Color3.fromRGB(54, 54, 60),
		Text            = Color3.fromRGB(235, 235, 240),
		SubText         = Color3.fromRGB(150, 150, 160),
		Accent          = Color3.fromRGB(99, 102, 241),   -- indigo
		AccentHover     = Color3.fromRGB(129, 132, 255),
		Success         = Color3.fromRGB(52, 199, 89),
		Danger          = Color3.fromRGB(255, 69, 58),
		Font            = Enum.Font.GothamMedium,
	},
	Light = {
		Background      = Color3.fromRGB(246, 246, 248),
		Surface         = Color3.fromRGB(255, 255, 255),
		SurfaceAlt      = Color3.fromRGB(238, 238, 242),
		Border          = Color3.fromRGB(220, 220, 226),
		Text            = Color3.fromRGB(24, 24, 27),
		SubText         = Color3.fromRGB(110, 110, 120),
		Accent          = Color3.fromRGB(79, 70, 229),
		AccentHover     = Color3.fromRGB(99, 91, 245),
		Success         = Color3.fromRGB(34, 179, 76),
		Danger          = Color3.fromRGB(220, 38, 38),
		Font            = Enum.Font.GothamMedium,
	},
}

UILib.CurrentTheme = "Dark"
UILib._registry = {} -- all themable instances: {Instance, propertyMap}

-- ============================================================
-- INTERNAL HELPERS
-- ============================================================

local function new(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	return inst
end

local function corner(radius)
	return new("UICorner", { CornerRadius = UDim.new(0, radius or 8) })
end

local function stroke(color, thickness)
	return new("UIStroke", {
		Color = color,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function tween(inst, props, time, style)
	TweenService:Create(inst, TweenInfo.new(time or 0.18, style or Enum.EasingStyle.Quad), props):Play()
end

-- Registers an instance + a table of {Property = "ThemeKeyName"} so it
-- auto-updates whenever the theme is switched.
function UILib:_register(inst, map)
	table.insert(self._registry, { inst = inst, map = map })
	self:_applyTheme(inst, map)
end

function UILib:_applyTheme(inst, map)
	local theme = self.Themes[self.CurrentTheme]
	for prop, themeKey in pairs(map) do
		if inst and inst.Parent ~= nil or inst then
			local ok = pcall(function()
				inst[prop] = theme[themeKey]
			end)
		end
	end
end

function UILib:SetTheme(name)
	assert(self.Themes[name], "Unknown theme: " .. tostring(name))
	self.CurrentTheme = name
	for _, entry in ipairs(self._registry) do
		if entry.inst and entry.inst.Parent then
			tween(entry.inst, (function()
				local theme = self.Themes[name]
				local t = {}
				for prop, key in pairs(entry.map) do
					t[prop] = theme[key]
				end
				return t
			end)(), 0.2)
		end
	end
end

function UILib:ToggleTheme()
	self:SetTheme(self.CurrentTheme == "Dark" and "Light" or "Dark")
end

-- ============================================================
-- ROOT SCREENGUI
-- ============================================================

local function getScreenGui(name)
	local player = Players.LocalPlayer
	local pg = player:WaitForChild("PlayerGui")
	local existing = pg:FindFirstChild(name)
	if existing then existing:Destroy() end
	local sg = new("ScreenGui", {
		Name = name,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = pg,
	})
	return sg
end

-- ============================================================
-- WINDOW
-- ============================================================

function UILib:CreateWindow(config)
	config = config or {}
	local title = config.Title or "Window"
	local size = config.Size or UDim2.fromOffset(520, 380)
	local theme = self.Themes[self.CurrentTheme]

	local screenGui = getScreenGui(config.Name or "UILib_" .. title)

	local main = new("Frame", {
		Name = "Main",
		Size = size,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.Background,
		Parent = screenGui,
	})
	corner(12).Parent = main
	stroke(theme.Border, 1).Parent = main
	self:_register(main, { BackgroundColor3 = "Background" })

	-- Title bar
	local titleBar = new("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = theme.Surface,
		Parent = main,
	})
	corner(12).Parent = titleBar
	self:_register(titleBar, { BackgroundColor3 = "Surface" })

	-- mask the bottom corners of the title bar so it looks flush
	local mask = new("Frame", {
		Size = UDim2.new(1, 0, 0, 12),
		Position = UDim2.new(0, 0, 1, -12),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Parent = titleBar,
	})
	self:_register(mask, { BackgroundColor3 = "Surface" })

	local titleLabel = new("TextLabel", {
		Text = title,
		Font = theme.Font,
		TextSize = 16,
		TextColor3 = theme.Text,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -100, 1, 0),
		Position = UDim2.fromOffset(16, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = titleBar,
	})
	self:_register(titleLabel, { TextColor3 = "Text" })

	-- Theme toggle button (sun/moon icon)
	local themeBtn = new("ImageButton", {
		Name = "ThemeToggle",
		Size = UDim2.fromOffset(28, 28),
		Position = UDim2.new(1, -76, 0.5, -14),
		BackgroundTransparency = 1,
		Image = Icons.Get("sun"),
		ImageColor3 = theme.SubText,
		Parent = titleBar,
	})
	self:_register(themeBtn, { ImageColor3 = "SubText" })
	themeBtn.MouseButton1Click:Connect(function()
		self:ToggleTheme()
		themeBtn.Image = self.CurrentTheme == "Dark" and Icons.Get("moon") or Icons.Get("sun")
	end)

	-- Close button
	local closeBtn = new("ImageButton", {
		Name = "Close",
		Size = UDim2.fromOffset(28, 28),
		Position = UDim2.new(1, -38, 0.5, -14),
		BackgroundTransparency = 1,
		Image = Icons.Get("x"),
		ImageColor3 = theme.SubText,
		Parent = titleBar,
	})
	self:_register(closeBtn, { ImageColor3 = "SubText" })
	closeBtn.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)

	-- Body / content container
	local body = new("Frame", {
		Name = "Body",
		Size = UDim2.new(1, -24, 1, -60),
		Position = UDim2.new(0, 12, 0, 52),
		BackgroundTransparency = 1,
		Parent = main,
	})

	local layout = new("UIListLayout", {
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = body,
	})

	-- ---------------- Dragging ----------------
	do
		local dragging, dragStart, startPos
		titleBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = main.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - dragStart
				main.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + delta.X,
					startPos.Y.Scale, startPos.Y.Offset + delta.Y
				)
			end
		end)
	end

	-- ---------------- Window API ----------------
	local Window = setmetatable({
		_gui = screenGui,
		_main = main,
		_body = body,
		_lib = self,
	}, { __index = UILib._WindowMethods })

	return Window
end

-- ============================================================
-- COMPONENTS (attached to Window)
-- ============================================================

UILib._WindowMethods = {}
local WM = UILib._WindowMethods

function WM:AddButton(config)
	local lib = self._lib
	local theme = lib.Themes[lib.CurrentTheme]
	config = config or {}

	local btn = new("TextButton", {
		Text = "",
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = theme.Accent,
		AutoButtonColor = false,
		Parent = self._body,
	})
	corner(8).Parent = btn
	lib:_register(btn, { BackgroundColor3 = "Accent" })

	local label = new("TextLabel", {
		Text = config.Text or "Button",
		Font = theme.Font,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Parent = btn,
	})

	if config.Icon then
		label.Size = UDim2.new(1, -28, 1, 0)
		label.Position = UDim2.fromOffset(28, 0)
		local icon = new("ImageLabel", {
			Image = Icons.Get(config.Icon),
			Size = UDim2.fromOffset(18, 18),
			Position = UDim2.new(0, 10, 0.5, -9),
			BackgroundTransparency = 1,
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			Parent = btn,
		})
	end

	btn.MouseEnter:Connect(function()
		tween(btn, { BackgroundColor3 = lib.Themes[lib.CurrentTheme].AccentHover }, 0.12)
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, { BackgroundColor3 = lib.Themes[lib.CurrentTheme].Accent }, 0.12)
	end)
	btn.MouseButton1Click:Connect(function()
		if config.Callback then config.Callback() end
	end)

	return btn
end

function WM:AddToggle(config)
	local lib = self._lib
	local theme = lib.Themes[lib.CurrentTheme]
	config = config or {}
	local state = config.Default or false

	local holder = new("Frame", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		Parent = self._body,
	})

	local label = new("TextLabel", {
		Text = config.Text or "Toggle",
		Font = theme.Font,
		TextSize = 14,
		TextColor3 = theme.Text,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -50, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = holder,
	})
	lib:_register(label, { TextColor3 = "Text" })

	local track = new("Frame", {
		Size = UDim2.fromOffset(42, 24),
		Position = UDim2.new(1, -42, 0.5, -12),
		BackgroundColor3 = state and theme.Accent or theme.SurfaceAlt,
		Parent = holder,
	})
	corner(12).Parent = track
	lib:_register(track, { BackgroundColor3 = state and "Accent" or "SurfaceAlt" })

	local knob = new("Frame", {
		Size = UDim2.fromOffset(18, 18),
		Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Parent = track,
	})
	corner(9).Parent = knob

	local clickArea = new("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Parent = holder,
	})

	local function set(newState, fire)
		state = newState
		tween(track, { BackgroundColor3 = lib.Themes[lib.CurrentTheme][state and "Accent" or "SurfaceAlt"] }, 0.15)
		tween(knob, { Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9) }, 0.15)
		if fire ~= false and config.Callback then config.Callback(state) end
	end

	clickArea.MouseButton1Click:Connect(function()
		set(not state)
	end)

	return { Set = function(_, v) set(v, false) end, Get = function() return state end }
end

function WM:AddSlider(config)
	local lib = self._lib
	local theme = lib.Themes[lib.CurrentTheme]
	config = config or {}
	local min, max = config.Min or 0, config.Max or 100
	local value = math.clamp(config.Default or min, min, max)

	local holder = new("Frame", {
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundTransparency = 1,
		Parent = self._body,
	})

	local label = new("TextLabel", {
		Text = config.Text or "Slider",
		Font = theme.Font,
		TextSize = 14,
		TextColor3 = theme.Text,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -60, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = holder,
	})
	lib:_register(label, { TextColor3 = "Text" })

	local valueLabel = new("TextLabel", {
		Text = tostring(value),
		Font = theme.Font,
		TextSize = 14,
		TextColor3 = theme.SubText,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(50, 20),
		Position = UDim2.new(1, -50, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = holder,
	})
	lib:_register(valueLabel, { TextColor3 = "SubText" })

	local track = new("Frame", {
		Size = UDim2.new(1, 0, 0, 6),
		Position = UDim2.fromOffset(0, 30),
		BackgroundColor3 = theme.SurfaceAlt,
		Parent = holder,
	})
	corner(3).Parent = track
	lib:_register(track, { BackgroundColor3 = "SurfaceAlt" })

	local fill = new("Frame", {
		Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
		BackgroundColor3 = theme.Accent,
		Parent = track,
	})
	corner(3).Parent = fill
	lib:_register(fill, { BackgroundColor3 = "Accent" })

	local knob = new("Frame", {
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.new((value - min) / (max - min), -7, 0.5, -7),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Parent = track,
	})
	corner(7).Parent = knob
	stroke(theme.Border, 1).Parent = knob

	local dragging = false
	local function setFromX(xPos)
		local rel = math.clamp((xPos - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local val = math.floor(min + (max - min) * rel + 0.5)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		knob.Position = UDim2.new(rel, -7, 0.5, -7)
		valueLabel.Text = tostring(val)
		value = val
		if config.Callback then config.Callback(val) end
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setFromX(input.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setFromX(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	return { Get = function() return value end }
end

function WM:AddTextBox(config)
	local lib = self._lib
	local theme = lib.Themes[lib.CurrentTheme]
	config = config or {}

	local holder = new("Frame", {
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundTransparency = 1,
		Parent = self._body,
	})

	local label = new("TextLabel", {
		Text = config.Text or "Input",
		Font = theme.Font,
		TextSize = 14,
		TextColor3 = theme.Text,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = holder,
	})
	lib:_register(label, { TextColor3 = "Text" })

	local box = new("TextBox", {
		Text = config.Default or "",
		PlaceholderText = config.Placeholder or "Type here...",
		Font = theme.Font,
		TextSize = 14,
		TextColor3 = theme.Text,
		PlaceholderColor3 = theme.SubText,
		BackgroundColor3 = theme.SurfaceAlt,
		ClearTextOnFocus = false,
		Size = UDim2.new(1, 0, 0, 32),
		Position = UDim2.fromOffset(0, 22),
		Parent = holder,
	})
	corner(8).Parent = box
	stroke(theme.Border, 1).Parent = box
	lib:_register(box, { BackgroundColor3 = "SurfaceAlt", TextColor3 = "Text", PlaceholderColor3 = "SubText" })

	box.FocusLost:Connect(function(enterPressed)
		if config.Callback then config.Callback(box.Text, enterPressed) end
	end)

	return { Get = function() return box.Text end, Set = function(_, v) box.Text = v end }
end

function WM:AddLabel(text)
	local lib = self._lib
	local theme = lib.Themes[lib.CurrentTheme]
	local label = new("TextLabel", {
		Text = text or "",
		Font = theme.Font,
		TextSize = 13,
		TextColor3 = theme.SubText,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self._body,
	})
	lib:_register(label, { TextColor3 = "SubText" })
	return label
end

function WM:Destroy()
	self._gui:Destroy()
end

return UILib
