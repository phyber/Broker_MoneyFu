local L = LibStub("AceLocale-3.0"):NewLocale("Broker_MoneyFu", "zhTW")
if not L then return end
--
L["NAME"] = "FuBar - MoneyFu"
L["DESCRIPTION"] = "持續追縱目前的金錢狀況(目前角色及同伺服器其他角色)。"
L["COMMANDS"] = {"/monfu", "/moneyfu"}
L["TEXT_TOTAL"] = "總計"
L["TEXT_SESSION_RESET"] = "重置這個階段的統計"
L["TEXT_THIS_SESSION"] = "目前階段"
L["TEXT_GAINED"] = "收入"
L["TEXT_SPENT"] = "支出"
L["TEXT_AMOUNT"] = "總計"
L["TEXT_PER_HOUR"] = "每小時"
L["This Week"] = "本週", -- edit

L["ARGUMENT_RESETSESSION"] = "resetSession"

L["MENU_RESET_SESSION"] = "重置這個階段的統計"
L["MENU_CHARACTER_SPECIFIC_CASHFLOW"] = "只顯示目前角色的金錢狀態"
L["MENU_PURGE"] = "清除"
L["MENU_SHOW_GRAPHICAL"] = "以錢幣圖示形式顯示"
L["MENU_SHOW_FULL"] = "完整顯示"
L["MENU_SHOW_SHORT"] = "簡短顯示"
L["MENU_SHOW_CONDENSED"] = "緊縮顯示"
L["SIMPLIFIED_TOOLTIP"] = "精簡提示"
L["SHOW_PER_HOUR_CASHFLOW"] = "顯示每小時金錢使用狀況"

L["TEXT_SESSION_RESET"] = "重置這個階段的統計。"
L["TEXT_CHARACTERS"] = "角色"
L["TEXT_PROFIT"] = "盈利"
L["TEXT_LOSS"] = "虧損"

L["HINT"] = "點擊拾取金錢"
