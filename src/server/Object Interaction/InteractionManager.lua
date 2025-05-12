--!strict

local InteractionManager = {}
InteractionManager.__index = InteractionManager

InteractionManager.Interactions = {}

-- IMPORT --
-----------------------------------
local Interaction = require(script.Parent.Interaction)

function InteractionManager:register(
    name: string, 
    onInteracted: () -> (), 
    object: Model
)

    local interaction = Interaction.new(name, onInteracted, object)
    if not interaction then
        warn("Failed to create interaction: ".. name)
        return nil
    end
    
    self.Interactions[interaction.name] = interaction
    return interaction
end

function InteractionManager:unregister(name: string)
    local interaction = self.Interactions[name]
    if interaction then
        if typeof(interaction.destroy) == "function" then
            interaction:destroy()
        end
        self.Interactions[name] = nil
    end
end

function InteractionManager:triggerInteraction(name: string)
    if self.Interactions[name] then
        self.Interactions[name]:interact()
    end
end


return InteractionManager 