local vter = mods.multiverse.vter
local lwl = mods.lightweight_lua
local lwk = mods.lightweight_keybinds
local lwsb = mods.lightweight_statboosts

--If large swaths of people don't notice how important something is until it's gone, we are probably doing a bad job of conveying why that thing is important.
--Persistant list:
--Which members are currently on automation status from this mod.  If they're not on this list and not controllable, DNI.


--static final vars
local METAVAR_NAME_CREW_POS = "selective_crew_automation"
local REUP_PERIOD = 100 --ms.  Changing this number breaks things in unclear ways.
local KEY_AUTOMATION_STATE = "automationState"
local KEY_BOOST_ID = "boostId"

--todo lwl getSelectedCrew()
--crewmem.extend.selfId does what I need
local automationBoost = Hyperspace.StatBoostDefinition()
--todo check this is the right value/name
automationBoost.stat = Hyperspace.CrewStat.CONTROLLABLE
automationBoost.value = false
automationBoost.boostType = Hyperspace.StatBoostDefinition.BoostType.SET
automationBoost.boostSource = Hyperspace.StatBoostDefinition.BoostSource.AUGMENT
automationBoost.shipTarget = Hyperspace.StatBoostDefinition.ShipTarget.ALL
automationBoost.crewTarget = Hyperspace.StatBoostDefinition.CrewTarget.ALL
automationBoost.duration = 2 --seconds, I think
automationBoost.priority = 9998
automationBoost.realBoostId = Hyperspace.StatBoostDefinition.statBoostDefs:size()
Hyperspace.StatBoostDefinition.statBoostDefs:push_back(automationBoost) --init requirement

local function generateCrewFilterFunction(crewmem)
    return function (crew)
        return crew.extend.selfId == crewmem.extend.selfId
    end
end

--I guess I could refresh the boosts every [TIMEPERIOD] as long as the selection state is on, but man, that's so much cludgier.
--Saves the positions of your crew (if they're on your ship)  todo make it persist across closing the game.
local function toggleAutomation(crewMembers)
    for k, crewmem in ipairs(crewMembers) do
        --todo this doesn't actually persist anything, add stat boost persistance in my library.
        local savedState = Hyperspace.metaVariables[METAVAR_NAME_CREW_POS..crewmem.extend.selfId..KEY_AUTOMATION_STATE]
        
        if (savedState == nil) then
            --Don't toggle things that are already disabled to begin with
            if crewmem.extend:GetDefinition().controllable == false then
                return 0
            end
            --we will be turning this on, so it's false right now
            savedState = 0
        end
        if savedState == 0 then
            savedState = 1
            local boostId = lwsb.addStatBoost(Hyperspace.CrewStat.CONTROLLABLE, lwsb.TYPE_BOOLEAN, lwsb.ACTION_SET, false, generateCrewFilterFunction(crewmem))
            lwl.setMetavar(METAVAR_NAME_CREW_POS..crewmem.extend.selfId..KEY_BOOST_ID, boostId)
        else
            savedState = 0
            lwsb.removeStatBoost(Hyperspace.metaVariables[METAVAR_NAME_CREW_POS..crewmem.extend.selfId..KEY_BOOST_ID])
        end
        lwl.setMetavar(METAVAR_NAME_CREW_POS..crewmem.extend.selfId..KEY_AUTOMATION_STATE, savedState)

    end
    return #crewMembers
end


local function toggleAutomationCallback(operatorKey)
    local selectedCrew = lwl.getSelectedCrew(lwl.SELECTED())
    if (#selectedCrew == 0) then --Only try to apply to hovered ones if nothing is selected otherwise.
        selectedCrew = lwl.getSelectedCrew(lwl.SELECTED_HOVER())
    end
    toggleAutomation(selectedCrew)
end

lwk.registerKeyFunctionCombo(Defines.SDL_KEY_i, {lwk.CTRL}, toggleAutomationCallback)