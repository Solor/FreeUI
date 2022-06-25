local F, C = unpack(select(2, ...))

table.insert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    local r, g, b = C.r, C.g, C.b

    F.ReskinPortraitFrame(_G.CharacterFrame)
    F.StripTextures(_G.CharacterFrameInsetRight)

    for i = 1, 3 do
        F.ReskinTab(_G['CharacterFrameTab' .. i])
    end

    _G.CharacterFrameTab1:ClearAllPoints()
    _G.CharacterFrameTab1:SetPoint('TOPLEFT', _G.CharacterFrame, 'BOTTOMLEFT', 10, 1)

    _G.CharacterModelFrame:DisableDrawLayer('BACKGROUND')
    _G.CharacterModelFrame:DisableDrawLayer('BORDER')
    _G.CharacterModelFrame:DisableDrawLayer('OVERLAY')

    -- [[ Item buttons ]]

    local function colourPopout(self)
        local aR, aG, aB
        local glow = self:GetParent().IconBorder

        if glow:IsShown() then
            aR, aG, aB = glow:GetVertexColor()
        else
            aR, aG, aB = r, g, b
        end

        self.arrow:SetVertexColor(aR, aG, aB)
    end

    local function clearPopout(self)
        self.arrow:SetVertexColor(1, 1, 1)
    end

    local function UpdateAzeriteItem(self)
        if not self.styled then
            self.AzeriteTexture:SetAlpha(0)
            self.RankFrame.Texture:SetTexture('')
            self.RankFrame.Label:ClearAllPoints()
            self.RankFrame.Label:SetPoint('TOPLEFT', self, 2, -1)
            self.RankFrame.Label:SetTextColor(1, 0.5, 0)

            self.styled = true
        end
    end

    local function UpdateAzeriteEmpoweredItem(self)
        self.AzeriteTexture:SetAtlas('AzeriteIconFrame')
        self.AzeriteTexture:SetInside()
        self.AzeriteTexture:SetDrawLayer('BORDER', 1)
    end

    local function UpdateHighlight(self)
        local highlight = self:GetHighlightTexture()
        highlight:SetColorTexture(1, 1, 1, 0.25)
        highlight:SetInside()
    end

    local function UpdateCosmetic(self)
        local itemLink = GetInventoryItemLink('player', self:GetID())
        self.IconOverlay:SetShown(itemLink and IsCosmeticItem(itemLink))
    end

    local slots = {
        'Head',
        'Neck',
        'Shoulder',
        'Shirt',
        'Chest',
        'Waist',
        'Legs',
        'Feet',
        'Wrist',
        'Hands',
        'Finger0',
        'Finger1',
        'Trinket0',
        'Trinket1',
        'Back',
        'MainHand',
        'SecondaryHand',
        'Tabard',
    }

    for i = 1, #slots do
        local slot = _G['Character' .. slots[i] .. 'Slot']
        local cooldown = _G['Character' .. slots[i] .. 'SlotCooldown']

        F.StripTextures(slot)
        slot.icon:SetTexCoord(unpack(C.TEX_COORD))
        slot.icon:SetInside()
        slot.bg = F.CreateBDFrame(slot.icon, 0.25)
        slot.bg:SetFrameLevel(3)
        cooldown:SetInside()

        slot.ignoreTexture:SetTexture('Interface\\PaperDollInfoFrame\\UI-GearManager-LeaveItem-Transparent')
        slot.IconOverlay:SetInside()
        F.ReskinIconBorder(slot.IconBorder)

        local popout = slot.popoutButton
        popout:SetNormalTexture('')
        popout:SetHighlightTexture('')

        local arrow = popout:CreateTexture(nil, 'OVERLAY')
        arrow:SetSize(14, 14)
        if slot.verticalFlyout then
            F.SetupArrow(arrow, 'down')
            arrow:SetPoint('TOP', slot, 'BOTTOM', 0, 1)
        else
            F.SetupArrow(arrow, 'right')
            arrow:SetPoint('LEFT', slot, 'RIGHT', -1, 0)
        end
        popout.arrow = arrow

        popout:HookScript('OnEnter', clearPopout)
        popout:HookScript('OnLeave', colourPopout)

        hooksecurefunc(slot, 'DisplayAsAzeriteItem', UpdateAzeriteItem)
        hooksecurefunc(slot, 'DisplayAsAzeriteEmpoweredItem', UpdateAzeriteEmpoweredItem)
    end

    hooksecurefunc('PaperDollItemSlotButton_Update', function(button)
        -- also fires for bag slots, we don't want that
        if button.popoutButton then
            button.icon:SetShown(GetInventoryItemTexture('player', button:GetID()) ~= nil)
            colourPopout(button.popoutButton)
        end
        UpdateCosmetic(button)
        UpdateHighlight(button)
    end)

    -- [[ Stats pane ]]

    local pane = _G.CharacterStatsPane
    pane.ClassBackground:Hide()
    pane.ItemLevelFrame.Corruption:SetPoint('RIGHT', 22, -8)

    local categories = { pane.ItemLevelCategory, pane.AttributesCategory, pane.EnhancementsCategory }
    for _, category in pairs(categories) do
        category.Background:SetTexture('Interface\\LFGFrame\\UI-LFG-SEPARATOR')
        category.Background:SetTexCoord(0, 0.66, 0, 0.31)
        category.Background:SetVertexColor(r, g, b, 0.8)
        category.Background:SetPoint('BOTTOMLEFT', -30, -4)

        category.Title:SetTextColor(r, g, b)
    end

    -- [[ Sidebar tabs ]]

    for i = 1, #_G.PAPERDOLL_SIDEBARS do
        local tab = _G['PaperDollSidebarTab' .. i]

        if i == 1 then
            for i = 1, 4 do
                local region = select(i, tab:GetRegions())
                region:SetTexCoord(0.16, 0.86, 0.16, 0.86)
                region.SetTexCoord = nop
            end
        end

        tab.bg = F.CreateBDFrame(tab)
        tab.bg:SetPoint('TOPLEFT', 2, -3)
        tab.bg:SetPoint('BOTTOMRIGHT', 0, -2)

        tab.Icon:SetInside(tab.bg)
        tab.Hider:SetInside(tab.bg)
        tab.Highlight:SetInside(tab.bg)
        tab.Highlight:SetColorTexture(1, 1, 1, 0.25)
        tab.Hider:SetColorTexture(0.3, 0.3, 0.3, 0.4)
        tab.TabBg:SetAlpha(0)
    end

    -- [[ Equipment manager ]]

    F.StripTextures(_G.GearManagerDialogPopup.BorderBox)
    _G.GearManagerDialogPopup.BG:Hide()
    F.SetBD(_G.GearManagerDialogPopup)
    _G.GearManagerDialogPopup:SetHeight(525)
    F.StripTextures(_G.GearManagerDialogPopupScrollFrame)
    F.ReskinScroll(_G.GearManagerDialogPopupScrollFrameScrollBar)
    F.Reskin(_G.GearManagerDialogPopupOkay)
    F.Reskin(_G.GearManagerDialogPopupCancel)
    F.ReskinInput(_G.GearManagerDialogPopupEditBox)
    F.ReskinScroll(_G.PaperDollTitlesPaneScrollBar)
    F.ReskinScroll(_G.PaperDollEquipmentManagerPaneScrollBar)
    F.StripTextures(_G.PaperDollSidebarTabs)
    F.Reskin(_G.PaperDollEquipmentManagerPaneEquipSet)
    F.Reskin(_G.PaperDollEquipmentManagerPaneSaveSet)

    for i = 1, _G.NUM_GEARSET_ICONS_SHOWN do
        local bu = _G['GearManagerDialogPopupButton' .. i]
        local ic = _G['GearManagerDialogPopupButton' .. i .. 'Icon']

        bu:SetCheckedTexture(C.Assets.Button.Checked)
        select(2, bu:GetRegions()):Hide()
        local hl = bu:GetHighlightTexture()
        hl:SetColorTexture(1, 1, 1, 0.25)
        hl:SetInside()

        ic:SetInside()
        F.ReskinIcon(ic)
    end

    for _, bu in pairs(_G.PaperDollEquipmentManagerPane.buttons) do
        F.HideObject(bu.Stripe)
        bu.BgTop:SetTexture('')
        bu.BgMiddle:SetTexture('')
        bu.BgBottom:SetTexture('')
        F.ReskinIcon(bu.icon)

        bu.HighlightBar:SetColorTexture(1, 1, 1, 0.25)
        bu.HighlightBar:SetDrawLayer('BACKGROUND')
        bu.SelectedBar:SetColorTexture(r, g, b, 0.25)
        bu.SelectedBar:SetDrawLayer('BACKGROUND')
    end

    local titles = false
    hooksecurefunc('PaperDollTitlesPane_Update', function()
        if titles == false then
            for i = 1, 17 do
                _G['PaperDollTitlesPaneButton' .. i]:DisableDrawLayer('BACKGROUND')
            end
            titles = true
        end
    end)

    _G.PaperDollEquipmentManagerPaneEquipSet:SetWidth(_G.PaperDollEquipmentManagerPaneEquipSet:GetWidth() - 1)
    _G.PaperDollEquipmentManagerPaneSaveSet:SetPoint('LEFT', _G.PaperDollEquipmentManagerPaneEquipSet, 'RIGHT', 1, 0)
    _G.GearManagerDialogPopup:HookScript('OnShow', function(self)
        self:SetPoint('TOPLEFT', _G.CharacterFrame, 'TOPRIGHT', 3, 0)
    end)

    -- Reputation Frame
    _G.ReputationDetailCorner:Hide()
    _G.ReputationDetailDivider:Hide()
    _G.ReputationDetailFrame:SetPoint('TOPLEFT', _G.ReputationFrame, 'TOPRIGHT', 3, -28)

    local function UpdateFactionSkins()
        for i = 1, GetNumFactions() do
            local statusbar = _G['ReputationBar' .. i .. 'ReputationBar']
            if statusbar then
                statusbar:SetStatusBarTexture(C.Assets.Statusbar.Normal)

                if not statusbar.reskinned then
                    F.CreateBDFrame(statusbar, 0.25)
                    statusbar.reskinned = true
                end

                _G['ReputationBar' .. i .. 'Background']:SetTexture(nil)
                _G['ReputationBar' .. i .. 'ReputationBarHighlight1']:SetTexture(nil)
                _G['ReputationBar' .. i .. 'ReputationBarHighlight2']:SetTexture(nil)
                _G['ReputationBar' .. i .. 'ReputationBarAtWarHighlight1']:SetTexture(nil)
                _G['ReputationBar' .. i .. 'ReputationBarAtWarHighlight2']:SetTexture(nil)
                _G['ReputationBar' .. i .. 'ReputationBarLeftTexture']:SetTexture(nil)
                _G['ReputationBar' .. i .. 'ReputationBarRightTexture']:SetTexture(nil)
            end
        end
    end
    _G.ReputationFrame:HookScript('OnShow', UpdateFactionSkins)
    _G.ReputationFrame:HookScript('OnEvent', UpdateFactionSkins)

    for i = 1, _G.NUM_FACTIONS_DISPLAYED do
        local bu = _G['ReputationBar' .. i .. 'ExpandOrCollapseButton']
        F.ReskinCollapse(bu)
    end

    F.StripTextures(_G.ReputationDetailFrame)
    F.SetBD(_G.ReputationDetailFrame)
    F.ReskinClose(_G.ReputationDetailCloseButton)
    F.ReskinCheck(_G.ReputationDetailAtWarCheckBox)
    F.ReskinCheck(_G.ReputationDetailInactiveCheckBox)
    F.ReskinCheck(_G.ReputationDetailMainScreenCheckBox)
    F.ReskinScroll(_G.ReputationListScrollFrameScrollBar)

    -- Token frame
    _G.TokenFramePopupCorner:Hide()
    _G.TokenFramePopup:SetPoint('TOPLEFT', _G.TokenFrame, 'TOPRIGHT', 3, -28)
    F.StripTextures(_G.TokenFramePopup)
    F.SetBD(_G.TokenFramePopup)
    F.ReskinClose(_G.TokenFramePopupCloseButton)
    F.ReskinCheck(_G.TokenFramePopupInactiveCheckBox)
    F.ReskinCheck(_G.TokenFramePopupBackpackCheckBox)
    F.ReskinScroll(_G.TokenFrameContainerScrollBar)

    local function updateButtons()
        local buttons = _G.TokenFrameContainer.buttons
        if not buttons then
            return
        end

        for i = 1, #buttons do
            local bu = buttons[i]

            if not bu.styled then
                bu.highlight:SetPoint('TOPLEFT', 1, 0)
                bu.highlight:SetPoint('BOTTOMRIGHT', -1, 0)
                bu.highlight.SetPoint = nop
                bu.highlight:SetColorTexture(r, g, b, 0.2)
                bu.highlight.SetTexture = nop

                bu.categoryMiddle:SetAlpha(0)
                bu.categoryLeft:SetAlpha(0)
                bu.categoryRight:SetAlpha(0)

                bu.bg = F.ReskinIcon(bu.icon)

                if bu.expandIcon then
                    bu.expBg = F.CreateBDFrame(bu.expandIcon, 0, true)
                    bu.expBg:SetPoint('TOPLEFT', bu.expandIcon, -3, 3)
                    bu.expBg:SetPoint('BOTTOMRIGHT', bu.expandIcon, 3, -3)
                end

                bu.styled = true
            end

            if bu.isHeader then
                bu.bg:Hide()
                bu.expBg:Show()
            else
                bu.bg:Show()
                bu.expBg:Hide()
            end
        end
    end

    _G.TokenFrame:HookScript('OnShow', updateButtons)
    hooksecurefunc('TokenFrame_Update', updateButtons)
    hooksecurefunc(_G.TokenFrameContainer, 'update', updateButtons)

    -- Quick Join
    F.ReskinScroll(_G.QuickJoinScrollFrame.scrollBar)
    F.Reskin(_G.QuickJoinFrame.JoinQueueButton)

    F.SetBD(_G.QuickJoinRoleSelectionFrame)
    F.Reskin(_G.QuickJoinRoleSelectionFrame.AcceptButton)
    F.Reskin(_G.QuickJoinRoleSelectionFrame.CancelButton)
    F.ReskinClose(_G.QuickJoinRoleSelectionFrame.CloseButton)
    F.StripTextures(_G.QuickJoinRoleSelectionFrame)

    F.ReskinRole(_G.QuickJoinRoleSelectionFrame.RoleButtonTank, 'TANK')
    F.ReskinRole(_G.QuickJoinRoleSelectionFrame.RoleButtonHealer, 'HEALER')
    F.ReskinRole(_G.QuickJoinRoleSelectionFrame.RoleButtonDPS, 'DPS')
end)
