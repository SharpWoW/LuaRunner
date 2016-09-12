local NAME, T = ...

local function box(status, ...) return status, {...} end

local context = {
    depth = 0,
    GetTableName = function() return nil end,
    GetFunctionName = function() return nil end,
    GetUserdataName = function() return nil end,

    Write = function(self, message)
        self.output[#self.output + 1] = message
    end
}

local function exec(str)
    if type(str) ~= "string" then return "<<< Invalid Input >>>" end

    local func, err = loadstring("return " .. str)

    if not func then return tostring(err) end

    local success, values = box(pcall(func))

    if not success then return tostring(values[1]) end

    context.output = {}

    DevTools_RunDump(values, context)

    return table.concat(context.output, "\n")
end

local frame

local function create()
    if frame then return frame end
    frame = CreateFrame("Frame", nil, UIParent)

    frame:EnableMouse(true)
    frame:SetMovable(true)

    frame:SetWidth(400)
    frame:SetHeight(300)

    frame:SetPoint("CENTER")

    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        edgeSize = 16,
        tileSize = 32,
        insets = {
            left = 2.5,
            right = 2.5,
            top = 2.5,
            bottom = 2.5
        }
    })

    frame:SetScript("OnMouseDown", function(f) f:StartMoving() end)
    frame:SetScript("OnMouseUp", function(f) f:StopMovingOrSizing() end)

    frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.label:SetWidth(400)
    frame.label:SetHeight(16)
    frame.label:SetPoint("TOP", frame, "TOP", 0, -5)
    frame.label:SetText("LuaRunner")
    frame.label:SetJustifyH("CENTER")

    frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
    frame.close:SetScript("OnClick", function() frame:Hide() end)

    local function escape(f) f:ClearFocus() end

    frame.input = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    frame.input:SetPoint("TOP", frame.label, "BOTTOM", 0, -5)
    frame.input:SetPoint("LEFT", frame, "LEFT", 10, 0)
    frame.input:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
    frame.input:SetHeight(20)
    frame.input:SetAutoFocus(false)
    frame.input:SetScript("OnEscapePressed", escape)

    frame.output = CreateFrame("ScrollFrame", nil, frame, "InputScrollFrameTemplate")
    frame.output:SetPoint("TOPLEFT", frame.input, "BOTTOMLEFT", 0, -5)
    frame.output:SetPoint("TOPRIGHT", frame.input, "BOTTOMRIGHT", 0, -5)
    frame.output:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
    frame.output.EditBox:SetPoint("RIGHT", frame.output, "RIGHT", 0, 0)
    frame.output.CharCount:Hide()

    frame.input:SetScript("OnTextChanged", function(f, user)
        if not user then return end

        local result = exec(f:GetText())

        if type(result) ~= "string" then
            result = "<<< exec returned non-string value >>>"
        end

        frame.output.EditBox:SetText(result)
    end)

    return frame
end

for i, v in ipairs({"luarunner", "lr"}) do
    _G["SLASH_" .. NAME:upper() .. i] = "/" .. v
end

SlashCmdList[NAME:upper()] = function(msg, editbox)
    LoadAddOn("Blizzard_DebugTools")
    create():Show()
end
