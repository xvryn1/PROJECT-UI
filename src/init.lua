--!strict

local Atomic = {}

local Theme = require(script.Theme)
local Utility = require(script.Utility)
local Animation = require(script.Animation)
local IconManager = require(script.IconManager)

Atomic.Theme = Theme
Atomic.Utility = Utility
Atomic.Animation = Animation
Atomic.IconManager = IconManager

export type Theme = Theme.ThemeObject
export type AnimationConfig = Animation.AnimationConfig
export type AnimationObject = Animation.AnimationObject

function Atomic.CreateTheme(config: {
	Name: string?,
	Colors: Theme.ColorScheme?,
	Radius: number?,
	Padding: number?,
	Spacing: number?,
	AnimationSpeed: number?,
	FontSize: number?,
	FontFamily: Enum.Font?,
	StrokeThickness: number?,
}?): Theme.ThemeObject
	return Theme.new(config)
end

function Atomic.GetVersion(): string
	return "1.0.0"
end

return Atomic
