# FEATURES

- Singular Module Based Level System (Customizable)
- Clean EXP-to-level formula with cap support
- Simple API for adding EXP and checking level
- Client UI syncs automatically using attribute change signals
- Smooth EXP bar animation using TweenService
- Fully modular and expandable structure

## 2. Example: Server Integration

```lua
local Level = require("path.to.module")

Players.PlayerAdded:Connect(function(player)
    player:SetAttribute("LEVEL", 1)
    player:SetAttribute("EXP", 0)

    -- Add 250 EXP after 5 seconds
    task.delay(5, function()
        Level.addExp(player, 250)
    end)
end)
