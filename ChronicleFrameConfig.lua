local ChronicleConfig;


function ChronicleFrameConfig_OnShow()
	if Chronicle.db.char.config.inIdle then
		ChronicleOptionsPanelSetIdle:SetChecked()
	end
	if
		Chronicle.db.char.config.inCombat then
		ChronicleOptionsPanelSetCombat:SetChecked()
	end
	if 
		Chronicle.db.char.config.inCombatHide then
		ChronicleOptionsPanelSetCombatHide:SetChecked()
	end
	if 
		Chronicle.db.char.config.inFlight then
		ChronicleOptionsPanelSetFlight:SetChecked()
	end
	if 
		Chronicle.db.char.config.uihide then
		ChronicleOptionsPanelSetHide:SetChecked()
	end
end

function ChronicleFrameConfigSetHandler(checkBox)
	if checkBox == "SetIdle" then
		Chronicle.db.char.config.inIdle = this:GetChecked()
	elseif checkBox == "SetCombat" then
		Chronicle.db.char.config.inCombat = this:GetChecked()
	elseif checkBox == "SetCombatHide" then
		Chronicle.db.char.config.inCombatHide = this:GetChecked()
	elseif checkBox == "SetFlight" then
		Chronicle.db.char.config.inFlight = this:GetChecked()
	elseif checkBox == "SetHide" then
		Chronicle.db.char.config.uihide = this:GetChecked()
	end
end