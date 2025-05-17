# Cutscene Module

A fully modular and customizable cutscene handler for Roblox games using `TweenService` and scriptable camera control.

---

## Features

- Plays through a series of `CFrame` positions for cinematic camera movement.
- Clean, class-like structure using metatables.
- Customizable `duration`, `easingStyle`, and `easingDirection`.
- Supports early termination with resource cleanup.
- Supports looping with optional loop count.
- Add new CFrame points dynamically during runtime.
- Callback support after cutscene ends.

---

## Constructor

```lua
Cutscene.new(
    camera: Camera,
    targetCFrames: {CFrame},
    duration: number? = 5,
    easingStyle: Enum.EasingStyle? = Enum.EasingStyle.Sine,
    easingDirection: Enum.EasingDirection? = Enum.EasingDirection.InOut,
    shouldLoop: boolean? = false,
    loopCount: number? = nil -- nil means infinite looping
) -> Cutscene
