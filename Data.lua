-- Data.lua - Данные для автоматической настройки интерфейса
local _, addon = ...

addon.WARNINGS = {
    bigwigs_not_loaded = "BigWigs не загружен. Установка прервана.",
    bigwigs_not_found = "BigWigs не установлен. Установка прервана.",
    already_installed = "Настройка интерфейса уже выполнена для этого персонажа.",
    install_success = "Интерфейс успешно настроен!",
    install_failed = "Ошибка при настройке интерфейса: %s",
}
addon.profiles = {}
addon.importers = {}

addon.PROFILE_NAME = "RimuruUI"

function addon:GetResolution()
    local uiScale = UIParent:GetScale()
    if uiScale <= 0.64 then return "4k"
    elseif uiScale <= 0.711111 then return "1440p"
    else return "1080p"
    end
end

addon.resolution = addon:GetResolution()

addon.BIGWIGS_PROFILE_NAME = "RimuruUI"
addon.BIGWIGS_PROFILE_DATA = {
    ["namespaces"] = {
        ["Bars"] = {
            ["profiles"] = {
                ["RimuruUI"] = {
                    ["fontName"] = "Rimuru - Expressway",
                    ["fontSize"] = 12,
                    ["texture"] = "Rimuru - EthricArrow",
                    ["growup"] = true,
                    ["emphasizeGrowup"] = true,
                    ["emphasizeScale"] = 1.2,
                    ["iconPosition"] = "LEFT",
                    ["visibleBars"] = 10,
                    ["positions"] = {
                        ["BigWigsAnchor"] = {
                            ["point"] = "CENTER",
                            ["relPoint"] = "CENTER",
                            ["x"] = -350,
                            ["y"] = -120,
                        },
                        ["BigWigsEmphasizedAnchor"] = {
                            ["point"] = "CENTER",
                            ["relPoint"] = "CENTER",
                            ["x"] = 0,
                            ["y"] = 180,
                        },
                    },
                },
            },
        },
        ["Messages"] = {
            ["profiles"] = {
                ["RimuruUI"] = {
                    ["fontName"] = "Rimuru - Expressway",
                    ["fontSize"] = 22,
                    ["positions"] = {
                        ["BigWigsMessageAnchor"] = {
                            ["point"] = "TOP",
                            ["relPoint"] = "TOP",
                            ["x"] = 0,
                            ["y"] = -220,
                        },
                    },
                },
            },
        },
    },
    ["profiles"] = {
        ["RimuruUI"] = {
            ["fontName"] = "Rimuru - Expressway",
        },
    },
}

addon.ELITES_EDIT_MODE_LAYOUT_STRING = "2 52 0 0 1 7 7 UIParent 0.0 45.0 -1 ##$$%/&%'%)$+$,$ 0 1 1 7 7 UIParent 0.0 45.0 -1 ##$$%/&%'%(#,$ 0 2 1 7 7 UIParent 0.0 45.0 -1 ##$$%/&%'%(#,$ 0 3 1 5 5 UIParent -5.0 -77.0 -1 #$$$%/&''%(#,$ 0 4 1 5 5 UIParent -5.0 -77.0 -1 #$$$%/&''%(#,$ 0 5 0 4 4 UIParent 300.0 -417.7 -1 #$$%%-&&'%(#,$ 0 6 1 1 4 UIParent 0.0 -50.0 -1 ##$$%/&('%(#,$ 0 7 1 1 4 UIParent 0.0 -100.0 -1 ##$$%/&('%(#,$ 0 10 1 7 7 UIParent 0.0 45.0 -1 ##$$&('% 0 11 1 7 7 UIParent 0.0 45.0 -1 ##$$&('%,# 0 12 1 7 7 UIParent 0.0 45.0 -1 ##$$&('% 1 -1 0 0 0 UIParent 932.6 -809.2 -1 #$$#%# 2 -1 1 2 2 UIParent 0.0 0.0 -1 ##$#%(&( 3 0 0 1 1 UIParent -248.0 -726.8 -1 $#3# 3 1 0 1 1 UIParent 248.0 -726.8 -1 %#3# 3 2 0 1 4 UIParent 478.0 14.0 -1 %#&$3# 3 3 0 0 0 UIParent 568.3 -302.0 -1 '$(#)#-].;/#1#3#5#627U8(92 3 4 0 0 0 UIParent 225.3 -468.8 -1 ,#-;.-/#0#1#2(3#5%6(7-7$8(9( 3 5 1 5 5 UIParent 0.0 0.0 -1 &#*$3# 3 6 1 5 5 UIParent 0.0 0.0 -1 -#.#/#4$5#6(7-7$8(9( 3 7 1 4 4 UIParent 0.0 0.0 -1 3# 4 -1 0 1 1 UIParent 552.6 -1000.6 -1 # 5 -1 0 4 4 UIParent 0.0 -360.4 -1 # 6 0 1 2 2 UIParent -255.0 -10.0 -1 ##$#%#&.(()( 6 1 0 1 7 BuffFrame 27.7 -4.0 -1 ##$#%#'+(()(-$ 6 2 0 0 0 UIParent 616.0 -614.0 -1 ##$#%$&.(*)(+#,-,$ 7 -1 0 4 4 UIParent -734.3 500.0 -1 # 8 -1 0 6 6 UIParent 34.0 206.4 -1 #'$u%$&q 9 -1 1 7 7 UIParent 0.0 45.0 -1 # 10 -1 1 0 0 UIParent 16.0 -116.0 -1 # 11 -1 1 8 8 UIParent -9.0 85.0 -1 # 12 -1 0 1 7 MinimapCluster -125.8 -4.0 -1 #/$#%# 13 -1 1 8 8 MicroButtonAndBagsBar 0.0 0.0 -1 ##$#%)&- 14 -1 1 2 2 MicroButtonAndBagsBar 0.0 10.0 -1 ##$#%( 15 0 1 7 7 StatusTrackingBarManager 0.0 0.0 -1 &- 15 1 1 7 7 StatusTrackingBarManager 0.0 17.0 -1 &- 16 -1 1 5 5 UIParent 0.0 0.0 -1 #( 17 -1 1 1 1 UIParent 0.0 -100.0 -1 ## 18 -1 0 2 8 MinimapCluster 0.0 -4.0 -1 #- 19 -1 1 7 7 UIParent 0.0 0.0 -1 ## 20 0 0 7 7 UIParent 0.0 292.8 -1 ##$.%#&('%(-($)#+$,$-# 20 1 0 4 4 UIParent -150.0 -18.4 -1 #$$.%$&/'%(-($)#+$,$-# 20 2 0 1 1 UIParent -150.0 -442.8 -1 #$$$%#&+'%(-($)#+$,$-$ 20 3 0 8 8 UIParent -163.4 230.4 -1 #$$$%#&('((-($)#*$+$,$-$.-.$ 21 -1 0 7 7 UIParent 0.0 392.0 -1 #$%#&#'((()#*-*$+#,&-#.#/(0#1# 22 0 0 4 4 UIParent 0.0 -166.9 -1 ##$$%#&/''(#)U*$+$,$-#.#/U0% 22 1 0 7 1 MediumEncounterWarnings -7.7 4.0 -1 &('()U*#+$ 22 2 0 7 7 UIParent 0.0 972.8 -1 &('()U*#+$ 22 3 0 1 1 UIParent 0.0 -212.8 -1 &('()U*#+$ 23 -1 0 7 7 UIParent -887.3 2.0 -1 ##$$%$&8'Y(#)U+$,$-1.(/# 24 -1 1 1 1 UIParent 0.0 -182.0 -1 # 26 -1 1 4 4 UIParent 0.0 0.0 -1 #("
