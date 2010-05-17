Chronicle = LibStub("AceAddon-3.0"):NewAddon("Chronicle", "AceConsole-3.0", "AceEvent-3.0")
timerSeconds = 0
counter = 0
timePlayed = 0
chronShot = false
local defaults = {
	char = {
		config = {
			pause = true,
			interval = 1800,
			uihide = false,
			inCombatHide = false,
			recordPvP = false,
			inCombat = true,
			inFlight = false,
			inIdle = false,
		},
		captureData = {},
		static = {},
	}
}
--Addon Initialize/enable disabled
function Chronicle:OnInitialize()
	Chronicle:Print("Chronicle 0.1.5 Alpha loaded")
	Chronicle:Print("\"/chron help\" to display help")
	Chronicle:Print("PAUSED BY DEFAULT, USE \"/chron toggle\" TO START")
	self.db = LibStub("AceDB-3.0"):New("ChronicleDB",defaults,true)
end
function Chronicle:OnEnable()
    player = GetUnitName("player")
	playerLevel = UnitLevel(player)
	playerRace = UnitRace(player)
	if self.db.char.static == {} then
		self.db.char.static = {
			gender = UnitSex(player),
			race = UnitRace(player),
		}
	end
end
function Chronicle:OnDisable()
    -- Called when the addon is disabled
end

-----------------
--local functions
-----------------

--Get date, get currrent CP, check if player in combat
function sanDate()
	return date("%m%d%y%H%M%S"), date("%m%d%y_%H%M%S")
end
function curXP()
   percent = (math.floor((UnitXP(player)/UnitXPMax(player))*100))
   return UnitXP(player).."/"..UnitXPMax(player), "%"..percent
end

function inCombatFunc()
	if UnitAffectingCombat(player) == 1 then
		return true
	else
		return false
	end
end

--Check if 
function getData()
	if not Chronicle.db.char.config.pause then
		if UnitIsAFK(player) then
			if Chronicle.db.char.config.inIdle then
				chronShot = true
				RequestTimePlayed()
			end
		else
			Chronicle:Print("You are AFK, data capture skipped")
		end
	end
end
function secondstodays(inputSeconds)
	fdays = math.floor(inputSeconds/86400)
	fhours = math.floor((bit.mod(inputSeconds,86400))/3600)
	fminutes = math.floor(bit.mod((bit.mod(inputSeconds,86400)),3600)/60)
	fseconds = math.floor(bit.mod(bit.mod((bit.mod(inputSeconds,86400)),3600),60))
	return fdays.." days/"..fhours.." hours/"..fminutes.." minutes/"..fseconds.." seconds"
end

--Check several conditions, return true if all met
function isPlayerReady()
	
end
--Registered Events
function Chronicle:SCREENSHOT_SUCCEEDED()
	if not UIParent:IsVisible() or uiHideAlpha then
		UIParent:SetAlpha(1)
		UIParent:Show()
	end
	Chronicle:Print("SS Taken")
end
function Chronicle:TIME_PLAYED_MSG(arg1, arg2)
	timePlayed = secondstodays(arg2)
end
function Chronicle:PLAYER_LEVEL_UP(arg1, arg2)
	playerLevel = arg2
	getData()
end
function Chronicle:ZONE_CHANGED_NEW_AREA()
	chronShot = true
	getData()
end
function Chronicle:ACHIEVEMENT_EARNED()
	chronShot = true
	getData()
end
function onUpdate(self,elapsed)
	if timePlayed ~= 0 and chronShot then
		if inCombatFunc() then
			if Chronicle.db.char.config.uihide 
			and Chronicle.db.char.config.inCombatHide 
			and UIParent:IsVisible() then
				UIParent:SetAlpha(0)
				uiHideAlpha = true
			end
		else
			if Chronicle.db.char.config.uihide and UIParent:IsVisible() then
				UIParent:Hide()
			end
		end
	Chronicle:Print("Recording Data...")
	inCombatFunc()
	TakeScreenshot()
	curTime, screenNumber = sanDate()
	curTime = tonumber(curTime, 10)
	Chronicle.db.char.captureData[curTime] = {
		screenshotNumber = screenNumber,
		level = playerLevel,
		zone = GetZoneText(),
		subZone = GetMinimapZoneText(),
		currentXP = UnitXP(player),
		neededXP = UnitXPMax(player),
		percentXP = (math.floor((UnitXP(player)/UnitXPMax(player))*100)),
		money = GetCoinText(GetMoney(),"/"),
		totalPlayed = timePlayed,
		achievPoints = GetTotalAchievementPoints(),
		isInCombat = inCombatFunc(),
		honor = GetHonorCurrency(),
		arena = GetArenaCurrency(),	
	}
	Chronicle:Print("Done!")
	timePlayed = 0
	chronShot = false
	end
	if not Chronicle.db.char.config.pause then
		timerSeconds = timerSeconds + elapsed
		if timerSeconds >= Chronicle.db.char.config.interval then
			chronShot = true
			getData()
			timerSeconds = 0
		end
	end
end

local countFrame = CreateFrame("frame")
countFrame:SetScript("OnUpdate", onUpdate)



--Slash Commands
function Chronicle:ChronicleSlashFunc(input)
	if input == "SS" then
		TakeScreenshot()
	elseif input == "toggle" then
		if self.db.char.config.pause == false then
			self.db.char.config.pause = true
			Chronicle:Print("Recording paused")
		else
			self.db.char.config.pause = false
			Chronicle:Print("Recording resumed")
		end
	elseif input == "force" then
		chronShot = true
		RequestTimePlayed()
	elseif input == "help" then
		Chronicle:Print("Use \"/chron toggle\" to pause or resume.\nUse \"/chron force\" to force data capture manually.\nUse \"/chron set XXs/m/h\" to set a custom time\nUse \"/chron uihide\" to toggle UI visibility\nUse\"/chron uihide combat\" to toggle UI visiblity during combat\nAll settings persistent across sessions!")
	elseif input == "wipe" then
		wipe(self.db.char)
		ReloadUI()
	elseif input == "uihide" then
		if self.db.char.config.uihide == false then
			self.db.char.config.uihide = true
			Chronicle:Print("UI will hide on capture")
		else
			self.db.char.config.uihide = false
			Chronicle:Print("UI will show on capture")
		end	
	elseif input == "uihide combat" then
		if self.db.char.config.inCombatHide then
			self.db.char.config.inCombatHide = false
			Chronicle:Print("UI visible during capture in combat.")
		else 
			self.db.char.config.inCombatHide = true
			if not self.db.char.config.uihide then
				Chronicle:Print("WARNING: UI Hiding disabled! Enable for this setting to take effect")
			else
				Chronicle:Print("UI hidden during capture in combat")
			end
		end
	elseif input == "debug" then
		Chronicle:Print(self.db.char.config.pause,self.db.char.config.interval,self.db.char.config.uihide)
	elseif input == "" then
		Chronicle:Print("Usage: /chron help | toggle | force | set XXs/m/h | uihide | uihide combat")
	elseif input == "pvp" then
		Chronicle.db.char.config.recordPvP = true
	elseif input == "sort" then
		table.sort(Chronicle.db.char.captureData)
		ReloadUI()
	elseif input == "options" then
		if ChronicleOptionsFrame:IsVisible() then
			ChronicleOptionsFrame:Hide()
		else
			ChronicleOptionsFrame:Show()
		end
	else
		newInterval = 0
		for newInterval in string.gmatch(input, "set") do
			if newInterval == "set" then
				for newInterval in string.gmatch(input, "([0-9]+)s") do
					string.gsub(newInterval, "s", "")
					newInterval = tonumber(newInterval)
					self.db.char.config.interval = newInterval
					Chronicle:Print("Timer set to "..newInterval.." second(s).")
				end
				for newInterval in string.gmatch(input, "([0-9]+)m") do
					string.gsub(newInterval, "m", "")
					newInterval = tonumber(newInterval)
					Chronicle:Print("Timer set to "..newInterval.." minute(s).")
					newInterval = newInterval * 60
					self.db.char.config.interval = newInterval
				end
				for newInterval in string.gmatch(input, "([0-9]+)h") do
					string.gsub(newInterval, "h", "")
					newInterval = tonumber(newInterval)
					Chronicle:Print("Timer set to "..newInterval.." hour(s).")
					newInterval = (newInterval * 60) * 60
					self.db.char.config.interval = newInterval
				end
			end
   		end
	end
end


--Register Declarations
Chronicle:RegisterEvent("SCREENSHOT_SUCCEEDED")
Chronicle:RegisterChatCommand("chron", "ChronicleSlashFunc")
Chronicle:RegisterEvent("TIME_PLAYED_MSG")
Chronicle:RegisterEvent("PLAYER_LEVEL_UP")
Chronicle:RegisterEvent("ZONE_CHANGED_NEW_AREA")
Chronicle:RegisterEvent("ACHIEVEMENT_EARNED")