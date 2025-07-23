-- Basic Garry's Mod inventory system client side

if CLIENT then
    local inventoryData
    local invFrame

    local function requestInventory()
        net.Start("WD_OpenInventory")
        net.SendToServer()
    end

    local function updateServer()
        if not inventoryData then return end
        net.Start("WD_UpdateInventory")
        net.WriteTable(inventoryData)
        net.SendToServer()
    end

    local function createSlot(parent, slotId)
        local slot = vgui.Create("DPanel", parent)
        slot:SetSize(64,64)
        slot.Paint = function(self,w,h)
            surface.SetDrawColor(40,40,40,200)
            surface.DrawRect(0,0,w,h)
        end
        slot.DropTarget = slotId
        slot.Receiver = "WD_Slot" .. slotId
        function slot:OnDrop(mcanvas, dropped)
            local wepClass = dropped.WepClass
            if not wepClass then return end
            if dropped.SlotId then
                inventoryData.slots[dropped.SlotId] = nil
            end
            inventoryData.slots[slotId] = wepClass
            dropped:SetParent(nil)
            dropped:Remove()
            updateServer()
            createInventory() -- refresh
        end
        return slot
    end

    local function createInventory()
        if IsValid(invFrame) then invFrame:Remove() end
        invFrame = vgui.Create("DFrame")
        invFrame:SetTitle("Inventory")
        invFrame:SetSize(500,300)
        invFrame:Center()
        invFrame:MakePopup()
        invFrame.OnClose = updateServer

        local grid = vgui.Create("DIconLayout", invFrame)
        grid:Dock(FILL)
        grid:SetSpaceY(5)
        grid:SetSpaceX(5)

        for i=1,20 do
            local slot = createSlot(grid, i)
            grid:Add(slot)
            local wepClass = inventoryData.slots[i]
            if wepClass then
                local icon = vgui.Create("SpawnIcon", slot)
                icon:SetModel(weapons.Get(wepClass) and weapons.Get(wepClass).WorldModel or "models/props_c17/oildrum001.mdl")
                icon:SetSize(64,64)
                icon:SetPos(0,0)
                icon:SetDragParent(slot)
                icon:SetDropTarget(false)
                icon.WepClass = wepClass
                icon.SlotId = i
                icon:Droppable("WD_Item")
            end
        end

        hook.Run("WD_BuildInventory", invFrame, inventoryData)
    end

    net.Receive("WD_InventoryData", function()
        inventoryData = net.ReadTable() or {slots = {}}
        createInventory()
    end)

    local function toggleInventory()
        if IsValid(invFrame) then
            invFrame:Close()
        else
            requestInventory()
        end
    end

    hook.Add("PlayerButtonDown", "WD_OpenInventoryKey", function(ply, button)
        if button == KEY_TAB and not gui.IsGameUIVisible() then
            toggleInventory()
        end
    end)
end

