local F, C, L = unpack(select(2, ...))
local UNITFRAME = F:GetModule('Unitframe')
local oUF = F.Libs.oUF

local colors = oUF.colors
local tags = oUF.Tags
local tagMethods = tags.Methods
local tagEvents = tags.Events
local tagSharedEvents = tags.SharedEvents

local events = {
    healthvalue = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION UNIT_NAME_UPDATE',
    healthperc = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION UNIT_NAME_UPDATE',
    powervalue = 'UNIT_MAXPOWER UNIT_POWER_UPDATE UNIT_CONNECTION UNIT_DISPLAYPOWER',
    altpowerperc = 'UNIT_MAXPOWER UNIT_POWER_UPDATE',
    dead = 'UNIT_HEALTH',
    offline = 'UNIT_HEALTH UNIT_CONNECTION',
    name = 'UNIT_NAME_UPDATE',
    partyname = 'UNIT_NAME_UPDATE',
    raidname = 'UNIT_NAME_UPDATE',
    npname = 'UNIT_NAME_UPDATE',
    tarname = 'UNIT_NAME_UPDATE UNIT_THREAT_SITUATION_UPDATE UNIT_HEALTH',
    color = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_FACTION UNIT_CONNECTION PLAYER_FLAGS_CHANGED',
    nptitle = 'UNIT_NAME_UPDATE',
    grouprole = 'PLAYER_ROLES_ASSIGNED GROUP_ROSTER_UPDATE',
    groupleader = 'PARTY_LEADER_CHANGED GROUP_ROSTER_UPDATE',
    resting = 'PLAYER_UPDATE_RESTING',
    pvp = 'UNIT_FACTION',
    classification = 'UNIT_CLASSIFICATION_CHANGED'
}

local function AbbrName(string, i)
    if string.len(string) > i then
        return string.gsub(string, '%s?(.[\128-\191]*)%S+%s', '%1. ')
    else
        return string
    end
end

local _tags = {
    -- health value
    healthvalue = function(unit)
        if not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit) then
            return
        end

        local cur = UnitHealth(unit)
        local r, g, b = unpack(colors.reaction[UnitReaction(unit, 'player') or 5])

        return string.format('|cff%02x%02x%02x%s|r', r * 255, g * 255, b * 255, F:Numb(cur))
    end,
    -- health perc
    healthperc = function(unit)
        if not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit) then
            return
        end

        local cur, max = UnitHealth(unit), UnitHealthMax(unit)
        local r, g, b = F:ColorGradient(cur / max, unpack(colors.smooth))
        r, g, b = r * 255, g * 255, b * 255

        if cur ~= max then
            return string.format('|cff%02x%02x%02x%d%%|r', r, g, b, math.floor(cur / max * 100 + 0.5))
        end
    end,
    -- power value
    powervalue = function(unit)
        local cur, max = UnitPower(unit), UnitPowerMax(unit)
        if (cur == 0 or max == 0 or not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit)) then
            return
        end

        return F:Numb(cur)
    end,
    -- altpower perc
    altpowerperc = function(unit)
        local cur = UnitPower(unit, _G.ALTERNATE_POWER_INDEX)
        local max = UnitPowerMax(unit, _G.ALTERNATE_POWER_INDEX)

        if max > 0 and not UnitIsDeadOrGhost(unit) then
            return ('%s%%'):format(math.floor(cur / max * 100 + .5))
        end
    end,
    -- dead
    dead = function(unit)
        if UnitIsDeadOrGhost(unit) then
            return '|cffd84343' .. L['Dead']
        end
    end,
    -- offline
    offline = function(unit)
        if not UnitIsConnected(unit) then
            return '|cffcccccc' .. L['Off']
        end
    end,
    -- name
    name = function(unit)
        local shorten = C.DB.Unitframe.ShortenName
        local isParty = (unit:match('party%d?$'))
        local isRaid = (unit:match('raid%d?$'))
        local isBoss = (unit:match('boss%d?$'))
        local str = UnitName(unit)
        local num = GetLocale() == 'zhCN' and 8 or 12
        local newStr = AbbrName(str, num) or str

        if (unit == 'targettarget' and UnitIsUnit('targettarget', 'player')) or (unit == 'focustarget' and UnitIsUnit('focustarget', 'player')) then
            return '<' .. _G.YOU .. '>'
        else
            return shorten and F.ShortenString(newStr, num, true) or str
        end
    end,
    -- party name
    partyname = function(unit)
        local shorten = C.DB.Unitframe.ShortenName
        local str = UnitName(unit)
        local num = GetLocale() == 'zhCN' and 4 or 6

        return shorten and F.ShortenString(str, num) or str
    end,
    -- raid name
    raidname = function(unit)
        local shorten = C.DB.Unitframe.ShortenName
        local str = UnitName(unit)
        local num = GetLocale() == 'zhCN' and 2 or 4

        return shorten and F.ShortenString(str, num) or str
    end,
    -- nameplate name
    npname = function(unit)
        local shorten = C.DB.Unitframe.ShortenName
        local num = C.IsChinese and 8 or 12
        local str = UnitName(unit)
        local newStr = (string.len(str) > num) and string.gsub(str, '%s?(.[\128-\191]*)%S+%s', '%1. ') or str

        return shorten and F.ShortenString(newStr, num, true) or str
    end,
    -- target name
    tarname = function(unit)
        local tarUnit = unit .. 'target'
        if UnitExists(tarUnit) then
            local tarClass = select(2, UnitClass(tarUnit))
            return '<' .. F:RGBToHex(colors.class[tarClass]) .. UnitName(tarUnit) .. '|r>'
        end
    end,
    -- name color
    color = function(unit)
        local class = select(2, UnitClass(unit))
        local reaction = UnitReaction(unit, 'player')
        local isOffline = not UnitIsConnected(unit)
        local isTapped = UnitIsTapDenied(unit)

        if (unit == 'targettarget' and UnitIsUnit('targettarget', 'player')) or (unit == 'focustarget' and UnitIsUnit('focustarget', 'player')) then
            return F:RGBToHex(1, 0, 0)
        elseif isTapped or isOffline then
            return F:RGBToHex(colors.tapped)
        elseif UnitIsPlayer(unit) then
            return F:RGBToHex(colors.class[class])
        elseif reaction then
            return F:RGBToHex(colors.reaction[reaction])
        else
            return F:RGBToHex(1, 1, 1)
        end
    end,
    -- nameplate title (name only mode)
    nptitle = function(unit)
        if UnitIsPlayer(unit) then
            return
        end

        F.ScanTip:SetOwner(_G.UIParent, 'ANCHOR_NONE')
        F.ScanTip:SetUnit(unit)

        local title = _G[string.format('FreeUI_ScanTooltipTextLeft%d', GetCVarBool('colorblindmode') and 3 or 2)]:GetText()
        if title and not string.find(title, '^' .. _G.LEVEL) then
            return title
        end
    end,
    -- group role
    grouprole = function(unit)
        local role = UnitGroupRolesAssigned(unit)

        if role == 'TANK' then
            return '|cffffe934#|r'
        elseif role == 'HEALER' then
            return '|cff2aff3d+|r'
        elseif role == 'DAMAGER' then
            return '|cffff0052*|r'
        end
    end,
    -- group leader
    groupleader = function(unit)
        local isLeader = (UnitInParty(unit) or UnitInRaid(unit)) and UnitIsGroupLeader(unit)

        return isLeader and '|cffffffff!|r'
    end,
    -- player resting
    resting = function(unit)
        if (unit == 'player' and IsResting()) then
            return '|cff2C8D51Zzz|r'
        end
    end,
    -- player PvP
    pvp = function(unit)
        if UnitIsPVP(unit) then
            return '|cffCC3300P|r'
        end
    end,
    classification = function(unit)
        local class, level = UnitClassification(unit), UnitLevel(unit)

        if (class == 'worldboss' or level == -1) then
            return '|cff9D2933' .. _G.BOSS .. '|r'
        elseif (class == 'rare') then
            return '|cffFF99FF' .. _G.RARE .. '|r'
        elseif (class == 'rareelite') then
            return '|cffFF0099' .. _G.RAREELITE .. '|r'
        elseif (class == 'elite') then
            return '|cffCC3300' .. _G.ELITE .. '|r'
        end
    end
}

for tag, func in next, _tags do
    tagMethods['free:' .. tag] = func
    tagEvents['free:' .. tag] = events[tag]
end

function UNITFRAME:CreateGroupLeaderTag(self)
    local font = C.Assets.Fonts.Pixel
    local tag = F.CreateFS(self.Health, font, 8, 'OUTLINE, MONOCHROME')
    tag:SetPoint('TOPLEFT', 2, -2)

    self:Tag(tag, '[free:groupleader]')
    self.GroupLeader = tag
end

function UNITFRAME:CreateGroupRoleTag(self)
    local font = C.Assets.Fonts.Pixel
    local tag = F.CreateFS(self.Health, font, 8, 'OUTLINE, MONOCHROME')
    tag:SetPoint('BOTTOM', 1, 1)

    self:Tag(tag, '[free:grouprole]')
    self.GroupRole = tag
end

function UNITFRAME:CreateGroupNameTag(self)
    local font = C.Assets.Fonts.Condensed
    local outline = _G.FREE_ADB.FontOutline
    local showName = C.DB.Unitframe.GroupShowName
    local tag = F.CreateFS(self.Health, font, 11, outline, nil, nil, outline or 'THICK')

    if showName then
        self:Tag(tag, '[free:color][free:partyname]')
    else
        self:Tag(tag, '[free:color][free:offline][free:dead]')
    end
    self.GroupNameTag = tag
end

function UNITFRAME:CreateNameTag(self)
    local font = C.Assets.Fonts.Condensed
    local style = self.unitStyle
    local isNP = style == 'nameplate'
    local outline = _G.FREE_ADB.FontOutline
    local boldFont = C.Assets.Fonts.Bold

    local tag = F.CreateFS(self.Health, isNP and boldFont or font, 11, outline, nil, nil, outline or 'THICK')

    if style == 'target' then
        tag:SetJustifyH('RIGHT')
        tag:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', 0, 3)
    elseif style == 'arena' or style == 'boss' then
        tag:SetJustifyH('LEFT')
        tag:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0, 3)
    elseif style == 'nameplate' then
        tag:SetJustifyH('CENTER')
        tag:SetPoint('BOTTOM', self, 'TOP', 0, -3)
    else
        tag:SetJustifyH('CENTER')
        tag:SetPoint('BOTTOM', self, 'TOP', 0, 3)
    end

    if style == 'nameplate' then
        self:Tag(tag, '[free:npname]')
    elseif style == 'arena' then
        self:Tag(tag, '[free:color][free:name] [arenaspec]')
    else
        self:Tag(tag, '[free:color][free:name]')
    end

    self.NameTag = tag
end

function UNITFRAME:CreateHealthTag(self)
    local font = C.Assets.Fonts.Condensed
    local style = self.unitStyle
    local outline = _G.FREE_ADB.FontOutline

    local tag = F.CreateFS(self.Health, font, 11, outline, nil, nil, outline or 'THICK')
    tag:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0, 3)

    if style == 'target' then
        self:Tag(tag, '[free:dead][free:offline][free:healthvalue] [free:healthperc]')
    elseif style == 'boss' then
        tag:ClearAllPoints()
        tag:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', 0, 3)
        tag:SetJustifyH('RIGHT')
        self:Tag(tag, '[free:dead][free:healthvalue] [free:healthperc]')
    elseif style == 'arena' then
        tag:ClearAllPoints()
        tag:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', 0, 3)
        tag:SetJustifyH('RIGHT')
        self:Tag(tag, '[free:dead][free:offline][free:healthvalue]')
    end

    self.HealthTag = tag
end

function UNITFRAME:CreateAltPowerTag(self)
    local font = C.Assets.Fonts.Condensed
    local style = self.unitStyle
    local outline = _G.FREE_ADB.FontOutline

    local tag = F.CreateFS(self.Health, font, 11, outline, nil, nil, outline or 'THICK')

    if style == 'boss' then
        tag:SetPoint('LEFT', self, 'RIGHT', 2, 0)
    else
        tag:SetPoint('BOTTOM', self.Health, 'TOP', 0, 3)
    end

    self:Tag(tag, '[free:altpowerperc]')

    self.AltPowerTag = tag
end

local function Player_OnEnter(self)
    self.LeftTag:Show()
    self.RightTag:Show()
    self:UpdateTags()
end

local function Player_OnLeave(self)
    self.LeftTag:Hide()
    self.RightTag:Hide()
end

function UNITFRAME:CreatePlayerTags(self)
    local font = C.Assets.Fonts.Condensed
    local outline = _G.FREE_ADB.FontOutline

    local leftTag = F.CreateFS(self, font, 11, outline, nil, nil, outline or 'THICK')
    leftTag:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0, 3)

    self:Tag(leftTag, '[free:healthvalue] [free:healthperc] [free:dead] [free:pvp] [free:resting]')

    local rightTag = F.CreateFS(self, font, 11, outline, nil, nil, outline or 'THICK')
    rightTag:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', 0, 3)

    self:Tag(rightTag, '[powercolor][free:powervalue]')

    self.LeftTag = leftTag
    self.RightTag = rightTag

    if C.DB.Unitframe.HidePlayerTags then
        self.LeftTag:Hide()
        self.RightTag:Hide()
        self:HookScript('OnEnter', Player_OnEnter)
        self:HookScript('OnLeave', Player_OnLeave)
    end
end
