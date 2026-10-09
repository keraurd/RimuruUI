local _, addon = ...
local L = addon.L

addon.importers["EditMode"] = function(profileData)
    local layoutInfo = C_EditMode.ConvertStringToLayoutInfo(profileData)
    if not layoutInfo then return false end

    local name = addon:GetImportName()
    local layouts = C_EditMode.GetLayouts()

    local existingIndex
    for i = #layouts.layouts, 1, -1 do
        if layouts.layouts[i].layoutName == name then
            existingIndex = i
            tremove(layouts.layouts, i)
        end
    end

    if not existingIndex and #layouts.layouts >= 5 then
        addon:Print(L["editmode_cap"], addon.COLOR.statusErr)
        return false
    end

    layoutInfo.layoutName = name
    layoutInfo.layoutType = Enum.EditModeLayoutType.Account

    tinsert(layouts.layouts, layoutInfo)
    C_EditMode.SaveLayouts(layouts)

    local newIndex = Enum.EditModePresetLayoutsMeta.NumValues + #layouts.layouts
    if existingIndex then
        C_EditMode.SetActiveLayout(newIndex)
    else
        C_EditMode.OnLayoutAdded(newIndex, true, true)
    end

    return true
end
