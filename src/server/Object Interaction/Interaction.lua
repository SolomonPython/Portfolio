--!strict

-- TYPES --
--------------------------
type InteractionData = {
    Type: "ProximityPrompt" | "ClickDetector",
    Func: "Triggered" | "MouseClick",
    Instance: ProximityPrompt | ClickDetector
}

export type IObject = {
    name: string;
    onInteracted: ()->();
    OnInteractedbject: Model | BasePart;

    interactMethod: string?;
    interactFunc: string?;
    connection: RBXScriptConnection?;

    --// Object Methods
    new: (
        name: string,
        onInteracted: ()->(),
        object: Model | BasePart
    ) -> IObject?;
    interact: (self: IObject) -> ();
    destroy:(self: IObject) -> ()
}

local Interaction: IObject = {} :: IObject

local function resolveType(object: any): InteractionData?
    local interactInstance = object:FindFirstChildWhichIsA("ProximityPrompt", true)
    if interactInstance then
        return {
            Type = "ProximityPrompt",
            Func = "Triggered",
            Instance = interactInstance
        }
    end

    interactInstance = object:FindFirstChildWhichIsA("ClickDetector", true)
    if interactInstance then
        return {
            Type = "ClickDetector",
            Func = "MouseClick",
            Instance = interactInstance
        }
    end

    return nil
end

function Interaction.new(
    name: string, 
    onInteracted: ()->(), 
    object: Model | BasePart
)
    local self = setmetatable({
        name = name,
        onInteracted = onInteracted,
        object = object,
    }, {__index = Interaction}) :: any

    local data = resolveType(object)
    if data then
        self.interactMethod = data.Instance
        self.interactFunc = data.Func
    end

    if self.interactMethod and self.interactFunc then
        self.connection = self.interactMethod[self.interactFunc]:Connect(function(_)
            self:interact()
        end)
    else
        error("Unable to find an interaction method for the provided object.")
        return nil
    end

    return self
end

function Interaction:interact()
    self.onInteracted()
end

function Interaction:destroy()
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end
end

return Interaction