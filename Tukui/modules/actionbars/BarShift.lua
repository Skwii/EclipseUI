local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
if not C["actionbar"].enable == true then return end

---------------------------------------------------------------------------
-- Setup Shapeshift Bar
---------------------------------------------------------------------------

local TukuiShift = CreateFrame("Frame", "TukuiShiftBar", UIParent)
TukuiShift:Height(T.stancebuttonsize + 10)
TukuiShift:Point("TOPLEFT",  TukuiMinimap, "TOPRIGHT", 3, 0)
TukuiShift:SetFrameStrata("LOW")
TukuiShift:SetMovable(true)
TukuiShift:SetClampedToScreen(true)
TukuiShift:SetScript("OnEvent", function(self, event, ...)
	if T.myclass == "SHAMAN" then
		TukuiShift:Width(210)

		TukuiShift:SetBackdropBorderColor(0,0,0,0)
		TukuiShift:SetBackdropBorderColor(0,0,0,0)
	else
		TukuiShift:SetTemplate("Transparent")
		TukuiShift:CreateShadow("Default")
		TukuiShift:CreateBorder(true, true)

		local forms = GetNumShapeshiftForms()
		if forms > 0 then
			TukuiShift:Width((T.stancebuttonsize * forms) + (T.buttonspacing * forms + 1) + 5)
			TukuiShift:Show()
		else
			TukuiShift:Hide()
		end
	end
end)
TukuiShift:RegisterEvent("PLAYER_LOGIN")
TukuiShift:RegisterEvent("PLAYER_ENTERING_WORLD")
TukuiShift:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
TukuiShift:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
TukuiShift:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
TukuiShift:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR")


-- shapeshift command to move totem or shapeshift in-game
local ssmover = CreateFrame("Frame", "TukuiShapeShiftHolder", UIParent)
ssmover:SetParent(TukuiShift)
ssmover:SetAllPoints(TukuiShift)
ssmover:SetTemplate("Default")
ssmover:SetBackdropBorderColor(1,0,0)
ssmover:SetAlpha(0)
ssmover.text = T.SetFontString(ssmover, C.media.pixel_font, 12, "MONOCHROMEOUTLINE")
ssmover.text:SetPoint("CENTER")
ssmover.text:SetText(L.move_shapeshift)

-- hide it if not needed and stop executing code
if C["actionbar"].hideshapeshift then TukuiShift:Hide() return end

-- create the shapeshift bar if we enabled it
local bar = CreateFrame("Frame", "TukuiShapeShift", TukuiShift, "SecureHandlerStateTemplate")
bar:ClearAllPoints()
bar:SetAllPoints(TukuiShift)

local States = {
	["DRUID"] = "show",
	["WARRIOR"] = "show",
	["PALADIN"] = "show",
	["DEATHKNIGHT"] = "show",
	["ROGUE"] = "show,",
	["PRIEST"] = "show,",
	["HUNTER"] = "show,",
	["WARLOCK"] = "show,",
}

bar:RegisterEvent("PLAYER_LOGIN")
bar:RegisterEvent("PLAYER_ENTERING_WORLD")
bar:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
bar:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")
bar:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN")
bar:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
bar:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
bar:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		local button
		for i = 1, NUM_SHAPESHIFT_SLOTS do
			button = _G["ShapeshiftButton"..i]
			button:ClearAllPoints()
			button:SetParent(self)
			button:SetFrameStrata("LOW")
			if i == 1 then
				button:Point("BOTTOMLEFT", 5, 5)
			else
				local previous = _G["ShapeshiftButton"..i-1]
				button:Point("LEFT", previous, "RIGHT", T.buttonspacing, 0)
			end
			local _, name = GetShapeshiftFormInfo(i)
			if name then
				button:Show()
			end
		end
		RegisterStateDriver(self, "visibility", States[T.myclass] or "hide")
	elseif event == "UPDATE_SHAPESHIFT_FORMS" then
		-- Update Shapeshift Bar Button Visibility
		-- I seriously don't know if it's the best way to do it on spec changes or when we learn a new stance.
		if InCombatLockdown() then return end -- > just to be safe ;p
		local button
		for i = 1, NUM_SHAPESHIFT_SLOTS do
			button = _G["ShapeshiftButton"..i]
			local _, name = GetShapeshiftFormInfo(i)
			if name then
				button:Show()
			else
				button:Hide()
			end
		end
		T.TukuiShiftBarUpdate()
	elseif event == "PLAYER_ENTERING_WORLD" then
		T.StyleShift()
	else
		T.TukuiShiftBarUpdate()
	end
end)