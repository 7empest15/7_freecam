
local enabled = false
local cam = nil
local camCoords = nil
local camRot = nil

RegisterCommand('toggleFreecam', function(source, args, raw)

    if enabled then
        disableFreecam()
    else
        enableFreecam()
    end
end, false)

function enableFreecam()
    enabled = true
    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)
    camCoords = GetEntityCoords(PlayerPedId())
    camRot = GetEntityRotation(PlayerPedId())
    SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z)
    SetCamRot(cam, camRot.x, camRot.y, camRot.z, 0)
    SetCamFov(cam, 50.0)

    speed = Config.speed

    

    CreateThread(function()

        local scaleform = getScaleform(speed)

        while enabled do

            DisableAllControlActions(0)

            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)

            local mouseX = GetDisabledControlNormal(0, 1) * 8.0
            local mouseY = GetDisabledControlNormal(0, 2) * 8.0
            camRot = camRot + vector3(-mouseY, 0, -mouseX)

            
            local dx, dy, dz = 0, 0, 0
            local adjustedZ = math.rad(camRot.z + 90)
            if IsDisabledControlPressed(0, 32) then -- Avancer
                dx = dx + math.cos(adjustedZ) * speed
                dy = dy + math.sin(adjustedZ) * speed
            end
            if IsDisabledControlPressed(0, 33) then -- Reculer
                dx = dx - math.cos(adjustedZ) * speed
                dy = dy - math.sin(adjustedZ) * speed
            end
            if IsDisabledControlPressed(0, 34) then -- Gauche
                dx = dx - math.sin(adjustedZ) * speed
                dy = dy + math.cos(adjustedZ) * speed
            end
            if IsDisabledControlPressed(0, 35) then -- Droite
                dx = dx + math.sin(adjustedZ) * speed
                dy = dy - math.cos(adjustedZ) * speed
            end

            if IsDisabledControlPressed(0, 44) then -- Descendre
                dz = dz - speed
            end

            if IsDisabledControlPressed(0, 38) then -- Monter
                dz = dz + speed
            end

            if IsDisabledControlPressed(0, 14) then -- Scroll down
                speed = speed + 0.1
                scaleform = getScaleform(speed)
            end

            if IsDisabledControlPressed(0, 15) then -- Scroll up
                if speed > 0.1 then
                    speed = speed - 0.1
                    scaleform = getScaleform(speed)
                end
            end

            if IsDisabledControlPressed(0, 45) then -- Reset speed
                camCoords = GetEntityCoords(PlayerPedId())
                camRot = GetEntityRotation(PlayerPedId())
            end

            local newCamCoords = camCoords + vector3(dx, dy, dz)

            local distance = #(newCamCoords - GetEntityCoords(PlayerPedId()))
            if distance <= 100 then
                camCoords = newCamCoords
                if distance > 95 then
                    DrawSphere(GetEntityCoords(PlayerPedId()).x, GetEntityCoords(PlayerPedId()).y, GetEntityCoords(PlayerPedId()).z, 100.0, 255, 0, 0, 0.8)
                end
            else
                DrawSphere(GetEntityCoords(PlayerPedId()).x, GetEntityCoords(PlayerPedId()).y, GetEntityCoords(PlayerPedId()).z, 100.0, 255, 0, 0, 0.8)
                drawTxt(0.35, 0.5, 0.5, "Vous ne pouvez pas aller trop loin", 255, 255, 255, 255)
            end
            
            SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z)
            
            SetCamRot(cam, camRot.x, camRot.y, camRot.z, 0)
            Wait(0)
        end
    end)

end

function disableFreecam()
    enabled = false
    RenderScriptCams(false, false, 0, true, true)
    DestroyCam(cam, false)
end

function drawTxt(x, y, scale, text, r, g, b, a)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

function Button(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

function setupScaleform(scaleform, buttons)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end

    -- draw it once to set up layout
    DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 0, 0)

    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    for i, button in ipairs(buttons) do
        PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
        PushScaleformMovieFunctionParameterInt(i - 1)
        Button(GetControlInstructionalButton(2, button.control, true))
        ButtonMessage(button.text)
        PopScaleformMovieFunctionVoid()
    end

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

function getScaleform(speed)
    local scaleform = setupScaleform("instructional_buttons", {
        {text = "Avancer", control = 32},
        {text = "Reculer", control = 33},
        {text = "Gauche", control = 34},
        {text = "Droite", control = 35},
        {text = "Descendre", control = 44},
        {text = "Monter", control = 38},
        {text = "Vitesse " .. speed, control = 348},
        {text = "Reset", control = 45}
    
    })
    return scaleform
end