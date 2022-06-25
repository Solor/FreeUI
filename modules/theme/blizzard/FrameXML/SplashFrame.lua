local F, C = unpack(select(2, ...))

table.insert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    local SplashFrame = _G.SplashFrame

    F.Reskin(SplashFrame.BottomCloseButton)
    F.ReskinClose(SplashFrame.TopCloseButton)

    SplashFrame.TopCloseButton:ClearAllPoints()
    SplashFrame.TopCloseButton:SetPoint('TOPRIGHT', SplashFrame, 'TOPRIGHT', -18, -18)

    SplashFrame.Label:SetTextColor(1, 0.8, 0)
end)
