local _G = _G
local format = format
local floor = floor
local rad = rad
local wipe = wipe
local unpack = unpack
local select = select
local split = strsplit
local strupper = strupper
local CreateFrame = CreateFrame
local UnitFrame_OnEnter = UnitFrame_OnEnter
local UnitFrame_OnLeave = UnitFrame_OnLeave
local UnitGUID = UnitGUID
local UnitName = UnitName
local UnitIsUnit = UnitIsUnit
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsConnected = UnitIsConnected
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitIsTapDenied = UnitIsTapDenied
local UnitIsPlayer = UnitIsPlayer
local UnitAura = UnitAura
local UnitInVehicle = UnitInVehicle
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitThreatSituation = UnitThreatSituation
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitExists = UnitExists
local GetThreatStatusColor = GetThreatStatusColor
local GetSpecialization = GetSpecialization
local IsUsableSpell = IsUsableSpell
local IsPlayerSpell = IsPlayerSpell
local GetSpellInfo = GetSpellInfo
local GetSpellCooldown = GetSpellCooldown
local GetRuneCooldown = GetRuneCooldown
local GetUnitPowerBarStringsByID = GetUnitPowerBarStringsByID
local CancelUnitBuff = CancelUnitBuff
local InCombatLockdown = InCombatLockdown
local GetTime = GetTime
local IsResting = IsResting
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local IsPartyLFG = IsPartyLFG
local C_ChatInfo_SendAddonMessage = C_ChatInfo.SendAddonMessage
local C_ChatInfo_RegisterAddonMessagePrefix = C_ChatInfo.RegisterAddonMessagePrefix
local YOU = YOU

local F, C, L = unpack(select(2, ...))
local UNITFRAME = F.UNITFRAME
local NAMEPLATE = F.NAMEPLATE
local OUF = F.OUF

--[[ Backdrop ]]

local function UNITFRAME_OnEnter(self)
    UnitFrame_OnEnter(self)
    self.Highlight:Show()
end

local function UNITFRAME_OnLeave(self)
    UnitFrame_OnLeave(self)
    self.Highlight:Hide()
end

function UNITFRAME:AddBackDrop(self)
    local highlight = self:CreateTexture(nil, 'OVERLAY')
    highlight:SetAllPoints()
    highlight:SetTexture('Interface\\PETBATTLES\\PetBattle-SelectedPetGlow')
    highlight:SetTexCoord(0, 1, .5, 1)
    highlight:SetVertexColor(.6, .6, .6)
    highlight:SetBlendMode('BLEND')
    highlight:Hide()
    self.Highlight = highlight

    self:RegisterForClicks('AnyUp')
    self:HookScript('OnEnter', UNITFRAME_OnEnter)
    self:HookScript('OnLeave', UNITFRAME_OnLeave)

    F.CreateTex(self)

    local bg = F.CreateBDFrame(self)
    bg:SetBackdropBorderColor(0, 0, 0, 1)
    bg:SetBackdropColor(0, 0, 0, 0)
    self.Bg = bg

    local glow = F.CreateSD(self.Bg)
    self.Glow = glow

    if not self.unitStyle == 'player' then
        return
    end

    local width = C.DB.unitframe.player_width
    local height = C.DB.unitframe.class_power_bar_height

    local classPowerBarHolder = CreateFrame('Frame', nil, self)
    classPowerBarHolder:SetSize(width, height)
    classPowerBarHolder:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -3)

    self.ClassPowerBarHolder = classPowerBarHolder
end

--[[ Selected border ]]

local function UpdateSelectedBorder(self)
    if UnitIsUnit('target', self.unit) then
        self.Border:Show()
    else
        self.Border:Hide()
    end
end

function UNITFRAME:AddSelectedBorder(self)
    local border = F.CreateBDFrame(self.Bg)
    border:SetBackdropBorderColor(1, 1, 1, 1)
    border:SetBackdropColor(0, 0, 0, 0)
    border:SetFrameLevel(self:GetFrameLevel() + 5)
    border:Hide()

    self.Border = border
    self:RegisterEvent('PLAYER_TARGET_CHANGED', UpdateSelectedBorder, true)
    self:RegisterEvent('GROUP_ROSTER_UPDATE', UpdateSelectedBorder, true)
end

--[[ Health ]]

local function OverrideHealth(self, event, unit)
    if not C.DB.unitframe.transparent_mode then
        return
    end
    if (not unit or self.unit ~= unit) then
        return
    end

    local health = self.Health
    local cur, max = UnitHealth(unit), UnitHealthMax(unit)
    local isOffline = not UnitIsConnected(unit)
    local isDead = UnitIsDead(unit)
    local isGhost = UnitIsGhost(unit)

    health:SetMinMaxValues(0, max)

    if isDead or isGhost or isOffline then
        self:SetValue(0)
    else
        if max == cur then
            health:SetValue(0)
        else
            health:SetValue(max - cur)
        end
    end
end

local function PostUpdateHealth(self, unit, cur, max)
    local parent = self:GetParent()
    local style = self.__owner.unitStyle
    local perhp = floor(UnitHealth('player') / max * 100 + .5)
    if style == 'player' then
        if perhp < 35 then
            parent.EmergencyIndicator:Show()
        else
            parent.EmergencyIndicator:Hide()
        end
    end

    local isOffline = not UnitIsConnected(unit)
    local isDead = UnitIsDead(unit)
    local isGhost = UnitIsGhost(unit)
    local isTapped = UnitIsTapDenied(unit)

    if not C.DB.unitframe.transparent_mode then
        return
    end
    if isDead or isGhost or isOffline then
        self:SetValue(0)
    else
        if max == cur then
            self:SetValue(0)
        else
            self:SetValue(max - cur)
        end
    end

    if isDead or isGhost then
        parent.Bg:SetBackdropColor(0, 0, 0, .8)
    elseif isOffline or isTapped then
        parent.Bg:SetBackdropColor(.5, .5, .5, .6)
    else
        parent.Bg:SetBackdropColor(.1, .1, .1, .6)
    end
end

function UNITFRAME:AddHealthBar(self)
    local style = self.unitStyle
    local transMode = C.DB.unitframe.transparent_mode
    local groupColorStyle = C.DB.unitframe.group_color_style
    local colorStyle = C.DB.unitframe.color_style
    local isParty = (style == 'party')
    local isRaid = (style == 'raid')
    local isBoss = (style == 'boss')
    local isArena = (style == 'arena')
    local isBaseUnits = F:MultiCheck(style, 'player', 'pet', 'target', 'targettarget', 'focus', 'focustarget')

    local health = CreateFrame('StatusBar', nil, self)
    health:SetFrameStrata('LOW')
    health:SetStatusBarTexture(C.Assets.statusbar_tex)
    health:SetReverseFill(C.DB.unitframe.transparent_mode)
    health:SetStatusBarColor(.1, .1, .1, 1)
    health:SetPoint('TOP')
    health:SetPoint('LEFT')
    health:SetPoint('RIGHT')
    health:SetPoint('BOTTOM', 0, C.Mult + C.DB.unitframe.power_bar_height)
    health:SetHeight(self:GetHeight() - C.DB.unitframe.power_bar_height - C.Mult)
    F:SmoothBar(health)

    if not transMode then
        local bg = health:CreateTexture(nil, 'BACKGROUND')
        bg:SetAllPoints(health)
        bg:SetTexture(C.Assets.bd_tex)
        bg:SetVertexColor(.6, .6, .6)
        bg.multiplier = .1
        health.bg = bg
    end

    health.colorTapping = true
    health.colorDisconnected = true

    if ((isParty or isRaid or isBoss) and groupColorStyle == 2) or (isBaseUnits and colorStyle == 2) or isArena then
        health.colorClass = true
        health.colorSelection = true
    elseif ((isParty or isRaid or isBoss) and groupColorStyle == 3) or (isBaseUnits and colorStyle == 3) then
        health.colorSmooth = true
    else
        health.colorHealth = true
    end

    self.Health = health
    self.Health.frequentUpdates = true
    self.Health.PreUpdate = OverrideHealth
    self.Health.PostUpdate = PostUpdateHealth
end

--[[ Health prediction ]]

function UNITFRAME:AddHealthPrediction(self)
    if not C.DB.unitframe.heal_prediction then
        return
    end

    local colors = C.ClassColors[C.MyClass] or C.ClassColors['PRIEST']

    local myBar = CreateFrame('StatusBar', nil, self.Health)
    myBar:SetPoint('TOP')
    myBar:SetPoint('BOTTOM')
    myBar:SetPoint('LEFT', self.Health:GetStatusBarTexture(), C.DB.unitframe.transparent_mode and 'LEFT' or 'RIGHT')
    myBar:SetStatusBarTexture(C.Assets.statusbar_tex)
    myBar:GetStatusBarTexture():SetBlendMode('BLEND')
    -- myBar:SetStatusBarColor(0, .8, .8, .6)
    myBar:SetStatusBarColor(colors.r / 2, colors.g / 2, colors.b / 2, .85)
    myBar:SetWidth(self:GetWidth())

    local otherBar = CreateFrame('StatusBar', nil, self.Health)
    otherBar:SetPoint('TOP')
    otherBar:SetPoint('BOTTOM')
    otherBar:SetPoint('LEFT', myBar:GetStatusBarTexture(), C.DB.unitframe.transparent_mode and 'LEFT' or 'RIGHT')
    otherBar:SetStatusBarTexture(C.Assets.statusbar_tex)
    otherBar:GetStatusBarTexture():SetBlendMode('BLEND')
    -- otherBar:SetStatusBarColor(0, .6, .6, .6)
    otherBar:SetStatusBarColor(colors.r / 2, colors.g / 2, colors.b / 2, .85)
    otherBar:SetWidth(self:GetWidth())

    local absorbBar = CreateFrame('StatusBar', nil, self.Health)
    absorbBar:SetPoint('TOP')
    absorbBar:SetPoint('BOTTOM')
    absorbBar:SetPoint('LEFT', otherBar:GetStatusBarTexture(), C.DB.unitframe.transparent_mode and 'LEFT' or 'RIGHT')
    absorbBar:SetStatusBarTexture(C.Assets.stripe_tex)
    absorbBar:GetStatusBarTexture():SetBlendMode('BLEND')
    absorbBar:SetStatusBarColor(.8, .8, .8, .8)
    absorbBar:SetWidth(self:GetWidth())

    local overAbsorb = self.Health:CreateTexture(nil, 'OVERLAY')
    overAbsorb:SetPoint('TOP', self.Health, 'TOPRIGHT', -1, 4)
    overAbsorb:SetPoint('BOTTOM', self.Health, 'BOTTOMRIGHT', -1, -4)
    overAbsorb:SetWidth(12)
    overAbsorb:SetTexture(C.AssetsPath .. 'textures\\spark_tex')
    overAbsorb:SetBlendMode('ADD')

    -- LuaFormatter off
    self.HealthPrediction = {
        myBar = myBar,
        otherBar = otherBar,
        absorbBar = absorbBar,
        overAbsorb = overAbsorb,
        maxOverflow = 1,
        frequentUpdates = true,
    }
    -- LuaFormatter on
end

--[[ Power ]]

local function PostUpdatePower(power, unit, _, _, max)
    if max == 0 or not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit) then
        power:SetValue(0)
    end
end

local function UpdatePowerColor(power, unit)
    if unit ~= 'player' or UnitHasVehicleUI('player') then
        return
    end

    local spec = GetSpecialization() or 0
    if C.MyClass == 'DEMONHUNTER' then
        if spec ~= 1 then
            return
        end

        -- EyeBeam needs 30 power, ChaosStrike needs 40 power
        -- BladeDance needs 35 power or 15 power with FirstBlood
        local eyeBeam, _ = IsUsableSpell(198013)
        local chaosStrike, _ = IsUsableSpell(162794)
        -- local bladeDance, _ = IsUsableSpell(188499)

        if chaosStrike then
            power:SetStatusBarColor(.85, .16, .23)
        elseif eyeBeam then
            power:SetStatusBarColor(.93, .74, .13)
        else
            power:SetStatusBarColor(.5, .5, .5)
        end
    elseif C.MyClass == 'WARRIOR' then
        if spec ~= 2 then
            return
        end

        local rampage, _ = IsUsableSpell(184367)

        if rampage then
            power:SetStatusBarColor(184 / 255, 92 / 255, 214 / 255)
        else
            power:SetStatusBarColor(215 / 255, 22 / 255, 55 / 255)
        end
    end
end

function UNITFRAME:AddPowerBar(self)
    local style = self.unitStyle

    local power = CreateFrame('StatusBar', nil, self)
    power:SetPoint('LEFT')
    power:SetPoint('RIGHT')
    power:SetPoint('TOP', self.Health, 'BOTTOM', 0, -C.Mult)
    power:SetStatusBarTexture(C.Assets.statusbar_tex)
    power:SetHeight(C.DB.unitframe.power_bar_height)

    F:SmoothBar(power)
    power.frequentUpdates = true

    self.Power = power

    local line = power:CreateTexture(nil, 'OVERLAY')
    line:SetHeight(C.Mult)
    line:SetPoint('TOPLEFT', 0, C.Mult)
    line:SetPoint('TOPRIGHT', 0, C.Mult)
    line:SetTexture(C.Assets.bd_tex)
    line:SetVertexColor(0, 0, 0)

    local bg = power:CreateTexture(nil, 'BACKGROUND')
    bg:SetAllPoints()
    bg:SetTexture(C.Assets.bd_tex)
    bg:SetAlpha(.2)
    bg.multiplier = .1
    power.bg = bg

    power.colorTapping = true
    power.colorDisconnected = true

    if C.DB.unitframe.transparent_mode and style ~= 'player' then
        power.colorClass = true
        power.colorReaction = true
    else
        power.colorPower = true
    end

    self.Power.PostUpdate = PostUpdatePower

    if style == 'player' or style == 'playerplate' then
        self.Power.PostUpdateColor = UpdatePowerColor
    end
end

--[[ Alternative power ]]

local function AltPowerOnEnter(self)
    if (not self:IsVisible()) then
        return
    end

    _G.GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
    self:UpdateTooltip()
end

local function AltPowerUpdateTooltip(self)
    local value = self:GetValue()
    local min, max = self:GetMinMaxValues()
    local name, tooltip = GetUnitPowerBarStringsByID(self.__barID)
    _G.GameTooltip:SetText(name or '', 1, 1, 1)
    _G.GameTooltip:AddLine(tooltip or '', nil, nil, nil, true)
    _G.GameTooltip:AddLine(format('%d (%d%%)', value, (value - min) / (max - min) * 100), 1, 1, 1)
    _G.GameTooltip:Show()
end

local function PostUpdateAltPower(self, _, cur, _, max)
    local parent = self.__owner

    if cur and max then
        local value = parent.AlternativePowerValue
        local r, g, b = F:ColorGradient(cur / max, unpack(OUF.colors.smooth))

        self:SetStatusBarColor(r, g, b)
        value:SetTextColor(r, g, b)
    end

    if self:IsShown() then
        parent.ClassPowerBarHolder:ClearAllPoints()
        parent.ClassPowerBarHolder:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -3)
    else
        parent.ClassPowerBarHolder:ClearAllPoints()
        parent.ClassPowerBarHolder:SetPoint('TOPLEFT', parent, 'BOTTOMLEFT', 0, -3)
    end
end

function UNITFRAME:AddAlternativePowerBar(self)
    if not C.DB.unitframe.alt_power then
        return
    end

    local altPower = CreateFrame('StatusBar', nil, self)
    altPower:SetStatusBarTexture(C.Assets.statusbar_tex)
    altPower:SetPoint('TOP', self.Power, 'BOTTOM', 0, -2)
    altPower:Size(self:GetWidth(), C.DB.unitframe.alt_power_height)
    altPower:EnableMouse(true)
    F:SmoothBar(altPower)
    altPower.bg = F.SetBD(altPower)

    altPower.UpdateTooltip = AltPowerUpdateTooltip
    altPower:SetScript('OnEnter', AltPowerOnEnter)

    self.AlternativePower = altPower
    self.AlternativePower.PostUpdate = PostUpdateAltPower
end

--[[ Auras ]]

-- LuaFormatter off
local debuffColors = {
    Curse = {.8, 0, 1},
    Disease = {.8, .6, 0},
    Magic = {0, .8, 1},
    Poison = {0, .8, 0},
    none = {0, 0, 0},
}
-- LuaFormatter on

local function AuraOnEnter(self)
    if not self:IsVisible() then
        return
    end

    _G.GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
    self:UpdateTooltip()
end

local function AuraOnLeave()
    _G.GameTooltip:Hide()
end

local function UpdateAuraTooltip(aura)
    _G.GameTooltip:SetUnitAura(aura:GetParent().__owner.unit, aura:GetID(), aura.filter)
end

function UNITFRAME.PostCreateIcon(element, button)
    local style = element.__owner.unitStyle
    local isParty = style == 'party'

    button.bg = F.CreateBDFrame(button)
    button.glow = F.CreateSD(button.bg, .25, 3, 3)

    element.disableCooldown = true
    button:SetFrameLevel(element:GetFrameLevel() + 4)

    button.overlay:SetTexture(nil)
    button.stealable:SetTexture(nil)
    button.cd:SetReverse(true)
    button.icon:SetDrawLayer('ARTWORK')
    button.icon:SetTexCoord(.08, .92, isParty and .08 or .25, isParty and .92 or .85)

    button.HL = button:CreateTexture(nil, 'HIGHLIGHT')
    button.HL:SetColorTexture(1, 1, 1, .25)
    button.HL:SetAllPoints()

    button.count = F.CreateFS(button, C.Assets.Fonts.Roadway, 12, 'OUTLINE', nil, nil, true)
    button.count:ClearAllPoints()
    button.count:SetPoint('TOPRIGHT', button, 2, 4)

    button.timer = F.CreateFS(button, C.Assets.Fonts.Roadway, 12, 'OUTLINE', nil, nil, true)
    button.timer:ClearAllPoints()
    button.timer:SetPoint('BOTTOMLEFT', button, 2, -4)

    button.UpdateTooltip = UpdateAuraTooltip
    button:SetScript('OnEnter', AuraOnEnter)
    button:SetScript('OnLeave', AuraOnLeave)
    button:SetScript('OnClick', function(self, button)
        if not InCombatLockdown() and button == 'RightButton' then
            CancelUnitBuff('player', self:GetID(), self.filter)
        end
    end)
end

function UNITFRAME.PostUpdateIcon(element, unit, button, index, _, duration, expiration, debuffType)
    if duration then
        button.bg:Show()

        if button.glow then
            button.glow:Show()
        end
    end

    local style = element.__owner.unitStyle
    local isParty = style == 'party'
    local _, _, _, _, _, _, _, canStealOrPurge = UnitAura(unit, index, button.filter)

    button:SetSize(element.size, isParty and element.size or element.size * .75)

    if button.isDebuff and F:MultiCheck(style, 'target', 'boss', 'arena') and not button.isPlayer then
        button.icon:SetDesaturated(true)
    else
        button.icon:SetDesaturated(false)
    end

    if element.disableCooldown then
        if duration and duration > 0 then
            button.expiration = expiration
            button:SetScript('OnUpdate', F.CooldownOnUpdate)
            button.timer:Show()
        else
            button:SetScript('OnUpdate', nil)
            button.timer:Hide()
        end
    end

    if canStealOrPurge and element.showStealableBuffs then
        button.bg:SetBackdropBorderColor(1, 1, 1)

        if button.glow then
            button.glow:SetBackdropBorderColor(1, 1, 1, .25)
        end
    elseif button.isDebuff and element.showDebuffType then
        local color = debuffColors[debuffType] or debuffColors.none

        button.bg:SetBackdropBorderColor(color[1], color[2], color[3])

        if button.glow then
            button.glow:SetBackdropBorderColor(color[1], color[2], color[3], .25)
        end
    else
        button.bg:SetBackdropBorderColor(0, 0, 0)

        if button.glow then
            button.glow:SetBackdropBorderColor(0, 0, 0, .25)
        end
    end
end

local function BolsterPreUpdate(element)
    element.bolster = 0
    element.bolsterIndex = nil
end

local function BolsterPostUpdate(element)
    if not element.bolsterIndex then
        return
    end

    for _, button in pairs(element) do
        if button == element.bolsterIndex then
            button.count:SetText(element.bolster)

            return
        end
    end
end

function UNITFRAME.CustomFilter(element, unit, button, name, _, _, _, _, _, caster, isStealable, _, spellID, _, _, _,
    nameplateShowAll)
    local style = element.__owner.unitStyle
    local isMine = F:MultiCheck(caster, 'player', 'pet', 'vehicle')

    if name and spellID == 209859 then
        element.bolster = element.bolster + 1
        if not element.bolsterIndex then
            element.bolsterIndex = button
            return true
        end
    elseif style == 'party' then
        if C.RaidBuffsList[spellID] then
            return true
        else
            return false
        end
    elseif style == 'raid' then
        if C.DB.unitframe.corner_indicator then
            return C.RaidBuffsList['ALL'][spellID] or _G.FREE_ADB['RaidAuraWatch'][spellID]
        else
            return (button.isPlayer or caster == 'pet') and UNITFRAME.CornerSpellsList[spellID] or
                       C.RaidBuffsList['ALL'][spellID] or C.RaidBuffsList['WARNING'][spellID]
        end
    elseif style == 'target' then
        if element.onlyShowPlayer and button.isDebuff then
            return isMine
        else
            return true
        end
    elseif style == 'focus' then
        if button.isDebuff then
            return true
        else
            return false
        end
    elseif style == 'pet' then
        return true
    elseif style == 'nameplate' or style == 'boss' or style == 'arena' then
        if _G.FREE_ADB['NPAuraFilter'][2][spellID] or C.AuraBlackList[spellID] then
            return false
        elseif element.showStealableBuffs and isStealable and not UnitIsPlayer(unit) then
            return true
        elseif _G.FREE_ADB['NPAuraFilter'][1][spellID] or C.AuraWhiteList[spellID] then
            return true
        else
            local auraFilter = C.DB.Nameplate.AuraFilterMode
            return (auraFilter == 3 and nameplateShowAll) or (auraFilter ~= 1 and isMine)
        end
    elseif (element.onlyShowPlayer and button.isPlayer) or (not element.onlyShowPlayer and name) then
        return true
    end
end

function UNITFRAME.PostUpdateGapIcon(_, _, icon)
    icon:Hide()
end

local function getIconSize(w, n, s)
    return (w - (n - 1) * s) / n
end

function UNITFRAME:AddAuras(self)
    local style = self.unitStyle
    local auras = CreateFrame('Frame', nil, self)
    auras.gap = true
    auras.spacing = 4
    auras.numTotal = 32

    if style == 'target' then
        auras.initialAnchor = 'BOTTOMLEFT'
        auras:SetPoint('BOTTOM', self, 'TOP', 0, 24)
        auras['growth-y'] = 'UP'
        auras.iconsPerRow = C.DB.unitframe.target_auras_per_row
    elseif style == 'pet' or style == 'focus' or style == 'boss' or style == 'arena' then
        auras.initialAnchor = 'TOPLEFT'
        auras:SetPoint('TOP', self, 'BOTTOM', 0, -6)
        auras['growth-y'] = 'DOWN'

        if style == 'pet' then
            auras.iconsPerRow = C.DB.unitframe.pet_auras_per_row
        elseif style == 'focus' then
            auras.iconsPerRow = C.DB.unitframe.focus_auras_per_row
        elseif style == 'boss' then
            auras.iconsPerRow = C.DB.unitframe.boss_auras_per_row
        elseif style == 'arena' then
            auras.iconsPerRow = C.DB.unitframe.arena_auras_per_row
        end
    elseif style == 'party' then
        auras.initialAnchor = 'LEFT'
        auras:SetPoint('LEFT', self, 'RIGHT', 5, 0)
        auras['growth-y'] = 'RIGHT'
        auras.size = C.DB.unitframe.party_height * .7
        auras.numTotal = 4
        auras.gap = false
    elseif style == 'nameplate' and C.DB.Nameplate.ShowAura then
        auras.initialAnchor = 'BOTTOMLEFT'
        auras:SetPoint('BOTTOM', self, 'TOP', 0, 8)
        auras['growth-y'] = 'UP'
        auras.size = C.DB.Nameplate.AuraSize
        auras.numTotal = C.DB.Nameplate.AuraNumTotal
        auras.gap = false
        auras.disableMouse = true
    end

    local width = self:GetWidth()
    local maxAuras = auras.numTotal or auras.numBuffs + auras.numDebuffs
    local maxLines = auras.iconsPerRow and floor(maxAuras / auras.iconsPerRow + .5) or 2

    auras.size = auras.iconsPerRow and getIconSize(width, auras.iconsPerRow, auras.spacing) or auras.size
    auras:SetWidth(width)
    auras:SetHeight((auras.size + auras.spacing) * maxLines)

    auras.onlyShowPlayer = C.DB.unitframe.debuffs_by_player
    auras.showDebuffType = C.DB.unitframe.debuff_type
    auras.showStealableBuffs = C.DB.unitframe.stealable_buffs
    auras.CustomFilter = UNITFRAME.CustomFilter
    auras.PostCreateIcon = UNITFRAME.PostCreateIcon
    auras.PostUpdateIcon = UNITFRAME.PostUpdateIcon
    auras.PostUpdateGapIcon = UNITFRAME.PostUpdateGapIcon
    auras.PreUpdate = BolsterPreUpdate
    auras.PostUpdate = BolsterPostUpdate

    self.Auras = auras
end

--[[ Corner aura indicator ]]

UNITFRAME.CornerSpellsList = {}
function UNITFRAME:UpdateCornerSpells()
    wipe(UNITFRAME.CornerSpellsList)

    for spellID, value in pairs(C.CornerSpellsList[C.MyClass]) do
        local modData = _G.FREE_ADB['CornerSpellsList'][C.MyClass]
        if not (modData and modData[spellID]) then
            local r, g, b = unpack(value[2])
            UNITFRAME.CornerSpellsList[spellID] = {value[1], {r, g, b}, value[3]}
        end
    end

    for spellID, value in pairs(_G.FREE_ADB['CornerSpellsList'][C.MyClass]) do
        if next(value) then
            local r, g, b = unpack(value[2])
            UNITFRAME.CornerSpellsList[spellID] = {value[1], {r, g, b}, value[3]}
        end
    end
end

UNITFRAME.BloodlustList = {}
for _, spellID in pairs(C.BloodlustList) do
    UNITFRAME.BloodlustList[spellID] = {'BOTTOMLEFT', {1, .8, 0}, true}
end

local found = {}
local auraFilter = {'HELPFUL', 'HARMFUL'}

function UNITFRAME:UpdateCornerIndicator(event, unit)
    if event == 'UNIT_AURA' and self.unit ~= unit then
        return
    end

    local spellList = UNITFRAME.CornerSpellsList
    local buttons = self.BuffIndicator
    unit = self.unit

    wipe(found)
    for _, filter in next, auraFilter do
        for i = 1, 32 do
            local name, _, _, _, duration, expiration, caster, _, _, spellID = UnitAura(unit, i, filter)
            if not name then
                break
            end
            local value = spellList[spellID] or (C.Role ~= 'Healer' and UNITFRAME.BloodlustList[spellID])
            if value and (value[3] or caster == 'player' or caster == 'pet') then
                local bu = buttons[value[1]]
                if bu then
                    if duration and duration > 0 then
                        bu.cd:SetCooldown(expiration - duration, duration)
                        bu.cd:Show()
                    else
                        bu.cd:Hide()
                    end

                    bu.icon:SetVertexColor(unpack(value[2]))

                    -- if count > 1 then
                    -- 	bu.count:SetText(count)
                    -- end
                    bu:Show()
                    found[bu.anchor] = true
                end
            end
        end
    end

    for _, bu in pairs(buttons) do
        if not found[bu.anchor] then
            bu:Hide()
        end
    end
end

function UNITFRAME:RefreshCornerIndicator(bu)
    bu:SetScript('OnUpdate', nil)
    bu.icon:SetTexture(C.Assets.bd_tex)
    bu.icon:Show()
    bu.cd:Show()
    bu.bg:Show()
end

function UNITFRAME:AddCornerIndicator(self)
    if not C.DB.unitframe.corner_indicator then
        return
    end

    local parent = CreateFrame('Frame', nil, self.Health)
    parent:SetPoint('TOPLEFT', 4, -4)
    parent:SetPoint('BOTTOMRIGHT', -4, 4)

    local anchors = {'TOPLEFT', 'TOP', 'TOPRIGHT', 'LEFT', 'RIGHT', 'BOTTOMLEFT', 'BOTTOM', 'BOTTOMRIGHT'}
    local buttons = {}
    for _, anchor in pairs(anchors) do
        local bu = CreateFrame('Frame', nil, parent)
        bu:SetFrameLevel(self:GetFrameLevel() + 10)
        bu:SetSize(5, 5)
        bu:SetScale(C.DB.unitframe.corner_indicator_scale)
        bu:SetPoint(anchor)
        bu:Hide()

        bu.bg = F.CreateBDFrame(bu)
        bu.icon = bu:CreateTexture(nil, 'BORDER')
        bu.icon:SetInside(bu.bg)
        bu.icon:SetTexCoord(unpack(C.TexCoord))
        bu.cd = CreateFrame('Cooldown', nil, bu, 'CooldownFrameTemplate')
        bu.cd:SetAllPoints(bu.bg)
        bu.cd:SetReverse(true)
        bu.cd:SetHideCountdownNumbers(true)

        bu.anchor = anchor
        buttons[anchor] = bu

        UNITFRAME:RefreshCornerIndicator(bu)
    end

    self.BuffIndicator = buttons
    self:RegisterEvent('UNIT_AURA', UNITFRAME.UpdateCornerIndicator)
    self:RegisterEvent('GROUP_ROSTER_UPDATE', UNITFRAME.UpdateCornerIndicator, true)
end

function UNITFRAME:RefreshRaidFrameIcons()
    for _, frame in pairs(OUF.objects) do
        if frame.mystyle == 'raid' then
            if frame.RaidDebuffs then
                frame.RaidDebuffs:SetScale(C.DB.unitframe.raid_debuffs_scale)
            end
            if frame.BuffIndicator then
                for _, bu in pairs(frame.BuffIndicator) do
                    bu:SetScale(C.DB.unitframe.corner_indicator_scale)
                    UNITFRAME:RefreshCornerIndicator(bu)
                end
            end
        end
    end
end

--[[ Debuff highlight ]]

function UNITFRAME:AddDebuffHighlight(self)
    if not C.DB.unitframe.group_debuff_highlight then
        return
    end

    self.DebuffHighlight = self:CreateTexture(nil, 'OVERLAY')
    self.DebuffHighlight:SetAllPoints(self)
    self.DebuffHighlight:SetTexture('Interface\\PETBATTLES\\PetBattle-SelectedPetGlow')
    self.DebuffHighlight:SetTexCoord(0, 1, .5, 1)
    self.DebuffHighlight:SetVertexColor(.6, .6, .6, 0)
    self.DebuffHighlight:SetBlendMode('ADD')
    self.DebuffHighlightAlpha = 1
    self.DebuffHighlightFilter = true
end

--[[ Group debuffs ]]

local debuffList = {}
function UNITFRAME:UpdateRaidDebuffs()
    wipe(debuffList)
    for instName, value in pairs(C.RaidDebuffsList) do
        for spell, priority in pairs(value) do
            if not (_G.FREE_ADB['RaidDebuffsList'][instName] and _G.FREE_ADB['RaidDebuffsList'][instName][spell]) then
                if not debuffList[instName] then
                    debuffList[instName] = {}
                end
                debuffList[instName][spell] = priority
            end
        end
    end
    for instName, value in pairs(_G.FREE_ADB['RaidDebuffsList']) do
        for spell, priority in pairs(value) do
            if priority > 0 then
                if not debuffList[instName] then
                    debuffList[instName] = {}
                end
                debuffList[instName][spell] = priority
            end
        end
    end
end

local function buttonOnEnter(self)
    if not self.index then
        return
    end
    _G.GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
    _G.GameTooltip:ClearLines()
    _G.GameTooltip:SetUnitAura(self.__owner.unit, self.index, self.filter)
    _G.GameTooltip:Show()
end

function UNITFRAME:AddRaidDebuffs(self)
    local bu = CreateFrame('Frame', nil, self)
    bu:Size(self:GetHeight() * .5)
    bu:SetPoint('CENTER')
    bu:SetFrameLevel(self.Health:GetFrameLevel() + 2)
    bu.bg = F.CreateBDFrame(bu)
    bu.shadow = F.CreateSD(bu.bg)
    if bu.shadow then
        bu.shadow:SetFrameLevel(bu:GetFrameLevel() - 1)
    end
    bu:Hide()

    bu.icon = bu:CreateTexture(nil, 'ARTWORK')
    bu.icon:SetAllPoints()
    bu.icon:SetTexCoord(unpack(C.TexCoord))

    local parentFrame = CreateFrame('Frame', nil, bu)
    parentFrame:SetAllPoints()
    parentFrame:SetFrameLevel(bu:GetFrameLevel() + 6)

    bu.count = F.CreateFS(parentFrame, C.Assets.Fonts.Square, 11, nil, '', nil, true, 'TOPRIGHT', 2, 4)
    bu.timer = F.CreateFS(bu, C.Assets.Fonts.Square, 11, nil, '', nil, true, 'BOTTOMLEFT', 2, -4)

    bu.glowFrame = F.CreateGlowFrame(bu, bu:GetHeight())

    if not C.DB.unitframe.auras_click_through then
        bu:SetScript('OnEnter', buttonOnEnter)
        bu:SetScript('OnLeave', F.HideTooltip)
    end

    bu.ShowDispellableDebuff = true
    bu.ShowDebuffBorder = true
    bu.FilterDispellableDebuff = true

    if C.DB.unitframe.instance_auras then
        if not next(debuffList) then
            UNITFRAME:UpdateRaidDebuffs()
        end

        bu.Debuffs = debuffList
    end

    self.RaidDebuffs = bu
end

--[[ Castbar ]]

local channelingTicks = {
    [740] = 4, -- 宁静
    [755] = 5, -- 生命通道
    [5143] = 4, -- 奥术飞弹
    [12051] = 6, -- 唤醒
    [15407] = 6, -- 精神鞭笞
    [47757] = 3, -- 苦修
    [47758] = 3, -- 苦修
    [48045] = 6, -- 精神灼烧
    [64843] = 4, -- 神圣赞美诗
    [120360] = 15, -- 弹幕射击
    [198013] = 10, -- 眼棱
    [198590] = 5, -- 吸取灵魂
    [205021] = 5, -- 冰霜射线
    [205065] = 6, -- 虚空洪流
    [206931] = 3, -- 饮血者
    [212084] = 10, -- 邪能毁灭
    [234153] = 5, -- 吸取生命
    [257044] = 7, -- 急速射击
    [291944] = 6, -- 再生，赞达拉巨魔
    [314791] = 4, -- 变易幻能
    [324631] = 8, -- 血肉铸造，盟约
}

if C.MyClass == 'PRIEST' then
    local function updateTicks()
        local numTicks = 3
        if IsPlayerSpell(193134) then
            numTicks = 4
        end
        channelingTicks[47757] = numTicks
        channelingTicks[47758] = numTicks
    end
    F:RegisterEvent('PLAYER_LOGIN', updateTicks)
    F:RegisterEvent('PLAYER_TALENT_UPDATE', updateTicks)
end

local ticks = {}
local function updateCastBarTicks(bar, numTicks)
    if numTicks and numTicks > 0 then
        local delta = bar:GetWidth() / numTicks
        for i = 1, numTicks do
            if not ticks[i] then
                ticks[i] = bar:CreateTexture(nil, 'OVERLAY')
                ticks[i]:SetTexture(C.Assets.bd_tex)
                ticks[i]:SetVertexColor(0, 0, 0, .85)
                ticks[i]:SetWidth(C.Mult)
                ticks[i]:SetHeight(bar:GetHeight())
            end
            ticks[i]:ClearAllPoints()
            ticks[i]:SetPoint('CENTER', bar, 'LEFT', delta * i, 0)
            ticks[i]:Show()
        end
    else
        for _, tick in pairs(ticks) do
            tick:Hide()
        end
    end
end

function UNITFRAME:OnCastbarUpdate(elapsed)
    if self.casting or self.channeling then
        local decimal = self.Decimal

        local duration = self.casting and self.duration + elapsed or self.duration - elapsed
        if (self.casting and duration >= self.max) or (self.channeling and duration <= 0) then
            self.casting = nil
            self.channeling = nil
            return
        end

        if self.__owner.unit == 'player' then
            if self.delay ~= 0 then
                self.Time:SetFormattedText(decimal .. ' | |cffff0000' .. decimal, duration,
                                           self.casting and self.max + self.delay or self.max - self.delay)
            else
                self.Time:SetFormattedText(decimal .. ' | ' .. decimal, duration, self.max)
                if self.Lag and self.SafeZone and self.SafeZone.timeDiff and self.SafeZone.timeDiff ~= 0 then
                    self.Lag:SetFormattedText('%d ms', self.SafeZone.timeDiff * 1000)
                end
            end
        else
            if duration > 1e4 then
                self.Time:SetText('∞ | ∞')
            else
                self.Time:SetFormattedText(decimal .. ' | ' .. decimal, duration,
                                           self.casting and self.max + self.delay or self.max - self.delay)
            end
        end
        self.duration = duration
        self:SetValue(duration)
        self.Spark:SetPoint('CENTER', self, 'LEFT', (duration / self.max) * self:GetWidth(), 0)
    elseif self.holdTime > 0 then
        self.holdTime = self.holdTime - elapsed
    else
        self.Spark:Hide()
        local alpha = self:GetAlpha() - .02
        if alpha > 0 then
            self:SetAlpha(alpha)
        else
            self.fadeOut = nil
            self:Hide()
        end
    end
end

function UNITFRAME:OnCastSent()
    local element = self.Castbar
    if not element.SafeZone then
        return
    end
    element.SafeZone.sendTime = GetTime()
    element.SafeZone.castSent = true
end

local function updateSpellTarget(self, unit)
    if not C.DB.Nameplate.SpellTarget then
        return
    end

    if not self.spellTarget or not unit then
        return
    end

    local unitTarget = unit .. 'target'
    if UnitExists(unitTarget) then
        local nameString
        if UnitIsUnit(unitTarget, 'player') then
            nameString = format('|cffff0000%s|r', '>' .. strupper(YOU) .. '<')
        else
            nameString = F:RGBToHex(F:UnitColor(unitTarget)) .. UnitName(unitTarget)
        end
        self.spellTarget:SetText(nameString)
    end
end

local function resetSpellTarget(self)
    if self.spellTarget then
        self.spellTarget:SetText('')
    end
end

function UNITFRAME:PostCastStart(unit)
    local compact = C.DB.unitframe.CastbarCompact
    local normalColor = C.DB.unitframe.CastbarCastingColor
    local uninterruptibleColor = C.DB.unitframe.CastbarUninterruptibleColor
    local color = self.notInterruptible and uninterruptibleColor or normalColor
    local textColor = self.notInterruptible and {1, 0, 0} or {1, 1, 1}

    -- F:Debug(self.name)
    -- F:Debug(self.spellID)

    self:SetAlpha(1)
    self.Spark:Show()

    if unit == 'vehicle' or UnitInVehicle('player') then
        if self.SafeZone then
            self.SafeZone:Hide()
        end
        if self.Lag then
            self.Lag:Hide()
        end
    elseif unit == 'player' then
        local safeZone = self.SafeZone
        if not safeZone then
            return
        end

        safeZone.timeDiff = 0
        if safeZone.castSent then
            safeZone.timeDiff = GetTime() - safeZone.sendTime
            safeZone.timeDiff = safeZone.timeDiff > self.max and self.max or safeZone.timeDiff
            safeZone:SetWidth(self:GetWidth() * (safeZone.timeDiff + .001) / self.max)
            safeZone:Show()
            safeZone.castSent = false
        end

        local numTicks = 0
        if self.channeling then
            numTicks = channelingTicks[self.spellID] or 0
        end
        updateCastBarTicks(self, numTicks)

    end

    if compact then
        self:SetStatusBarColor(color.r, color.g, color.b, .6)
        self.Backdrop:SetBackdropColor(0, 0, 0, .2)
        self.Backdrop:SetBackdropBorderColor(0, 0, 0, 0)
        self.Border:SetBackdropBorderColor(color.r, color.g, color.b, .6)
    else
        self:SetStatusBarColor(color.r, color.g, color.b, 1)
        self.Backdrop:SetBackdropColor(0, 0, 0, .6)
        self.Backdrop:SetBackdropBorderColor(0, 0, 0, 1)
        self.Border:SetBackdropBorderColor(color.r, color.g, color.b, .35)
    end

    self.Text:SetTextColor(unpack(textColor))

    if self.__owner.unitStyle == 'nameplate' then
        -- Major spells
        if C.DB.Nameplate.MajorSpellsGlow and NAMEPLATE.MajorSpellsList[self.spellID] then
            F.ShowOverlayGlow(self.glowFrame)
        else
            F.HideOverlayGlow(self.glowFrame)
        end

        -- Spell target
        updateSpellTarget(self, unit)
    end


end

function UNITFRAME:PostCastUpdate(unit)
    updateSpellTarget(self, unit)
end

function UNITFRAME:PostUpdateInterruptible()
    local compact = C.DB.unitframe.CastbarCompact
    local normalColor = C.DB.unitframe.CastbarCastingColor
    local uninterruptibleColor = C.DB.unitframe.CastbarUninterruptibleColor
    local color = self.notInterruptible and uninterruptibleColor or normalColor
    local textColor = self.notInterruptible and {1, 0, 0} or {1, 1, 1}

    if compact then
        self:SetStatusBarColor(color.r, color.g, color.b, .6)
        self.Backdrop:SetBackdropColor(0, 0, 0, .2)
        self.Backdrop:SetBackdropBorderColor(0, 0, 0, 0)
        self.Border:SetBackdropBorderColor(color.r, color.g, color.b, .6)
    else
        self:SetStatusBarColor(color.r, color.g, color.b, 1)
        self.Backdrop:SetBackdropColor(0, 0, 0, .6)
        self.Backdrop:SetBackdropBorderColor(0, 0, 0, 1)
        self.Border:SetBackdropBorderColor(color.r, color.g, color.b, .35)
    end

    self.Text:SetTextColor(unpack(textColor))
end

function UNITFRAME:PostCastStop()
    local color = C.DB.unitframe.CastbarCompleteColor

    if not self.fadeOut then
        self:SetStatusBarColor(color.r, color.g, color.b)
        self.fadeOut = true
    end

    self:Show()

    resetSpellTarget(self)
end

function UNITFRAME:PostCastFailed()
    local color = C.DB.unitframe.CastbarFailColor

    self:SetStatusBarColor(color.r, color.g, color.b)
    self:SetValue(self.max)
    self.fadeOut = true
    self:Show()

    resetSpellTarget(self)
end

local function CreateBarMover(bar, text, value, anchor)
    local mover = F.Mover(bar, text, value, anchor, bar:GetHeight() + bar:GetWidth() + 3, bar:GetHeight() + 3)
    bar:ClearAllPoints()
    bar:SetPoint('CENTER', mover)
    bar.mover = mover
end

local cbPosition = {
    player = {'CENTER', _G.UIParent, 'CENTER', 0, -280},
    target = {'LEFT', _G.UIParent, 'CENTER', 113, -152},
    focus = {'CENTER', _G.UIParent, 'CENTER', 0, 120},
}

function UNITFRAME:AddCastBar(self)
    if not C.DB.unitframe.EnableCastbar then
        return
    end

    local style = self.unitStyle
    local compact = C.DB.unitframe.CastbarCompact
    local playerWidth = C.DB.unitframe.CastbarPlayerWidth
    local playerHeight = C.DB.unitframe.CastbarPlayerHeight
    local targetWidth = C.DB.unitframe.CastbarTargetWidth
    local targetHeight = C.DB.unitframe.CastbarTargetHeight
    local focusWidth = C.DB.unitframe.CastbarFocusWidth
    local focusHeight = C.DB.unitframe.CastbarFocusHeight
    local outline = C.DB.unitframe.FontOutline
    local font = C.Assets.Fonts.Condensed
    local color = C.DB.unitframe.CastbarCastingColor

    local castbar = CreateFrame('StatusBar', 'oUF_Castbar' .. style, self)
    castbar:SetStatusBarTexture(C.Assets.statusbar_tex)

    castbar.Backdrop = F.CreateBDFrame(castbar)
    castbar.Border = F.CreateSD(castbar.Backdrop, .35, 6, 6, true)

    local spark = castbar:CreateTexture(nil, 'OVERLAY')
    spark:SetTexture(C.Assets.spark_tex)
    spark:SetBlendMode('ADD')
    spark:SetAlpha(.7)
    spark:SetSize(12, castbar:GetHeight() * 2)
    castbar.Spark = spark

    local text = F.CreateFS(castbar, font, 11, outline, '', nil, outline or 'THICK')
    text:SetPoint('TOP', castbar, 'BOTTOM', 0, -3)
    text:SetShown(C.DB.unitframe.CastbarSpellName)
    text:SetTextColor(1, 1, 1)
    castbar.Text = text

    local time = F.CreateFS(castbar, font, 11, outline, '', nil, outline or 'THICK')
    time:SetPoint('CENTER', castbar)
    time:SetShown(C.DB.unitframe.CastbarSpellTime)
    castbar.Time = time
    castbar.Decimal = '%.1f'

    local icon = castbar:CreateTexture(nil, 'ARTWORK')
    icon:SetTexCoord(unpack(C.TexCoord))
    F.SetBD(icon)
    castbar.Icon = icon

    if compact then
        castbar:SetStatusBarColor(0, 0, 0, 0)
        castbar:SetAllPoints(self)
        castbar:SetFrameLevel(self.Health:GetFrameLevel() + 3)
        castbar:SetStatusBarColor(color.r, color.g, color.b, .6)
        castbar.Backdrop:SetBackdropColor(0, 0, 0, 0)
        castbar.Border:SetBackdropBorderColor(color.r, color.g, color.b, .45)

        icon:SetSize(self:GetHeight() + 6, self:GetHeight() + 6)
        icon:SetPoint('RIGHT', castbar, 'LEFT', -4, 0)
    else
        if style == 'player' then
            castbar:SetSize(playerWidth, playerHeight)
            CreateBarMover(castbar, L.MOVER.PLAYER_CASTBAR, 'PlayerCastbar', cbPosition.player)

            icon:SetSize(castbar:GetHeight() + 8, castbar:GetHeight() + 8)
            icon:SetPoint('RIGHT', castbar, 'LEFT', -4, 0)
        elseif style == 'target' then
            castbar:SetSize(targetWidth, targetHeight)
            CreateBarMover(castbar, L.MOVER.TARGET_CASTBAR, 'TargetCastbar', cbPosition.target)

            icon:SetSize(castbar:GetHeight() + 8, castbar:GetHeight() + 8)
            icon:SetPoint('RIGHT', castbar, 'LEFT', -4, 0)
        elseif style == 'focus' then
            castbar:SetSize(focusWidth, focusHeight)
            CreateBarMover(castbar, L.MOVER.FOCUS_CASTBAR, 'FocusCastbar', cbPosition.focus)

            icon:SetSize(castbar:GetHeight() + 8, castbar:GetHeight() + 8)
            icon:SetPoint('RIGHT', castbar, 'LEFT', -4, 0)
        elseif style == 'nameplate' then
            castbar:SetSize(self:GetWidth(), 4)
            castbar:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -2)

            icon:SetSize(castbar:GetHeight() + self:GetHeight() + 2, castbar:GetHeight() + self:GetHeight() + 2)
            icon:ClearAllPoints()
            icon:SetPoint('TOPRIGHT', self, 'TOPLEFT', -2, 0)
        end

        castbar:SetStatusBarColor(color.r, color.g, color.b)
    end

    if style == 'player' then
        local safeZone = castbar:CreateTexture(nil, 'OVERLAY')
        safeZone:SetTexture(C.Assets.statusbar_tex)
        safeZone:SetVertexColor(.87, .25, .42, .6)
        safeZone:SetPoint('TOPRIGHT')
        safeZone:SetPoint('BOTTOMRIGHT')
        castbar.SafeZone = safeZone
    elseif style == 'nameplate' then
        castbar.glowFrame = F.CreateGlowFrame(castbar, icon:GetHeight())
        castbar.glowFrame:SetPoint('CENTER', castbar.Icon)

        local spellTarget = F.CreateFS(castbar, font, 11, outline, '', nil, outline or 'THICK')
        spellTarget:ClearAllPoints()
        spellTarget:SetJustifyH('CENTER')
        spellTarget:SetPoint('TOP', self, 'BOTTOM', 0, -3)
        castbar.spellTarget = spellTarget
    end

    self.Castbar = castbar

    castbar.OnUpdate = UNITFRAME.OnCastbarUpdate
    castbar.PostCastStart = UNITFRAME.PostCastStart
    castbar.PostCastUpdate = UNITFRAME.PostCastUpdate
    castbar.PostCastStop = UNITFRAME.PostCastStop
    castbar.PostCastFail = UNITFRAME.PostCastFailed
    castbar.PostCastInterruptible = UNITFRAME.PostUpdateInterruptible
end

--[[ Class power ]]

-- LuaFormatter off
local fullyChargedColors = {
    DRUID = {.78, .48, .96},
    MAGE = {.87, .14, .24},
    MONK = {.87, .14, .24},
    PALADIN = {.87, .14, .24},
    ROGUE = {.78, .48, .96},
    WARLOCK = {.87, .14, .24},
}
-- LuaFormatter on

local function PostUpdateClassPower(element, cur, max, diff, powerType)
    -- local style = element.__owner.unitStyle
    local gap = 3
    local maxWidth = C.DB.unitframe.player_width

    if diff then
        for i = 1, max do
            element[i]:SetWidth((maxWidth - (max - 1) * gap) / max)
        end
    end

    element.thisColor = cur == max and 1 or 2
    if not element.prevColor or element.prevColor ~= element.thisColor then
        local r, g, b = fullyChargedColors[C.MyClass] and unpack(fullyChargedColors[C.MyClass]) or 1, 0, 0
        if element.thisColor == 2 then
            local color = element.__owner.colors.power[powerType]
            r, g, b = color[1], color[2], color[3]
        end
        for i = 1, #element do
            element[i]:SetStatusBarColor(r, g, b)
        end

        element.prevColor = element.thisColor
    end
end

function UNITFRAME:OnUpdateRunes(elapsed)
    local duration = self.duration + elapsed
    self.duration = duration
    self:SetValue(duration)

    if self.timer then
        local remain = self.runeDuration - duration
        if remain > 0 then
            self.timer:SetText(F:FormatTime(remain))
        else
            self.timer:SetText(nil)
        end
    end
end

local function PostUpdateRunes(element, runemap)
    for index, runeID in next, runemap do
        local rune = element[index]
        local start, duration, runeReady = GetRuneCooldown(runeID)
        if rune:IsShown() then
            if runeReady then
                rune:SetAlpha(1)
                rune:SetScript('OnUpdate', nil)
                if rune.timer then
                    rune.timer:SetText(nil)
                end
            elseif start then
                rune:SetAlpha(.3)
                rune.runeDuration = duration
                rune:SetScript('OnUpdate', UNITFRAME.OnUpdateRunes)
            end
        end
    end
end

local function UpdateRunesColor(element)
    local spec = GetSpecialization() or 0

    for index = 1, #element do
        if spec == 1 then -- blood
            element[index]:SetStatusBarColor(177 / 255, 40 / 255, 45 / 255)
        elseif spec == 2 then -- frost
            element[index]:SetStatusBarColor(42 / 255, 138 / 255, 186 / 255)
        elseif spec == 3 then
            element[index]:SetStatusBarColor(101 / 255, 186 / 255, 112 / 255)
        else
            element[index]:SetStatusBarColor(1, 1, 1)
        end
    end
end

function UNITFRAME:AddClassPowerBar(self)
    if not C.DB.unitframe.class_power_bar then
        return
    end

    local gap = 3
    local barWidth = C.DB.unitframe.player_width
    local barHeight = C.DB.unitframe.class_power_bar_height

    local bars = {}
    for i = 1, 6 do
        bars[i] = CreateFrame('StatusBar', nil, self.ClassPowerBarHolder)
        bars[i]:SetHeight(barHeight)
        bars[i]:SetWidth((barWidth - 5 * gap) / 6)
        bars[i]:SetStatusBarTexture(C.Assets.statusbar_tex)
        bars[i]:SetFrameLevel(self:GetFrameLevel() + 5)

        F.SetBD(bars[i])

        if i == 1 then
            bars[i]:SetPoint('BOTTOMLEFT')
        else
            bars[i]:SetPoint('LEFT', bars[i - 1], 'RIGHT', gap, 0)
        end

        if C.MyClass == 'DEATHKNIGHT' and C.DB.unitframe.runes_timer then
            bars[i].timer = F.CreateFS(bars[i], C.Assets.Fonts.Regular, 11, nil, '')
        end
    end

    if C.MyClass == 'DEATHKNIGHT' then
        bars.colorSpec = true
        bars.sortOrder = 'asc'
        bars.PostUpdate = PostUpdateRunes
        bars.PostUpdateColor = UpdateRunesColor
        self.Runes = bars
    else
        bars.PostUpdate = PostUpdateClassPower
        self.ClassPower = bars
    end
end

--[[ Stagger ]]

function UNITFRAME:AddStagger(self)
    if C.MyClass ~= 'MONK' then
        return
    end
    if not C.DB.unitframe.stagger_bar then
        return
    end

    local stagger = CreateFrame('StatusBar', nil, self.ClassPowerBarHolder)
    stagger:SetAllPoints(self.ClassPowerBarHolder)
    stagger:SetStatusBarTexture(C.Assets.statusbar_tex)

    F.SetBD(stagger)

    local text = F.CreateFS(stagger, C.Assets.Fonts.Regular, 11, nil, '', nil, 'THICK')
    text:SetPoint('TOP', stagger, 'BOTTOM', 0, -4)
    self:Tag(text, '[free:stagger]')

    self.Stagger = stagger
end

--[[ Totems ]]

local totemsColor = {
    {0.71, 0.29, 0.13}, -- red    181 /  73 /  33
    {0.26, 0.71, 0.13}, -- green   67 / 181 /  33
    {0.13, 0.55, 0.71}, -- blue    33 / 141 / 181
    {0.58, 0.13, 0.71}, -- violet 147 /  33 / 181
    {0.71, 0.58, 0.13},
    -- yellow 181 / 147 /  33
}

function UNITFRAME:AddTotems(self)
    if C.MyClass ~= 'SHAMAN' then
        return
    end
    if not C.DB.unitframe.totems_bar then
        return
    end

    local totems = {}
    local maxTotems = 5
    local spacing = 3
    local width

    width = (self:GetWidth() - (maxTotems + 1) * spacing) / maxTotems
    spacing = width + spacing

    for slot = 1, maxTotems do
        local totem = CreateFrame('StatusBar', nil, self.ClassPowerBarHolder)
        local color = totemsColor[slot]
        local r, g, b = color[1], color[2], color[3]
        totem:SetStatusBarTexture(C.Assets.statusbar_tex)
        totem:SetStatusBarColor(r, g, b)
        totem:SetSize(width, C.DB.unitframe.class_power_bar_height)
        F.SetBD(totem)

        totem:SetPoint('TOPLEFT', self.ClassPowerBarHolder, 'TOPLEFT', (slot - 1) * spacing + 1, 0)

        totems[slot] = totem
    end

    self.CustomTotems = totems
end

--[[ Combat fader ]]

function UNITFRAME:AddCombatFader(self)
    if not C.DB.unitframe.fade then
        return
    end

    if not self.Fader then
        self.Fader = {}
    end

    self.Fader.maxAlhpa = C.DB.unitframe.fade_in_alpha
    self.Fader.minAlpha = C.DB.unitframe.fade_out_alpha
    self.Fader.outDuration = C.DB.unitframe.fade_out_duration
    self.Fader.inDuration = C.DB.unitframe.fade_in_duration
    self.Fader.hover = C.DB.unitframe.condition_hover
    self.Fader.arena = C.DB.unitframe.condition_arena
    self.Fader.instance = C.DB.unitframe.condition_instance
    self.Fader.combat = C.DB.unitframe.condition_combat
    self.Fader.target = C.DB.unitframe.condition_target
    self.Fader.casting = C.DB.unitframe.condition_casting
    self.Fader.injured = C.DB.unitframe.condition_injured
    self.Fader.mana = C.DB.unitframe.condition_mana
    self.Fader.power = C.DB.unitframe.condition_power
end

--[[ Range check ]]

function UNITFRAME:AddRangeCheck(self)
    if not C.DB.unitframe.range_check then
        return
    end

    if not self.RangeCheck then
        self.RangeCheck = {}
    end

    self.RangeCheck.enabled = true
    self.RangeCheck.insideAlpha = 1
    self.RangeCheck.outsideAlpha = 0.4
end

--[[ Indicatiors ]]

function UNITFRAME:UpdateGCDIndicator()
    local start, duration = GetSpellCooldown(61304)
    if start > 0 and duration > 0 then
        if self.duration ~= duration then
            self:SetMinMaxValues(0, duration)
            self.duration = duration
        end
        self:SetValue(GetTime() - start)
        self.spark:Show()
    else
        self.spark:Hide()
    end
end

function UNITFRAME:ToggleGCDIndicator()
    local frame = _G.oUF_Player
    local ticker = frame and frame.GCDIndicator
    if not ticker then
        return
    end

    ticker:SetShown(C.DB.unitframe.GCDIndicator)
end

function UNITFRAME:AddGCDIndicator(self)
    local ticker = CreateFrame('StatusBar', nil, self)
    ticker:SetFrameLevel(self.Health:GetFrameLevel() + 4)
    ticker:SetStatusBarTexture(C.Assets.norm_tex)
    ticker:GetStatusBarTexture():SetAlpha(0)
    ticker:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0, 0)
    ticker:SetWidth(self:GetWidth())
    ticker:SetHeight(6)

    local spark = ticker:CreateTexture(nil, 'OVERLAY')
    spark:SetTexture(C.Assets.spark_tex)
    spark:SetBlendMode('ADD')
    spark:SetPoint('TOPLEFT', ticker:GetStatusBarTexture(), 'TOPRIGHT', -3, 3)
    spark:SetPoint('BOTTOMRIGHT', ticker:GetStatusBarTexture(), 'BOTTOMRIGHT', 3, -3)

    ticker.spark = spark

    ticker:SetScript('OnUpdate', UNITFRAME.UpdateGCDIndicator)
    self.GCDIndicator = ticker

    UNITFRAME:ToggleGCDIndicator()
end

function UNITFRAME:AddPvPIndicator(self) -- Deprecated
    if not C.DB.unitframe.player_pvp_indicator then
        return
    end

    local outline = C.DB.unitframe.FontOutline
    local font = C.Assets.Fonts.Condensed

    local PvPIndicator = F.CreateFS(self, font, 11, outline, '', nil, outline or 'THICK')
    PvPIndicator:SetPoint('BOTTOMLEFT', self.HealthValue, 'BOTTOMRIGHT', 5, 0)

    PvPIndicator.SetTexture = F.Dummy
    PvPIndicator.SetTexCoord = F.Dummy

    self.PvPIndicator = PvPIndicator
end

local function CombatIndicatorPostUpdate(self, inCombat)
    local isResting = IsResting()
    if inCombat then
        self.__owner.RestingIndicator:Hide()
    elseif isResting then
        self.__owner.RestingIndicator:Show()
    end
end

function UNITFRAME:AddCombatIndicator(self)
    if not C.DB.unitframe.player_combat_indicator then
        return
    end

    local combatIndicator = self:CreateTexture(nil, 'OVERLAY')
    combatIndicator:SetPoint('BOTTOMLEFT', self, 'TOPLEFT')
    combatIndicator:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT')
    combatIndicator:SetHeight(6)
    combatIndicator:SetTexture(C.Assets.glow_tex)
    combatIndicator:SetVertexColor(1, 0, 0, .25)

    self.CombatIndicator = combatIndicator
    self.CombatIndicator.PostUpdate = CombatIndicatorPostUpdate
end

function UNITFRAME:AddRestingIndicator(self)
    if not C.DB.unitframe.player_resting_indicator then
        return
    end

    local restingIndicator = self:CreateTexture(nil, 'OVERLAY')
    restingIndicator:SetPoint('BOTTOMLEFT', self, 'TOPLEFT')
    restingIndicator:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT')
    restingIndicator:SetHeight(6)
    restingIndicator:SetTexture(C.Assets.glow_tex)
    restingIndicator:SetVertexColor(0, 1, 0, .25)

    self.RestingIndicator = restingIndicator
end

function UNITFRAME:AddEmergencyIndicator(self)
    local emergencyIndicator = self:CreateTexture(nil, 'OVERLAY')
    emergencyIndicator:SetPoint('TOPLEFT', self, 'BOTTOMLEFT')
    emergencyIndicator:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT')
    emergencyIndicator:SetHeight(10)
    emergencyIndicator:SetTexture(C.Assets.glow_tex)
    emergencyIndicator:SetRotation(rad(180))
    emergencyIndicator:SetVertexColor(1, 0, 0, .45)
    emergencyIndicator:Hide()

    self.EmergencyIndicator = emergencyIndicator
end

function UNITFRAME:UpdateRaidTargetIndicator()
    local style = self.unitStyle
    local raidTarget = self.RaidTargetIndicator
    local nameOnlyName = self.nameOnlyName
    local title = self.npcTitle
    local isNameOnly = self.isNameOnly
    local size = C.DB.unitframe.RaidTargetIndicatorSize
    local alpha = C.DB.unitframe.RaidTargetIndicatorAlpha
    local npSize = C.DB.Nameplate.RaidTargetIndicatorSize
    local npAlpha = C.DB.Nameplate.RaidTargetIndicatorAlpha

    if style == 'nameplate' then
        if isNameOnly then
            raidTarget:SetParent(self)
            raidTarget:ClearAllPoints()
            raidTarget:SetPoint('TOP', title or nameOnlyName, 'BOTTOM')
        else
            raidTarget:SetParent(self.Health)
            raidTarget:ClearAllPoints()
            raidTarget:SetPoint('CENTER')
        end

        raidTarget:SetAlpha(npAlpha)
        raidTarget:SetSize(npSize, npSize)
    else
        raidTarget:SetPoint('CENTER')
        raidTarget:SetAlpha(alpha)
        raidTarget:SetSize(size, size)
    end
end

function UNITFRAME:AddRaidTargetIndicator(self)
    local icon = self.Health:CreateTexture(nil, 'OVERLAY')
    icon:SetPoint('CENTER')
    icon:SetAlpha(1)
    icon:SetSize(24, 24)
    icon:SetTexture(C.Assets.target_icon)

    self.RaidTargetIndicator = icon

    UNITFRAME.UpdateRaidTargetIndicator(self)
end

function UNITFRAME:AddReadyCheckIndicator(self)
    local readyCheckIndicator = self.Health:CreateTexture(nil, 'OVERLAY')
    readyCheckIndicator:SetPoint('CENTER', self.Health)
    readyCheckIndicator:SetSize(16, 16)
    self.ReadyCheckIndicator = readyCheckIndicator
end

local function updateGroupRoleIndicator(self, event)
    local lfdrole = self.GroupRoleIndicator
    local role = UnitGroupRolesAssigned(self.unit)

    if role == 'DAMAGER' then
        lfdrole:SetTextColor(.8, .2, .1, 1)
        lfdrole:SetText('*')
    elseif role == 'TANK' then
        lfdrole:SetTextColor(.9, .8, .2, 1)
        lfdrole:SetText('#')
    elseif role == 'HEALER' then
        lfdrole:SetTextColor(0, 1, 0, 1)
        lfdrole:SetText('+')
    else
        lfdrole:SetTextColor(0, 0, 0, 0)
    end
end

function UNITFRAME:AddGroupRoleIndicator(self)
    local font = C.Assets.Fonts.Pixel

    local groupRoleIndicator = F.CreateFS(self.Health, font, 8, 'OUTLINE, MONOCHROME')
    groupRoleIndicator:SetPoint('BOTTOM', 1, 1)
    groupRoleIndicator.Override = updateGroupRoleIndicator
    self.GroupRoleIndicator = groupRoleIndicator
end

function UNITFRAME:AddLeaderIndicator(self)
    local font = C.Assets.Fonts.Pixel

    local leaderIndicator = F.CreateFS(self.Health, font, 8, 'OUTLINE, MONOCHROME', '!')
    leaderIndicator:SetPoint('TOPLEFT', 2, -2)
    self.LeaderIndicator = leaderIndicator
end

function UNITFRAME:AddPhaseIndicator(self)
    local phase = CreateFrame('Frame', nil, self)
    phase:SetSize(16, 16)
    phase:SetPoint('CENTER', self)
    phase:SetFrameLevel(5)
    phase:EnableMouse(true)
    local icon = phase:CreateTexture(nil, 'OVERLAY')
    icon:SetAllPoints()
    phase.Icon = icon
    self.PhaseIndicator = phase
end

function UNITFRAME:AddSummonIndicator(self)
    local summonIndicator = self.Health:CreateTexture(nil, 'OVERLAY')
    summonIndicator:SetSize(self:GetHeight() * .8, self:GetHeight() * .8)
    summonIndicator:SetPoint('CENTER')

    self.SummonIndicator = summonIndicator
end

function UNITFRAME:AddResurrectIndicator(self)
    local resurrectIndicator = self.Health:CreateTexture(nil, 'OVERLAY')
    resurrectIndicator:SetSize(self:GetHeight() * .8, self:GetHeight() * .8)
    resurrectIndicator:SetPoint('CENTER')

    self.ResurrectIndicator = resurrectIndicator
end

--[[ Threat ]]

local function UpdateThreat(self, event, unit)
    if not self.Glow or self.unit ~= unit then
        return
    end

    local status = UnitThreatSituation(unit)
    if status and status > 0 then
        local r, g, b = GetThreatStatusColor(status)
        self.Glow:SetBackdropBorderColor(r, g, b, .6)
    else
        self.Glow:SetBackdropBorderColor(0, 0, 0, .35)
    end
end

function UNITFRAME:AddThreatIndicator(self)
    if not C.DB.unitframe.group_threat_indicator then
        return
    end

    self.ThreatIndicator = {
        IsObjectType = function()
        end,
        Override = UpdateThreat,
    }
end

--[[ Portrait ]]

local function PostUpdatePortrait(element)
    if C.DB.unitframe.portrait_saturation then
        return
    end
    element:SetDesaturation(1)
end

function UNITFRAME:AddPortrait(self)
    if not C.DB.unitframe.portrait then
        return
    end

    local portrait = CreateFrame('PlayerModel', nil, self)
    portrait:SetAllPoints(self)
    portrait:SetFrameLevel(self.Health:GetFrameLevel() + 2)
    portrait:SetAlpha(.1)
    portrait.PostUpdate = PostUpdatePortrait
    self.Portrait = portrait
end

--[[ Party spells ]]

UNITFRAME.PartySpellsList = {}
function UNITFRAME:UpdatePartyWatcherSpells()
    wipe(UNITFRAME.PartySpellsList)

    for spellID, duration in pairs(C.PartySpellsList) do
        local name = GetSpellInfo(spellID)
        if name then
            local modDuration = _G.FREE_ADB['PartySpellsList'][spellID]
            if not modDuration or modDuration > 0 then
                UNITFRAME.PartySpellsList[spellID] = duration
            end
        end
    end

    for spellID, duration in pairs(_G.FREE_ADB['PartySpellsList']) do
        if duration > 0 then
            UNITFRAME.PartySpellsList[spellID] = duration
        end
    end
end

local watchingList = {}
function UNITFRAME:PartyWatcherPostUpdate(button, unit, spellID)
    local guid = UnitGUID(unit)
    if not watchingList[guid] then
        watchingList[guid] = {}
    end
    watchingList[guid][spellID] = button
end

function UNITFRAME:HandleCDMessage(...)
    local prefix, msg = ...
    if prefix ~= 'ZenTracker' then
        return
    end

    local _, msgType, guid, spellID, duration, remaining = split(':', msg)
    if msgType == 'U' then
        spellID = tonumber(spellID)
        duration = tonumber(duration)
        remaining = tonumber(remaining)
        local button = watchingList[guid] and watchingList[guid][spellID]
        if button then
            local start = GetTime() + remaining - duration
            if start > 0 and duration > 1.5 then
                button.CD:SetCooldown(start, duration)
            end
        end
    end
end

local lastUpdate = 0
function UNITFRAME:SendCDMessage()
    local thisTime = GetTime()
    if thisTime - lastUpdate >= 5 then
        local value = watchingList[UNITFRAME.myGUID]
        if value then
            for spellID in pairs(value) do
                local start, duration, enabled = GetSpellCooldown(spellID)
                if enabled ~= 0 and start ~= 0 then
                    local remaining = start + duration - thisTime
                    if remaining < 0 then
                        remaining = 0
                    end
                    C_ChatInfo_SendAddonMessage('ZenTracker', format('3:U:%s:%d:%.2f:%.2f:%s', UNITFRAME.myGUID,
                                                                     spellID, duration, remaining, '-'),
                                                IsPartyLFG() and 'INSTANCE_CHAT' or 'PARTY')
                    -- sync to others
                end
            end
        end
        lastUpdate = thisTime
    end
end

local lastSyncTime = 0
function UNITFRAME:UpdateSyncStatus()
    if IsInGroup() and not IsInRaid() and C.DB.unitframe.party_spell_sync then
        local thisTime = GetTime()
        if thisTime - lastSyncTime > 5 then
            C_ChatInfo_SendAddonMessage('ZenTracker', format('3:H:%s:0::0:1', UNITFRAME.myGUID),
                                        IsPartyLFG() and 'INSTANCE_CHAT' or 'PARTY')
            -- handshake to ZenTracker
            lastSyncTime = thisTime
        end
        F:RegisterEvent('SPELL_UPDATE_COOLDOWN', UNITFRAME.SendCDMessage)
    else
        F:UnregisterEvent('SPELL_UPDATE_COOLDOWN', UNITFRAME.SendCDMessage)
    end
end

function UNITFRAME:SyncWithZenTracker()
    if not C.DB.unitframe.party_spell_sync then
        return
    end

    UNITFRAME.myGUID = UnitGUID('player')
    C_ChatInfo_RegisterAddonMessagePrefix('ZenTracker')
    F:RegisterEvent('CHAT_MSG_ADDON', UNITFRAME.HandleCDMessage)

    UNITFRAME:UpdateSyncStatus()
    F:RegisterEvent('GROUP_ROSTER_UPDATE', UNITFRAME.UpdateSyncStatus)
end

function UNITFRAME:AddPartySpells(self)
    if not C.DB.unitframe.party_spell_watcher then
        return
    end

    local buttons = {}
    local maxIcons = 4
    local iconSize = C.DB.unitframe.party_height * .7

    for i = 1, maxIcons do
        local bu = CreateFrame('Frame', nil, self)
        bu:SetSize(iconSize, iconSize)
        F.AuraIcon(bu)
        bu.CD:SetReverse(false)
        if i == 1 then
            bu:SetPoint('RIGHT', self, 'LEFT', -5, 0)
        else
            bu:SetPoint('RIGHT', buttons[i - 1], 'LEFT', -4, 0)
        end
        bu:Hide()

        buttons[i] = bu
    end

    buttons.__max = maxIcons
    buttons.PartySpells = UNITFRAME.PartySpellsList
    buttons.TalentCDFix = C.TalentCDFixList
    self.PartyWatcher = buttons
    if C.DB.unitframe.party_spell_sync then
        self.PartyWatcher.PostUpdate = UNITFRAME.PartyWatcherPostUpdate
    end
end

--[[ Tags ]]

function UNITFRAME:AddGroupNameText(self)
    local outline = C.DB.unitframe.FontOutline
    local font = C.Assets.Fonts.Condensed

    local groupName = F.CreateFS(self.Health, font, 11, outline, nil, nil, outline or 'THICK')

    self:Tag(groupName, '[free:groupname][free:offline][free:dead]')
    self.GroupName = groupName
end

function UNITFRAME:AddNameText(self)
    local style = self.unitStyle
    local outline = C.DB.unitframe.FontOutline
    local font = C.Assets.Fonts.Condensed

    local name = F.CreateFS(self.Health, font, 11, outline, nil, nil, outline or 'THICK')

    if style == 'target' then
        name:SetJustifyH('RIGHT')
        name:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', 0, 3)
    elseif style == 'arena' or style == 'boss' then
        name:SetJustifyH('LEFT')
        name:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0, 3)
    elseif style == 'nameplate' then
        name:SetJustifyH('CENTER')
        name:SetPoint('BOTTOM', self, 'TOP', 0, -3)
    else
        name:SetJustifyH('CENTER')
        name:SetPoint('BOTTOM', self, 'TOP', 0, 3)
    end

    self:Tag(name, '[free:name] [arenaspec]')
    self.Name = name
end

function UNITFRAME:AddHealthValueText(self)
    local style = self.unitStyle
    local outline = C.DB.unitframe.FontOutline
    local font = C.Assets.Fonts.Condensed

    local healthValue = F.CreateFS(self.Health, font, 11, outline, nil, nil, outline or 'THICK')
    healthValue:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0, 3)

    if style == 'player' or style == 'playerplate' then
        self:Tag(healthValue, '[free:health] [free:pvp]')
    elseif style == 'target' then
        self:Tag(healthValue, '[free:dead][free:offline][free:health] [free:healthpercentage]')
    elseif style == 'boss' then
        healthValue:ClearAllPoints()
        healthValue:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', 0, 3)
        healthValue:SetJustifyH('RIGHT')
        self:Tag(healthValue, '[free:dead][free:health] [free:healthpercentage]')
    elseif style == 'arena' then
        healthValue:ClearAllPoints()
        healthValue:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', 0, 3)
        healthValue:SetJustifyH('RIGHT')
        self:Tag(healthValue, '[free:dead][free:offline][free:health]')
    end

    self.HealthValue = healthValue
end

function UNITFRAME:AddPowerValueText(self)
    local style = self.unitStyle
    local outline = C.DB.unitframe.FontOutline
    local font = C.Assets.Fonts.Condensed

    local powerValue = F.CreateFS(self.Health, font, 11, outline, nil, nil, outline or 'THICK')
    powerValue:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', 0, 3)

    if style == 'target' then
        powerValue:ClearAllPoints()
        powerValue:SetPoint('BOTTOMLEFT', self.HealthValue, 'BOTTOMRIGHT', 4, 0)
    elseif style == 'boss' then
        powerValue:ClearAllPoints()
        powerValue:SetPoint('BOTTOMRIGHT', self.HealthValue, 'BOTTOMLEFT', -4, 0)
    end

    self:Tag(powerValue, '[powercolor][free:power]')
    powerValue.frequentUpdates = true

    self.PowerValue = powerValue
end

function UNITFRAME:AddAlternativePowerValueText(self)
    local style = self.unitStyle
    local outline = C.DB.unitframe.FontOutline
    local font = C.Assets.Fonts.Condensed

    local altPowerValue = F.CreateFS(self.Health, font, 11, outline, nil, nil, outline or 'THICK')

    if style == 'boss' then
        altPowerValue:SetPoint('LEFT', self, 'RIGHT', 2, 0)
    else
        altPowerValue:SetPoint('BOTTOM', self.Health, 'TOP', 0, 3)
    end

    self:Tag(altPowerValue, '[free:altpower]')

    self.AlternativePowerValue = altPowerValue
end
