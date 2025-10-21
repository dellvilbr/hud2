-----------------------------------------------------------------------------------------------------------------------------------------
-- Hud
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vClient = {}
Tunnel.bindInterface("hud",vClient)
vSERVER = Tunnel.getInterface("hud")

---
local baseXP = 100
local fator = 1.5
local maxLevel = 80
local xpBase = 0
local totalPlayers = 0
local abates = 0
local active = false

local hotbar = {
    { id = 1, icon = nil },
    { id = 2, icon = nil },
    { id = 3, icon = nil },
    { id = 4, icon = "knife.png" },
}

local categoriaParaSlot = {
    Fuzil = 1,
    Sub = 2,
    Pistola = 3
}


function getXPToNextLevel(level)
    return math.floor(baseXP * (level ^ fator))
end

function getLevelFromXP(totalXP)
    local level = 1
    local xpAcumulado = 0

    if not totalXP then
        totalXP = 0
    end

    while true do
        local xpParaLevel = getXPToNextLevel(level)
        if totalXP < xpAcumulado + xpParaLevel or level >= maxLevel then
            break
        end
        xpAcumulado = xpAcumulado + xpParaLevel
        level = level + 1
    end

    local xpAtual = totalXP - xpAcumulado
    local xpProximo = getXPToNextLevel(level)
    local xpFalta = xpProximo - xpAtual

    return level, xpAtual, xpProximo, xpFalta
end
--

vClient.startHud = function()
    CreateThread(function()
        Wait(500)
        SendNUIMessage({ action = "setVisible", data = true })
        active = true

        SendNUIMessage({
            action = "setHotbar",
            data = hotbar
        })

        while true do 
            local ped = GetPlayerPed(-1)
            local health = GetEntityHealth(ped)
            local healthPercent = math.floor(((health - 100) / 100) * 100)
            healthPercent = math.max(0, math.min(healthPercent, 100))
            
            SendNUIMessage({ action = "setHealth", data = healthPercent })
            SendNUIMessage({ action = "setAbates", data = abates })
    

            local level, xpAtualNoNivel, xpParaProximo = getLevelFromXP(xpBase)
            SendNUIMessage({ action = "setLevel", data = level })
            SendNUIMessage({ action = "ui:setXp", data = {
                xp = xpAtualNoNivel,
                xpMax = xpParaProximo,
            } })
            SendNUIMessage({ action = "setPlayers", data = totalPlayers })


            Wait(0)
        end
    end)
end

RegisterCommand("hud", function()
    if not active then 
        xpBase = vSERVER.getLevel()
        totalPlayers = vSERVER.totalPlayers()
        vClient.startHud()
        Wait(500)
        vSERVER.getAvatar()
    end

end)

vClient.avatar = function(url)
    SendNUIMessage({ action = "setAvatar", data = url })
end

vClient.getInfos = function()
    xpBase = vSERVER.getLevel()
    totalPlayers = vSERVER.totalPlayers()
end

    
CreateThread(function()
    while true do
        totalPlayers = vSERVER.totalPlayers()
        Wait(60000)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- Kill
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Kill")
AddEventHandler("Kill", function(name, xp)
    xpBase = xpBase + xp
    abates = abates + 1
    SendNUIMessage({
        action = "kill",
        data = {
            name = name,
            xp = xp
        }
    })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Kill 2
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Kill2")
AddEventHandler("Kill2", function(nameattacker, namevictim,idattacker,idvictim)
    SendNUIMessage({
        action = "kill2",
        data = {
            nameattacker = nameattacker,
            namevictim = namevictim,
            idattacker = idattacker,
            idvictim = idvictim
        }
    })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- Kill
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent("hud:updateSlotArma")
AddEventHandler("hud:updateSlotArma", function(categoria, arma)
    local slot = categoriaParaSlot[categoria]
    if slot then
        hotbar[slot].icon = arma
        SendNUIMessage({
            action = "setHotbar",
            data = hotbar
        })

    else
        print(("Categoria '%s' não reconhecida"):format(categoria))
    end
end)

RegisterNetEvent("survival")
AddEventHandler("survival", function(bool)
    SendNUIMessage({ action = "setHover", data = bool })
end)

CreateThread(function() 
    Wait(500)
    ExecuteCommand("hud")
end)