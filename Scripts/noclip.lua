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
NO_CLIP_NORMAL_SPEED = 0.5
NO_CLIP_FAST_SPEED = 2.5
ENABLE_TOGGLE_NO_CLIP = true

-- Variables --
local isNoClipping = false
local playerPed = PlayerPedId()
local playerId = PlayerId()
local target = playerPed
local speed = NO_CLIP_NORMAL_SPEED
local input = vector3(0, 0, 0)
local previousVelocity = vector3(0, 0, 0)
local currentPosition = GetEntityCoords(target, true)
local justExitedNoClip = false;
local breakSpeed = 10.0;

function ToggleNoClipMode()

    SetNoClip(not isNoClipping)

end

function IsControlAlwaysPressed(inputGroup, control)

    return IsControlPressed(inputGroup, control) or IsDisabledControlPressed(inputGroup, control)

end

function IsControlAlwaysJustPressed(inputGroup, control)

    return IsControlJustPressed(inputGroup, control) or IsDisabledControlJustPressed(inputGroup, control);

end

function SetInvincible(val)

    SetEntityInvincible(target, val)
    SetPlayerInvincible(target, val)

end

function LerpVector3 (a, b, t)

    return vector3(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, a.z + (b.z - a.z) * t)

end

function SetNoClip(val)

    if (isNoClipping ~= val) then

        isNoClipping = val;

        SetUserRadioControlEnabled(not isNoClipping)
        FreezeEntityPosition(target, isNoClipping)
        ClearPedTasksImmediately(target)

        if (isNoClipping) then

            SetInvincible(true);
            currentPosition = GetEntityCoords(target, true)
            justExitedNoClip = true;

        else

            -- On attend d'atterrir avant d'enlever l'invincibilité du joueur --
            Citizen.CreateThread(function()

                while justExitedNoClip and not isNoClipping do

                    Citizen.Wait(0);

                    if (GetEntityHeightAboveGround(target) <= 2) and not IsPedFalling(target) then

                        SetInvincible(false);
                        justExitedNoClip = false;

                    end

                end

            end)

        end

    end

end

function MoveInNoClip()

    local rotX, rotY, rotZ = table.unpack(GetGameplayCamRot(0))
    SetEntityRotation(target, rotX, rotY, rotZ, true)
    local forward, right, up, c = GetEntityMatrix(target)
    -- On utilise le système de coordonné du ped pour le faire bouger --

    local velocity = LerpVector3(previousVelocity, (((right * input.x * speed) + (up * -input.z * speed) + (forward * -input.y * speed))), Timestep() * breakSpeed);
    c = c + velocity
    SetEntityCoords(target, c.x, c .y, c.z-1, true, true, true, false)
    previousVelocity = velocity

end

-- On rechange le playerPed quand le joueur spawn (ou respawn dans notre cas) --
AddEventHandler('playerSpawned', function()

    playerPed = PlayerPedId()
    playerId = PlayerId()

end)

if ENABLE_TOGGLE_NO_CLIP then

    Citizen.CreateThread(function()

        print(('NoCliper v%s initialized'):format(GetResourceMetadata(GetCurrentResourceName(), 'version', 0)))

        while true do
            Citizen.Wait(0)

            if (IsControlAlwaysJustPressed(1, VEHICLE_NEXT_RADIO)) then

                ToggleNoClipMode()

            end

            if (isNoClipping) then

                -- `(a and b) or c`, c'est l'équivalent de `a ? b : c` --

                input = vector3(GetControlNormal(0, MOVE_LEFT_RIGHT), GetControlNormal(0, MOVE_UP_DOWN), (IsControlAlwaysPressed(1, MOVE_UP_KEY) and 1) or ((IsControlAlwaysPressed(1, MOVE_DOWN_KEY) and -1) or 0))
                speed = (IsControlAlwaysPressed(1, CHANGE_SPEED_KEY) and NO_CLIP_FAST_SPEED) or NO_CLIP_NORMAL_SPEED

                MoveInNoClip();

            end

        end

    end)

end

