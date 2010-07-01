local L = LibStub("AceLocale-3.0"):NewLocale("Broker_MoneyFu", "enUS", true)
if not L then return end
--
L["NAME"] = "FuBar - MoneyFu"
L["DESCRIPTION"] = "Keeps track of current money and all your characters on one realm."
L["COMMANDS"] = {"/monfu", "/moneyfu"}
L["TEXT_TOTAL"] = "Total"
L["TEXT_SESSION_RESET"] = "Session reset"
L["TEXT_THIS_SESSION"] = "This session"
L["TEXT_GAINED"] = "Gained"
L["TEXT_SPENT"] = "Spent"
L["TEXT_AMOUNT"] = "Amount"
L["TEXT_PER_HOUR"] = "Per hour"
L["This Week"] = true

L["ARGUMENT_RESETSESSION"] = "resetSession"

L["MENU_RESET_SESSION"] = "Reset Session"
L["MENU_CHARACTER_SPECIFIC_CASHFLOW"] = "Show character-specific cashflow"
L["MENU_PURGE"] = "Purge"
L["MENU_SHOW_GRAPHICAL"] = "Show with coins"
L["MENU_SHOW_FULL"] = "Show full style"
L["MENU_SHOW_SHORT"] = "Show short style"
L["MENU_SHOW_CONDENSED"] = "Show condensed style"
L["SIMPLIFIED_TOOLTIP"] = "Simplified Tooltip"
L["SHOW_PER_HOUR_CASHFLOW"] = "Show per hour cashflow"

L["TEXT_SESSION_RESET"] = "Session reset."
L["TEXT_CHARACTERS"] = "Characters"
L["TEXT_PROFIT"] = "Profit"
L["TEXT_LOSS"] = "Loss"

L["HINT"] = "Click to pick up money"
