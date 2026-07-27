--!strict

local Utility = {}

type Connection = {
	Connected: boolean,
	Disconnect: (self: Connection) -> (),
}

type Signal = {
	Fire: (self: Signal, ...any) -> (),
	Connect: (self: Signal, callback: (...any) -> ()) -> Connection,
	Wait: (self: Signal) -> ...any,
	_bindable: BindableEvent,
}

export type UIPadding = {
	Top: number,
	Bottom: number,
	Left: number,
	Right: number,
}

function Utility.Signal(): Signal
	local bindable = Instance.new("BindableEvent")

	local signal: Signal = {
		_bindable = bindable,
		Fire = function(self: Signal, ...: any): ()
			self._bindable:Fire(...)
		end,
		Connect = function(self: Signal, callback: (...any) -> ()): Connection
			return self._bindable.Event:Connect(callback) :: Connection
		end,
		Wait = function(self: Signal): ...any
			return self._bindable.Event:Wait()
		end,
	}

	return signal
end

function Utility.CleanupSignal(signal: Signal): ()
	if signal._bindable then
		signal._bindable:Destroy()
	end
end

function Utility.Tween(
	object: Instance,
	tweenInfo: TweenInfo,
	properties: { [string]: any }
): Tween
	local tweenService = game:GetService("TweenService")
	return tweenService:Create(object, tweenInfo, properties)
end

function Utility.CreateUIPadding(
	parent: Instance,
	config: { Top: number?, Bottom: number?, Left: number?, Right: number? }?
): UIPadding
	local config = config or {}
	local padding: UIPadding = {
		Top = config.Top or 0,
		Bottom = config.Bottom or 0,
		Left = config.Left or 0,
		Right = config.Right or 0,
	}
	return padding
end

function Utility.ApplyPadding(parent: Instance, padding: UIPadding): UIPadding
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, padding.Top)
	uiPadding.PaddingBottom = UDim.new(0, padding.Bottom)
	uiPadding.PaddingLeft = UDim.new(0, padding.Left)
	uiPadding.PaddingRight = UDim.new(0, padding.Right)
	uiPadding.Parent = parent

	return padding
end

function Utility.CreateUICorner(parent: Instance, radius: number): UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
	return corner
end

function Utility.CreateUIStroke(
	parent: Instance,
	color: Color3,
	thickness: number
): UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.Parent = parent
	return stroke
end

function Utility.CreateUIGradient(
	parent: Instance,
	colors: ColorSequence,
	rotation: number?
): UIGradient
	local gradient = Instance.new("UIGradient")
	gradient.Color = colors
	gradient.Rotation = rotation or 0
	gradient.Parent = parent
	return gradient
end

function Utility.LerpColor(c1: Color3, c2: Color3, t: number): Color3
	return Color3.new(
		c1.R + (c2.R - c1.R) * t,
		c1.G + (c2.G - c1.G) * t,
		c1.B + (c2.B - c1.B) * t
	)
end

function Utility.RgbToHsv(color: Color3): (number, number, number)
	local r, g, b = color.R, color.G, color.B
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local delta = max - min

	local h = 0
	local s = max == 0 and 0 or delta / max
	local v = max

	if delta ~= 0 then
		if max == r then
			h = ((g - b) / delta) % 6
		elseif max == g then
			h = (b - r) / delta + 2
		else
			h = (r - g) / delta + 4
		end
		h = h / 6
	end

	return h, s, v
end

function Utility.HsvToRgb(h: number, s: number, v: number): Color3
	local c = v * s
	local x = c * (1 - math.abs((h * 6) % 2 - 1))
	local m = v - c

	local r, g, b = 0, 0, 0

	if h < 1 / 6 then
		r, g, b = c, x, 0
	elseif h < 2 / 6 then
		r, g, b = x, c, 0
	elseif h < 3 / 6 then
		r, g, b = 0, c, x
	elseif h < 4 / 6 then
		r, g, b = 0, x, c
	elseif h < 5 / 6 then
		r, g, b = x, 0, c
	else
		r, g, b = c, 0, x
	end

	return Color3.new(r + m, g + m, b + m)
end

function Utility.Debounce(callback: (...any) -> (), delay: number): (...any) -> ()
	local lastCall = 0

	return function(...: any): ()
		local now = tick()
		if now - lastCall >= delay then
			lastCall = now
			callback(...)
		end
	end
end

function Utility.Throttle(callback: (...any) -> (), delay: number): (...any) -> ()
	local lastCall = 0
	local pending = false
	local pendingArgs: { any } = {}

	return function(...: any): ()
		local now = tick()
		pendingArgs = { ... }

		if now - lastCall >= delay then
			lastCall = now
			callback(...)
			pending = false
		elseif not pending then
			pending = true
			task.delay(delay - (now - lastCall), function()
				if pending then
					lastCall = tick()
					callback(unpack(pendingArgs))
					pending = false
				end
			end)
		end
	end
end

function Utility.DeepClone(tbl: { [string]: any }): { [string]: any }
	local clone: { [string]: any } = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			clone[k] = Utility.DeepClone(v)
		else
			clone[k] = v
		end
	end
	return clone
end

function Utility.Merge(
	tbl1: { [string]: any },
	tbl2: { [string]: any }
): { [string]: any }
	local result = Utility.DeepClone(tbl1)
	for k, v in pairs(tbl2) do
		if type(v) == "table" and type(result[k]) == "table" then
			result[k] = Utility.Merge(result[k], v)
		else
			result[k] = v
		end
	end
	return result
end

function Utility.GetTextSize(
	text: string,
	fontSize: number,
	fontFamily: Enum.Font,
	frameSize: Vector2
): Vector2
	local textService = game:GetService("TextService")

	local textParams = Instance.new("GetTextBoundsParams")
	textParams.Text = text
	textParams.Size = fontSize
	textParams.Font = fontFamily
	textParams.Width = frameSize.X

	local bounds = textService:GetTextBoundsAsync(textParams)
	return bounds
end

function Utility.FormatNumber(num: number): string
	if num >= 1000000 then
		return string.format("%.1fM", num / 1000000):gsub("%.0", "")
	elseif num >= 1000 then
		return string.format("%.1fK", num / 1000):gsub("%.0", "")
	else
		return tostring(num)
	end
end

function Utility.IsPointInBounds(point: Vector2, position: Vector2, size: Vector2): boolean
	return point.X >= position.X
		and point.X <= position.X + size.X
		and point.Y >= position.Y
		and point.Y <= position.Y + size.Y
end

function Utility.ConnectToMouse(
	button: GuiButton,
	onEnter: (() -> ())?,
	onLeave: (() -> ())?
): { [string]: Connection }
	local connections: { [string]: Connection } = {}

	if onEnter then
		connections.MouseEnter = button.MouseEnter:Connect(onEnter)
	end

	if onLeave then
		connections.MouseLeave = button.MouseLeave:Connect(onLeave)
	end

	return connections
end

function Utility.DisconnectConnections(connections: { [string]: Connection }): ()
	for _, connection in pairs(connections) do
		if connection and connection.Connected then
			connection:Disconnect()
		end
	end
end

function Utility.WaitForDescendant(
	parent: Instance,
	name: string,
	timeout: number?
): Instance?
	local timeout = timeout or 30
	local deadline = tick() + timeout

	while tick() < deadline do
		local child = parent:FindFirstChild(name, true)
		if child then
			return child
		end
		task.wait(0.1)
	end

	return nil
end

function Utility.SafeCall(callback: (...any) -> (), ...: any): (boolean, any)
	return pcall(callback, ...)
end

return Utility
