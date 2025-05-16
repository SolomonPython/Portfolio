-- SERVICES --
------------------------------------
local UserInputService = game:GetService('UserInputService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TweenService = game:GetService('TweenService')
local RunService = game:GetService('RunService')

-- CONSTANTS --
------------------------------------
local GRAVITY = 0.5
local MOVE_SPEED = 0.8
local ZONE_TIME_REQUIRED = 5 -- Required amount of time to be within the zone to win

-- VARIABLES --
------------------------------------
local isPlaying = false
local isHolding = false
local timeInZone = 0
local gameTime = 0

local renderConnection: RBXScriptConnection? = nil
local timerConnection: RBXScriptConnection? = nil

local fishingEvent: RemoteEvent = ReplicatedStorage:WaitForChild("path.to.event")

-- INTERFACE --
------------------------------------
local RootGui = script.Parent
local GameFrame = RootGui.GameFrame
local Container = GameFrame.BarContainer
local MoveBar = Container.MoveBar
local PlayerBar = Container.PlayerBar
local TimerBar = GameFrame.TimerContainer
local Timer = TimerBar.TimerFrame

-- HELPERS --
------------------------------------
local function GetRandoms()
    local randomY = math.random(30, 98) / 100
    local duration = math.random(1, 1.5)

    return randomY, duration
end

-- FUNCTONS --
------------------------------------
local function MoveTargetBar()
    while isPlaying do
        local randomY, duration = GetRandoms()

        local tweenInfo = TweenInfo.new(
            duration, 
            Enum.EasingStyle.Sine, 
            Enum.EasingDirection.InOut
        )
        local goal = {Position = UDim2.new(0.5, 0, randomY, 0)}
        local tween = TweenService:Create(MoveBar, tweenInfo, goal)

        tween:Play()
        tween.Completed:Wait()

        if not isPlaying then
            break
        end
   end
end

local function OnInputBegan(input: InputObject, isProcessed: boolean)
	if isProcessed or not isPlaying then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 
    or input.UserInputType == Enum.UserInputType.Touch then

		isHolding = true
	end
end

local function OnInputEnded(input: InputObject, isProcessed: boolean)
	if isProcessed or not isPlaying then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 
    or input.UserInputType == Enum.UserInputType.Touch then

		isHolding = false
	end
end

local function EndGame(result: boolean)
    if not isPlaying then
        return
    end

    isPlaying = false
    RootGui.Enabled = false 

    if renderConnection then
        renderConnection:Disconnect()
        renderConnection = nil 
    end

    if timerConnection then
        timerConnection:Disconnect()
        timerConnection = nil
    end

    fishingEvent:FireServer(result)
end

local function StartTimer(duration: number)
    gameTime = duration

    while isPlaying and gameTime > 0 do
        local start = tick()

        local goal = {Size = UDim2.new(1, 0, gameTime / duration, 0)}
        local tweenInfo = TweenInfo.new(
            1,
            Enum.EasingStyle.Linear
        )

        local tween = TweenService:Create(Timer, tweenInfo, goal)
        tween:Play()

       repeat
			task.wait()
		until tick() - start >= 1

		gameTime -= 1
    end

    if isPlaying then
        EndGame(false)
    end
end

local function CheckInBounds(playerTop, playerBottom, barTop, barBottom): boolean
    return playerBottom >= barTop and playerTop <= barBottom
end

local function StartGame(duration: number)
    if isPlaying then 
        return 
    end

    isPlaying = true 
    RootGui.Enabled = true 

    timeInZone = 0
    PlayerBar.Position = UDim2.new(0.5, 0, .98, 0)

    task.spawn(MoveTargetBar)
    task.spawn(StartTimer, duration)

    renderConnection = RunService.RenderStepped:Connect(function(deltaTime: number)
        if not isPlaying then
            return
        end

        local barPosition = PlayerBar.Position.Y.Scale 
        if isHolding then 
            barPosition = math.max(barPosition - (MOVE_SPEED * deltaTime), 0.1)
        else 
            barPosition = math.min(barPosition + (GRAVITY * deltaTime),.98)
        end
        PlayerBar.Position = UDim2.new(0.5, 0, barPosition, 0)

        local InBounds = CheckInBounds(
           PlayerBar.AbsolutePosition.Y,
           PlayerBar.AbsolutePosition.Y + PlayerBar.AbsoluteSize.Y,
           MoveBar.AbsolutePosition.Y,
           MoveBar.AbsolutePosition.Y + MoveBar.AbsoluteSize.Y
        )

        -- Possible use of haptics here for mobile
        if InBounds then
            timeInZone += deltaTime
        else 
            timeInZone = math.max(timeInZone - (deltaTime * 0.5), 0) -- Slowly Decrease Time
        end

        if timeInZone >= ZONE_TIME_REQUIRED then
            EndGame(true)
        end
    end)
end

-- EVENT CONNECTIONS --
------------------------------------
UserInputService.InputBegan:Connect(OnInputBegan)
UserInputService.InputEnded:Connect(OnInputEnded)
fishingEvent.OnClientEvent:Connect(StartGame)