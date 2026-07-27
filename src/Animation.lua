--!strict

local Animation = {}
Animation.__index = Animation

local Utility = require(script.Parent.Utility)

export type AnimationConfig = {
	Duration: number?,
	EasingStyle: Enum.EasingStyle?,
	EasingDirection: Enum.EasingDirection?,
	Delay: number?,
	RepeatCount: number?,
	Reverses: boolean?,
}

export type AnimationObject = {
	_instance: Instance,
	_tweens: { Tween },
	_connections: { Utility.Connection },
	_isPlaying: boolean,
	Play: (self: AnimationObject) -> (),
	Pause: (self: AnimationObject) -> (),
	Stop: (self: AnimationObject) -> (),
	Cleanup: (self: AnimationObject) -> (),
}

function Animation.new(instance: Instance, config: AnimationConfig?): AnimationObject
	local config = config or {}

	local self: AnimationObject = setmetatable({
		_instance = instance,
		_tweens = {},
		_connections = {},
		_isPlaying = false,
	} :: AnimationObject, Animation)

	self._config = {
		Duration = config.Duration or 0.3,
		EasingStyle = config.EasingStyle or Enum.EasingStyle.Quad,
		EasingDirection = config.EasingDirection or Enum.EasingDirection.InOut,
		Delay = config.Delay or 0,
		RepeatCount = config.RepeatCount or 0,
		Reverses = config.Reverses or false,
	}

	return self
end

function Animation.FadeIn(instance: Instance, duration: number?): AnimationObject
	local duration = duration or 0.3
	local anim = Animation.new(instance)

	if instance:IsA("GuiObject") then
		(instance :: GuiObject).BackgroundTransparency = 1
		anim:To({ BackgroundTransparency = 0 }, duration)
	end

	return anim
end

function Animation.FadeOut(instance: Instance, duration: number?): AnimationObject
	local duration = duration or 0.3
	local anim = Animation.new(instance)

	if instance:IsA("GuiObject") then
		anim:To({ BackgroundTransparency = 1 }, duration)
	end

	return anim
end

function Animation.SlideIn(
	instance: Instance,
	direction: string,
	distance: number?,
	duration: number?
): AnimationObject
	local distance = distance or 50
	local duration = duration or 0.3
	local anim = Animation.new(instance)

	if instance:IsA("GuiObject") then
		local gui = instance :: GuiObject
		local originalPos = gui.Position

		if direction == "left" then
			gui.Position = originalPos - UDim2.new(0, distance, 0, 0)
			anim:To({ Position = originalPos }, duration)
		elseif direction == "right" then
			gui.Position = originalPos + UDim2.new(0, distance, 0, 0)
			anim:To({ Position = originalPos }, duration)
		elseif direction == "up" then
			gui.Position = originalPos - UDim2.new(0, 0, 0, distance)
			anim:To({ Position = originalPos }, duration)
		elseif direction == "down" then
			gui.Position = originalPos + UDim2.new(0, 0, 0, distance)
			anim:To({ Position = originalPos }, duration)
		end
	end

	return anim
end

function Animation.Scale(
	instance: Instance,
	scaleX: number,
	scaleY: number?,
	duration: number?
): AnimationObject
	local scaleY = scaleY or scaleX
	local duration = duration or 0.3
	local anim = Animation.new(instance)

	if instance:IsA("GuiObject") then
		anim:To({ Size = UDim2.new(scaleX, 0, scaleY, 0) }, duration)
	end

	return anim
end

function Animation:To(properties: { [string]: any }, duration: number?): AnimationObject
	local duration = duration or self._config.Duration
	local tweenInfo = TweenInfo.new(
		duration,
		self._config.EasingStyle,
		self._config.EasingDirection,
		self._config.RepeatCount,
		self._config.Reverses,
		self._config.Delay
	)

	local tween = Utility.Tween(self._instance, tweenInfo, properties)
	table.insert(self._tweens, tween)

	return self
end

function Animation:Play(): ()
	if self._isPlaying then
		return
	end

	self._isPlaying = true

	for _, tween in ipairs(self._tweens) do
		tween:Play()
	end
end

function Animation:Pause(): ()
	if not self._isPlaying then
		return
	end

	for _, tween in ipairs(self._tweens) do
		tween:Pause()
	end
end

function Animation:Stop(): ()
	self._isPlaying = false

	for _, tween in ipairs(self._tweens) do
		tween:Cancel()
	end
end

function Animation:Cleanup(): ()
	self:Stop()

	for _, connection in ipairs(self._connections) do
		if connection and connection.Connected then
			connection:Disconnect()
		end
	end

	table.clear(self._tweens)
	table.clear(self._connections)
end

function Animation.Chain(...: AnimationObject): () -> ()
	local animations = { ... }
	local index = 1

	local function playNext()
		if index <= #animations then
			local current = animations[index]
			local connection
			connection = current._tweens[#current._tweens].Completed:Connect(function()
				if connection then
					connection:Disconnect()
				end
				index = index + 1
				playNext()
			end)
			current:Play()
		end
	end

	return playNext
end

function Animation.Parallel(...: AnimationObject): () -> ()
	local animations = { ... }

	return function()
		for _, anim in ipairs(animations) do
			anim:Play()
		end
	end
end

return Animation
