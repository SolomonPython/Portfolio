# FEATURES

- Register object interactions using a unique name
- Simple class-based structure for easy expansion
- Trigger interactions programmatically
- Unregister and clean up interactions at any time
- Clean interface for connecting models to logic
- Minimal and efficient structure for scalable use

# SETUP

1. Place the `InteractionManager` module and its required `Interaction` module in the same folder (e.g., `ReplicatedStorage.Modules`).

2. In a server-side Script or ModuleScript, require the `InteractionManager` and use it like this:

```lua
local InteractionManager = require(path.to.InteractionManager)

-- Register an interaction
InteractionManager:register("CoffeeMachine", function()
    print("Coffee dispensed!")
end, workspace.CoffeeMachine)

-- Trigger interaction manually
InteractionManager:triggerInteraction("CoffeeMachine")

-- Unregister when done
InteractionManager:unregister("CoffeeMachine")
