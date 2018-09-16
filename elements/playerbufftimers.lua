local _, ns = ...

local FormatTime = ns.FormatTime

local function OnUpdate(timer, elapsed)
	local timeLeft = timer.timeLeft - elapsed
	timer.remaining:SetText((timeLeft > 0) and FormatTime(timeLeft))
	timer.timeLeft = timeLeft
end

local function UpdateTimer(timer, duration, expiration, barID, auraID)
	local _, _, texture = GetSpellInfo(auraID)
	timer.icon:SetTexture(texture)
	timer.timeLeft = expiration - GetTime()
end

function ns.AddPlayerBuffTimers(self)
	local timers = {}
	for i = 1, 2 do
		local button = CreateFrame('Button', nil, self)
		button:SetSize(32, 32)
		button:SetPoint("BOTTOMLEFT", self, "TOPLEFT", (i - 1) * (32 + 5), 65)

		local icon = button:CreateTexture(nil, 'BORDER')
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		icon:SetAllPoints()
		button.icon = icon

		local overlay = button:CreateTexture(nil, 'ARTWORK')
		overlay:SetTexture(ns.assets.BUTTONOVERLAY)
		overlay:SetPoint('TOPLEFT', -2.5, 2.5)
		overlay:SetPoint('BOTTOMRIGHT', 2.5, -2.5)

		local remaining = button:CreateFontString(nil, 'OVERLAY', 'LayoutFont_Bold_Small_Outline')
		remaining:SetPoint('TOPLEFT', 0, 0)
		button.remaining = remaining

		button.UpdateTimer = UpdateTimer
		button:SetScript('OnUpdate', OnUpdate)

		timers[i] = button
	end

	self.PlayerBuffTimers = timers
end
