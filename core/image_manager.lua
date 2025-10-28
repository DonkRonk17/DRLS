-- DRGUI Image Manager
-- Front-end UI for loading and managing images across all features

local DRGUI = DRGUI or {}
DRGUI.ImageManager = {}

local AceGUI = LibStub("AceGUI-3.0")

-- Image categories
local IMAGE_CATEGORIES = {
    borders = {
        name = "Borders",
        path = "Interface\\AddOns\\DRGUI\\media\\borders\\",
        description = "Action bar and frame borders",
        extensions = {".tga", ".blp"}
    },
    icons = {
        name = "Icons",
        path = "Interface\\AddOns\\DRGUI\\media\\icons\\",
        description = "Ability and UI icons",
        extensions = {".tga", ".blp"}
    },
    backgrounds = {
        name = "Backgrounds",
        path = "Interface\\AddOns\\DRGUI\\media\\backgrounds\\",
        description = "UI panel backgrounds",
        extensions = {".tga", ".blp"}
    },
    fonts = {
        name = "Fonts",
        path = "Interface\\AddOns\\DRGUI\\media\\fonts\\",
        description = "Custom font files",
        extensions = {".ttf", ".otf"}
    },
    textures = {
        name = "Textures",
        path = "Interface\\AddOns\\DRGUI\\media\\textures\\",
        description = "UI element textures",
        extensions = {".tga", ".blp"}
    }
}

-- Initialize image database
DRGUIDB.images = DRGUIDB.images or {
    borders = {},
    icons = {},
    backgrounds = {},
    textures = {},
    custom = {}
}

-- Main image manager frame
local imageFrame = nil
local currentCategory = "borders"
local currentPreview = nil
local selectedImage = nil

-- Create main image manager window
local function CreateImageManagerFrame()
    if imageFrame then
        imageFrame:Show()
        return imageFrame
    end
    
    imageFrame = AceGUI:Create("Frame")
    imageFrame:SetTitle("DRGUI Image Manager")
    imageFrame:SetStatusText("Manage UI Images & Media")
    imageFrame:SetLayout("Flow")
    imageFrame:SetWidth(800)
    imageFrame:SetHeight(600)
    imageFrame:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
        imageFrame = nil
    end)
    
    return imageFrame
end

-- Scan for available images in a category
local function ScanImagesInCategory(category)
    local images = {}
    local categoryData = IMAGE_CATEGORIES[category]
    
    if not categoryData then return images end
    
    -- Note: WoW doesn't allow direct file system access
    -- Instead, we'll track known images and allow users to add custom ones
    
    -- Load from saved database
    if DRGUIDB.images[category] then
        for _, img in ipairs(DRGUIDB.images[category]) do
            table.insert(images, img)
        end
    end
    
    -- Add default images
    if category == "borders" then
        table.insert(images, {name = "Default Border", path = "media/borders/default_border.tga", builtin = true})
        table.insert(images, {name = "Bushido Border", path = "media/borders/bushido_border.tga", builtin = true})
        table.insert(images, {name = "Action Border", path = "media/borders/action_border.tga", builtin = true})
    elseif category == "icons" then
        table.insert(images, {name = "Default Icon", path = "media/icons/default_icon.tga", builtin = true})
        table.insert(images, {name = "Class Icon", path = "media/icons/class_icon.tga", builtin = true})
    elseif category == "backgrounds" then
        table.insert(images, {name = "Default BG", path = "media/backgrounds/default_bg.tga", builtin = true})
    end
    
    return images
end

-- Create image preview frame
local function CreateImagePreview(container, imagePath)
    local previewGroup = AceGUI:Create("InlineGroup")
    previewGroup:SetTitle("Preview")
    previewGroup:SetFullWidth(true)
    previewGroup:SetLayout("Flow")
    
    -- Create actual WoW texture frame for preview
    local previewFrame = CreateFrame("Frame", nil, previewGroup.frame)
    previewFrame:SetSize(256, 256)
    previewFrame:SetPoint("CENTER")
    
    local texture = previewFrame:CreateTexture(nil, "ARTWORK")
    texture:SetAllPoints()
    
    if imagePath then
        texture:SetTexture("Interface\\AddOns\\DRGUI\\" .. imagePath)
    else
        texture:SetColorTexture(0.2, 0.2, 0.2, 1)
    end
    
    currentPreview = {frame = previewFrame, texture = texture}
    
    return previewGroup
end

-- Create category selector
local function CreateCategorySelector(container)
    local categoryGroup = AceGUI:Create("InlineGroup")
    categoryGroup:SetTitle("Image Category")
    categoryGroup:SetFullWidth(true)
    categoryGroup:SetLayout("Flow")
    
    for catKey, catData in pairs(IMAGE_CATEGORIES) do
        local btn = AceGUI:Create("Button")
        btn:SetText(catData.name)
        btn:SetWidth(140)
        btn:SetCallback("OnClick", function()
            currentCategory = catKey
            DRGUI.ImageManager:RefreshImageList()
        end)
        categoryGroup:AddChild(btn)
    end
    
    container:AddChild(categoryGroup)
end

-- Create image list
local function CreateImageList(container)
    local listGroup = AceGUI:Create("InlineGroup")
    listGroup:SetTitle("Available Images - " .. (IMAGE_CATEGORIES[currentCategory] and IMAGE_CATEGORIES[currentCategory].name or ""))
    listGroup:SetFullWidth(true)
    listGroup:SetFullHeight(true)
    listGroup:SetLayout("List")
    
    local images = ScanImagesInCategory(currentCategory)
    
    if #images == 0 then
        local label = AceGUI:Create("Label")
        label:SetText("No images found in this category.\n\nAdd custom images using the 'Add Image' button below.")
        label:SetFullWidth(true)
        listGroup:AddChild(label)
    else
        for _, img in ipairs(images) do
            local imgButton = AceGUI:Create("Button")
            imgButton:SetText(img.name .. (img.builtin and " (Built-in)" or ""))
            imgButton:SetFullWidth(true)
            imgButton:SetCallback("OnClick", function()
                selectedImage = img
                if currentPreview then
                    currentPreview.texture:SetTexture("Interface\\AddOns\\DRGUI\\" .. img.path)
                end
                print("DRGUI: Selected image: " .. img.name)
            end)
            listGroup:AddChild(imgButton)
        end
    end
    
    container:AddChild(listGroup)
end

-- Create action buttons
local function CreateActionButtons(container)
    local btnGroup = AceGUI:Create("SimpleGroup")
    btnGroup:SetFullWidth(true)
    btnGroup:SetLayout("Flow")
    
    -- Add Image button
    local addBtn = AceGUI:Create("Button")
    addBtn:SetText("Add Image")
    addBtn:SetWidth(150)
    addBtn:SetCallback("OnClick", function()
        DRGUI.ImageManager:ShowAddImageDialog()
    end)
    btnGroup:AddChild(addBtn)
    
    -- Apply Image button
    local applyBtn = AceGUI:Create("Button")
    applyBtn:SetText("Apply Selected")
    applyBtn:SetWidth(150)
    applyBtn:SetCallback("OnClick", function()
        if selectedImage then
            DRGUI.ImageManager:ApplyImage(selectedImage, currentCategory)
        else
            print("DRGUI: No image selected")
        end
    end)
    btnGroup:AddChild(applyBtn)
    
    -- Generate via AI button
    local aiBtn = AceGUI:Create("Button")
    aiBtn:SetText("Generate (AI)")
    aiBtn:SetWidth(150)
    aiBtn:SetCallback("OnClick", function()
        if DRGUI and DRGUI.LaunchImageGen then
            DRGUI:LaunchImageGen()
        end
    end)
    btnGroup:AddChild(aiBtn)
    
    -- Delete button
    local delBtn = AceGUI:Create("Button")
    delBtn:SetText("Delete Custom")
    delBtn:SetWidth(150)
    delBtn:SetCallback("OnClick", function()
        if selectedImage and not selectedImage.builtin then
            DRGUI.ImageManager:DeleteImage(selectedImage)
        else
            print("DRGUI: Can only delete custom images")
        end
    end)
    btnGroup:AddChild(delBtn)
    
    container:AddChild(btnGroup)
end

-- Show add image dialog
function DRGUI.ImageManager:ShowAddImageDialog()
    local dialog = AceGUI:Create("Frame")
    dialog:SetTitle("Add Custom Image")
    dialog:SetWidth(500)
    dialog:SetHeight(300)
    dialog:SetLayout("Flow")
    
    local nameLabel = AceGUI:Create("Label")
    nameLabel:SetText("Image Name:")
    nameLabel:SetFullWidth(true)
    dialog:AddChild(nameLabel)
    
    local nameInput = AceGUI:Create("EditBox")
    nameInput:SetFullWidth(true)
    nameInput:SetLabel("")
    dialog:AddChild(nameInput)
    
    local pathLabel = AceGUI:Create("Label")
    pathLabel:SetText("Image Path (relative to DRGUI folder):")
    pathLabel:SetFullWidth(true)
    dialog:AddChild(pathLabel)
    
    local pathInput = AceGUI:Create("EditBox")
    pathInput:SetFullWidth(true)
    pathInput:SetLabel("")
    pathInput:SetText("media/" .. currentCategory .. "/")
    dialog:AddChild(pathInput)
    
    local infoLabel = AceGUI:Create("Label")
    infoLabel:SetText("\nExample: media/borders/my_border.tga\n\nPlace your image file in the DRGUI folder at the path above.")
    infoLabel:SetFullWidth(true)
    dialog:AddChild(infoLabel)
    
    local addBtn = AceGUI:Create("Button")
    addBtn:SetText("Add Image")
    addBtn:SetFullWidth(true)
    addBtn:SetCallback("OnClick", function()
        local name = nameInput:GetText()
        local path = pathInput:GetText()
        
        if name and name ~= "" and path and path ~= "" then
            self:AddCustomImage(currentCategory, name, path)
            dialog:Hide()
            self:RefreshImageList()
        else
            print("DRGUI: Please enter both name and path")
        end
    end)
    dialog:AddChild(addBtn)
end

-- Add custom image to database
function DRGUI.ImageManager:AddCustomImage(category, name, path)
    DRGUIDB.images[category] = DRGUIDB.images[category] or {}
    
    table.insert(DRGUIDB.images[category], {
        name = name,
        path = path,
        builtin = false,
        dateAdded = date("%Y-%m-%d %H:%M:%S")
    })
    
    print("DRGUI: Added custom image: " .. name)
end

-- Delete custom image
function DRGUI.ImageManager:DeleteImage(image)
    if image.builtin then
        print("DRGUI: Cannot delete built-in images")
        return
    end
    
    for i, img in ipairs(DRGUIDB.images[currentCategory] or {}) do
        if img.name == image.name and img.path == image.path then
            table.remove(DRGUIDB.images[currentCategory], i)
            print("DRGUI: Deleted image: " .. image.name)
            self:RefreshImageList()
            return
        end
    end
end

-- Apply image to UI element
function DRGUI.ImageManager:ApplyImage(image, category)
    local comboKey = GetCharacterCombo()
    
    if not DRGUIDB[comboKey] then
        print("DRGUI: No profile found")
        return
    end
    
    if category == "borders" then
        -- Apply border to action bars
        DRGUIDB[comboKey].actionbar.bar1.backdrop = {
            texture = "Interface\\AddOns\\DRGUI\\" .. image.path
        }
        print("DRGUI: Applied border: " .. image.name)
        print("Type /reload to see changes")
        
    elseif category == "icons" then
        -- Apply icon theme
        DRGUIDB[comboKey].general.iconTheme = "Interface\\AddOns\\DRGUI\\" .. image.path
        print("DRGUI: Applied icon theme: " .. image.name)
        print("Type /reload to see changes")
        
    elseif category == "backgrounds" then
        -- Apply background to panels
        DRGUIDB[comboKey].general.panelBackdrop = {
            bgFile = "Interface\\AddOns\\DRGUI\\" .. image.path
        }
        print("DRGUI: Applied background: " .. image.name)
        print("Type /reload to see changes")
    end
    
    -- Save applied image
    DRGUIDB.images.applied = DRGUIDB.images.applied or {}
    DRGUIDB.images.applied[category] = {
        name = image.name,
        path = image.path,
        appliedDate = date("%Y-%m-%d %H:%M:%S")
    }
end

-- Refresh image list
function DRGUI.ImageManager:RefreshImageList()
    if not imageFrame then return end
    
    imageFrame:ReleaseChildren()
    
    -- Recreate UI
    CreateCategorySelector(imageFrame)
    
    local contentContainer = AceGUI:Create("SimpleGroup")
    contentContainer:SetFullWidth(true)
    contentContainer:SetFullHeight(true)
    contentContainer:SetLayout("Flow")
    
    -- Left side - Image list (50%)
    local listContainer = AceGUI:Create("SimpleGroup")
    listContainer:SetWidth(380)
    listContainer:SetFullHeight(true)
    listContainer:SetLayout("Fill")
    CreateImageList(listContainer)
    contentContainer:AddChild(listContainer)
    
    -- Right side - Preview (50%)
    local previewContainer = AceGUI:Create("SimpleGroup")
    previewContainer:SetWidth(380)
    previewContainer:SetFullHeight(true)
    previewContainer:SetLayout("Fill")
    local preview = CreateImagePreview(previewContainer, selectedImage and selectedImage.path)
    contentContainer:AddChild(previewContainer)
    
    imageFrame:AddChild(contentContainer)
    
    -- Bottom - Action buttons
    CreateActionButtons(imageFrame)
end

-- Show image manager
function DRGUI.ImageManager:Show()
    local frame = CreateImageManagerFrame()
    self:RefreshImageList()
    frame:Show()
end

-- Export
_G.DRGUI = DRGUI
