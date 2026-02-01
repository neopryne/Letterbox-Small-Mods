local vter = mods.multiverse.vter
local lwl = mods.lightweight_lua
local userdata_table = mods.multiverse.userdata_table

mods.more_crew_positions = {}
local mscp = mods.more_crew_positions
--todo remove userdata, just use metavars.

--static final vars
local METAVAR_NAME_CREW_POS = "saved_crew_positions"
--static vars
local sSavedPositionsKeys = {"mods.crew_positions.first", "mods.crew_positions.second"}
local sReturnMessages = {"Return to Secondary Stations!", "Return to Tertiary Stations!"}
local sSaveMessages = {"Secondary Stations saved.", "Tertiary Stations saved."}
local sShowReturnMessageTimer = 0
local sInitialized

script.on_init(function()
        sInitialized = false
    end)

function mscp.moveToSavedPosition(crewmem, number)
    local crewTable = userdata_table(crewmem, sSavedPositionsKeys[number])
    if (crewTable.roomId ~= nil) then
        crewmem:MoveToRoom(crewTable.roomId, crewTable.slotId, false)
        return true
    end
    return false
end

local function loadPosition(crewmem, index)
    --print("loaded ", i, " ", room1, slot1, room2, slot2)
    local crewTable = userdata_table(crewmem, sSavedPositionsKeys[index])
    crewTable.roomId = Hyperspace.metaVariables[index..METAVAR_NAME_CREW_POS..crewmem.extend.selfId.."roomId"]
    crewTable.slotId = Hyperspace.metaVariables[index..METAVAR_NAME_CREW_POS..crewmem.extend.selfId.."slotId"]
end

local function persistSavedPosition(crewmem, index)
    local crewTable1 = userdata_table(crewmem, sSavedPositionsKeys[index])
    lwl.setMetavar(index..METAVAR_NAME_CREW_POS..crewmem.extend.selfId.."roomId", crewTable1.roomId)
    lwl.setMetavar(index..METAVAR_NAME_CREW_POS..crewmem.extend.selfId.."slotId", crewTable1.slotId)
end

local function persistPositions(index)
    local shipManager = Hyperspace.ships(0)
    if (shipManager ~= nil) then
        for k, crewmem in ipairs(lwl.getAllMemberCrewFromFactory(lwl.filterOwnshipTrueCrew)) do
            persistSavedPosition(crewmem, index)
        end
    end
end

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(shipManager)
        if (not sInitialized and shipManager ~= nil) then
            --print("loading persisted crew positions")
            if (shipManager.iShipId == 0) then
                --if metavars exist, load and clear them.
                for k, crewmem in ipairs(lwl.getAllMemberCrewFromFactory(lwl.filterOwnshipTrueCrew)) do
                    loadPosition(crewmem, 1)
                    loadPosition(crewmem, 2)
                end
                sInitialized = true
            end
        end
    end)

--Saves the positions of your crew (if they're on your ship)  todo make it persist across closing the game.
local function savePositions(index)
    local savedPositions = sSavedPositionsKeys[index]
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
    persistPositions(index)
    print(sSaveMessages[index])
end

--Returns all crew on your ship to their saved positions.
--todo test and push an update for this, this bug is bad.
local function returnToPositions(index)
    local shipManager = Hyperspace.ships(0)
    for crewmem in vter(shipManager.vCrewList) do
        if (crewmem.iShipId == 0) then
            mscp.moveToSavedPosition(crewmem, index)
        end
    end
    print(sReturnMessages[index])
end

script.on_internal_event(Defines.InternalEvents.ON_KEY_DOWN, function(key)
        if (key == Defines.SDL.KEY_PERIOD) then
            savePositions(1)
        elseif (key == Defines.SDL.KEY_COMMA) then
            savePositions(2)
        elseif (key == Defines.SDL.KEY_QUOTE) then
            returnToPositions(1)
        elseif (key == Defines.SDL.KEY_SEMICOLON) then
            returnToPositions(2)
        end
    end)