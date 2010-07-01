local L = LibStub("AceLocale-3.0"):NewLocale("Broker_MoneyFu", "ruRU")
if not L then return end
--
L["NAME"] = "FuBar - MoneyFu"
L["DESCRIPTION"] = "Отслеживает количество денег у всех ваших персонажей на сервере."
L["COMMANDS"] = {"/monfu", "/moneyfu"}
L["TEXT_TOTAL"] = "Всего"
L["TEXT_SESSION_RESET"] = "Сброс сессии"
L["TEXT_THIS_SESSION"] = "Эта сессия"
L["TEXT_GAINED"] = "Получено"
L["TEXT_SPENT"] = "Потрачено"
L["TEXT_AMOUNT"] = "Колиичество"
L["TEXT_PER_HOUR"] = "В час"
L["This Week"] = "Эта неделя"

L["ARGUMENT_RESETSESSION"] = "сброс сесии"

L["MENU_RESET_SESSION"] = "Сброс сессии"
L["MENU_CHARACTER_SPECIFIC_CASHFLOW"] = "Показывать статистику по каждому персонажу"
L["MENU_PURGE"] = "Очистить"
L["MENU_SHOW_GRAPHICAL"] = "Показывать с монетами"
L["MENU_SHOW_FULL"] = "Полный стиль"
L["MENU_SHOW_SHORT"] = "Короткий стиль"
L["MENU_SHOW_CONDENSED"] = "Уплотнённый стиль"
L["SIMPLIFIED_TOOLTIP"] = "Упрощённое всплывающее окошко"
L["SHOW_PER_HOUR_CASHFLOW"] = "Поток денег в час"

L["TEXT_SESSION_RESET"] = "Сессия сброшена."
L["TEXT_CHARACTERS"] = "Персонажи"
L["TEXT_PROFIT"] = "Прибыль"
L["TEXT_LOSS"] = "Потеря"

L["HINT"] = "Click to pick up money"
