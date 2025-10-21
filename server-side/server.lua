-----------------------------------------------------------------------------------------------------------------------------------------
-- kadu
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vSERVER = {}
Tunnel.bindInterface("hud",vSERVER)
vCLIENT = Tunnel.getInterface("hud")

vRP.Prepare("gangs/getXP", "SELECT * FROM characters WHERE id = @id")


function vSERVER.getLevel()
    local source = source
    local Passport = vRP.Passport(source)
    if not Passport then return end

    local row = vRP.Query("gangs/getXP", { id = Passport })
    if row and row[1] then
        return row[1].xp
    end
end

function vSERVER.totalPlayers()
    local source = source
    local Passport = vRP.Passport(source)
    if not Passport then return end

    local totalPlayers = #GetPlayers()
    return totalPlayers
end


-- 
function GetSteamID64(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        if string.sub(id, 1, 6) == "steam:" then
            return tostring(tonumber(string.sub(id, 7), 16)) -- Converte para SteamID64
        end
    end
    return nil
end


getAvatar = function(source, callback)
    local steamId64 = GetSteamID64(source)
    if not steamId64 then
        print("SteamID não encontrado para o jogador " .. source)
        callback(nil)
        return
    end

    local apiKey = "04484DDF0A29E116803DDBD4A78F8C08"
    local url = "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=" .. apiKey .. "&steamids=" .. steamId64

    PerformHttpRequest(url, function(statusCode, response, headers)
        if statusCode == 200 then
            local data = json.decode(response)
            if data and data.response and data.response.players and #data.response.players > 0 then
                local avatarUrl = data.response.players[1].avatarmedium
                callback(avatarUrl) 
            else
                print("Nenhum jogador encontrado na resposta da Steam API.")
                callback(nil)
            end
        else
            print("Erro na requisição HTTP: " .. statusCode)
            callback("Logo.png")
        end
    end, "GET", "", { ["Content-Type"] = "application/json" })
end

vSERVER.getAvatar = function()
    local source = source
    getAvatar(source, function(avatar)
        if avatar then
            vCLIENT.avatar(source,avatar)
        end
    end)
end

AddEventHandler("Connect", function(Passport, source)
    vCLIENT.getInfos(source)
    vCLIENT.startHud(source)
    Wait(500)
    getAvatar(source, function(avatar)
        if avatar then
            vCLIENT.avatar(source,avatar)
        end
    end)
end)