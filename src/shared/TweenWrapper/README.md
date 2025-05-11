# FEATURES

- Tween any GuiObject with custom properties
- Built-in hover, click, and pulse animations
- Option to cancel previous tweens
- Optional callback when tween completes
- Clean API with simple integration

# SETUP

1. Place `_DoTween` ModuleScript inside `ReplicatedStorage` or any shared location
2. Require it in your LocalScript:

```lua
local DoTween = require(game.ReplicatedStorage:WaitForChild("_DoTween"))
