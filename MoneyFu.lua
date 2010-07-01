local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local LQT = LibStub("LibQTip-1.0")
local abacus = LibStub("LibAbacus-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Broker_MoneyFu")
local dataobj = LDB:NewDataObject("Broker_MoneyFu", {
	type = "data source",
	text = "???",
	icon = "Interface\\Broker_MoneyFu\\icon.tga",
})

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
					desc = L["Character Specific Cashflow"],
					type = "toggle",
					order = 100,
				},
				showPerHour = {
					name = L["Per Hour Cashflow"],
					desc = L["Per Hour Cashflow"],
					type = "toggle",
					order = 200,
				},
				simpleTooltip = {
					name = L["Simple Tooltip"],
					desc = L["Simple Tooltip"],
					type = "toggle",
					order = 300,
				},
				style = {
					name = L["Style"],
					desc = L["Style"],
					type = "select",
					order = 400,
					values = {
						GRAPHICAL = "Graphical",
						FULL = "Full",
						SHORT = "Short",
						CONDENSED = "Condensed",
					},
					style = "dropdown",
				},
			}
		}
		return options
	end
	if appName == "Broker_MoneyFu-Purge" then
		-- Base menu
		local options = {
			type = "group",
			name = "Purge",
			args = {
				bmfupdesc = {
					type = "description",
					order = 0,
					name = "Purge Character",
				},
				purge = {
					name = "Characters",
					desc = "Select a character to purge",
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

local function getAbacus()
	local func
	if db.style == "CONDENSED" then
		func = abacus.FormatMoneyCondensed
	elseif db.style == "SHORT" then
		func = abacus.FormatMoneyShort
	else
		func = abacus.FormatMoneyFull
	end
	return func
end

function Broker_MoneyFu:ResetSession()
	self.initialMoney = GetMoney()
	self.sessionTime = time()
	self.gained = 0
	self.spent = 0
end

function Broker_MoneyFu:HideTooltip()
	if MouseIfOver(tooltip) then
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

	-- Header
	tooltip:AddLine(GetAddOnMetadata("Broker_MoneyFu", "Title"))
	tooltip:AddLine()

	-- Gold earned stats.
	if not self.db.profile.simpleTooltip then
		-- This session
		tooltip:AddLine("This session", "Amount", "Per hour")
		tooltip:AddLine(
			"Gained",
			func(abacus, self.gained, true),
			func(abacus, self.gained / (now - self.sessionTime) * 3600, true)
		)
		tooltip:AddLine(
			"Spent",
			func(abacus, self.spent, true),
			func(abacus, self.spent / (now - self.sessionTime) * 3600)
		)
		local profit = self.gained - self.spent
		tooltip:AddLine(
			"Profit",
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

		-- Yesterday

		-- This week
	end

	-- Character gold totals.
	
	-- Hints

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

function Broker_MoneyFu:OnInitialize()
	-- Set up the DB
	self.db = LibStub("AceDB-3.0"):New("Broker_MoneyFu", defaults, true)
	db = self.db.profile

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Broker_MoneyFu-General", GetOptions)
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Broker_MoneyFu-Purge", GetOptions)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Broker_MoneyFu-General", GetAddOnMetadata("Broker_MoneyFu", "Title"))
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Broker_MoneyFu-Purge", "Purge", GetAddOnMetadata("Broker_MoneyFu", "Title"))

	--self.hasIcon = true
	--self.canHideText = true
	--[[
	local frame = self.frame
	local icon = frame:CreateTexture("MoneyFuFrameIcon", "ARTWORK")
	icon:SetWidth(16)
	icon:SetHeight(16)
	icon:SetPoint("LEFT", frame, "LEFT")
	self.iconFrame = icon

	local text = frame:CreateFontString("MoneyFuFrameText", "OVERLAY")
	text:SetJustifyH("RIGHT")
	text:SetPoint("RIGHT", frame, "RIGHT", 0, 1)
	text:SetFontObject(GameFontNormal)
	self.textFrame = text

	self:SetIcon(true)

	local goldIcon = frame:CreateTexture("MoneyFuFrameGoldIcon", "ARTWORK")
	goldIcon:SetWidth(16)
	goldIcon:SetHeight(16)
	goldIcon:SetTexture("Interface\\MoneyFrame\\UI-MoneyIcons")
	goldIcon:SetTexCoord(0, 0.25, 0, 1)

	local silverIcon = frame:CreateTexture("MoneyFuFrameSilverIcon", "ARTWORK")
	silverIcon:SetWidth(16)
	silverIcon:SetHeight(16)
	silverIcon:SetTexture("Interface\\MoneyFrame\\UI-MoneyIcons")
	silverIcon:SetTexCoord(0.25, 0.5, 0, 1)

	local copperIcon = frame:CreateTexture("MoneyFuFrameCopperIcon", "ARTWORK")
	copperIcon:SetWidth(16)
	copperIcon:SetHeight(16)
	copperIcon:SetTexture("Interface\\MoneyFrame\\UI-MoneyIcons")
	copperIcon:SetTexCoord(0.5, 0.75, 0, 1)

	local goldText = frame:CreateFontString("MoneyFuFrameGoldText", "OVERLAY")
	goldText:SetJustifyH("RIGHT")
	goldText:SetPoint("RIGHT", goldIcon, "LEFT", 0, 1)
	goldText:SetFontObject(GameFontNormal)

	local silverText = frame:CreateFontString("MoneyFuFrameSilverText", "OVERLAY")
	silverText:SetJustifyH("RIGHT")
	silverText:SetPoint("RIGHT", silverIcon, "LEFT", 0, 1)
	silverText:SetFontObject(GameFontNormal)

	local copperText = frame:CreateFontString("MoneyFuFrameCopperText", "OVERLAY")
	copperText:SetJustifyH("RIGHT")
	copperText:SetPoint("RIGHT", copperIcon, "LEFT", 0, 1)
	copperText:SetFontObject(GameFontNormal)

	copperIcon:SetPoint("RIGHT", frame, "RIGHT")
	silverIcon:SetPoint("RIGHT", copperText, "LEFT")
	goldIcon:SetPoint("RIGHT", silverText, "LEFT")
	]]
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

	if self.db.profile.style == "GRAPHICAL" then
		--self:HideIcon()
		--self.iconFrame:Hide()
		self.hasIcon = false
	end
	self:RegisterEvent("PLAYER_MONEY", "UpdateData")
	self:RegisterEvent("PLAYER_TRADE_MONEY", "UpdateData")
	self:RegisterEvent("TRADE_MONEY_CHANGED", "UpdateData")
	self:RegisterEvent("SEND_MAIL_MONEY_CHANGED", "UpdateData")
	self:RegisterEvent("SEND_MAIL_COD_CHANGED", "UpdateData")

	self:Hook("OpenCoinPickupFrame", true)

	MoneyFuFrameGoldIcon:ClearAllPoints()
	MoneyFuFrameGoldIcon:SetPoint("RIGHT", MoneyFuFrameSilverText, "LEFT", 0, -1)
	MoneyFuFrameSilverIcon:ClearAllPoints()
	MoneyFuFrameSilverIcon:SetPoint("RIGHT", MoneyFuFrameCopperText, "LEFT", 0, -1)

	--self:ScheduleRepeatingEvent("MoneyFuUpdater", self.UpdateTooltip, 60, self)
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

function Broker_MoneyFu:UpdateText()
	if self.db.profile == nil then
		return
	end
	if self.db.profile.style == "GRAPHICAL" then
		if self:IsIconShown() then
			self.db.profile.iconVisible = true
			self:HideIcon()
		end
		self.hasIcon = false
		MoneyFuFrameIcon:Hide()
		MoneyFuFrameText:Hide()
		local copper = GetMoney()
		local gold = math.floor(copper / 10000)
		local silver = math.mod(math.floor(copper / 100), 100)
		copper = math.mod(copper, 100)
		local width = 0
		if gold == 0 then
			MoneyFuFrameGoldIcon:Hide()
			MoneyFuFrameGoldText:Hide()
		else
			MoneyFuFrameGoldIcon:Show()
			MoneyFuFrameGoldText:Show()
			MoneyFuFrameGoldText:SetWidth(0)
			MoneyFuFrameGoldText:SetText(gold)
			width = width + MoneyFuFrameGoldIcon:GetWidth() + MoneyFuFrameGoldText:GetWidth()
		end
		if gold == 0 and silver == 0 then
			MoneyFuFrameSilverIcon:Hide()
			MoneyFuFrameSilverText:Hide()
		else
			MoneyFuFrameSilverIcon:Show()
			MoneyFuFrameSilverText:Show()
			MoneyFuFrameSilverText:SetWidth(0)
			MoneyFuFrameSilverText:SetText(silver)
			width = width + MoneyFuFrameSilverIcon:GetWidth() + MoneyFuFrameSilverText:GetWidth()
		end
		MoneyFuFrameCopperIcon:Show()
		MoneyFuFrameCopperText:Show()
		MoneyFuFrameCopperText:SetWidth(0)
		MoneyFuFrameCopperText:SetText(copper)
		width = width + MoneyFuFrameCopperIcon:GetWidth() + MoneyFuFrameCopperText:GetWidth()
		self.frame:SetWidth(width)
	else
		if not self.hasIcon then
			self.hasIcon = true
			if self.db.profile.iconVisible then
				self:ShowIcon()
			end
		end
		self.db.profile.iconVisible = false
		MoneyFuFrameGoldIcon:Hide()
		MoneyFuFrameSilverIcon:Hide()
		MoneyFuFrameCopperIcon:Hide()
		MoneyFuFrameGoldText:Hide()
		MoneyFuFrameSilverText:Hide()
		MoneyFuFrameCopperText:Hide()
		MoneyFuFrameText:Show()
		if self.db.profile.style == "CONDENSED" then
			self:SetText(abacus:FormatMoneyCondensed(GetMoney(), true))
		elseif self.db.profile.style == "FULL" then
			self:SetText(abacus:FormatMoneyFull(GetMoney(), true))
		else
			self:SetText(abacus:FormatMoneyShort(GetMoney(), true))
		end
		self:CheckWidth(true)
	end
end

function Broker_MoneyFu:OnTooltipUpdate()
	local now = time()
	local today = self.lastTime
	self.db.char.time[today] = self.db.char.time[today] + now - self.savedTime
	self.db.realm.time[today] = self.db.realm.time[today] + now - self.savedTime
	self.savedTime = now
	local func
	if self.db.profile.style == "CONDENSED" then
		func = abacus.FormatMoneyCondensed
	elseif self.db.profile.style == "SHORT" then
		func = abacus.FormatMoneyShort
	else
		func = abacus.FormatMoneyFull
	end

	local numColumns
	if self.db.profile.showPerHour then
		numColumns = 3
	else
		numColumns = 2
	end

	local supercat = tablet:AddCategory(
		'columns', numColumns,
		'child_text2', L["TEXT_AMOUNT"],
		'child_text3', L["TEXT_PER_HOUR"],
		'child_child_textR', 1,
		'child_child_textG', 1,
		'child_child_textB', 0,
		'child_child_text2R', 1,
		'child_child_text2G', 1,
		'child_child_text2B', 1,
		'child_child_text3R', 1,
		'child_child_text3G', 1,
		'child_child_text3B', 1
	)

	------------
	if not self.db.profile.simpleTooltip then
		local cat = supercat:AddCategory(
			'text', L["TEXT_THIS_SESSION"]
		)

		cat:AddLine(
			'text', L["TEXT_GAINED"],
			'text2', func(abacus, self.gained, true),
			'text3', func(abacus, self.gained / (now - self.sessionTime) * 3600, true)
		)
		cat:AddLine(
			'text', L["TEXT_SPENT"],
			'text2', func(abacus, self.spent, true),
			'text3', func(abacus, self.spent / (now - self.sessionTime) * 3600, true)
		)
		local profit = self.gained - self.spent
		cat:AddLine(
			'text', profit >= 0 and L["TEXT_PROFIT"] or L["TEXT_LOSS"],
			'text2', func(abacus, profit, true, true),
			'text3', func(abacus, profit / (now - self.sessionTime) * 3600, true, true)
		)

		local t
		if self.db.profile.trackByRealm then
			t = self.db.realm
		else
			t = self.db.char
		end
		local gained = t.gained
		local spent = t.spent
		local time = t.time

		-- ------------
		-- Session totals
		-- ------------
		cat = supercat:AddCategory(
			'text', HONOR_THIS_SESSION
		)

		cat:AddLine(
			'text', L["TEXT_GAINED"],
			'text2', func(abacus, gained[self.lastTime], true),
			'text3', func(abacus, gained[self.lastTime] / time[self.lastTime] * 3600, true)
		)
		cat:AddLine(
			'text', L["TEXT_SPENT"],
			'text2', func(abacus, spent[self.lastTime], true),
			'text3', func(abacus, spent[self.lastTime] / time[self.lastTime] * 3600, true)
		)
		local profit = gained[self.lastTime] - spent[self.lastTime]
		cat:AddLine(
			'text', profit >= 0 and L["TEXT_PROFIT"] or L["TEXT_LOSS"],
			'text2', func(abacus, profit, true, true),
			'text3', func(abacus, profit / time[self.lastTime] * 3600, true, true)
		)

		-- -----------
		-- Yesterday totals
		-- -----------
		cat = supercat:AddCategory(
			'text', HONOR_YESTERDAY
		)

		cat:AddLine(
			'text', L["TEXT_GAINED"],
			'text2', func(abacus, gained[self.lastTime - 1], true),
			'text3', func(abacus, gained[self.lastTime - 1] / time[self.lastTime - 1] * 3600, true)
		)
		cat:AddLine(
			'text', L["TEXT_SPENT"],
			'text2', func(abacus, spent[self.lastTime - 1], true),
			'text3', func(abacus, spent[self.lastTime - 1] / time[self.lastTime - 1] * 3600, true)
		)
		local profit = gained[self.lastTime - 1] - spent[self.lastTime - 1]
		cat:AddLine(
			'text', profit >= 0 and L["TEXT_PROFIT"] or L["TEXT_LOSS"],
			'text2', func(abacus, profit, true, true),
			'text3', func(abacus, profit / time[self.lastTime - 1] * 3600, true, true)
		)

		-- -----------
		-- Week totals
		-- -----------
		local weekGained = 0
		local weekSpent = 0
		local weekTime = 0
		for i = self.lastTime - 6, self.lastTime do
			weekGained = weekGained + gained[i]
			weekSpent = weekSpent + spent[i]
			weekTime = weekTime + time[i]
		end
		cat = supercat:AddCategory(
--~ 			'text', HONOR_THISWEEK -- no longer supported?
			'text', L["This Week"]
		)

		cat:AddLine(
			'text', L["TEXT_GAINED"],
			'text2', func(abacus, weekGained, true),
			'text3', func(abacus, weekGained / weekTime * 3600, true)
		)
		cat:AddLine(
			'text', L["TEXT_SPENT"],
			'text2', func(abacus, weekSpent, true),
			'text3', func(abacus, weekSpent / weekTime * 3600, true)
		)
		local profit = weekGained - weekSpent
		cat:AddLine(
			'text', profit >= 0 and L["TEXT_PROFIT"] or L["TEXT_LOSS"],
			'text2', func(abacus, profit, true, true),
			'text3', func(abacus, profit / weekTime * 3600, true, true)
		)
	end
	-- -------------
	-- Character Totals, we always show this bit.
	-- -------------
	local total = 0
	local addedCat = false
	if next(self.db.realm.chars) ~= UnitName("player") or next(self.db.realm.chars, UnitName("player")) then
		local t = {}
		for name in pairs(self.db.realm.chars) do
			table.insert(t, name)
		end
		if not self.sort_func then
			self.sort_func = function(alpha, bravo)
				return self.db.realm.chars[alpha] < self.db.realm.chars[bravo]
			end
		end
		table.sort(t, self.sort_func)

		local cat = tablet:AddCategory(
			'columns', 2,
			'text', L["TEXT_CHARACTERS"],
			'text2', L["TEXT_AMOUNT"],
			'child_textR', 1,
			'child_textG', 1,
			'child_textB', 0,
			'child_text2R', 1,
			'child_text2G', 1,
			'child_text2B', 1
		)
		for _,name in pairs(t) do
			local value = self.db.realm.chars[name]
			cat:AddLine(
				'text', name,
				'text2', func(abacus, value, true)
			)
			total = total + value
		end
		t = nil
	else
		total = self.db.realm.chars[UnitName("player")]
	end

	local cat = tablet:AddCategory(
		'columns', 2,
		'child_textR', 1,
		'child_textG', 1,
		'child_textB', 1,
		'child_text2R', 1,
		'child_text2G', 1,
		'child_text2B', 1
	)

	cat:AddLine(
		'text', L["TEXT_TOTAL"],
		'text2', func(abacus, total, true)
	)

	tablet:SetHint(L["HINT"])

	--self:ScheduleRepeatingEvent("MoneyFuUpdater", self.UpdateTooltip, 60, self)
end

local function getsecond(_, value)
	return value
end

function Broker_MoneyFu:OnClick(button)
	local money = GetMoney()
	local multiplier
	if money < 100 then
		multiplier = 1
	elseif money < 10000 then
		multiplier = 100
	else
		multiplier = 10000
	end
	self.frame.moneyType = "PLAYER"
	OpenCoinPickupFrame(multiplier, money, self.frame)
	self.frame.hasPickup = 1

	CoinPickupFrame:ClearAllPoints()
	local frame = self.frame
	if self:IsMinimapAttached() then
		frame = self.minimapFrame
	end
	if frame:GetCenter() < GetScreenWidth()/2 then
		if getsecond(frame:GetCenter()) < GetScreenHeight()/2 then
			CoinPickupFrame:SetPoint("BOTTOMLEFT", frame, "TOPLEFT")
		else
			CoinPickupFrame:SetPoint("TOPLEFT", frame, "BOTTOMLEFT")
		end
	else
		if getsecond(frame:GetCenter()) < GetScreenHeight()/2 then
			CoinPickupFrame:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT")
		else
			CoinPickupFrame:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT")
		end
	end
end

function Broker_MoneyFu:OpenCoinPickupFrame(multiplier, maxMoney, parent)
	CoinPickupFrame:ClearAllPoints()
	self.hooks.OpenCoinPickupFrame(multiplier, maxMoney, parent)
end

function Broker_MoneyFu:SetFontSize(size)
	if MoneyFuFrameGoldIcon == nil then
		self.fontSize = size
		return
	end
	MoneyFuFrameGoldIcon:SetWidth(size)
	MoneyFuFrameGoldIcon:SetHeight(size)
	MoneyFuFrameSilverIcon:SetWidth(size)
	MoneyFuFrameSilverIcon:SetHeight(size)
	MoneyFuFrameCopperIcon:SetWidth(size)
	MoneyFuFrameCopperIcon:SetHeight(size)
	self.iconFrame:SetWidth(size)
	self.iconFrame:SetHeight(size)
	local font,_,flags = MoneyFuFrameGoldText:GetFont()
	if font ~= nil then
		MoneyFuFrameGoldText:SetFont(font, size, flags)
		MoneyFuFrameSilverText:SetFont(font, size, flags)
		MoneyFuFrameCopperText:SetFont(font, size, flags)
		self.textFrame:SetFont(font, size)
	end
	self:UpdateText()
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
