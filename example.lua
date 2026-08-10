--[[
	example.lua
	Demonstrates how to use UILibrary to build a basic window with
	a button, toggle, slider, and text input.

	Setup:
	  1. Put UILibrary.lua and Icons.lua inside a ModuleScript folder,
	     e.g. ReplicatedStorage/UILib/UILibrary.lua (Icons.lua as a
	     sibling ModuleScript named "Icons").
	  2. Run this as a LocalScript (e.g. in StarterPlayerScripts).
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UILib = require(ReplicatedStorage.UILib.UILibrary)

-- Optional: register your uploaded icon ids before building the UI.
-- local Icons = require(ReplicatedStorage.UILib.Icons)
-- Icons.RegisterBatch({ ["sun"] = "rbxassetid://YOUR_ID", ["moon"] = "rbxassetid://YOUR_ID" })

-- Start in dark mode
UILib.CurrentTheme = "Dark"

local Window = UILib:CreateWindow({
	Title = "Script Hub",
	Size = UDim2.fromOffset(480, 420),
})

Window:AddLabel("Player Options")

Window:AddButton({
	Text = "Print Hello",
	Icon = "zap",
	Callback = function()
		print("Hello from the script hub!")
	end,
})

local flightToggle = Window:AddToggle({
	Text = "Enable Flight",
	Default = false,
	Callback = function(state)
		print("Flight enabled:", state)
	end,
})

local speedSlider = Window:AddSlider({
	Text = "Walk Speed",
	Min = 16,
	Max = 200,
	Default = 16,
	Callback = function(value)
		local char = game.Players.LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.WalkSpeed = value
		end
	end,
})

local nameInput = Window:AddTextBox({
	Text = "Target Player",
	Placeholder = "Enter a username...",
	Callback = function(text, enterPressed)
		if enterPressed then
			print("Target set to:", text)
		end
	end,
})

Window:AddButton({
	Text = "Toggle Theme",
	Icon = "sun",
	Callback = function()
		UILib:ToggleTheme()
	end,
})
