local _, addon = ...

addon.L = setmetatable({}, {
    __index = function(_, key) return key end,
})
local L = addon.L

L["welcome_heading"] = "Добро пожаловать в RimuruUI"
L["welcome_body"] = "Установщик импортирует предварительно настроенные профили для ваших аддонов."
L["resolution_heading"] = "Выберите разрешение"
L["resolution_body"] = "Это определяет, какой варианта профиля будет импортирован для каждого аддона."
L["current_scale"] = "Текущий масштаб интерфейса: "
L["next"] = "Далее"
L["back"] = "Назад"
L["begin"] = "Начать"
L["finish"] = "Завершить"
L["import"] = "Импорт"
L["complete_heading"] = "Установка завершена"
L["complete_body"] = "Все выбранные профили были импортированы.\nПерезагрузите интерфейс для применения всех изменений."
L["imported_reload"] = "%s импортирован. Профиль применится при перезагрузке интерфейса."
L["status_not_loaded"] = "Аддон не загружен"
L["status_loaded"] = "Аддон загружен"
L["status_no_data"] = "Данные профиля отсутствуют"
L["editmode_cap"] = "Edit Mode: достигнут лимит в 5 макетов, удалите один."
L["page_welcome"] = "Приветствие"
L["page_resolution"] = "Разрешение"
L["page_complete"] = "Завершение"
L["page_ellesmereui"] = "EllesmereUI"
L["page_editmode"] = "Edit Mode"
L["page_bigwigs"] = "BigWigs"
L["page_cdm"] = "Кулдаун-менеджер"
L["desc_ellesmereui"] = "Основа интерфейса\nНастройка через /ellesmereui"
L["desc_editmode"] = "Макет окна Blizzard\nESC -> Редактор макетов -> выбрать RimuruUI"
L["desc_bigwigs"] = "Таймеры боссов, таймер боя, счетчик воскрешений\nНастройка через /bigwigs"
L["desc_cdm"] = "Профили для Blizzard Cooldown Manager"