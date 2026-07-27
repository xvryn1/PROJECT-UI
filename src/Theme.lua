--!strict

local Theme = {}
Theme.__index = Theme

export type ColorScheme = {
	Background: Color3,
	Surface: Color3,
	SurfaceVariant: Color3,
	OnBackground: Color3,
	OnSurface: Color3,
	Primary: Color3,
	Secondary: Color3,
	Tertiary: Color3,
	Error: Color3,
}

export type ThemeObject = {
	Name: string,
	Colors: ColorScheme,
	Radius: number,
	Padding: number,
	Spacing: number,
	AnimationSpeed: number,
	FontSize: number,
	FontFamily: Enum.Font,
	StrokeThickness: number,
}

local LIGHT_THEME: ColorScheme = {
	Background = Color3.fromRGB(255, 255, 255),
	Surface = Color3.fromRGB(245, 245, 245),
	SurfaceVariant = Color3.fromRGB(240, 240, 240),
	OnBackground = Color3.fromRGB(20, 20, 20),
	OnSurface = Color3.fromRGB(40, 40, 40),
	Primary = Color3.fromRGB(100, 200, 255),
	Secondary = Color3.fromRGB(180, 180, 180),
	Tertiary = Color3.fromRGB(200, 150, 100),
	Error = Color3.fromRGB(255, 100, 100),
}

local DARK_THEME: ColorScheme = {
	Background = Color3.fromRGB(20, 20, 20),
	Surface = Color3.fromRGB(35, 35, 35),
	SurfaceVariant = Color3.fromRGB(45, 45, 45),
	OnBackground = Color3.fromRGB(240, 240, 240),
	OnSurface = Color3.fromRGB(220, 220, 220),
	Primary = Color3.fromRGB(100, 200, 255),
	Secondary = Color3.fromRGB(100, 100, 100),
	Tertiary = Color3.fromRGB(200, 150, 100),
	Error = Color3.fromRGB(255, 150, 150),
}

local DEFAULT_THEME: ThemeObject = {
	Name = "Dark",
	Colors = DARK_THEME,
	Radius = 8,
	Padding = 12,
	Spacing = 8,
	AnimationSpeed = 0.2,
	FontSize = 14,
	FontFamily = Enum.Font.GothamSSm,
	StrokeThickness = 1,
}

function Theme.new(config: {
	Name: string?,
	Colors: ColorScheme?,
	Radius: number?,
	Padding: number?,
	Spacing: number?,
	AnimationSpeed: number?,
	FontSize: number?,
	FontFamily: Enum.Font?,
	StrokeThickness: number?,
}?): ThemeObject
	local self: ThemeObject = setmetatable({} :: ThemeObject, Theme)

	local config = config or {}

	self.Name = config.Name or DEFAULT_THEME.Name
	self.Colors = config.Colors or table.clone(DEFAULT_THEME.Colors)
	self.Radius = config.Radius or DEFAULT_THEME.Radius
	self.Padding = config.Padding or DEFAULT_THEME.Padding
	self.Spacing = config.Spacing or DEFAULT_THEME.Spacing
	self.AnimationSpeed = config.AnimationSpeed or DEFAULT_THEME.AnimationSpeed
	self.FontSize = config.FontSize or DEFAULT_THEME.FontSize
	self.FontFamily = config.FontFamily or DEFAULT_THEME.FontFamily
	self.StrokeThickness = config.StrokeThickness or DEFAULT_THEME.StrokeThickness

	return self
end

function Theme.Light(): ThemeObject
	return Theme.new({
		Name = "Light",
		Colors = table.clone(LIGHT_THEME),
	})
end

function Theme.Dark(): ThemeObject
	return Theme.new({
		Name = "Dark",
		Colors = table.clone(DARK_THEME),
	})
end

function Theme.WithColors(colors: ColorScheme): ThemeObject
	return Theme.new({
		Colors = table.clone(colors),
	})
end

return Theme
