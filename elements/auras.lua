local _, ns = ...

local floor = math.floor
local format = string.format

local function AuraOnEnter(aura)
	if (not aura:IsVisible()) then return end

	GameTooltip:SetOwner(aura, 'ANCHOR_BOTTOMRIGHT')
	aura:UpdateTooltip()
end

local function AuraOnLeave(aura)
	GameTooltip:Hide()
end

local function FormatTime(seconds)
	local day, hour, minute = 86400, 3600, 60
	if (seconds >= day) then
		return format('%dd', floor(seconds/day + 0.5))
	elseif (seconds >= hour) then
		return format('%dh', floor(seconds/hour + 0.5))
	elseif (seconds >= minute) then
		if (seconds <= minute * 5) then
			return format('%d:%02d', floor(seconds/minute), seconds % minute)
		end
		return format('%dm', floor(seconds/minute + 0.5))
	else
		return format('%d', seconds)
	end
end

local function UpdateAuraTimer(aura, elapsed)
	local timeLeft = aura.timeLeft - elapsed
	aura.timer:SetText((timeLeft > 0) and FormatTime(timeLeft))
	aura.timeLeft = timeLeft
end

local function UpdateAuraTooltip(aura)
	GameTooltip:SetUnitAura(aura:GetParent().__owner.unit, aura:GetID(), aura.filter)
end

local function PostUpdateAura(auras, unit, aura, index, offset)
	local _, _, _, _, _, duration, expiration = UnitAura(unit, index, aura.filter)

	if (duration and duration > 0) then
		aura.timeLeft = expiration - GetTime()
		aura:SetScript('OnUpdate', UpdateAuraTimer)
	else
		aura:SetScript('OnUpdate', nil)
		aura.timer:SetText()
	end
end

local function CreateAura(auras, index)
	local button = CreateFrame('Button', auras:GetName() .. index, auras)

	local icon = button:CreateTexture(nil, 'BORDER')
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	icon:SetAllPoints()
	button.icon = icon

	local overlay = button:CreateTexture(nil, 'ARTWORK')
	overlay:SetTexture(ns.assets.BUTTONOVERLAY)
	overlay:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	overlay:SetAllPoints()
	button.overlay = overlay

	local count = button:CreateFontString(nil, 'OVERLAY', 'LayoutFont_Shadow_Small')
	count:SetPoint('BOTTOMRIGHT', -1, 1)
	button.count = count

	local timer = button:CreateFontString(nil, 'OVERLAY', 'LAyoutFont_Shadow_Small')
	timer:SetPoint('TOPLEFT', 1, -1)
	button.timer = timer

	button.UpdateTooltip = UpdateAuraTooltip
	button:SetScript('OnEnter', AuraOnEnter)
	button:SetScript('OnLeave', AuraOnLeave)

	return button
end

function ns.AddDebuffs(self, unit)
	local debuffs = CreateFrame('Frame', self:GetName() .. '_Debuffs', self)
	debuffs.spacing = 2.5
	debuffs.size = (230 - 7 * debuffs.spacing) / 8
	debuffs.showDebuffType = true
	debuffs.CreateIcon = CreateAura
	debuffs.PostUpdateIcon = PostUpdateAura

	if (unit == 'player' or unit == 'target') then
		debuffs:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 5, -2.5)
		debuffs:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT', -5, -2.5)
		debuffs:SetHeight(5 * (debuffs.size + debuffs.spacing))
		debuffs.initialAnchor = 'TOPLEFT'
		debuffs['growth-x'] = 'RIGHT'
		debuffs['growth-y'] = 'DOWN'
	else
		debuffs:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', -5, 2.5)
		debuffs.num = 6
		debuffs:SetSize(debuffs.num * (debuffs.size + debuffs.spacing), debuffs.size + debuffs.spacing)
		debuffs.initialAnchor = 'RIGHT'
		debuffs['growth-x'] = 'LEFT'
	end

	self.Debuffs = debuffs
end