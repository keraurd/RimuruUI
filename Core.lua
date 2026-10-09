local addonName, addon = ...

addon.currentPage = 1
addon.resolution = nil
addon.profiles = addon.profiles or {}

-- Проверка: если installerFrame уже создан при предыдущих загрузках (например, после /reload)
if not addon.installerFrame then
    EventUtil.ContinueOnAddOnLoaded(addonName, function()
        RimuruUIDB = RimuruUIDB or {}
        if RimuruUIDB.resolution then
            addon.resolution = RimuruUIDB.resolution
        end

        SLASH_RIMURUUI1 = "/rimuruui"
        SLASH_RIMURUUI2 = "/rui"
        SlashCmdList["RIMURUUI"] = function()
            addon:ToggleInstaller()
        end
    end)
end

EventUtil.ContinueOnPlayerLogin(function()
    if not RimuruUIDB.installerShown then
        RimuruUIDB.installerShown = true
        addon:ToggleInstaller()
    end
end)

function addon:ToggleInstaller()
    if not self.installerFrame then
        self:CreateInstallerFrame()
    end

    local f = self.installerFrame
    if f:IsShown() then
        f:Hide()
    else
        self:UpdateFrameScale()
        f:Show()
        self:PreloadBigWigs()
    end
end


function addon:PreloadBigWigs()
    if self.bigWigsPreloaded then return end
    self.bigWigsPreloaded = true
    if C_AddOns.IsAddOnLoaded("BigWigs_Options") then return end
    C_Timer.After(0, function()
        C_AddOns.LoadAddOn("BigWigs_Options")
        if BigWigs and BigWigs.Enable then BigWigs:Enable() end
    end)
end

function addon:UpdateFrameScale()
    local f = self.installerFrame
    if not f then return end
    local uiScale = UIParent:GetEffectiveScale()
    f:SetScale(1 / uiScale)
end

function addon:SaveResolution(res)
    self.resolution = res
    RimuruUIDB.resolution = res
    self:ApplyEllesmereUIScale()
    self:UpdateFrameScale()
    self:RefreshScaleText()
end

function addon:RefreshScaleText()
    if not self.scaleText then return end
    self.scaleText:SetText(self.L["current_scale"] .. string.format("%.2f", UIParent:GetScale()))
end

local SCALE_BY_RES = { ["1080p"] = 0.711111, ["1440p"] = 0.533333, ["4k"] = 0.4 }

function addon:ApplyEllesmereUIScale()
    local scale = SCALE_BY_RES[self.resolution]
    if not scale then return end
    if not EllesmereUI then return end
    local E = EllesmereUI[1]
    if not E or not E.global or not E.global.general then return end
    E.global.general.UIScale = scale
    if E.PixelScaleChanged then E:PixelScaleChanged() end
end

function addon:IsAddonLoaded(addonKey)
    if addonKey == "EditMode" then return true end
    local realName = addon.ADDON_FOLDER_MAP[addonKey] or addonKey
    return C_AddOns.IsAddOnLoaded(realName)
end

function addon:GetProfileData(profileKey)
    local tbl = self.profiles[profileKey]
    if not tbl then return nil end

    if profileKey == "LittleWigsSounds" then
        return tbl
    end

    local res = self.resolution
    if not res then return nil end
    
    -- Для EllesmereUI специальная обработка - возвращаем profile1, а не всю таблицу
    if profileKey == "EllesmereUI" then
        local resData = tbl[res]
        if resData and resData.profile1 then
            return resData.profile1
        end
        return nil
    end
    
    return tbl[res]
end

function addon:HasProfileData(data)
    if not data then return false end
    if type(data) == "string" then return data ~= "" end
    if type(data) == "table" then
        if data.profile ~= nil then
            return data.profile ~= ""
        end
        for _, v in pairs(data) do
            if type(v) == "string" and v ~= "" then return true end
        end
        return false
    end
    return false
end


function addon:Print(msg, color)
    local f = self.installerFrame
    if f and f:IsShown() and f.statusLine and self:IsAddonPage(self.currentPage) then
        f.statusLine:SetText(msg)
        f.statusLine:SetTextColor(unpack(color or self.COLOR.textSec))
    else
        print("|cffe8a020RIMURUUI|r: " .. msg)
    end
end

function addon:GetImportName()
    local label = self.RES_LABEL[self.resolution]
    if label then return self.PROFILE_NAME .. " " .. label end
    return self.PROFILE_NAME
end

function addon:DoImport(addonKey, profileKey, profileData)
    local fn = self.importers[addonKey]
    if not fn then
        self:Print("No importer for " .. addonKey)
        return false
    end

    profileData = profileData or self:GetProfileData(profileKey)
    if not self:HasProfileData(profileData) then
        self:Print("No profile data for " .. profileKey)
        return false
    end

    local result = fn(profileData, profileKey)
    if result == self.IMPORT_HANDLED then return true end
    if result then
        self:Print(self.L["page_" .. self.pageConfig[self.currentPage].localeKey] .. " imported.", self.COLOR.success)
        return true
    end
    return false
end
