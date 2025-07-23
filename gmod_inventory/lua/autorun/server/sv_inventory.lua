-- Basic Garry's Mod inventory system server side

if SERVER then
    util.AddNetworkString("WD_OpenInventory")
    util.AddNetworkString("WD_InventoryData")
    util.AddNetworkString("WD_UpdateInventory")

    local function loadInventory(ply)
        if not IsValid(ply) or not ply.SteamID64 then return {slots = {}} end
        local path = "wd_inventory/" .. ply:SteamID64() .. ".txt"
        if file.Exists(path, "DATA") then
            local data = file.Read(path, "DATA")
            local tbl = util.JSONToTable(data)
            if istable(tbl) then return tbl end
        end

        local tbl = {slots = {}}
        for i, wep in ipairs(ply:GetWeapons()) do
            tbl.slots[i] = wep:GetClass()
        end
        return tbl
    end

    local function saveInventory(ply, inv)
        if not IsValid(ply) or not ply.SteamID64 then return end
        local path = "wd_inventory/" .. ply:SteamID64() .. ".txt"
        file.CreateDir("wd_inventory")
        file.Write(path, util.TableToJSON(inv, true))
    end

    net.Receive("WD_OpenInventory", function(len, ply)
        local inv = loadInventory(ply)
        ply.WD_Inventory = inv
        net.Start("WD_InventoryData")
        net.WriteTable(inv)
        net.Send(ply)
    end)

    net.Receive("WD_UpdateInventory", function(len, ply)
        local inv = net.ReadTable()
        if not istable(inv) then return end
        saveInventory(ply, inv)
        ply.WD_Inventory = inv
    end)

    hook.Add("PlayerInitialSpawn", "WD_LoadInventory", function(ply)
        ply.WD_Inventory = loadInventory(ply)
    end)
end

