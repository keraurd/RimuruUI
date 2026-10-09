local _, addon = ...
local L = addon.L

addon.importers = {}
addon.IMPORT_HANDLED = {}

function addon:DoImport(addonKey, profileKey, profileData)
    local fn = addon.importers[addonKey]
    if not fn then
        addon:Print("No importer for " .. addonKey)
        return false
    end

    profileData = profileData or addon:GetProfileData(profileKey)
    if not addon:HasProfileData(profileData) then
        addon:Print("No profile data for " .. profileKey)
        return false
    end

    local result = fn(profileData, profileKey)
    if result == addon.IMPORT_HANDLED then return true end
    if result then
        addon:Print(L["page_" .. addon.pageConfig[addon.currentPage].localeKey] .. " imported.", addon.COLOR.success)
        return true
    end
    return false
end
