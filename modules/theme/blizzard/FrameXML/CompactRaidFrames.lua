local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
	if not _G.FREE_ADB.ReskinBlizz then return end

	if not CompactRaidFrameManagerToggleButton then return end

	CompactRaidFrameManagerToggleButton:SetNormalTexture("Interface\\Buttons\\UI-ColorPicker-Buttons")
	CompactRaidFrameManagerToggleButton:GetNormalTexture():SetTexCoord(.15, .39, 0, 1)
	CompactRaidFrameManagerToggleButton:SetSize(15, 15)
	hooksecurefunc("CompactRaidFrameManager_Collapse", function()
		CompactRaidFrameManagerToggleButton:GetNormalTexture():SetTexCoord(.15, .39, 0, 1)
	end)
	hooksecurefunc("CompactRaidFrameManager_Expand", function()
		CompactRaidFrameManagerToggleButton:GetNormalTexture():SetTexCoord(.86, 1, 0, 1)
	end)

	local buttons = {
		CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleTank,
		CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleHealer,
		CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleDamager,
		CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup1,
		CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup2,
		CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup3,
		CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup4,
		CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup5,
		CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup6,
		CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup7,
		CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup8,
		CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll,
		CompactRaidFrameManagerDisplayFrameLeaderOptionsCountdown,
		CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck,
		--CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton,
		CompactRaidFrameManagerDisplayFrameLockedModeToggle,
		CompactRaidFrameManagerDisplayFrameHiddenModeToggle,
		CompactRaidFrameManagerDisplayFrameConvertToRaid
	}
	for _, button in pairs(buttons) do
		for i = 1, 9 do
			select(i, button:GetRegions()):SetAlpha(0)
		end
		F.Reskin(button)
	end
	CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetNormalTexture("Interface\\RaidFrame\\Raid-WorldPing")

	for i = 1, 8 do
		select(i, CompactRaidFrameManager:GetRegions()):SetAlpha(0)
	end
	select(1, CompactRaidFrameManagerDisplayFrameFilterOptions:GetRegions()):SetAlpha(0)
	select(1, CompactRaidFrameManagerDisplayFrame:GetRegions()):SetAlpha(0)
	select(4, CompactRaidFrameManagerDisplayFrame:GetRegions()):SetAlpha(0)

	local bd = F.SetBD(CompactRaidFrameManager)
	bd:SetPoint("TOPLEFT")
	bd:SetPoint("BOTTOMRIGHT", -9, 9)
	F.ReskinDropDown(CompactRaidFrameManagerDisplayFrameProfileSelector)
	F.ReskinCheck(CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton)
end)
