local vter = mods.multiverse.vter
local lwl = mods.lightweight_lua
local userdata_table = mods.multiverse.userdata_table

--todo hash function for checking if crew list has changed?

--static final vars
local PERSIST_POSITIONS_TIME = 120
local WHITE = Graphics.GL_Color(222 / 255, 222 / 255, 222 / 255, 1)
local METAVAR_NAME_CREW_POS = "saved_crew_positions"
--static vars
local sSavedPositions1 = "mods.crew_positions.first"
local sSavedPositions2 = "mods.crew_positions.second"
local sShowReturnMessageTimer = 0
local sCrewTimer = PERSIST_POSITIONS_TIME
local sInitialized

script.on_init(function()
        sInitialized = false
        print("loaded")
    end)

local function persistPositions()
    local shipManager = Hyperspace.ships(0)
    print("persist positions")
    local i = 0
    if (shipManager ~= nil) then
        for k, crewmem in ipairs(lwl.getAllMemberCrew(shipManager)) do
            local crewTable1 = userdata_table(crewmem, sSavedPositions1)
            local crewTable2 = userdata_table(crewmem, sSavedPositions2)
            lwl.setMetavar("1"..METAVAR_NAME_CREW_POS..i.."roomId", crewTable1.roomId)
            lwl.setMetavar("1"..METAVAR_NAME_CREW_POS..i.."slotId", crewTable1.slotId)
            lwl.setMetavar("2"..METAVAR_NAME_CREW_POS..i.."roomId", crewTable2.roomId)
            lwl.setMetavar("2"..METAVAR_NAME_CREW_POS..i.."slotId", crewTable2.slotId)
            i = i + 1
        end
    end
end

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(shipManager)
        if (not sInitialized and shipManager ~= nil) then
            print("loading persisted crew positions")
            if (shipManager.iShipId == 0) then
                --if metavars exist, load and clear them.
                local i = 0
                for k, crewmem in ipairs(lwl.getAllMemberCrew(shipManager)) do
                    room1 = Hyperspace.metaVariables["1"..METAVAR_NAME_CREW_POS..i.."roomId"]
                    slot1 = Hyperspace.metaVariables["1"..METAVAR_NAME_CREW_POS..i.."slotId"]
                    room2 = Hyperspace.metaVariables["2"..METAVAR_NAME_CREW_POS..i.."roomId"]
                    slot2 = Hyperspace.metaVariables["2"..METAVAR_NAME_CREW_POS..i.."slotId"]
                    print("loaded ", i, " ", room1, slot1, room2, slot2)
                    local crewTable1 = userdata_table(crewmem, sSavedPositions1)
                    local crewTable2 = userdata_table(crewmem, sSavedPositions2)
                    crewTable1.roomId = room1
                    crewTable1.slotId = slot1
                    crewTable2.roomId = room2
                    crewTable2.slotId = slot2
                    i = i + 1
                end
                sInitialized = true
            end
        end
        sCrewTimer = sCrewTimer - 1
        if (sCrewTimer <= 0) then
            sCrewTimer = PERSIST_POSITIONS_TIME
            persistPositions()
        end
    end)

--Saves the positions of your crew (if they're on your ship)  todo make it persist across closing the game.
local function savePositions(savedPositions)
    local shipManager = Hyperspace.ships(0)
    for crewmem in vter(shipManager.vCrewList) do
        if (crewmem.iShipId == 0) then
            local crewTable = userdata_table(crewmem, savedPositions)
            local saved_slot = crewmem.currentSlot
            if (saved_slot ~= nil) then
                crewTable.roomId = saved_slot.roomId
                crewTable.slotId = saved_slot.slotId
            end
        end
    end
    print("Positions saved!")
end

--Returns all crew on your ship to their saved positions.
local function returnToPositions(savedPositions)
    print("Return to Stations!")
    local shipManager = Hyperspace.ships(0)
    for crewmem in vter(shipManager.vCrewList) do
        if (crewmem.iShipId == 0) then
            local crewTable = userdata_table(crewmem, savedPositions)
            if (crewTable.roomId ~= nil) then
                crewmem:MoveToRoom(crewTable.roomId, crewTable.slotId, false)
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