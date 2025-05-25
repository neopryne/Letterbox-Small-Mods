local lwl = mods.lightweight_lua
local lwk = mods.lightweight_keybinds
--[[
Usage: Patch this mod.
--]]
if not lwk then
    error("Lightweight Lua was not patched, or was patched after Print Mouse Position.  Some features will be disabled.")
end

script.on_render_event(Defines.RenderEvents.MOUSE_CONTROL, function() end, function()
        local mousePos = Hyperspace.Mouse.position
        local printString = "("..mousePos.x..", "..mousePos.y..")"
        if lwl then --fail gracefully if lwl isn't installed.
            if lwk.metaPressed() then
                local ownshipPos = lwl.convertMousePositionToPlayerShipPosition(mousePos)
                printString = "Player: ("..ownshipPos.x..", "..ownshipPos.y..")"
            elseif lwk.shiftPressed() then
                local enemyPos = lwl.convertMousePositionToEnemyShipPosition(mousePos)
                printString = "Enemy: ("..enemyPos.x..", "..enemyPos.y..")"
            end
        end
        --todo maybe ensure color correctness, but I kind of like it.
        local xOffset
        local yOffset
        if (mousePos.x > 1200) then
            xOffset = -67
        else
            xOffset = 13
        end
        if (mousePos.y > 689) then
            yOffset = -12
        else
            yOffset = 17
        end
        local xPos = mousePos.x + xOffset
        local yPos = mousePos.y + yOffset
        
        Graphics.CSurface.GL_PushMatrix()
        local endPos = Graphics.freetype.easy_print(9, xPos, yPos, printString)
        Graphics.CSurface.GL_DrawRect(xPos, yPos, endPos.x, endPos.y - yPos, Graphics.GL_Color(0, 0, 0, .6))
        Graphics.freetype.easy_print(9, xPos, yPos, printString)
        Graphics.CSurface.GL_PopMatrix()
    end)