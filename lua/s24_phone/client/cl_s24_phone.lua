local PHONE_WIDTH = 360
local PHONE_HEIGHT = 720
local BACKGROUND_CVAR = "s24_phone_bg"

CreateClientConVar(BACKGROUND_CVAR, "", true, false, "Background image URL")

local function createAppFrame(title)
    local frame = vgui.Create("DFrame")
    frame:SetSize(PHONE_WIDTH * 0.9, PHONE_HEIGHT * 0.8)
    frame:SetTitle(title)
    frame:Center()
    frame:MakePopup()
    frame:SetSizable(false)
    frame:ShowCloseButton(true)
    return frame
end

local apps = {
    {name = "Messages", icon = "icon16/comments.png", open = function()
        local f = createAppFrame("Messages")
        local label = vgui.Create("DLabel", f)
        label:Dock(FILL)
        label:SetText("Messaging app placeholder")
        label:SetContentAlignment(5)
    end},
    {name = "Browser", icon = "icon16/world.png", open = function()
        local f = createAppFrame("Browser")
        local html = vgui.Create("DHTML", f)
        html:Dock(FILL)
        html:OpenURL("https://google.com")
    end},
    {name = "Settings", icon = "icon16/cog.png", open = function()
        local f = createAppFrame("Settings")
        local label = vgui.Create("DLabel", f)
        label:Dock(TOP)
        label:SetText("Enter Imgur link for background:")

        local textEntry = vgui.Create("DTextEntry", f)
        textEntry:Dock(TOP)
        textEntry:SetText(GetConVar(BACKGROUND_CVAR):GetString())

        local saveButton = vgui.Create("DButton", f)
        saveButton:Dock(TOP)
        saveButton:SetText("Save")
        saveButton.DoClick = function()
            RunConsoleCommand(BACKGROUND_CVAR, textEntry:GetValue())
        end
    end}
}

local phoneFrame

local function openPhone()
    if IsValid(phoneFrame) then return end

    phoneFrame = vgui.Create("DFrame")
    phoneFrame:SetSize(PHONE_WIDTH, PHONE_HEIGHT)
    phoneFrame:SetTitle("")
    phoneFrame:ShowCloseButton(false)
    phoneFrame:SetDraggable(true)
    phoneFrame:Center()
    phoneFrame:MakePopup()

    local bgPanel = vgui.Create("DPanel", phoneFrame)
    bgPanel:Dock(FILL)

    local bgImage = vgui.Create("DHTML", bgPanel)
    bgImage:Dock(FILL)
    bgImage:SetHTML("<style>body{margin:0;padding:0;background-size:cover;background-image:url('" .. GetConVar(BACKGROUND_CVAR):GetString() .. "');}</style>")

    local grid = vgui.Create("DIconLayout", bgPanel)
    grid:Dock(FILL)
    grid:SetSpaceY(5)
    grid:SetSpaceX(5)

    for _, app in ipairs(apps) do
        local btn = grid:Add("DButton")
        btn:SetSize(64,64)
        btn:SetText("")
        btn:SetIcon(app.icon)
        function btn:DoClick()
            app.open()
        end
    end

    phoneFrame.OnClose = function()
        phoneFrame = nil
    end
end

concommand.Add("s24_phone_toggle", function()
    if IsValid(phoneFrame) then
        phoneFrame:Close()
        phoneFrame = nil
    else
        openPhone()
    end
end)

hook.Add("OnPlayerChat", "s24_phone_chatcommand", function(ply, text)
    if ply ~= LocalPlayer() then return end
    if string.lower(text) == "!phone" then
        RunConsoleCommand("s24_phone_toggle")
        return true
    end
end)
