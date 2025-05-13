--!strict

-- SERVICES --
----------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- VARIABLES --
----------------------------------------
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local SETTINGS = { -- REPEATED DATA (BETTER TO STORE IN A SHARED MODULE)
	BASE_EXP = 100,
	INCREMENT = 150,
	MAX_LEVEL = 100,
}

local Cache = {}

-- UI --
----------------------------------------
local DemoRoot = PlayerGui:WaitForChild("Demo")


--[[ QUICK CACHE ACCESS TO GET USER INTERFACE ]]
local function QuickCache()
	for _, item in ipairs(DemoRoot:GetDescendants()) do
		Cache[item.Name] = item
	end
end

-- [[ GET EXP REQUIRED SHOULD BE IN A SHARED MODULE IN A REAL GAME ]]
local function getExpRequired(level: number): number
	if level and level < SETTINGS.MAX_LEVEL then 
		return SETTINGS.BASE_EXP + (SETTINGS.INCREMENT * (level - 1)) 
	else
		return math.huge
	end
end

-- HANDLES TWEENING THE UI
local function UpdateInterface()
	local level = LocalPlayer:GetAttribute("LEVEL") or 1 
	local exp = LocalPlayer:GetAttribute("EXP") or 0

	local expRequired = getExpRequired(level) 

	local LevelDisplayText = Cache["LEVEL_DISPLAY"] :: TextLabel
	local ExpDisplayText = Cache["EXP_DISPLAY"] :: TextLabel
	local ExpBar = Cache["ControlledFrame"] :: Frame

	if LevelDisplayText then
		LevelDisplayText.Text = "Level: " .. tostring(level)
	end

	if ExpDisplayText then
		ExpDisplayText.Text = tostring(exp) .. " / " .. expRequired
	end

	if ExpBar then
		local goalScale = math.clamp(exp / expRequired, 0, 1)
		local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local tween = TweenService:Create(ExpBar, tweenInfo, {
			Size = UDim2.fromScale(goalScale, 1)
		})

		tween:Play()
	end
end

-- HANDLES CLIENT RESPONSE TO LEVEL/EXP CHANGES
local function SignalChange()
	LocalPlayer:GetAttributeChangedSignal("EXP"):Connect(UpdateInterface)
	LocalPlayer:GetAttributeChangedSignal("LEVEL"):Connect(UpdateInterface)
end

-- INIT --
----------------------------------------
task.spawn(function()
	QuickCache()
	SignalChange()
	UpdateInterface()
end)
