--!strict

-- SETTINGS --
-----------------------------------------
local SETTINGS = {
    BASE_EXP = 100,
    INCREMENT = 150,
    MAX_LEVEL = 100,
}

local Level = {}

-- HELPERS --
-----------------------------------------
local function getExpRequired(player: Player): number -- EXP | LEVEL FORMULA HERE
    local level = Level.getLevel(player) :: number
    if level and level < SETTINGS.MAX_LEVEL then 
        return SETTINGS.BASE_EXP + (SETTINGS.INCREMENT * (level - 1))
    else 
        warn("Level was not found")
        return math.huge
    end
end

function Level.addExp(player: Player, amount: number)
    if Level.isMaxLevel(player) then
        warn("Player reached maximum level")
        return
    end

    local currentExp: number = Level.getExp(player) :: number
    local currentLevel = Level.getLevel(player) :: number
    local newExp = currentExp + amount

    while not Level.isMaxLevel(player) do
        local requiredExp = getExpRequired(player)

        if newExp >= requiredExp then 
            newExp -= requiredExp
            currentLevel += 1

            player:SetAttribute("LEVEL", currentLevel)
            Level.updateLevel(player)
        else 
            break
        end
    end
    player:SetAttribute("EXP", Level.isMaxLevel(player) and 0 or newExp)
end

function Level.updateLevel(_: Player) -- Use this to update the level through a datastore!
    return true
end

function Level.isMaxLevel(player: Player)
    return Level.getLevel(player) >= SETTINGS.MAX_LEVEL
end

function Level.getLevel(player: Player)
    return player:GetAttribute("LEVEL") or 1
end

function Level.getExp(player: Player)
    return player:GetAttribute("EXP") or 0
end


return Level