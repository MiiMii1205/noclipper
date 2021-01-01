--[[
  * Created by MiiMii1205
  * license MIT
--]]

-- Constants --
MOVE_UP_KEY = 44
MOVE_DOWN_KEY = 46
CHANGE_SPEED_KEY = 21
MOVE_LEFT_RIGHT = 30
MOVE_UP_DOWN = 31
NOCLIP_TOGGLE_KEY = 81
NO_CLIP_NORMAL_SPEED = 0.5
NO_CLIP_FAST_SPEED = 2.5
ENABLE_TOGGLE_NO_CLIP = true
ENABLE_NO_CLIP_SOUND = true

STARTUP_STRING = ('%s v%s initialized'):format(GetCurrentResourceName(), GetResourceMetadata(GetCurrentResourceName(), 'version', 0))
STARTUP_HTML_STRING = (':business_suit_levitating: %s <small>v%s</small> initialized'):format(GetCurrentResourceName(), GetResourceMetadata(GetCurrentResourceName(), 'version', 0))

-- Variables --
local isNoClipping = false
local playerPed = PlayerPedId()
local playerId = PlayerId()
local speed = NO_CLIP_NORMAL_SPEED
local input = vector3(0, 0, 0)
local previousVelocity = vector3(0, 0, 0)
local breakSpeed = 10.0;
local offset = vector3(0, 0, 1);

function ToggleNoClipMode() return SetNoClip(not isNoClipping) end

function IsControlAlwaysPressed(inputGroup, control) return IsControlPressed(inputGroup, control) or IsDisabledControlPressed(inputGroup, control) end

function IsControlAlwaysJustPressed(inputGroup, control) return IsControlJustPressed(inputGroup, control) or IsDisabledControlJustPressed(inputGroup, control) end

function Lerp (a, b, t) return a + (b - a) * t end

function SetInvincible(val)

    SetEntityInvincible(playerPed, val)
    return SetPlayerInvincible(playerPed, val)

end

function SetNoClip(val)

    if (isNoClipping ~= val) then

        isNoClipping = val;

        if ENABLE_NO_CLIP_SOUND then

            if isNoClipping then
                PlaySoundFromEntity(-1, "SELECT", playerPed, "HUD_LIQUOR_STORE_SOUNDSET", 0, 0)
            else
                PlaySoundFromEntity(-1, "CANCEL", playerPed, "HUD_LIQUOR_STORE_SOUNDSET", 0, 0)
            end

        end

        TriggerEvent('msgprinter:addMessage', ((isNoClipping and ":airplane: No-clip enabled") or ":rock: No-clip disabled"), GetCurrentResourceName());

        SetUserRadioControlEnabled(not isNoClipping)
        FreezeEntityPosition(playerPed, isNoClipping)
        ClearPedTasksImmediately(playerPed)

        if (isNoClipping) then

            SetEntityAlpha(playerPed, 51, false)

            -- Start a No CLip thread
            Citizen.CreateThread(function()

                -- We start with no-clip mode because of the above if --
                SetInvincible(true);

                while isNoClipping do

                    Citizen.Wait(0);

                    -- `(a and b) or c`, is basically `a ? b : c` --
                    input = vector3(GetControlNormal(0, MOVE_LEFT_RIGHT), GetControlNormal(0, MOVE_UP_DOWN), (IsControlAlwaysPressed(1, MOVE_UP_KEY) and 1) or ((IsControlAlwaysPressed(1, MOVE_DOWN_KEY) and -1) or 0))
                    speed = (IsControlAlwaysPressed(1, CHANGE_SPEED_KEY) and NO_CLIP_FAST_SPEED) or NO_CLIP_NORMAL_SPEED

                    MoveInNoClip();

                end

                -- We're done with the while so we aren't in no-clip mode anymore --
                -- Wait until the player starts falling or is completely stopped --
                while (IsPedStopped(playerPed) or not IsPedFalling(playerPed)) and not isNoClipping do
                    Citizen.Wait(0);
                end

                while not isNoClipping do

                    Citizen.Wait(0);

                    if IsPedStopped(playerPed) and not IsPedFalling(playerPed) then

                        -- We hit land. We can safely remove the invincibility --
                        return SetInvincible(false);

                    end

                end

            end)

        else
            ResetEntityAlpha(playerPed)
        end

    end

end

function MoveInNoClip()

    SetEntityRotation(playerPed, GetGameplayCamRot(0), 0, true)
    local forward, right, up, c = GetEntityMatrix(playerPed)
    previousVelocity = Lerp(previousVelocity, (((right * input.x * speed) + (up * -input.z * speed) + (forward * -input.y * speed))), Timestep() * breakSpeed);
    c = c + previousVelocity
    SetEntityCoords(playerPed, c - offset, true, true, true, false)

end

AddEventHandler('playerSpawned', function()

    playerPed = PlayerPedId()
    playerId = PlayerId()

end)

Citizen.CreateThread(function()

    print(STARTUP_STRING)
    TriggerEvent('msgprinter:addMessage', STARTUP_HTML_STRING, GetCurrentResourceName());

    while ENABLE_TOGGLE_NO_CLIP do
        Citizen.Wait(0)
        if IsControlAlwaysJustPressed(1, NOCLIP_TOGGLE_KEY) then ToggleNoClipMode() end
    end

end)

