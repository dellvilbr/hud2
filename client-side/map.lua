-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Quadrado = true
local Default = 1920 / 1080
local OffsetX,OffsetY = 0,0
local ResolutionX,ResolutionY = GetActiveScreenResolution()
local AspectRatio = ResolutionX / ResolutionY
local AspectDiff = Default - AspectRatio
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSTART
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    if Quadrado then
        if LoadTexture("circleminimap") then
            AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "circleminimap", "radarmasksm")

            SetMinimapComponentPosition("minimap", "L", "B", 0.005, -0.025, 0.175, 0.225)
            SetMinimapComponentPosition("minimap_mask", "L", "B", 0.02, 0.39, 0.1135, 0.5)
            SetMinimapComponentPosition("minimap_blur", "L", "B", -0.02, -0.01, 0.265, 0.225)

            SetBigmapActive(true, false)

            repeat
                Wait(100)
                SetMinimapClipType(1)
                SetBigmapActive(false, false)
            until not IsBigmapActive()

            while Quadrado do
                Wait(100)
                local Ped = PlayerPedId()
                local Vehicle = GetVehiclePedIsIn(Ped, false)
                
                if Vehicle ~= 0 then
                    local Velocidade = GetEntitySpeed(Vehicle) * 3.6
                    
                    if Velocidade < 70 then
                        SetRadarZoom(1100)
                    else
                        SetRadarZoom(1100)
                    end
                else
                    SetRadarZoom(1100)
                end
            end
        end
    end
end)


Citizen.CreateThread(function()
	SetTextChatEnabled(false)
	SetNuiFocus(false)
    SetMinimapComponentPosition('bigmap', 'L', 'B',0.2000,-0.20,0.566, 0.537)
    SetMinimapComponentPosition('bigmap_mask', 'L', 'B',0.2000,-0.20,0.566, 0.537)
    SetMinimapComponentPosition('bigmap_blur', 'L', 'B',0.08,-0.20,0.566, 0.537)
  SetRadarBigmapEnabled(true, false)
  Wait(500)
  SetRadarBigmapEnabled(false, false)
end)

local bigmap = false

RegisterCommand("+bigmap",function()
  if not bigmap then
      bigmap = true
      SetRadarBigmapEnabled(true, false)
  elseif bigmap then
      bigmap = false
      SetRadarBigmapEnabled(false, false)
  end
end)

RegisterKeyMapping('+bigmap', 'aumentar o mapa', 'keyboard', 'm') 