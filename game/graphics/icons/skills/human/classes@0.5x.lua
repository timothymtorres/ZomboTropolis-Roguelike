--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:ac5daee5d8387517ac6e2cee2a0663ae:0b1950ef12ada65785d5da94b03978d7:f566188a86459ae073a2ad0b7302ee8b$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- biohazard
            x=2,
            y=2,
            width=64,
            height=64,

        },
        {
            -- crossed-swords
            x=68,
            y=2,
            width=64,
            height=64,

        },
        {
            -- tinker
            x=134,
            y=2,
            width=64,
            height=64,

        },
    },
    
    sheetContentWidth = 200,
    sheetContentHeight = 68
}

SheetInfo.frameIndex =
{

    ["biohazard"] = 1,
    ["crossed-swords"] = 2,
    ["tinker"] = 3,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
