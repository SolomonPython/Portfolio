--[[
    Test Dialogue System (To be improved)
]]


--!strict 

-- SERVICES --
----------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- IMPORTS --
----------------------------------------
local Maid = require(ReplicatedStorage.Packages:WaitForChild("maid"))

-- MAIN --
----------------------------------------
local _Dialogue = {}
_Dialogue.__index = _Dialogue

-- DATA --
----------------------------------------
local Cache = {} -- Stores any UI that is instantiated, and clears table on cleanup

-- VARIABLES --
----------------------------------------
local Root = nil
local DialogueLabel = nil

-- HELPER FUNCTIONS --
----------------------------------------
local function generateRoot(name: string): ()
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

    Root = Instance.new("ScreenGui")
    Root.Name = name
    Root.Parent = PlayerGui

    DialogueLabel = Instance.new("TextLabel") 
    DialogueLabel.Name = "DialogueLabel"
    DialogueLabel.Text = ""
    DialogueLabel.TextSize = 24
    DialogueLabel.BackgroundTransparency = 1
    DialogueLabel.TextColor3 = Color3.new(1, 1, 1)
    DialogueLabel.Font = Enum.Font.ArialBold
    DialogueLabel.Parent = Root
    DialogueLabel.Position = UDim2.fromScale(0.5, 0.5)

    Cache[DialogueLabel.Name] = DialogueLabel :: any
    Cache[name] = Root :: any
end

local function createTemplate(index: number, text: string): (Frame?)
    if not Root then return end

    local Template = ReplicatedStorage.Dialogue.Template:Clone()
    Template.Name = "Choice_" .. index
    Template.Position = UDim2.fromScale(0.3, 0.5) + UDim2.new(0, 0, 0, index * 50)

    local label = Template.Index
    label.Text = `[{index}]`

    local button = Template.TextButton
    button.Text = text

    Template.Parent = Cache[Root.Name] -- Your Screen Gui Here

    return Template
end

-- CONSTRUCTOR --
----------------------------------------
function _Dialogue.new(
    choices: {string},
    responses: any,  
    branches: any,  
    onDialogueComplete: () -> ()
): any 

    if not Root and not DialogueLabel then -- Generate the UI if it doesn't exist yet
       generateRoot("Dialogue")
    end

    local dialogue = setmetatable({
        choices = choices,
        responses = responses,
        branches = branches,
        onDialogueComplete = onDialogueComplete
    }, _Dialogue)

    dialogue._connections = {}
    dialogue.maid = Maid.new()

    dialogue.maid:GiveTask(function()
        for index, _: RBXScriptConnection in pairs(dialogue._connections) do
            dialogue._connections[index]:Disconnect()
        end
        dialogue._connections = {}
    end)

    dialogue:generateChoices()
   
    return dialogue
end

-- Generates buttons for the player to press
function _Dialogue:generateChoices()
     for _, child in pairs(Root:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    for _, conn in pairs(self._connections) do
        conn:Disconnect()
    end
    self._connections = {} -- Reset connections

    for i, text in ipairs(self.choices) do
        local template = createTemplate(i, text)
        task.wait(0.25)

        if template then
            self.maid:GiveTask(template)

            local button = template:FindFirstChildWhichIsA("TextButton")
            if not button then return end

            -- Connect button click event
           table.insert(self._connections, button.MouseButton1Click:Connect(function()      -- Disconnect all current button connections to prevent multiple triggers
                for _, conn in ipairs(self._connections) do
                    conn:Disconnect()
                end
                
                self._connections = {}
                self:nextOption(i)
            end))
        end
    end
end

-- Handling the result of player choosing the next option
function _Dialogue:nextOption(index: number)
    local response = self.responses[index]
    if not response then return end

    -- Execute the custom callback for this response, if any
    if typeof(response.callback) == "function" then
	    task.spawn(response.callback)
    end

    self:animateText(response.text, function()
        if response.nextDialogue and self.branches[response.nextDialogue] then
            local nextBranch = self.branches[response.nextDialogue]

            local newDialogue = _Dialogue.new(
                nextBranch.choices,
                nextBranch.responses,
                nextBranch.branches or {},
                nextBranch.onDialogueComplete or self.onDialogueComplete
            )

            for k, v in pairs(newDialogue) do
                self[k] = v
            end
        else
            self:exit()
        end
    end)
end

-- Type Writer Effect For Response
function _Dialogue:animateText(text: string, callback: () -> ())
    local displayed = ""
    local label = DialogueLabel

    task.spawn(function()
        for i = 1, #text do
            displayed = string.sub(text, 1, i)
            label.Text = displayed
            task.wait(0.05)
        end

        task.wait(1)

        if callback then 
            callback()
        end
    end)
end

-- Handles the cleanup when all is done
function _Dialogue:exit()
    if self.onDialogueComplete then 
        self.onDialogueComplete()
    end
    table.clear(Cache)
    self.maid:DoCleaning()
end


return _Dialogue

