--!strict

-- TYPES --
---------------------------
export type ICutscene = {

	--// Instance Properties
	camera: Camera,
	targetCFrames: {CFrame},
	duration: number?,
	easingStyle: Enum.EasingStyle?,
	easingDirection: Enum.EasingDirection?,
	tweens: {Tween},
	isComplete: boolean,
    shouldLoop: boolean?,
    loopCount: number?,

	--// Instance Methods
	new: (
		camera: Camera,
		targetCFrames: {CFrame},
		duration: number?,
		easingStyle: Enum.EasingStyle?,
		easingDirection: Enum.EasingDirection?,
        shouldLoop: boolean?,
        loopCount: number?
	) -> ICutscene,

	Start: (self: ICutscene, onComplete: () -> ()) -> (),
	End: (self: ICutscene) -> (),
	Add: (self: ICutscene, targets: {CFrame}) -> ()
}

-- SERVICES --
----------------------------------------
local TweenService = game:GetService('TweenService')

-- MODULE TABLE --
----------------------------------------
local Cutscene: ICutscene = {} :: ICutscene

-- CONSTRUCTOR --
----------------------------------------
function Cutscene.new(
	camera: Camera,
	targetCFrames: {CFrame},
	duration: number?,
	easingStyle: Enum.EasingStyle?,
	easingDirection: Enum.EasingDirection?,

    -- Optional looping parameters
    shouldLoop: boolean?,
    loopCount: number?
): ICutscene

	-- Create and return a new cutscene object with default or provided parameters
	local self = setmetatable({
		camera = camera, 
		targetCFrames = targetCFrames,
		duration = duration or 5,
		easingStyle = easingStyle or Enum.EasingStyle.Sine,
		easingDirection = easingDirection or Enum.EasingDirection.InOut,
		tweens = {},
		isComplete = false,
        shouldLoop = shouldLoop or false,
        loopCount = loopCount
	}, {__index = Cutscene}) :: any

	return self
end

-- METHODS --
----------------------------------------

-- Starts the cutscene animation
function Cutscene:Start(onComplete: () -> ()?): ()
	local loopCounter = 0
	
	task.spawn(function()
		while not self.isComplete do 
            local index = 1 

            -- Step through each CFrame in the sequence
            while index <= #self.targetCFrames do 
                if self.isComplete then 
                    return
                end

                local target = self.targetCFrames[index]

                -- Create tween for camera transition
                local info = TweenInfo.new(
                    self.duration,
                    self.easingStyle,
                    self.easingDirection
                )
                local tween = TweenService:Create(self.camera, info, {CFrame = target})
                table.insert(self.tweens, tween)

                -- Set camera mode and start tween
                self.camera.CameraType = Enum.CameraType.Scriptable
                tween:Play()
                tween.Completed:Wait()

                -- Final CFrame assignment to ensure precision
                self.camera.CFrame = target 
                index += 1
            end

            -- Increment loop counter and check loop conditions
            loopCounter += 1
            if not self.shouldLoop then 
                break 
            end
            if self.loopCount and loopCounter >= self.loopCount then
                break
            end
		end

        -- Call completion callback if provided
        if onComplete then
            onComplete()
        end
	end)
end

-- Ends the cutscene prematurely and cleans up
function Cutscene:End(): ()
	self.isComplete = true

	-- Cancel all tweens and reset camera
	for _, tween in ipairs(self.tweens) do
		tween:Cancel()
	end 
	self.tweens = {}

	self.camera.CameraType = Enum.CameraType.Custom
end

-- Adds one or more new target CFrames to the sequence
function Cutscene:Add(targets: {CFrame})
	if self.isComplete then return end

	for _, target in ipairs(targets) do
		table.insert(self.targetCFrames, target)
	end
end

return Cutscene
