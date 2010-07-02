local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local LQT = LibStub("LibQTip-1.0")
local abacus = LibStub("LibAbacus-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Broker_MoneyFu")
local dataobj = LDB:NewDataObject("Broker_MoneyFu", {
	type = "data source",
	text = "???",
	icon = "Interface\\AddOns\\Broker_MoneyFu\\icon.tga",
})
local icon = LibStub("LibDBIcon-1.0")
local YELLOW = { r = 1, g = 1, b = 0 }
local GREEN = { r = 0, g = 1, b = 0 }
-- Lovely functions
local math = math
local next = next
local pairs = pairs
local table = table
local string = string
local tonumber = tonumber
local GetAddOnMetadata = GetAddOnMetadata

Broker_MoneyFu = LibStub("AceAddon-3.0"):NewAddon("Broker_MoneyFu", "AceEvent-3.0", "AceHook-3.0")
local self, Broker_MoneyFu = Broker_MoneyFu, Broker_MoneyFu
local db
local tooltip
local defaults = {
	profile = {
		style = "GRAPHICAL",
		trackByRealm = true,
		simpleTooltip = false,
		showPerHour = true,
		minimap = {
			hide = false,
		},
	},
	char = {
		spent = {},
		gained = {},
		time = {},
	},
	realm = {
		chars = {},
		spent = {},
		gained = {},
		time = {},
	},
}

local function GetOptions(uiTypes, uiName, appName)
	if appName == "Broker_MoneyFu-General" then
		local options = {
			type = "group",
			name = GetAddOnMetadata("Broker_MoneyFu", "Title"),
			get = function(info) return db[info[#info]] end,
			set = function(info, value)
				db[info[#info]] = value
				Broker_MoneyFu:UpdateData()
			end,
			args = {
				bmfudesc = {
					type = "description",
					order = 0,
					name = GetAddOnMetadata("Broker_MoneyFu", "Notes"),
				},
				-- Character specific cashflow
				trackByRealm = {
					name = L["Character Specific Cashflow"],
					desc = L["Show character-specific cashflow"],
					type = "toggle",
					order = 100,
					get = function(info)
						return not db[info[#info]]
					end,
				},
				showPerHour = {
					name = L["Per Hour Cashflow"],
					desc = L["Show per hour cashflow"],
					type = "toggle",
					order = 200,
				},
				simpleTooltip = {
					name = L["Simplified Tooltip"],
					desc = L["Simplified Tooltip"],
					type = "toggle",
					order = 300,
				},
				style = {
					name = L["Style"],
					desc = L["Choose your style"],
					type = "select",
					order = 400,
					values = {
						GRAPHICAL = L["Graphical"],
						FULL = L["Full"],
						SHORT = L["Short"],
						CONDENSED = L["Condensed"],
					},
					style = "dropdown",
				},
				minimap = {
					name = L["Minimap Icon"],
					desc = L["Toggle minimap icon"],
					type = "toggle",
					get = function() return not db.minimap.hide end,
					set = function()
						db.minimap.hide = not db.minimap.hide
						if db.minimap.hide then
							icon:Hide("Broker_MoneyFu")
						else
							icon:Show("Broker_MoneyFu")
						end
					end,
				},
			}
		}
		return options
	end
	if appName == "Broker_MoneyFu-Purge" then
		-- Base menu
		local options = {
			type = "group",
			name = L["Purge"],
			args = {
				bmfupdesc = {
					type = "description",
					order = 0,
					name = L["Purge Character"],
				},
				purge = {
					name = L["Characters"],
					desc = L["Select a character to purge"],
					type = "select",
					order = 100,
					values = Broker_MoneyFu.db.realm.chars,
					style = "dropdown",
				},
			}
		}
		-- Fill with characters
		--[[for name, _ in pairs(self.db.realm.chars) do
			if name ~= UnitName("player") then
				options.args.purge.values[name] = name
			end
		end]]
		return options
	end
end

local function CoinString(_, value)
	return GetCoinTextureString(value)
end

local function getAbacus()
	local func
	if db.style == "GRAPHICAL" then
		func = CoinString
	elseif db.style == "CONDENSED" then
		func = abacus.FormatMoneyCondensed
	elseif db.style == "SHORT" then
		func = abacus.FormatMoneyShort
	else
		func = abacus.FormatMoneyFull
	end
	return func
end

local function ColourText(text, c)
	return string.format("|cff%2x%2x%2x%s|r", c.r * 255, c.g * 255, c.b * 255, text)
end

function Broker_MoneyFu:ResetSession()
	self.initialMoney = GetMoney()
	self.sessionTime = time()
	self.gained = 0
	self.spent = 0
end

function Broker_MoneyFu:HideTooltip()
	if MouseIsOver(tooltip) then
		return
	end
	tooltip:Hide()
end

function Broker_MoneyFu:DrawTooltip()
	tooltip:Hide()
	tooltip:Clear()

	local now = time()
	local today = self.lastTime
	self.db.char.time[today] = self.db.char.time[today] + now - self.savedTime
	self.db.realm.time[today] = self.db.realm.time[today] + now - self.savedTime
	self.savedTime = now

	local linenum
	local func = getAbacus()
	local NFC = NORMAL_FONT_COLOR

	-- Header
	tooltip:AddLine(ColourText(GetAddOnMetadata("Broker_MoneyFu", "Title"), NFC))
	tooltip:AddLine(" ")

	-- Gold earned stats.
	if not self.db.profile.simpleTooltip then
		-- This session
		tooltip:AddLine(L["This session"], L["Amount"], L["Per hour"])
		tooltip:AddLine(
			L["|cffffff00Gained|r"],
			func(abacus, self.gained, true),
			func(abacus, self.gained / (now - self.sessionTime) * 3600, true)
		)
		tooltip:AddLine(
			L["|cffffff00Spent|r"],
			func(abacus, self.spent, true),
			func(abacus, self.spent / (now - self.sessionTime) * 3600)
		)
		local profit = self.gained - self.spent
		tooltip:AddLine(
			L["|cffffff00Profit|r"],
			func(abacus, profit, true, true),
			func(abacus, profit / (now - self.sessionTime) * 3600, true, true)
		)
		
		-- Today
		local t
		if self.db.profile.trackByRealm then
			t = self.db.realm
		else
			t = self.db.char
		end
		local gained = t.gained
		local spent = t.spent
		local time = t.time

		tooltip:AddLine(" ")
		tooltip:AddLine(HONOR_THIS_SESSION, L["Amount"], L["Per hour"])
		tooltip:AddLine(
			L["|cffffff00Gained|r"],
			func(abacus, gained[self.lastTime], true),
			func(abacus, gained[self.lastTime] / time[self.lastTime] * 3600, true)
		)
		tooltip:AddLine(
			L["|cffffff00Spent|r"],
			func(abacus, spent[self.lastTime], true),
			func(abacus, spent[self.lastTime] / time[self.lastTime] * 3600, true)
		)
		local profit = gained[self.lastTime] - spent[self.lastTime]
		tooltip:AddLine(
			L["|cffffff00Profit|r"],
			func(abacus, profit, true, true),
			func(abacus, profit / time[self.lastTime] * 3600, true, true)
		)

		-- Yesterday
		tooltip:AddLine(" ")
		tooltip:AddLine(HONOR_YESTERDAY, L["Amount"], L["Per hour"])
		tooltip:AddLine(
			L["|cffffff00Gained|r"],
			func(abacus, gained[self.lastTime - 1], true),
			func(abacus, gained[self.lastTime - 1] / time[self.lastTime - 1] * 3600, true)
		)
		tooltip:AddLine(
			L["|cffffff00Spent|r"],
			func(abacus, spent[self.lastTime - 1], true),
			func(abacus, spent[self.lastTime - 1] / time[self.lastTime - 1] * 3600, true)
		)
		local profit = gained[self.lastTime - 1] - spent[self.lastTime - 1]
		tooltip:AddLine(
			L["|cffffff00Profit|r"],
			func(abacus, profit, true, true),
			func(abacus, profit / time[self.lastTime - 1] * 3600, true, true)
		)

		-- This week
		local weekGained = 0
		local weekSpent = 0
		local weekTime = 0
		for i = self.lastTime - 6, self.lastTime do
			weekGained = weekGained + gained[i]
			weekSpent = weekSpent + spent[i]
			weekTime = weekTime + time[i]
		end
		tooltip:AddLine(" ")
		tooltip:AddLine(L["This Week"], L["Amount"], L["Per hour"])
		tooltip:AddLine(
			L["|cffffff00Gained|r"],
			func(abacus, weekSpent, true),
			func(abacus, weekSpent / weekTime * 3600, true)
		)
		tooltip:AddLine(
			L["|cffffff00Spent|r"],
			func(abacus, weekSpent, true),
			func(abacus, weekSpent / weekTime * 3600, true)
		)
		local profit = weekGained - weekSpent
		tooltip:AddLine(
			L["|cffffff00Profit|r"],
			func(abacus, profit, true, true),
			func(abacus, profit / weekTime * 3600, true, true)
		)
	end

	-- Character gold totals.
	local total = 0
	if next(self.db.realm.chars) ~= UnitName("player") or next(self.db.realm.chars, UnitName("player")) then
		local t = {}
		for name, _ in pairs(self.db.realm.chars) do
			t[#t + 1] = name
		end
		if not self.sort_func then
			self.sort_func = function(a, b)
				return self.db.realm.chars[a] < self.db.realm.chars[b]
			end
		end
		table.sort(t, self.sort_func)

		tooltip:AddLine(" ")
		tooltip:AddLine(
			L["Characters"],
			db.showPerHour and " " or L["Amount"],
			db.showPerHour and L["Amount"] or " "
		)
		for _, name in pairs(t) do
			local money = self.db.realm.chars[name]
			local moneystr = func(abacus, money, true)
			tooltip:AddLine(
				string.format("|cffffff00%s|r", name),
				db.showPerHour and " " or moneystr,
				db.showPerHour and moneystr or " "
			)
			total = total + money
		end
		t = nil
	else
		total = self.db.realm.chars[UnitName("player")]
	end

	-- Total
	tooltip:AddLine(" ")
	tooltip:AddLine(
		L["Total"],
		db.showPerHour and " " or func(abacus, total, true),
		db.showPerHour and func(abacus, total, true) or " "
	)

	-- Hints
	--tooltip:SetColumnLayout(2, "LEFT", "LEFT")
	--tooltip:AddLine(" ")
	--tooltip:AddLine(ColourText(L["Hint: Click to pick up money"], GREEN))

	-- Show it
	--local p, rT, rP, x, y = tooltip:GetPoint()
	--tooltip:ClearAllPoints()
	--tooltip:SetPoint(p, rT, rP, -(tooltip:GetWidth() / 2), y)
	tooltip:Show()
end

function dataobj:OnEnter()
	-- Setup the tooltip
	if not LQT:IsAcquired("Broker_MoneyFu") then
		local perHour = db.showPerHour
		tooltip = LQT:Acquire("Broker_MoneyFuTip",
			perHour and 3 or 2,
			"LEFT",
			perHour and "CENTER" or "RIGHT",
			perHour and "RIGHT" or nil
		)
	end
	tooltip:Clear()
	tooltip:SmartAnchorTo(self)
	tooltip:SetAutoHideDelay(0.25, self)
	tooltip:SetScale(1)

	Broker_MoneyFu:DrawTooltip()
end

local function getsecond(_, value)
	return value
end

function dataobj:OnClick(button)
	if button == "LeftButton" then
		local money = GetMoney()
		local multiplier
		if money < 100 then
			multiplier = 1
		elseif money < 10000 then
			multiplier = 100
		else
			multiplier = 10000
		end
		self.moneyType = "PLAYER"
		OpenCoinPickupFrame(multiplier, money, self)
		self.hasPickup = 1

		CoinPickupFrame:ClearAllPoints()
		if self:GetCenter() < GetScreenWidth() / 2 then
			if getsecond(self:GetCenter()) < GetScreenHeight() / 2 then
				CoinPickupFrame:SetPoint("BOTTOMLEFT", self, "TOPLEFT")
			else
				CoinPickupFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
			end
		else
			if getsecond(self:GetCenter()) < GetScreenHeight() / 2 then
				CoinPickupFrame:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT")
			else
				CoinPickupFrame:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT")
			end
		end
		Broker_MoneyFu:HideTooltip()
	elseif button == "RightButton" then
		InterfaceOptionsFrame_OpenToCategory(GetAddOnMetadata("Broker_MoneyFu", "Title"))
	end
end

function Broker_MoneyFu:OnInitialize()
	-- Set up the DB
	self.db = LibStub("AceDB-3.0"):New("Broker_MoneyFuDB", defaults, true)
	db = self.db.profile

	-- Minimap icon
	icon:Register("Broker_MoneyFu", dataobj, db.minimap)
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Broker_MoneyFu-General", GetOptions)
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Broker_MoneyFu-Purge", GetOptions)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Broker_MoneyFu-General", GetAddOnMetadata("Broker_MoneyFu", "Title"))
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Broker_MoneyFu-Purge", "Purge", GetAddOnMetadata("Broker_MoneyFu", "Title"))
end

local function GetToday(self)
	return math.floor((time() / 60 / 60 + self:GetServerOffset()) / 24)
end

function Broker_MoneyFu:OnEnable()
	self.initialMoney = GetMoney()
	self.lastMoney = self.initialMoney
	self.lastTime = GetToday(self)
	local lastWeek = self.lastTime - 6
	for day in pairs(self.db.char.gained) do
		if day < lastWeek then
			self.db.char.gained[day] = nil
		end
	end
	for day in pairs(self.db.char.spent) do
		if day < lastWeek then
			self.db.char.spent[day] = nil
		end
	end
	for day in pairs(self.db.char.time) do
		if day < lastWeek then
			self.db.char.time[day] = nil
		end
	end
	for day in pairs(self.db.realm.gained) do
		if day < lastWeek then
			self.db.realm.gained[day] = nil
		end
	end
	for day in pairs(self.db.realm.spent) do
		if day < lastWeek then
			self.db.realm.spent[day] = nil
		end
	end
	for day in pairs(self.db.realm.time) do
		if day < lastWeek then
			self.db.realm.time[day] = nil
		end
	end
	for i = self.lastTime - 6, self.lastTime do
		if not self.db.char.gained[i] then
			self.db.char.gained[i] = 0
		end
		if not self.db.char.spent[i] then
			self.db.char.spent[i] = 0
		end
		if not self.db.char.time[i] then
			self.db.char.time[i] = 0
		end
		if not self.db.realm.gained[i] then
			self.db.realm.gained[i] = 0
		end
		if not self.db.realm.spent[i] then
			self.db.realm.spent[i] = 0
		end
		if not self.db.realm.time[i] then
			self.db.realm.time[i] = 0
		end
	end
	self.gained = 0
	self.spent = 0
	self.sessionTime = time()
	self.savedTime = time()

	self:RegisterEvent("PLAYER_MONEY", "UpdateData")
	self:RegisterEvent("PLAYER_TRADE_MONEY", "UpdateData")
	self:RegisterEvent("TRADE_MONEY_CHANGED", "UpdateData")
	self:RegisterEvent("SEND_MAIL_MONEY_CHANGED", "UpdateData")
	self:RegisterEvent("SEND_MAIL_COD_CHANGED", "UpdateData")

	self:RawHook("OpenCoinPickupFrame", true)

	--self:ScheduleRepeatingEvent("MoneyFuUpdater", self.UpdateTooltip, 60, self)
	self:UpdateData()
	dataobj.text = getAbacus()(abacus, self.initialMoney, true)
end

function Broker_MoneyFu:UpdateData()
	local today = GetToday(self)
	if not self.lastTime then
		self.lastTime = today
	end
	if today > self.lastTime then
		self.db.char.gained[today - 7] = nil
		self.db.char.spent[today - 7] = nil
		self.db.char.time[today - 7] = nil
		self.db.realm.gained[today - 7] = nil
		self.db.realm.spent[today - 7] = nil
		self.db.realm.time[today - 7] = nil
		self.db.char.gained[today] = self.db.char.gained[today] or 0
		self.db.char.spent[today] = self.db.char.spent[today] or 0
		self.db.char.time[today] = self.db.char.time[today] or 0
		self.db.realm.gained[today] = self.db.realm.gained[today] or 0
		self.db.realm.spent[today] = self.db.realm.spent[today] or 0
		self.db.realm.time[today] = self.db.realm.time[today] or 0
		self.lastTime = today
	end
	local current = GetMoney()
	if not self.lastMoney then
		self.lastMoney = current
	end
	if self.lastMoney < current then
		self.gained = (self.gained or 0) + current - self.lastMoney
		self.db.char.gained[today] = (self.db.char.gained[today] or 0) + current - self.lastMoney
		self.db.realm.gained[today] = (self.db.realm.gained[today] or 0) + current - self.lastMoney
	elseif self.lastMoney > current then
		self.spent = (self.spent or 0) + self.lastMoney - current
		self.db.char.spent[today] = (self.db.char.spent[today] or 0) + self.lastMoney - current
		self.db.realm.spent[today] = (self.db.realm.spent[today] or 0) + self.lastMoney - current
	end
	self.lastMoney = current
	self.db.realm.chars[UnitName("player")] = current
	local now = time()
	if not self.savedTime then
		self.savedTime = now
	end
	self.db.char.time[today] = self.db.char.time[today] + now - self.savedTime
	self.db.realm.time[today] = self.db.realm.time[today] + now - self.savedTime
	self.savedTime = now

	-- Display cashola on tooltip
	dataobj.text = getAbacus()(abacus, current, true)
end

function Broker_MoneyFu:OpenCoinPickupFrame(multiplier, maxMoney, parent)
	CoinPickupFrame:ClearAllPoints()
	self.hooks.OpenCoinPickupFrame(multiplier, maxMoney, parent)
end

local offset
function Broker_MoneyFu:GetServerOffset()
	if offset then
		return offset
	end
	local serverHour, serverMinute = GetGameTime()
	local utcHour = tonumber(date("!%H"))
	local utcMinute = tonumber(date("!%M"))
	local ser = serverHour + serverMinute / 60
	local utc = utcHour + utcMinute / 60
	offset = floor((ser - utc) * 2 + 0.5) / 2
	if offset >= 12 then
		offset = offset - 24
	elseif offset < -12 then
		offset = offset + 24
	end
	return offset
end
