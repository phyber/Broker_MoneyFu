local L = LibStub("AceLocale-3.0"):NewLocale("Broker_MoneyFu", "koKR")
if not L then return end
--
L["NAME"] = "FuBar - MoneyFu"
L["DESCRIPTION"] = "현재 소지금과 서버의 모든 캐릭터의 소지금을 표시합니다."
L["COMMANDS"] = {"/monfu", "/moneyfu"}
L["TEXT_TOTAL"] = "총"
L["TEXT_SESSION_RESET"] = "세션 초기화"
L["TEXT_THIS_SESSION"] = "이번 세션"
L["TEXT_GAINED"] = "획득량"
L["TEXT_SPENT"] = "소모량"
L["TEXT_AMOUNT"] = "금액"
L["TEXT_PER_HOUR"] = "시간당"
L["This Week"] = "이번 주"

L["ARGUMENT_RESETSESSION"] = "접속초기화"

L["MENU_RESET_SESSION"] = "세션 초기화"
L["MENU_CHARACTER_SPECIFIC_CASHFLOW"] = "캐릭터별 자산 이동 표시"
L["MENU_PURGE"] = "통합"
L["MENU_SHOW_GRAPHICAL"] = "동전 표시"
L["MENU_SHOW_FULL"] = "길게 보기"
L["MENU_SHOW_SHORT"] = "짧게 보기"
L["MENU_SHOW_CONDENSED"] = "생략해서 보기"
L["SIMPLIFIED_TOOLTIP"] = "간단한 툴팁"
L["SHOW_PER_HOUR_CASHFLOW"] = "시간당 유동량 표시"

L["TEXT_SESSION_RESET"] = "세션 초기화"
L["TEXT_CHARACTERS"] = "케릭터"
L["TEXT_PROFIT"] = "이득"
L["TEXT_LOSS"] = "손실"
L["HINT"] = "클릭하면 금전을 집습니다"
