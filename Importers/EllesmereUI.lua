local _, addon = ...

-- Функция для определения разрешения экрана игрока
local function GetCurrentResolutionBucket()
    local width = tonumber(string.match(GetCVar("gxWindowedResolution") or GetCVar("gxFullscreenResolution") or "1920x1080", "(%d+)x")) or 1920
    if width >= 3840 then
        return "4k"
    elseif width >= 2560 then
        return "1440p"
    else
        return "1080p"
    end
end

-- Полностью автоматический импортер на основе официального API EllesmereUI
addon.importers["EllesmereUI"] = function(profileData)
    -- 1. Вытаскиваем нужную строку под текущее разрешение экрана
    local rawString = ""
    if type(profileData) == "string" and profileData ~= "" then
        rawString = profileData
    elseif type(profileData) == "table" then
        local bucket = GetCurrentResolutionBucket()
        local resolutionTable = profileData[bucket] or profileData["1080p"]
        if resolutionTable and resolutionTable.profile1 then
            rawString = resolutionTable.profile1
        end
    end

    if rawString == "" then
        return false
    end
    
    -- 2. Убеждаемся, что EllesmereUI загружен
    if not C_AddOns.IsAddOnLoaded("EllesmereUI") then
        C_AddOns.LoadAddOn("EllesmereUI")
        if not C_AddOns.IsAddOnLoaded("EllesmereUI") then
            return false
        end
    end
    
    -- 3. Выполняем полностью автоматический импорт через официальное глобальное API
    -- Даем небольшую задержку (0.3 сек), чтобы глобальный объект EllesmereUI точно инициализировался
    C_Timer.After(0.3, function()
        if not _G["EllesmereUI"] then return end
        
        -- Получаем имя создаваемого профиля
        local profileName = (addon.GetImportName and addon:GetImportName()) or addon.PROFILE_NAME or "RimuruUI 1080p"
        
        -- Используем точный метод из предоставленного тобой файла модуля интеграции
        if type(EllesmereUI.ImportProfile) == "function" then
            -- Родная функция EllesmereUI сама раскодирует строку и создаст профиль в базе данных
            EllesmereUI.ImportProfile(rawString, profileName)
            
            -- Принудительно делаем этот профиль активным для текущего персонажа
            if type(EllesmereUI.SetProfile) == "function" then
                EllesmereUI.SetProfile(profileName)
            end
            
            -- Применяем масштаб интерфейса из твоего RimuruUI
            if addon.ApplyEllesmereUIScale then
                addon:ApplyEllesmereUIScale()
            end
            
            -- Выводим системный принт об успешной автоматической настройке
            if addon.Print then
                addon:Print("Интерфейс EllesmereUI успешно импортирован автоматически! Для сохранения настроек введите: /reload", addon.COLOR and addon.COLOR.success)
            end
        end
    end)
    
    return true
end
