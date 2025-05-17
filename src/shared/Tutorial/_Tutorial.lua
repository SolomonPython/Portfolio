--!strict

export type Tutorial = {
	title: string,
	pages: { string },
	currentPage: number,
	_connections: { RBXScriptConnection }?,
	_animating: boolean,

	new: (title: string, pages: { string }) -> Tutorial?,
	next: (self: Tutorial) -> (),
	prev: (self: Tutorial) -> (),
	animate: (self: Tutorial, text: string) -> (),
	tweenOpen: (self: Tutorial) -> (),
	tweenClose: (self: Tutorial, onComplete: () -> ()?) -> (),
	destroy: (self: Tutorial) -> (),
	start: () -> (),
}

-- SERVICES --
-----------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- OPTIONAL SOUND STORAGE
--// local SoundService = game:GetService("SoundService") -- Change this to anywhere you store your sounds (SoundService, ReplicatedStorage, Etc)

-- VARIABLES --
-----------------------------------------
local Cache = {} :: {[string]: any} -- Element Cache
local ActiveTutorial: Tutorial? = nil -- Current Active Tutorial Object

local LocalPlayer = Players.LocalPlayer :: Player
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui
local RootGui = PlayerGui:WaitForChild("Tutorial") :: ScreenGui
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut) :: TweenInfo

--// SOUND_REFERENCE: local TextSound = ""

-- TWEEN SIZE SETTINGS --
-----------------------------------------
local Settings = {
	xSize = 0.4, -- xSize for container
	ySize = 0.5, -- ySize for container
}

-- PRIVATE FUNCTIONS --
-----------------------------------------
local function CacheElements(root: ScreenGui): ()
	local AllowedTypes = { -- ADD MORE TYPES IF NEEDED
		TextLabel = true,
		TextButton = true,
		Frame = true,
	}

	for _, element in ipairs(root:GetDescendants()) do
		if AllowedTypes[element.ClassName] then
			Cache[element.Name] = element
		end
	end
end

local function UpdateCurrentPage(self): () -- UPDATES THE CURRENT PAGE
	local PageLabel = Cache["PageLabel"] :: TextLabel
	if not PageLabel then
		return
	end

	if self.currentPage and self.pages then
		PageLabel.Text = `{self.currentPage}/{#self.pages}`
	end
end

local _Tutorial: Tutorial = {} :: Tutorial

function _Tutorial.start()
	CacheElements(RootGui)
end

function _Tutorial.new(title: string, pages: { string }): Tutorial?
	if not title or not pages then
		error("Title or Pages not found")
	end

	if ActiveTutorial then

		-- Store parameters in a closure
		local function createAfterClose()
			_Tutorial.new(title, pages)
		end

		-- Close current and set up new one afterward
		ActiveTutorial:tweenClose(createAfterClose)
		return nil
	end

	local self = setmetatable({
		title = title,
		pages = pages,
		currentPage = 1,
		_animating = false,
	}, { __index = _Tutorial }) :: any

	local Next = Cache["Next"] :: TextButton
	local Prev = Cache["Prev"] :: TextButton
	local Close = Cache["Close"] :: TextButton
	local Title = Cache["Title"] :: TextLabel

	if not Next or not Prev or not Close or not Title then
		warn("Button not found")
		return nil
	end

	Title.Text = self.title

	self._connections = {
		Next.MouseButton1Click:Connect(function(): ()
			self:next()
		end),

		Prev.MouseButton1Click:Connect(function(): ()
			self:prev()
		end),

		Close.MouseButton1Click:Connect(function(): ()
			self:tweenClose()
		end),
	}

	UpdateCurrentPage(self)
	self:tweenOpen()

	ActiveTutorial = self

	return self
end

function _Tutorial:next(): ()
	if not self.pages then
		return
	end
	if self._animating then
		return
	end

	-- Called on next button clicked
	if self.currentPage + 1 > #self.pages then
		self:animate(self.pages[self.currentPage])
		return
	end

	self.currentPage += 1
	UpdateCurrentPage(self)
	self:animate(self.pages[self.currentPage])
end

function _Tutorial:prev(): ()
	if not self.pages then
		return
	end
	if self._animating then
		return
	end

	-- Called on prev button clicked
	if self.currentPage - 1 < 1 then
		self:animate(self.pages[self.currentPage])
		return
	end

	self.currentPage -= 1

	UpdateCurrentPage(self)
	self:animate(self.pages[self.currentPage])
end

function _Tutorial:animate(text: string): ()
	if self._animating then
		return
	end
	self._animating = true

	local BodyLabel = Cache["BodyLabel"] :: TextLabel
	if not BodyLabel then
		self._animating = false
		return
	end

	BodyLabel.Text = ""

	local lastPlayTime = 0
	for i = 1, #text do
		if not self._animating then
			break
		end

		BodyLabel.Text = string.sub(text, 1, i)

		local now = tick()
		if now - lastPlayTime >= 0.05 then
			--// PLAY SOUND: TextSound:Play()
			lastPlayTime = now
		end

		task.wait(0.05)
	end

	self._animating = false
end

function _Tutorial:tweenOpen(): ()
	if not self.pages then
		return
	end

	-- Called when opened
	local Container = Cache["Container"] :: Frame
	if not Container then
		return
	end

	local BodyLabel = Cache["BodyLabel"] :: TextLabel
	if not BodyLabel then
		return
	end

	BodyLabel.Text = ""

	Container.Visible = true

	local tween = TweenService:Create(Container, tweenInfo, { Size = UDim2.fromScale(Settings.xSize, Settings.ySize) })

	tween:Play()

	tween.Completed:Connect(function()
		self:animate(self.pages[self.currentPage])
	end)
end

function _Tutorial:tweenClose(onComplete: (() -> ())?)
	local Container = Cache["Container"] :: Frame
	if not Container then
		return
	end

	--//STOP SOUND HERE: 

	--TextSound:Stop()
	--TextSound.TimePosition = 0 -- Ensures it's fully reset

	self._animating = false

	local tween = TweenService:Create(Container, tweenInfo, { Size = UDim2.fromScale(0, 0) })

	tween:Play()

	tween.Completed:Connect(function(): ()
		Container.Visible = false
		self:destroy()

		if onComplete then
			onComplete()
		end
	end)
end

function _Tutorial:destroy(): ()
	if ActiveTutorial == self then
		ActiveTutorial = nil
	end

	if self._connections then
		for _, conn: RBXScriptConnection in ipairs(self._connections) do
			if conn and conn.Disconnect then
				conn:Disconnect()
			end
		end
		self._connections = nil
	end

	local Container = Cache["Container"] :: Frame
	if Container then
		Container.Visible = false
	end

	self.pages = {}

	
	table.clear(self)
	setmetatable(self, nil)
end

return _Tutorial
