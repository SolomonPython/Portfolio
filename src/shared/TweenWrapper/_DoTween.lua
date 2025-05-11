--!strict

-- TYPES --
-----------------------------------------
export type Options = {
    Duration: number?;
    EasingStyle: Enum.EasingStyle?;
    EasingDirection: Enum.EasingDirection?;
    OnComplete: (any) -> ()?;
    CancelPrevious: boolean?
}

-- SERVICES --
-----------------------------------------
local TweenService = game:GetService("TweenService")
local _DoTween = {}

-- DEFAULT SETTINGS --
-----------------------------------------
local activeTweens = {}
_DoTween.Defaults = { 
	Duration = 0.5,
	EasingStyle = Enum.EasingStyle.Sine,
	EasingDirection = Enum.EasingDirection.InOut,
}

local function createTween(
	instance : Instance, 
	properties : { [string]: any },
	duration : number?, 
	easingStyle : Enum.EasingStyle? , 
	easingDirection : Enum.EasingDirection?
): Tween

    assert(instance:IsA("GuiObject"), "The provided object is not a GuiObject.")
		
	local tweenInfo = TweenInfo.new(
		duration or _DoTween.Defaults.Duration,
		easingStyle or _DoTween.Defaults.EasingStyle,
		easingDirection or _DoTween.Defaults.EasingDirection
	)

	return TweenService:Create(instance, tweenInfo, properties)
end

-- Function to tween in (show) the GUI
function _DoTween.Play(
	instance : Instance, 
	properties : { [string]: any }, 
    options: Options
): Tween 

    assert(instance:IsA("GuiObject"), "The provided object is not a GuiObject.")
    assert(typeof(properties) == "table", "The properties table is not valid.")

    options = options or {}

    local tween = createTween(
        instance,
        properties,
        options.Duration,
        options.EasingStyle,
        options.EasingDirection
    )

   -- Cancel existing tween if requested
    if options.CancelPrevious and activeTweens[instance] then
        activeTweens[instance]:Cancel()
    end

    activeTweens[instance] = tween


    tween.Completed:Once(function(...)
        if options.OnComplete then 
            options.OnComplete(...)
        end
        activeTweens[instance] = nil
    end)

    tween:Play()

	return tween
end

-- ========== DEFAULT TWEEN UTILITIES ========== --

function _DoTween.AttachHoverEffect(
    button: GuiButton,
    duration: number?,
    scaleUp: UDim2?,
    scaleDown: UDim2?
): ()

    assert(button:IsA("GuiButton"), "The provided object is not a GuiButton.")

    local originalSize = button.Size 

    scaleUp = scaleUp or (originalSize + UDim2.fromScale(0.05, 0.05))
    scaleDown =  scaleDown or originalSize

    local finalDuration = duration or 0.15

    button.MouseEnter:Connect(function(): ()
        _DoTween.Play(button, { Size = scaleUp }, { Duration = finalDuration })
    end)

    button.MouseLeave:Connect(function()
        _DoTween.Play(button, { Size = scaleDown }, { CancelPrevious = true })
    end)
end

function _DoTween.AttachClickEffect(
    button: GuiButton,
    clickScale: UDim2?
): ()

    assert(button:IsA("GuiButton"), "The provided object is not a GuiButton.")

    local originalSize = button.Size
	clickScale = clickScale or (originalSize + UDim2.fromScale(0.05, 0.05))

	button.MouseButton1Click:Connect(function(): ()
       

		_DoTween.Play(button, { Size = clickScale }, {
			Duration = 0.1,
			CancelPrevious = true,
			OnComplete = function()
				_DoTween.Play(button, { Size = originalSize }, {
					Duration = 0.1,
					CancelPrevious = true
				})
			end
		})
	end)
end

function _DoTween.AttachPulse(
	button: GuiObject, 
	pulseScale: UDim2?, 
	speed: number?
): ()
	assert(button:IsA("GuiObject"), "The provided object is not a GUIObject.")

	local originalSize = button.Size
	local finalScale = pulseScale or (originalSize + UDim2.fromScale(0.03, 0.03))
	local finalSpeed = speed or 1 

	task.spawn(function(): ()
		while button:IsDescendantOf(game) do
			_DoTween.Play(button, { Size = finalScale }, { Duration = finalSpeed / 2 })
			task.wait(finalSpeed / 2)
            
			_DoTween.Play(button, { Size = originalSize }, { Duration = finalSpeed / 2 })
			task.wait(finalSpeed / 2)
		end
	end)
end

return _DoTween