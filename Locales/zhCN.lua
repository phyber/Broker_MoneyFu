local L = LibStub("AceLocale-3.0"):NewLocale("Broker_MoneyFu", "zhCN")
if not L then return end
--
L["NAME"] = "FuBar - MoneyFu"
L["DESCRIPTION"] = "记录你所在服务器上所有角色的金钱状况."
L["COMMANDS"] = {"/monfu", "/moneyfu"}
L["TEXT_TOTAL"] = "总计"
L["TEXT_SESSION_RESET"] = "重置本次连接统计"
L["TEXT_THIS_SESSION"] = "本次连接"
L["TEXT_GAINED"] = "盈利"
L["TEXT_SPENT"] = "消费"
L["TEXT_AMOUNT"] = "总计"
L["TEXT_PER_HOUR"] = "每小时"
L["This Week"] = "本周"

L["ARGUMENT_RESETSESSION"] = "resetSession"

L["MENU_RESET_SESSION"] = "重置本次连接统计"
L["MENU_CHARACTER_SPECIFIC_CASHFLOW"] = "只显示本角色金钱状况"
L["MENU_PURGE"] = "清空"
L["MENU_SHOW_GRAPHICAL"] = "硬币图标显示"
L["MENU_SHOW_FULL"] = "完全样式显示"
L["MENU_SHOW_SHORT"] = "简洁样式显示"
L["MENU_SHOW_CONDENSED"] = "紧缩样式显示"
L["SIMPLIFIED_TOOLTIP"] = "简单提示"
L["SHOW_PER_HOUR_CASHFLOW"] = "显示每小时金钱状况"

L["TEXT_SESSION_RESET"] = "重置本次连接统计."
L["TEXT_CHARACTERS"] = "角色"
L["TEXT_PROFIT"] = "盈利"
L["TEXT_LOSS"] = "消费"

L["HINT"] = "点击提取金钱"
