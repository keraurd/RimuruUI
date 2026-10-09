local _, addon = ...

addon.importers["BigWigs"] = function(profileData)
    if not BigWigsAPI then return false end
    BigWigsAPI.RegisterProfile(addon.PROFILE_NAME, profileData, addon:GetImportName())
    return true
end
