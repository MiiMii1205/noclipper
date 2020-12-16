--[[
  * Écrit par Oracle
  * license MIT
--]]

-- Constantes --
MOVE_UP_KEY = 44
MOVE_DOWN_KEY = 46
CHANGE_SPEED_KEY = 21
MOVE_LEFT_RIGHT = 30
MOVE_UP_DOWN = 31
VEHICLE_NEXT_RADIO = 81
NO_CLIP_NORMAL_SPEED = 1.8
NO_CLIP_FAST_SPEED = 2.5

-- Variables --
local isNoClipping = false
local playerPed = PlayerPedId()
local playerId = PlayerId()
local target = playerPed
local speed
local input

function ToggleNoClipMode()
    SetNoClip(not isNoClipping)
end

function IsControlAlwaysPressed(inputGroup, control)
    return IsControlPressed(inputGroup, control) or IsDisabledControlPressed(inputGroup, control)
end

function IsControlAlwaysJustPressed(inputGroup, control)
    return IsControlJustPressed(inputGroup, control) or IsDisabledControlJustPressed(inputGroup, control);
end

function SetNoClip(val)
    if (isNoClipping ~= val) then
        isNoClipping = val;

        SetUserRadioControlEnabled(not isNoClipping)
        FreezeEntityPosition(target, isNoClipping)
        SetEntityInvincible(target, isNoClipping)
        SetPlayerInvincible(target, isNoClipping)
        SetPlayerInvincibleKeepRagdollEnabled(target, isNoClipping)
    end
end

-- On rechange le playerPed quand le joueur spawn (ou respawn dans notre cas --
AddEventHandler('playerSpawned', function()
    playerPed = PlayerPedId()
    playerId = PlayerId()
end)

function MoveInNoClip()
    local rotX, rotY, rotZ = table.unpack(GetGameplayCamRot(0))
    SetEntityRotation(target, rotX, rotY, rotZ, true)
    local forward, right, up, c = GetEntityMatrix(target)

    -- On utilise le système de coordonné du ped pour le faire bouger --
    c = c + (((right * input.x * speed) + (up * -input.z * speed) + (forward * -input.y * speed)));
    SetEntityCoordsNoOffset(target, c.x, c .y, c.z, true, true, true)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- `(a and b) or c`, c'est l'équivalent de `a ? b : c` --
        input = vector3(GetControlNormal(0, MOVE_LEFT_RIGHT), GetControlNormal(0, MOVE_UP_DOWN), (IsControlAlwaysPressed(1, MOVE_UP_KEY) and 1) or ((IsControlAlwaysPressed(1, MOVE_DOWN_KEY) and -1) or 0))
        speed = (IsControlAlwaysPressed(1, CHANGE_SPEED_KEY) and NO_CLIP_FAST_SPEED) or NO_CLIP_NORMAL_SPEED

        if (IsControlAlwaysJustPressed(1, VEHICLE_NEXT_RADIO)) then
            ToggleNoClipMode()
        end

        if (isNoClipping) then
            MoveInNoClip();
        end

    end

end)
