local vter = mods.multiverse.vter

--todo metavars.  if I can do it without cluttering metavar space.

--static final vars
local SHOW_RETURN_MESSAGE_TIME = 120
local WHITE = Graphics.GL_Color(222 / 255, 222 / 255, 222 / 255, 1)
--static vars
local sSavedPositions1 = {}
local sSavedPositions2 = {}
local sShowReturnMessageTimer = 0

--[[  this doesn't show and I don't know why
local function showReturnMessage()
    Graphics.CSurface.GL_SetColor(WHITE);
    Graphics.freetype.easy_print(10, 30, 230, "Return to Stations!")
    sShowReturnMessageTimer = sShowReturnMessageTimer - 1
end

script.on_render_event(Defines.RenderEvents.LAYER_FRONT, function() end, function()
        if (sShowReturnMessageTimer > 0) then
            showReturnMessage()
        end
    end)
    --]]

--Returns all crew on your ship to their saved positions.
local function returnToPositions(savedPositions)
    sShowReturnMessageTimer = SHOW_RETURN_MESSAGE_TIME
    local shipManager = Hyperspace.ships(0)
    for crewmem in vter(shipManager.vCrewList) do
        if (crewmem.iShipId == 0) then
            local slot = savedPositions[crewmem.extend.selfId].slotId
            local room = savedPositions[crewmem.extend.selfId].roomId
            crewmem:MoveToRoom(room, slot, false)
        end
    end
end

--Saves the positions of your crew (if they're on your ship)
local function savePositions(savedPositions)
    local shipManager = Hyperspace.ships(0)
    for crewmem in vter(shipManager.vCrewList) do
        if (crewmem.iShipId == 0) then
            local saved_slot = crewmem.currentSlot
            if (saved_slot ~= nil) then
                savedPositions[crewmem.extend.selfId] = {slotId=saved_slot.slotId, roomId=saved_slot.roomId}
            end
        end
    end
end

script.on_internal_event(Defines.InternalEvents.ON_KEY_DOWN, function(key)
        if (key == Defines.SDL.KEY_PERIOD) then
            savePositions(sSavedPositions1)
        elseif (key == Defines.SDL.KEY_COMMA) then
            savePositions(sSavedPositions2)
        elseif (key == Defines.SDL.KEY_QUOTE) then
            returnToPositions(sSavedPositions1)
        elseif (key == Defines.SDL.KEY_SEMICOLON) then
            returnToPositions(sSavedPositions2)
        end
    end)