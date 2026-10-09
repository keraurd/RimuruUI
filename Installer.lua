local _, addon = ...
local L = addon.L
local C = addon.COLOR

local CONTENT_WIDTH  = addon.FRAME_WIDTH - addon.NAV_WIDTH
local CONTENT_HEIGHT = addon.FRAME_HEIGHT - addon.HEADER_HEIGHT - addon.BAR_HEIGHT

local PIXEL = 768 / select(2, GetPhysicalScreenSize())

local BACKDROP = {
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = PIXEL,
    insets   = { left = PIXEL, right = PIXEL, top = PIXEL, bottom = PIXEL },
}

local function DisableSnap(tex)
    if tex.SetSnapToPixelGrid then tex:SetSnapToPixelGrid(false) end
    if tex.SetTexelSnappingBias then tex:SetTexelSnappingBias(0) end
end

local function DisableTextureSnapping(frame)
    local regions = { frame:GetRegions() }
    for i = 1, #regions do
        local r = regions[i]
        if r and r:IsObjectType("Texture") then
            DisableSnap(r)
        end
    end
end

local function ReapplyHover(btn)
    if btn:IsMouseOver() and btn:IsEnabled() then
        local onEnter = btn:GetScript("OnEnter")
        if onEnter then onEnter(btn) end
    end
end

local function AccentColorCode(c)
    return string.format("|cff%02x%02x%02x", math.floor(c[1]*255 + 0.5), math.floor(c[2]*255 + 0.5), math.floor(c[3]*255 + 0.5))
end

local function MakeFontString(parent, size, color)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs:SetFont(addon.font, size or 12, "OUTLINE")
    if color then fs:SetTextColor(unpack(color)) end
    return fs
end

local function MakeButton(parent, w, h, label, accent)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(w, h)
    btn:SetBackdrop(BACKDROP)
    DisableTextureSnapping(btn)
    if accent then
        btn:SetBackdropColor(unpack(C.accentBg))
        btn:SetBackdropBorderColor(unpack(C.accent))
    else
        btn:SetBackdropColor(unpack(C.btnBg))
        btn:SetBackdropBorderColor(unpack(C.border))
    end
    local text = btn:CreateFontString(nil, "OVERLAY")
    text:SetFont(addon.font, 10, "OUTLINE")
    text:SetPoint("CENTER")
    text:SetText(label or "")
    if accent then
        text:SetTextColor(unpack(C.accent))
    else
        text:SetTextColor(unpack(C.textSec))
    end
    btn.label = text
    btn:SetScript("OnEnter", function(self)
        if not self:IsEnabled() then return end
        if accent then
            self:SetBackdropColor(unpack(C.accentBgHov))
        else
            self:SetBackdropColor(unpack(C.btnBgHover))
            self.label:SetTextColor(1, 1, 1)
        end
    end)
    btn:SetScript("OnLeave", function(self)
        if accent then
            self:SetBackdropColor(unpack(C.accentBg))
        else
            self:SetBackdropColor(unpack(C.btnBg))
            self.label:SetTextColor(unpack(C.textSec))
        end
    end)
    return btn
end

local function ColorGradient(pct, r1,g1,b1, r2,g2,b2, r3,g3,b3)
    if pct <= 0.5 then
        local t = pct * 2
        return r1+(r2-r1)*t, g1+(g2-g1)*t, b1+(b2-b1)*t
    else
        local t = (pct - 0.5) * 2
        return r2+(r3-r2)*t, g2+(g3-g2)*t, b2+(b3-b2)*t
    end
end

function addon:RefreshAddonPage(cfg)
    local f = self.installerFrame
    local statusText = f.addonStatus
    local importBtn = f.addonImportBtn

    importBtn:Show()
    statusText:Show()

    if not self:IsAddonLoaded(cfg.addonKey) then
        statusText:SetText(L["status_not_loaded"])
        statusText:SetTextColor(unpack(C.statusErr))
        importBtn:Disable()
        importBtn:SetAlpha(0.4)
        return
    end

    local profileData = self:GetProfileData(cfg.profileKey)
    if not self:HasProfileData(profileData) then
        statusText:SetText(L["status_no_data"])
        statusText:SetTextColor(unpack(C.textLocked))
        importBtn:Disable()
        importBtn:SetAlpha(0.4)
        return
    end

    statusText:Hide()

    importBtn:Enable()
    importBtn:SetAlpha(1)
    importBtn:SetScript("OnClick", function()
        if addon:DoImport(cfg.addonKey, cfg.profileKey) then
            addon:RefreshAddonPage(cfg)
        end
    end)
end

function addon:CreateInstallerFrame()
    addon.pageContent = {}
    for i = 1, addon.TOTAL_PAGES do
        addon.pageContent[i] = {}
    end

    local welcomeIdx    = addon:GetPageIndexByType("welcome")
    local resolutionIdx = addon:GetPageIndexByType("resolution")
    local completeIdx   = addon:GetPageIndexByType("complete")

    local f = CreateFrame("Frame", "RimuruUIInstallerFrame", UIParent, "BackdropTemplate")
    f:SetBackdrop(BACKDROP)
    DisableTextureSnapping(f)
    f:SetBackdropColor(unpack(C.bg))
    f:SetBackdropBorderColor(unpack(C.border))
    f:SetSize(addon.FRAME_WIDTH, addon.FRAME_HEIGHT)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetClampedToScreen(true)
    f:Hide()
    tinsert(UISpecialFrames, "RimuruUIInstallerFrame")
    f:SetScript("OnShow", function()
        addon:UpdateBottomBar()
    end)

    local bg = f:CreateTexture(nil, "BACKGROUND", nil, 1)
    bg:SetAllPoints()
    bg:SetTexture(addon.MEDIA_PATH .. "Rimuru_background_1.png")
    local frameRatio = addon.FRAME_WIDTH / addon.FRAME_HEIGHT
    local texRatio = 16 / 9
    local cropX = (1 - frameRatio / texRatio) / 2
    bg:SetTexCoord(cropX, 1 - cropX, 0, 1)
    bg:SetAlpha(addon.BG_ALPHA)

    local header = CreateFrame("Frame", nil, f)
    header:SetSize(CONTENT_WIDTH, addon.HEADER_HEIGHT)
    header:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)

    local headerShield = f:CreateTexture(nil, "ARTWORK")
    headerShield:SetSize(128, 72)
    headerShield:SetPoint("TOPLEFT", f, "TOPLEFT", -56, 24)
    headerShield:SetTexture(addon.MEDIA_PATH .. "logo_shield.png")

    local headerTitle = header:CreateFontString(nil, "OVERLAY")
    headerTitle:SetFont(addon.font, 12, "OUTLINE")
    headerTitle:SetPoint("LEFT", header, "LEFT", 36, 0)
    headerTitle:SetText(AccentColorCode(C.accent) .. "RimuruUI|r Installation")

    f.headerShield = headerShield
    f.headerTitle = headerTitle

    local nav = CreateFrame("Frame", nil, f, "BackdropTemplate")
    nav:SetSize(addon.NAV_WIDTH, addon.FRAME_HEIGHT)
    nav:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
    nav:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
    nav:SetBackdropColor(0, 0, 0, 0.35)

    local sep = f:CreateTexture(nil, "ARTWORK")
    sep:SetSize(PIXEL, addon.FRAME_HEIGHT)
    sep:SetPoint("TOPRIGHT", nav, "TOPLEFT")
    sep:SetColorTexture(0, 0, 0, 1)
    DisableSnap(sep)

    local pageNames = {}
    for i = 1, addon.TOTAL_PAGES do
        local cfg = addon.pageConfig[i]
        if cfg.type == "addon" then
            pageNames[i] = L["page_" .. cfg.localeKey]
        else
            pageNames[i] = L["page_" .. cfg.type]
        end
    end

    local sepAfter = { [resolutionIdx] = true, [completeIdx - 1] = true }
    local NAV_TEXT_H = 16
    local NAV_GAP = 8
    local yPos = -8

    addon.navButtons = {}
    for i = 1, addon.TOTAL_PAGES do
        if sepAfter[i - 1] then
            local line = nav:CreateTexture(nil, "ARTWORK")
            line:SetSize(addon.NAV_WIDTH - 16, PIXEL)
            line:SetPoint("TOPLEFT", nav, "TOPLEFT", 8, yPos)
            line:SetColorTexture(0, 0, 0, 1)
            DisableSnap(line)
            yPos = yPos - NAV_GAP
        end

        local btn = CreateFrame("Button", nil, nav)
        btn:SetSize(addon.NAV_WIDTH - 8, NAV_TEXT_H)
        btn:SetPoint("TOPLEFT", nav, "TOPLEFT", 4, yPos)

        local label = btn:CreateFontString(nil, "OVERLAY")
        label:SetFont(addon.font, 10, "OUTLINE")
        label:SetPoint("LEFT", 6, 0)
        label:SetText(pageNames[i])
        label:SetTextColor(unpack(C.textLocked))
        btn.label = label

        local pageIndex = i
        btn:SetScript("OnClick", function()
            if addon:CanNavigateTo(pageIndex) then
                addon:GoToPage(pageIndex)
            end
        end)
        btn:SetScript("OnEnter", function(self)
            if pageIndex == addon.currentPage then
                self.label:SetTextColor(unpack(C.accentHover))
            elseif addon:CanNavigateTo(pageIndex) then
                self.label:SetTextColor(1, 1, 1)
            end
        end)
        btn:SetScript("OnLeave", function()
            addon:UpdateNav()
        end)

        addon.navButtons[i] = btn
        yPos = yPos - NAV_TEXT_H - NAV_GAP
    end

    local content = CreateFrame("Frame", nil, f)
    content:SetSize(CONTENT_WIDTH, CONTENT_HEIGHT)
    content:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -addon.HEADER_HEIGHT)

    local backBtn = MakeButton(content, 70, 22, L["back"])
    backBtn:SetPoint("BOTTOMRIGHT", content, "BOTTOM", -8, 20)
    backBtn:SetScript("OnClick", function()
        addon:GoToPage(addon.currentPage - 1)
    end)

    local nextBtn = MakeButton(content, 70, 22, L["next"])
    nextBtn:SetPoint("BOTTOMLEFT", content, "BOTTOM", 8, 20)
    nextBtn:SetScript("OnClick", function()
        if addon.currentPage == addon.TOTAL_PAGES then
            ReloadUI()
        else
            addon:GoToPage(addon.currentPage + 1)
        end
    end)
    nextBtn:SetScript("OnEnter", function(self)
        if not self:IsEnabled() then return end
        if self.isSuccess then
            self:SetBackdropColor(unpack(C.successBgHov))
        else
            self:SetBackdropColor(unpack(C.btnBgHover))
            self.label:SetTextColor(unpack(C.accent))
        end
    end)
    nextBtn:SetScript("OnLeave", function(self)
        if self.isSuccess then
            self:SetBackdropColor(unpack(C.successBg))
        else
            self:SetBackdropColor(unpack(C.btnBg))
            self.label:SetTextColor(unpack(C.textSec))
        end
    end)

    local bar = CreateFrame("Frame", nil, f)
    bar:SetSize(CONTENT_WIDTH, addon.BAR_HEIGHT)
    bar:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)

    local progressBg = CreateFrame("Frame", nil, bar, "BackdropTemplate")
    progressBg:SetHeight(6)
    progressBg:SetPoint("LEFT", bar, "LEFT", 12, 0)
    progressBg:SetPoint("RIGHT", bar, "RIGHT", -50, 0)
    progressBg:SetBackdrop(BACKDROP)
    DisableTextureSnapping(progressBg)
    progressBg:SetBackdropColor(0.10, 0.10, 0.10, 1)
    progressBg:SetBackdropBorderColor(unpack(C.border))

    local progressFill = progressBg:CreateTexture(nil, "ARTWORK")
    progressFill:SetPoint("TOPLEFT", progressBg, "TOPLEFT", PIXEL, -PIXEL)
    progressFill:SetHeight(6 - PIXEL * 2)
    DisableSnap(progressFill)

    local pageCounter = MakeFontString(bar, 11, C.textSec)
    pageCounter:SetPoint("RIGHT", bar, "RIGHT", -12, 0)

    local versionLabel = MakeFontString(f, 9, { 0.80, 0.20, 0.20 })
    versionLabel:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -6, 5)
    versionLabel:SetText("v" .. addon.VERSION)

    f.content = content
    f.backBtn = backBtn
    f.nextBtn = nextBtn
    f.progressBg = progressBg
    f.progressFill = progressFill
    f.pageCounter = pageCounter

    local welcomeHeading = MakeFontString(content, 18, C.accent)
    welcomeHeading:SetPoint("CENTER", content, "CENTER", 0, 20)
    welcomeHeading:SetText(L["welcome_heading"])
    welcomeHeading:Hide()
    addon.pageContent[welcomeIdx][#addon.pageContent[welcomeIdx] + 1] = welcomeHeading

    local welcomeBody = MakeFontString(content, 13, C.textSec)
    welcomeBody:SetPoint("TOP", welcomeHeading, "BOTTOM", 0, -10)
    welcomeBody:SetWidth(CONTENT_WIDTH - 60)
    welcomeBody:SetJustifyH("CENTER")
    welcomeBody:SetText(L["welcome_body"])
    welcomeBody:Hide()
    addon.pageContent[welcomeIdx][#addon.pageContent[welcomeIdx] + 1] = welcomeBody

    local shield = content:CreateTexture(nil, "ARTWORK")
    shield:SetSize(192, 108)
    shield:SetPoint("BOTTOM", welcomeHeading, "TOP", 0, 12)
    shield:SetTexture(addon.MEDIA_PATH .. "logo_shield.png")
    shield:Hide()
    addon.pageContent[welcomeIdx][#addon.pageContent[welcomeIdx] + 1] = shield

    local resHeading = MakeFontString(content, 18, C.text)
    resHeading:SetPoint("CENTER", content, "CENTER", 0, 60)
    resHeading:SetText(L["resolution_heading"])
    resHeading:Hide()
    addon.pageContent[resolutionIdx][#addon.pageContent[resolutionIdx] + 1] = resHeading

    local resBody = MakeFontString(content, 13, C.textSec)
    resBody:SetPoint("TOP", resHeading, "BOTTOM", 0, -10)
    resBody:SetWidth(CONTENT_WIDTH - 60)
    resBody:SetJustifyH("CENTER")
    resBody:SetText(L["resolution_body"])
    resBody:Hide()
    addon.pageContent[resolutionIdx][#addon.pageContent[resolutionIdx] + 1] = resBody

    local resolutions = { "1080p", "1440p", "4k" }
    local resLabels = { "1080p", "1440p", "4K" }
    addon.resButtons = {}

    for i, res in ipairs(resolutions) do
        local btn = MakeButton(content, 80, 24, resLabels[i])
        btn:SetPoint("CENTER", content, "CENTER", (i - 2) * 90, -20)
        btn:Hide()
        btn:SetScript("OnClick", function()
            addon:SaveResolution(res)
            addon:GoToPage(addon.currentPage)
        end)
        btn:SetScript("OnEnter", function(self)
            if self.isSelected then
                self:SetBackdropColor(unpack(C.accentBgHov))
            else
                self:SetBackdropColor(unpack(C.btnBgHover))
                self.label:SetTextColor(1, 1, 1)
            end
        end)
        btn:SetScript("OnLeave", function(self)
            if self.isSelected then
                self:SetBackdropColor(unpack(C.accentBg))
            else
                self:SetBackdropColor(unpack(C.btnBg))
                self.label:SetTextColor(unpack(C.textSec))
            end
        end)
        addon.pageContent[resolutionIdx][#addon.pageContent[resolutionIdx] + 1] = btn
        addon.resButtons[res] = btn
    end

    local scaleText = MakeFontString(content, 11, C.textSec)
    scaleText:SetPoint("CENTER", content, "CENTER", 0, -55)
    scaleText:Hide()
    addon.scaleText = scaleText
    addon:RefreshScaleText()
    addon.pageContent[resolutionIdx][#addon.pageContent[resolutionIdx] + 1] = scaleText

    local addonHeading = MakeFontString(content, 18, C.text)
    addonHeading:SetPoint("CENTER", content, "CENTER", 0, 60)
    addonHeading:Hide()

    local addonDesc = MakeFontString(content, 13, C.textSec)
    addonDesc:SetPoint("TOP", addonHeading, "BOTTOM", 0, -12)
    addonDesc:SetWidth(CONTENT_WIDTH - 60)
    addonDesc:SetJustifyH("CENTER")
    addonDesc:Hide()

    local addonStatus = MakeFontString(content, 12)
    addonStatus:SetPoint("CENTER", content, "CENTER", 0, -10)
    addonStatus:Hide()

    local addonImportBtn = MakeButton(content, 120, 26, L["import"], true)
    addonImportBtn:SetPoint("CENTER", content, "CENTER", 0, -40)
    addonImportBtn:Hide()

    local statusLine = MakeFontString(content, 11, C.textSec)
    statusLine:SetPoint("TOP", addonImportBtn, "BOTTOM", 0, -10)
    statusLine:Hide()

    f.addonHeading = addonHeading
    f.addonDesc = addonDesc
    f.addonStatus = addonStatus
    f.addonImportBtn = addonImportBtn
    f.statusLine = statusLine



    local completeHeading = MakeFontString(content, 18, C.accent)
    completeHeading:SetPoint("CENTER", content, "CENTER", 0, 20)
    completeHeading:SetText(L["complete_heading"])
    completeHeading:Hide()
    addon.pageContent[completeIdx][#addon.pageContent[completeIdx] + 1] = completeHeading

    local completeBody = MakeFontString(content, 13, C.textSec)
    completeBody:SetPoint("TOP", completeHeading, "BOTTOM", 0, -12)
    completeBody:SetWidth(CONTENT_WIDTH - 60)
    completeBody:SetJustifyH("CENTER")
    completeBody:SetText(L["complete_body"])
    completeBody:Hide()
    addon.pageContent[completeIdx][#addon.pageContent[completeIdx] + 1] = completeBody

    addon.installerFrame = f
    addon:GoToPage(1)
end

function addon:CanNavigateTo(pageIndex)
    if pageIndex < 1 or pageIndex > addon.TOTAL_PAGES then return false end
    if addon:RequiresResolution(pageIndex) and not addon.resolution then return false end
    return true
end

function addon:GoToPage(pageIndex)
    if not addon:CanNavigateTo(pageIndex) then return end

    local f = addon.installerFrame

    for _, elements in pairs(addon.pageContent) do
        for _, el in ipairs(elements) do
            if el.Hide then el:Hide() end
        end
    end

    addon.currentPage = pageIndex
    local elements = addon.pageContent[pageIndex]
    if elements then
        for _, el in ipairs(elements) do
            if el.Show then el:Show() end
        end
    end

    local cfg = addon.pageConfig[pageIndex]
    local isAddonPage = addon:IsAddonPage(pageIndex)
    local isWelcome = addon:IsWelcomePage(pageIndex)

    f.headerShield:SetShown(not isWelcome)
    f.headerTitle:SetShown(not isWelcome)

    f.addonHeading:SetShown(isAddonPage)
    f.addonDesc:SetShown(isAddonPage)
    f.addonStatus:SetShown(isAddonPage)
    f.addonImportBtn:SetShown(isAddonPage)
    f.statusLine:SetText("")
    f.statusLine:SetShown(isAddonPage)

    if isAddonPage then
        f.addonHeading:SetText(L["page_" .. cfg.localeKey])
        f.addonDesc:SetText(L["desc_" .. cfg.localeKey])
        addon:RefreshAddonPage(cfg)
    end

    if addon:IsResolutionPage(pageIndex) and addon.resButtons then
        for res, btn in pairs(addon.resButtons) do
            if res == addon.resolution then
                btn.isSelected = true
                btn:SetBackdropColor(unpack(C.accentBg))
                btn:SetBackdropBorderColor(unpack(C.accent))
                btn.label:SetTextColor(unpack(C.accent))
            else
                btn.isSelected = false
                btn:SetBackdropColor(unpack(C.btnBg))
                btn:SetBackdropBorderColor(unpack(C.border))
                btn.label:SetTextColor(unpack(C.textSec))
            end
            ReapplyHover(btn)
        end
    end

    addon:UpdateNav()
    addon:UpdateBottomBar()
end

function addon:UpdateNav()
    for i, btn in ipairs(addon.navButtons) do
        local canNav = addon:CanNavigateTo(i)
        if i == addon.currentPage then
            btn.label:SetTextColor(unpack(C.accent))
        elseif canNav then
            btn.label:SetTextColor(unpack(C.textSec))
        else
            btn.label:SetTextColor(unpack(C.textLocked))
        end
    end
end

function addon:UpdateBottomBar()
    local f = addon.installerFrame
    local page = addon.currentPage

    f.backBtn:SetShown(not addon:IsWelcomePage(page))

    f.nextBtn:ClearAllPoints()
    local isSuccess = addon:IsWelcomePage(page) or addon:IsCompletePage(page)
    f.nextBtn.isSuccess = isSuccess
    if addon:IsWelcomePage(page) then
        f.nextBtn.label:SetText(L["begin"])
        f.nextBtn:SetPoint("BOTTOM", f.content, "BOTTOM", 0, 20)
    else
        f.nextBtn.label:SetText(addon:IsCompletePage(page) and L["finish"] or L["next"])
        f.nextBtn:SetPoint("BOTTOMLEFT", f.content, "BOTTOM", 8, 20)
    end

    if isSuccess then
        f.nextBtn:SetBackdropColor(unpack(C.successBg))
        f.nextBtn:SetBackdropBorderColor(unpack(C.success))
        f.nextBtn.label:SetTextColor(unpack(C.success))
    else
        f.nextBtn:SetBackdropColor(unpack(C.btnBg))
        f.nextBtn:SetBackdropBorderColor(unpack(C.border))
        f.nextBtn.label:SetTextColor(unpack(C.textSec))
    end

    if addon:IsResolutionPage(page) and not addon.resolution then
        f.nextBtn:Disable()
        f.nextBtn:SetAlpha(0.4)
    else
        f.nextBtn:Enable()
        f.nextBtn:SetAlpha(1)
    end

    ReapplyHover(f.nextBtn)

    local ratio = page / addon.TOTAL_PAGES
    local bgW = f.progressBg:GetWidth() - PIXEL * 2
    f.progressFill:SetWidth(math.max(1, bgW * ratio))
    local r, g, b = ColorGradient(ratio,
        C.barStart[1], C.barStart[2], C.barStart[3],
        C.barMid[1],   C.barMid[2],   C.barMid[3],
        C.barEnd[1],   C.barEnd[2],   C.barEnd[3])
    f.progressFill:SetColorTexture(r, g, b, 1)

    f.pageCounter:SetText(page .. " / " .. addon.TOTAL_PAGES)
end
