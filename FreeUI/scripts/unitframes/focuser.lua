local F, C = unpack(select(2, ...))
local module = F:GetModule("unitframe")
local oUF = FreeUI.oUF


function module:Focuser()
	if not C.unitframes.focuser then return end

	local modifier = "shift" -- shift, alt or ctrl
	local mouseButton = "1" -- 1 = left, 2 = right, 3 = middle, 4 and 5 = thumb buttons if there are any
	local pending = {}

	local function SetFocusHotkey(frame)
		if not frame or frame.focuser then return end
		if frame:GetName() and string.match(frame:GetName(), "oUF_NPs") then return end

		if not InCombatLockdown() then
			frame:SetAttribute(modifier.."-type"..mouseButton, "focus")
			frame.focuser = true
			pending[frame] = nil
		else
			pending[frame] = true
		end
	end

	local function CreateFrame_Hook(_, name, _, template)
		if name and template == "SecureUnitButtonTemplate" then
			SetFocusHotkey(_G[name])
		end
	end
	hooksecurefunc("CreateFrame", CreateFrame_Hook)

	-- Keybinding override so that models can be shift/alt/ctrl+clicked
	local f = CreateFrame("CheckButton", "FocuserButton", UIParent, "SecureActionButtonTemplate")
	f:SetAttribute("type1", "macro")
	f:SetAttribute("macrotext", "/focus mouseover")
	SetOverrideBindingClick(FocuserButton, true, modifier.."-BUTTON"..mouseButton, "FocuserButton")

	local function setupHotkey(event)
		if event == "PLAYER_REGEN_ENABLED" then
			for frame in pairs(pending) do
				SetFocusHotkey(frame)
			end
		else
			for _, object in pairs(oUF.objects) do
				SetFocusHotkey(object)
			end
		end
	end
	F:RegisterEvent("PLAYER_REGEN_ENABLED", setupHotkey)
	F:RegisterEvent("GROUP_ROSTER_UPDATE", setupHotkey)
	F:RegisterEvent("PLAYER_ENTERING_WORLD", setupHotkey)
end