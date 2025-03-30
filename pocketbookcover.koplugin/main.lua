local WidgetContainer = require("ui/widget/container/widgetcontainer")
local _ = require("gettext")
local UIManager = require("ui/uimanager")
local FileManagerBookInfo = require("apps/filemanager/filemanagerbookinfo")
local Screen = require("device").screen
local RenderImage = require("ui/renderimage")
local Blitbuffer = require("ffi/blitbuffer")

local PocketbookCover = WidgetContainer:extend{
    name = "pocketbookcover",
    is_doc_only = false,
}

function PocketbookCover:update(title, page)
    local image, _ = FileManagerBookInfo:getCoverImage(self.ui.document)
    if not image then return end

    local screenWidth = Screen:getWidth()
    local screenHeight = Screen:getHeight()
    local rotation = Screen:getRotationMode()

    if rotation == 1 or rotation == 3 then
        local tmp = screenWidth
        screenWidth = screenHeight
        screenHeight = tmp
    end

    local imageWidth = image:getWidth()
    local imageHeight = image:getHeight()
    local imageAspectRatio = imageWidth / imageHeight
    local screenAspectRatio = screenWidth / screenHeight

    local scaledWidth, scaledHeight
    if imageAspectRatio > screenAspectRatio then
        scaledWidth = screenWidth
        scaledHeight = screenWidth / imageAspectRatio
    else
        scaledWidth = screenHeight * imageAspectRatio
        scaledHeight = screenHeight
    end

    local imageScaled = RenderImage:scaleBlitBuffer(image, scaledWidth, scaledHeight)
    if not imageScaled then return end

    local backgroundBuffer = Blitbuffer.new(screenWidth, screenHeight, image:getType())
    if not backgroundBuffer then return end

    backgroundBuffer:fill(Blitbuffer.COLOR_BLACK)
    local offsetX = math.floor((screenWidth - scaledWidth) / 2)
    local offsetY = math.floor((screenHeight - scaledHeight) / 2)
    backgroundBuffer:blitFrom(imageScaled, offsetX, offsetY)

    backgroundBuffer:writeToFile("/mnt/ext1/system/logo/bookcover", "bmp", 100, false)
    backgroundBuffer:writeToFile("/mnt/ext1/system/resources/Line/taskmgr_lock_background.bmp", "bmp", 100, false)

    imageScaled:free()
    backgroundBuffer:free()
end

function PocketbookCover:onReaderReady(doc)
    self:update()
end

function PocketbookCover:onCloseDocument()
    self:update()
end

function PocketbookCover:onEndOfBook()
    self:update()
end

function PocketbookCover:onSuspend()
    self:update()
end

function PocketbookCover:onResume()
    self:update()
end

return PocketbookCover
