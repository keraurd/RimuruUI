local _, addon = ...

addon.font = [[Interface\AddOns\RimuruUI\Media\Fonts\Expressway.ttf]]
addon.MEDIA_PATH = "Interface\\AddOns\\RimuruUI\\Media\\Textures\\"
addon.PROFILE_NAME = "RimuruUI"

addon.COLOR = {
    accent      = { 0.91, 0.63, 0.13 },
    accentHover = { 0.95, 0.75, 0.30 },
    bg          = { 0.125, 0.125, 0.125, 1 },
    border      = { 0, 0, 0, 1 },
    text        = { 1, 1, 1 },
    textSec     = { 0.67, 0.67, 0.67 },
    textLocked  = { 0.33, 0.33, 0.33 },
    statusOk    = { 0.27, 1, 0.27 },
    statusErr   = { 1, 0.27, 0.27 },
    barStart    = { 0.80, 0.20, 0.20 },
    barMid      = { 0.80, 0.80, 0.20 },
    barEnd      = { 0.20, 0.80, 0.20 },
    btnBg       = { 0.165, 0.165, 0.165, 1 },
    btnBgHover  = { 0.22, 0.22, 0.22, 1 },
    accentBg    = { 0.137, 0.095, 0.020, 1 },
    accentBgHov = { 0.273, 0.189, 0.039, 1 },
    success     = { 0.35, 0.80, 0.35 },
    successBg   = { 0.052, 0.120, 0.052, 1 },
    successBgHov = { 0.105, 0.240, 0.105, 1 },
}

addon.VERSION = "1.0.0"

addon.FRAME_WIDTH   = 460
addon.FRAME_HEIGHT  = 360
addon.NAV_WIDTH     = 120
addon.HEADER_HEIGHT = 32
addon.BAR_HEIGHT    = 24
addon.BG_ALPHA      = 0.05

addon.pageConfig = {
    [1]  = { type = "welcome" },
    [2]  = { type = "resolution" },
    [3]  = { type = "addon", addonKey = "EllesmereUI",   localeKey = "ellesmereui", profileKey = "EllesmereUI" },
    [4]  = { type = "addon", addonKey = "EditMode",      localeKey = "editmode",    profileKey = "EditMode" },
    [5]  = { type = "addon", addonKey = "BigWigs",       localeKey = "bigwigs",     profileKey = "BigWigs" },
    [6]  = { type = "complete" },
}

addon.TOTAL_PAGES = #addon.pageConfig

function addon:IsWelcomePage(i)    local c = self.pageConfig[i]; return c and c.type == "welcome"    end
function addon:IsResolutionPage(i) local c = self.pageConfig[i]; return c and c.type == "resolution" end
function addon:IsAddonPage(i)      local c = self.pageConfig[i]; return c and c.type == "addon"      end
function addon:IsCompletePage(i)   local c = self.pageConfig[i]; return c and c.type == "complete"   end

function addon:RequiresResolution(i)
    local c = self.pageConfig[i]
    return c and (c.type == "addon" or c.type == "complete")
end

function addon:GetPageIndexByType(pageType, addonKey)
    for i, c in ipairs(self.pageConfig) do
        if c.type == pageType and (not addonKey or c.addonKey == addonKey) then
            return i
        end
    end
end

addon.RES_LABEL = { ["1080p"] = "1080", ["1440p"] = "1440", ["4k"] = "4K" }

addon.ADDON_FOLDER_MAP = {
    ["EllesmereUI"] = "EllesmereUI",
    ["EditMode"] = "EditMode",
    ["BigWigs"] = "BigWigs",
}
