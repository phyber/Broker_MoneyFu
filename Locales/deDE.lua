-- Deutsche/German
--				      lower		 upper
-- a umlaut	  \195\164	 \195\132
-- o umlaut	  \195\182	 \195\150
-- u umlaut	  \195\188	 \195\156
-- sharp s	  \195\159
-- ä = \195\164 -- Ä = \195\132
-- ö = \195\182 -- Ö = \195\150
-- ü = \195\188 -- Ü = \195\156
-- ß = \195\159

local L = LibStub("AceLocale-3.0"):NewLocale("Broker_MoneyFu", "deDE")
if not L then return end
--
L["Total"] = "Gesamt"
L["Session reset"] = "Sitzung zur\195\188cksetzen"
L["This session"] = "Diese Sitzung"
L["Per hour"] = "Pro Stunde"
L["This Week"] = "Diese Woche"
-- Yellow texts
L["|cffffff00Gained|r"] = "Eingenommen"
L["|cffffff00Spent|r"] = "Ausgegeben"
L["|cffffff00Profit|r"] = "Gewinn"
L["|cffffff00Loss|r"] = "Verlust"

L["Amount"] = "Geldmenge"
L["Reset Session"] = "Sitzung zur\195\188cksetzen"
L["Character Specific Cashflow"] = "Charakterspezifischen Geldfluss anzeigen"
L["Show character-specific cashflow"] = "Zeige Charakterspezifischen Geldfluss"
L["Purge"] = "L\195\182schen"
L["Purge Character"] = "Charakter L\195\182schen"
L["Select a character to purge"] = "W\195\164hle einen Charakter zum L\195\182schen"
L["Style"] = "Stil"
L["Choose your style"] = "W\195\164hle deinen Stil"
L["Graphical"] = "Anzeige mit M\195\188nzsymbolen"
L["Full"] = "Ausf\195\188hrlicher Stil"
L["Short"] = "Kurzstil"
L["Condensed"] = "Komprimierter Stil"
L["Simplified Tooltip"] = "Vereinfachter Tooltip"
L["Per Hour Cashflow"] = "Einnahme pro Stunde anzeigen"
L["Show per hour cashflow"] = "Zeige Einnahme pro Stunde"
L["Colour character names by class"] = "F\195\164rbe Charakter Namen nach Klasse"
L["Colour character names in tooltip by class"] = "F\195\164rbe Charakter Namen im Tooltip nach Klasse"

L["Minimap Icon"] = "Minikarte Symbol"
L["Toggle minimap icon"] = "Minikarte Symbol An/Aus"

L["Session reset"] = "Sitzung zur\195\188ckgesetzt."
L["Characters"] = "Charaktere"

-- Green text
L["|cff00ff00Click to pick up money|r"] = "Anklicken, um Geld aufzunehmen."
