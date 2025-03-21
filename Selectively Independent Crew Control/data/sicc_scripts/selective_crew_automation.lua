local vter = mods.multiverse.vter
local lwl = mods.lightweight_lua
local userdata_table = mods.multiverse.userdata_table
local lwed = mods.lightweight_editor

--If large swaths of people don't notice how important something is until it's gone, we are probably doing a bad job of conveying why that thing is important.
--Persistant list:
--Which members are currently on automation status from this mod.  If they're not on this list and not controllable, DNI.


--static final vars
local METAVAR_NAME_CREW_POS = "selective_crew_automation"
local REUP_PERIOD = 100 --ms.  Changing this number breaks things in unclear ways.
--static vars
local sAutomatedCrew = "mods.crew_automation"
local sReUpTimer = 0
local BOOST_ENABLED = -1 --inverse of zero is true, so -1.
local sInitialized = false

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

script.on_init(function() --on run start
        sInitialized = false
    end)

--I guess I could refresh the boosts every [TIMEPERIOD] as long as the selection state is on, but man, that's so much cludgier.
--Saves the positions of your crew (if they're on your ship)  todo make it persist across closing the game.
local function toggleAutomation(crewMembers)
    local shipManager = Hyperspace.ships(0)
    for k, crewmem in ipairs(crewMembers) do
        local savedState = Hyperspace.metaVariables[METAVAR_NAME_CREW_POS..crewmem.extend.selfId.."automationState"]
        
        if (savedState == nil) then
            --Don't toggle things that are already disabled to begin with
            if crewmem.extend:GetDefinition().controllable == false then
                return 0
            end
            --we will be turning this on, so it's false right now
            savedState = 0
        end
        savedState = ~savedState
        lwl.setMetavar(METAVAR_NAME_CREW_POS..crewmem.extend.selfId.."automationState", savedState)
    end
    return #crewMembers
end

local function applyStatBoosts(shipManager)
    for k, crewmem in ipairs(lwl.getAllMemberCrew(shipManager)) do
        if (Hyperspace.metaVariables[METAVAR_NAME_CREW_POS..crewmem.extend.selfId.."automationState"] == BOOST_ENABLED) then
            local statBoostManager = Hyperspace.StatBoostManager.GetInstance()
            print("applying stat boosts to ", crewmem:GetName())
            local boost = Hyperspace.StatBoost(automationBoost)
            print("boost created")
            statBoostManager:CreateTimedAugmentBoost(boost, crewmem)
        end
    end
end

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(shipManager)
        if (shipManager ~= nil) then
            if (shipManager.iShipId == 0) then
                if (sReUpTimer > REUP_PERIOD) then
                    sReUpTimer = 0
                    applyStatBoosts(shipManager)
                else
                    sReUpTimer = sReUpTimer + 1
                end
            end
        end
    end)

--todo update mscp with keybinds library and selfId version
lwed.registerKeyFunctionCombo("KEY_t", {"CTRL"}, function(operatorKey)
        local selected = toggleAutomation(lwl.getSelectedCrew(lwl.OWNSHIP(), lwl.SELECTED()))
        if (selected == 0) then --Only try to apply to hovered ones if nothing is selected otherwise.
            toggleAutomation(lwl.getSelectedCrew(lwl.OWNSHIP(), lwl.SELECTED_HOVER()))
        end
    end)