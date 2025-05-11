--[[
Usage: Patch this mod.
--]]

script.on_render_event(Defines.RenderEvents.MOUSE_CONTROL, function() end, function()
        local mousePos = Hyperspace.Mouse.position
        local printString = "("..mousePos.x..", "..mousePos.y..")"
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