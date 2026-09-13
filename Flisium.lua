--// FLISIUM
--// Self-contained LocalScript
--// Place in StarterPlayer > StarterPlayerScripts

--==================================================
-- SERVICES
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================

local CONFIG = {
Name = "Flisium",

Logo = "rbxassetid://114587360919088",
ClickSound = "rbxassetid://116080744084010",
HoverSound = "rbxassetid://139800881181209",
CloseSound = "rbxassetid://8968249849",

Width = 900,
Height = 620,

MinWidth = 700,
MinHeight = 480,
}

--==================================================
-- CLEAN OLD GUI
--==================================================

local OldGui = PlayerGui:FindFirstChild("Flisium")
if OldGui then
OldGui:Destroy()
end

--==================================================
-- COLORS
--==================================================

local C = {
Black = Color3.fromRGB(5, 8, 6),
Panel = Color3.fromRGB(10, 14, 11),
Panel2 = Color3.fromRGB(16, 22, 17),
Panel3 = Color3.fromRGB(24, 33, 25),

White = Color3.fromRGB(232, 242, 233),
Muted = Color3.fromRGB(142, 157, 145),
Dim = Color3.fromRGB(78, 94, 81),

Border = Color3.fromRGB(42, 59, 45),

Accent = Color3.fromRGB(92, 218, 112),
AccentDark = Color3.fromRGB(34, 104, 48),
Cyan = Color3.fromRGB(92, 218, 112),
Violet = Color3.fromRGB(68, 176, 88),
Magenta = Color3.fromRGB(112, 232, 130),

Red = Color3.fromRGB(215, 80, 85),
}

--==================================================
-- HELPERS
--==================================================

local function Create(className, properties, parent)
local object = Instance.new(className)

for property, value in pairs(properties or {}) do
object[property] = value
end

object.Parent = parent
return object
end

local function Round(object, radius)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, radius)
corner.Parent = object
return corner
end

local function Stroke(object, color, transparency, thickness)
local stroke = Instance.new("UIStroke")
stroke.Color = color or C.Border
stroke.Transparency = transparency or 0
stroke.Thickness = thickness or 1
stroke.Parent = object
return stroke
end

local function Tween(object, info, properties)
local tween = TweenService:Create(object, info, properties)
tween:Play()
return tween
end

local function PlaySound(soundId, volume)
if not UISoundsEnabled or SFXVolume <= 0 then
return
end

local sound = Instance.new("Sound")
sound.SoundId = soundId
sound.Volume = (volume or 0.5) * (SFXVolume / 100)
sound.Parent = PlayerGui
sound:Play()

task.delay(3, function()
if sound then
sound:Destroy()
end
end)
end

local function PlayClick()
PlaySound(CONFIG.ClickSound, 0.45)
end

local function PlayHover()
PlaySound(CONFIG.HoverSound, 0.22)
end

local function Clamp(value, minimum, maximum)
return math.clamp(value, minimum, maximum)
end

--==================================================
-- EXTRA SETTINGS / CONFIG STATE
--==================================================

local ClockEnabled = true
local UISoundsEnabled = true
local SFXVolume = 100
local UISize = 100
local Configs = {}
local SelectedConfig = nil
local UIScaleObject
local ClockTab
local ShowClock, HideClock
local Opened = true
local Minimized = false
local Maximized = false
local NormalSize = UDim2.fromOffset(CONFIG.Width, CONFIG.Height)
local NormalPosition = UDim2.new(0.5, -CONFIG.Width / 2, 0.5, -CONFIG.Height / 2)

--==================================================
-- GUI
--==================================================

local Gui = Create("ScreenGui", {
Name = "Flisium",
ResetOnSpawn = false,
IgnoreGuiInset = true,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
DisplayOrder = 100,
}, PlayerGui)

--==================================================
-- MAIN WINDOW
--==================================================

local Main = Create("Frame", {
Name = "Main",
Size = UDim2.fromOffset(CONFIG.Width, CONFIG.Height),
Position = UDim2.new(0.5, -CONFIG.Width / 2, 0.5, -CONFIG.Height / 2),
BackgroundColor3 = C.Black,
BorderSizePixel = 0,
ClipsDescendants = true,
}, Gui)

Round(Main, 10)
local MainStroke = Stroke(Main, C.Border, 0, 1)

-- Shadow
local Shadow = Create("ImageLabel", {
Name = "Shadow",
BackgroundTransparency = 1,
Image = "rbxassetid://6014261993",
ImageTransparency = 0.35,
ScaleType = Enum.ScaleType.Slice,
SliceCenter = Rect.new(49, 49, 450, 450),
Size = UDim2.new(1, 80, 1, 80),
Position = UDim2.fromOffset(-40, -40),
ZIndex = 0,
}, Main)

Main.ZIndex = 10

--==================================================
-- TOP GRADIENT ACCENT
--==================================================

local AccentBar = Create("Frame", {
Name = "Accent",
Size = UDim2.new(1, 0, 0, 2),
Position = UDim2.fromOffset(0, 0),
BorderSizePixel = 0,
ZIndex = 50,
}, Main)

local AccentGradient = Create("UIGradient", {
Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, C.AccentDark),
ColorSequenceKeypoint.new(0.5, C.Accent),
ColorSequenceKeypoint.new(1, C.AccentDark),
}),
Offset = Vector2.new(-0.35, 0),
}, AccentBar)

task.spawn(function()
while AccentBar.Parent do
Tween(
AccentGradient,
TweenInfo.new(2.2, Enum.EasingStyle.Linear),
{Offset = Vector2.new(0.35, 0)}
).Completed:Wait()

AccentGradient.Offset = Vector2.new(-0.35, 0)
end
end)

--==================================================
-- HEADER
--==================================================

local Header = Create("Frame", {
Name = "Header",
Size = UDim2.new(1, 0, 0, 42),
BackgroundColor3 = C.Panel,
BorderSizePixel = 0,
ZIndex = 20,
}, Main)

local Logo = Create("ImageLabel", {
Name = "Logo",
BackgroundTransparency = 1,
Image = CONFIG.Logo,
Size = UDim2.fromOffset(18, 18),
Position = UDim2.fromOffset(10, 9),
ZIndex = 22,
}, Header)

Round(Logo, 7)

local Title = Create("TextLabel", {
BackgroundTransparency = 1,
Text = "FLISIUM",
Font = Enum.Font.Code,
TextSize = 13,
TextColor3 = C.White,
TextXAlignment = Enum.TextXAlignment.Left,
Size = UDim2.fromOffset(150, 18),
Position = UDim2.fromOffset(35, 8),
ZIndex = 22,
}, Header)

local Subtitle = Create("TextLabel", {
BackgroundTransparency = 1,
Text = "CONTROL PANEL",
Font = Enum.Font.Code,
TextSize = 8,
TextColor3 = C.Muted,
TextXAlignment = Enum.TextXAlignment.Left,
Size = UDim2.fromOffset(160, 12),
Position = UDim2.fromOffset(36, 22),
ZIndex = 22,
}, Header)

--==================================================
-- WINDOW BUTTONS
--==================================================

local function CreateWindowButton(text, position)
local button = Create("TextButton", {
BackgroundColor3 = C.Panel2,
BackgroundTransparency = 0,
Text = text,
Font = Enum.Font.Code,
TextSize = 13,
TextColor3 = C.Muted,
AutoButtonColor = false,
Size = UDim2.fromOffset(26, 26),
Position = position,
ZIndex = 25,
}, Header)

Round(button, 6)

Stroke(button, C.Border, 0.2, 1)

button.MouseEnter:Connect(function()
PlayHover()

Tween(button, TweenInfo.new(0.12), {
BackgroundColor3 = C.Panel3,
TextColor3 = C.White,
})
end)

button.MouseLeave:Connect(function()
Tween(button, TweenInfo.new(0.12), {
BackgroundColor3 = C.Panel2,
TextColor3 = C.Muted,
})
end)

return button
end

local MinButton = CreateWindowButton("-", UDim2.new(1, -92, 0, 5))
local MaxButton = CreateWindowButton("+", UDim2.new(1, -62, 0, 5))
local CloseButton = CreateWindowButton("x", UDim2.new(1, -32, 0, 5))
local function AddButtonGlow(button, color)
    local stroke = button:FindFirstChildOfClass("UIStroke")
    if stroke then
        stroke.Color = color
        stroke.Transparency = 0.25
        button.MouseEnter:Connect(function()
            Tween(button, TweenInfo.new(0.12), {BackgroundColor3 = C.Panel3})
            Tween(stroke, TweenInfo.new(0.12), {Transparency = 0})
            PlayHover()
        end)
        button.MouseLeave:Connect(function()
            Tween(button, TweenInfo.new(0.12), {BackgroundColor3 = C.Panel2})
            Tween(stroke, TweenInfo.new(0.12), {Transparency = 0.25})
        end)
    end
end
AddButtonGlow(MinButton, C.Accent)
AddButtonGlow(MaxButton, C.Violet)
AddButtonGlow(CloseButton, C.Magenta)

--==================================================
-- REFERENCE-STYLE STATUS STRIP
--==================================================

ClockTab = Create("Frame", {
    Name = "ClockTab",
    BackgroundColor3 = C.Black,
    BorderSizePixel = 0,
    Size = UDim2.fromOffset(430, 22),
    Position = UDim2.fromOffset(0, 0),
    Visible = true,
    ZIndex = 100,
}, Gui)
Stroke(ClockTab, C.Border, 0.15, 1)

local ClockLogo = Create("ImageLabel", {
    BackgroundTransparency = 1,
    Image = CONFIG.Logo,
    Size = UDim2.fromOffset(13, 13),
    Position = UDim2.fromOffset(7, 4),
    ZIndex = 101,
}, ClockTab)

local ClockBrand = Create("TextLabel", {
    BackgroundTransparency = 1,
    Text = "flisium",
    Font = Enum.Font.Code,
    TextSize = 10,
    TextColor3 = C.White,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.fromOffset(100, 18),
    Position = UDim2.fromOffset(26, 2),
    ZIndex = 101,
}, ClockTab)

ClockText = Create("TextLabel", {
    BackgroundTransparency = 1,
    Text = "-- fps  •  --/--/----",
    Font = Enum.Font.Code,
    TextSize = 9,
    TextColor3 = C.Muted,
    TextXAlignment = Enum.TextXAlignment.Right,
    Size = UDim2.new(1, -138, 0, 18),
    Position = UDim2.fromOffset(130, 2),
    ZIndex = 101,
}, ClockTab)

-- Keep the strip attached to the window while dragging/resizing.
task.spawn(function()
    while Gui.Parent do
        local pos = Main.AbsolutePosition
        ClockTab.Position = UDim2.fromOffset(pos.X, math.max(0, pos.Y - 23))
        task.wait(0.05)
    end
end)

--==================================================
-- DRAGGING
--==================================================

local Dragging = false
local DragStart
local StartPosition

local function BeginDrag(input)
if input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch then

Dragging = true
DragStart = input.Position
StartPosition = Main.Position
end
end

local function EndDrag(input)
if input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch then

Dragging = false
end
end

local function UpdateDrag(input)
if not Dragging then
return
end

local delta = input.Position - DragStart

Main.Position = UDim2.new(
StartPosition.X.Scale,
StartPosition.X.Offset + delta.X,
StartPosition.Y.Scale,
StartPosition.Y.Offset + delta.Y
)
end

Header.InputBegan:Connect(BeginDrag)
Header.InputEnded:Connect(EndDrag)

UserInputService.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement
or input.UserInputType == Enum.UserInputType.Touch then

UpdateDrag(input)
end
end)

-- Side drag zones
local function CreateDragZone(name, size, position)
local zone = Create("Frame", {
Name = name,
BackgroundTransparency = 1,
Size = size,
Position = position,
ZIndex = 19,
}, Main)

zone.InputBegan:Connect(BeginDrag)
zone.InputEnded:Connect(EndDrag)

return zone
end

CreateDragZone(
"LeftDrag",
UDim2.fromOffset(8, CONFIG.Height - 64),
UDim2.fromOffset(0, 64)
)

CreateDragZone(
"RightDrag",
UDim2.fromOffset(8, CONFIG.Height - 64),
UDim2.new(1, -8, 0, 64)
)

CreateDragZone(
"BottomDrag",
UDim2.new(1, -16, 0, 8),
UDim2.new(0, 8, 1, -8)
)

--==================================================
-- SIDEBAR / VERTICAL NAVIGATION
--==================================================

local SIDEBAR_WIDTH = 156

local Sidebar = Create("Frame", {
Name = "Sidebar",
Size = UDim2.new(0, SIDEBAR_WIDTH, 1, -42),
Position = UDim2.fromOffset(0, 42),
BackgroundColor3 = C.Panel,
BorderSizePixel = 0,
Visible = true,
ZIndex = 15,
}, Main)
Round(Sidebar, 10)
Stroke(Sidebar, C.Border, 0.15, 1)

local SidebarMask = Create("Frame", {
BackgroundColor3 = C.Panel,
BorderSizePixel = 0,
Size = UDim2.new(1, 0, 0, 18),
Position = UDim2.fromOffset(0, -1),
ZIndex = 16,
}, Sidebar)

local SidebarLine = Create("Frame", {
Size = UDim2.fromOffset(1, CONFIG.Height - 50),
Position = UDim2.new(1, -1, 0, 0),
BackgroundColor3 = C.Border,
BorderSizePixel = 0,
ZIndex = 18,
}, Sidebar)

local NavTitle = Create("TextLabel", {
BackgroundTransparency = 1,
Text = "NAVIGATION",
Font = Enum.Font.Code,
TextSize = 9,
TextColor3 = C.Dim,
TextXAlignment = Enum.TextXAlignment.Left,
Size = UDim2.new(1, -24, 0, 18),
Position = UDim2.fromOffset(12, 16),
ZIndex = 20,
}, Sidebar)

local NavAccent = Create("Frame", {
BackgroundColor3 = C.Accent,
BorderSizePixel = 0,
Size = UDim2.fromOffset(24, 2),
Position = UDim2.fromOffset(12, 35),
ZIndex = 20,
}, Sidebar)
Round(NavAccent, 2)

local TabContainer = Create("Frame", {
BackgroundTransparency = 1,
Size = UDim2.new(1, -16, 0, 210),
Position = UDim2.fromOffset(8, 50),
ZIndex = 40,
}, Sidebar)

Create("UIListLayout", {
Padding = UDim.new(0, 6),
FillDirection = Enum.FillDirection.Vertical,
HorizontalAlignment = Enum.HorizontalAlignment.Center,
VerticalAlignment = Enum.VerticalAlignment.Top,
SortOrder = Enum.SortOrder.LayoutOrder,
}, TabContainer)

local Tabs = {
"Combat",
"Visuals",
"Player",
"Game",
"Settings",
}

local TabButtons = {}
local Pages = {}

--==================================================
-- CONTENT
--==================================================

local Content = Create("Frame", {
Name = "Content",
Size = UDim2.new(1, -SIDEBAR_WIDTH - 10, 1, -52),
Position = UDim2.fromOffset(SIDEBAR_WIDTH + 5, 47),
BackgroundColor3 = C.Black,
BorderSizePixel = 0,
ZIndex = 14,
}, Main)
Round(Content, 10)
Stroke(Content, C.Border, 0.35, 1)

-- Subtle top accent line for the content surface.
local ContentAccent = Create("Frame", {
BackgroundColor3 = C.Accent,
BorderSizePixel = 0,
Size = UDim2.new(1, -24, 0, 1),
Position = UDim2.fromOffset(12, 0),
ZIndex = 18,
}, Content)
Round(ContentAccent, 2)

for _, tabName in ipairs(Tabs) do
local Page = Create("ScrollingFrame", {
Name = tabName,
BackgroundTransparency = 1,
Size = UDim2.new(1, -16, 1, -10),
Position = UDim2.fromOffset(8, 5),
CanvasSize = UDim2.fromOffset(0, 0),
AutomaticCanvasSize = Enum.AutomaticSize.Y,
ScrollBarThickness = 2,
ScrollBarImageColor3 = C.Accent,
ScrollBarImageTransparency = 0.15,
BorderSizePixel = 0,
Visible = false,
ZIndex = 16,
}, Content)

Pages[tabName] = Page
end

--==================================================
-- TAB BUTTONS
--==================================================

local function SelectTab(tabName)
for name, button in pairs(TabButtons) do
local selected = name == tabName

Tween(button, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
BackgroundColor3 = selected and C.AccentDark or C.Panel2,
TextColor3 = selected and C.White or C.Muted,
})

local indicator = button:FindFirstChild("Indicator")
local icon = button:FindFirstChild("NavIcon")

if indicator then
Tween(indicator, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
BackgroundTransparency = selected and 0 or 1,
Size = selected and UDim2.fromOffset(3, 22) or UDim2.fromOffset(3, 8),
})
end

if icon then
Tween(icon, TweenInfo.new(0.18), {
TextColor3 = selected and C.White or C.Muted,
})
end

-- Switch the visible content page.
for name, page in pairs(Pages) do
page.Visible = (name == tabName)
end
end

for index, tabName in ipairs(Tabs) do
local button = Create("TextButton", {
Name = tabName,
BackgroundColor3 = C.Panel2,
Text = "",
AutoButtonColor = false,
Size = UDim2.new(1, 0, 0, 36),
LayoutOrder = index,
ZIndex = 41,
}, TabContainer)

Round(button, 8)
Stroke(button, C.Border, 0.45, 1)

local iconLetters = {
Combat = "C",
Visuals = "V",
Player = "P",
Game = "G",
Settings = "S",
}

local icon = Create("TextLabel", {
Name = "NavIcon",
BackgroundTransparency = 1,
Text = iconLetters[tabName] or "?",
Font = Enum.Font.Code,
TextSize = 11,
TextColor3 = C.Muted,
TextXAlignment = Enum.TextXAlignment.Center,
Size = UDim2.fromOffset(28, 28),
Position = UDim2.fromOffset(7, 4),
ZIndex = 43,
}, button)

local label = Create("TextLabel", {
BackgroundTransparency = 1,
Text = tabName,
Font = Enum.Font.Code,
TextSize = 10,
TextColor3 = C.Muted,
TextXAlignment = Enum.TextXAlignment.Left,
Size = UDim2.new(1, -52, 1, 0),
Position = UDim2.fromOffset(43, 0),
ZIndex = 43,
}, button)

local indicator = Create("Frame", {
Name = "Indicator",
BackgroundColor3 = C.Accent,
BackgroundTransparency = 1,
BorderSizePixel = 0,
Size = UDim2.fromOffset(3, 8),
Position = UDim2.new(1, -5, 0.5, -11),
ZIndex = 44,
}, button)
Round(indicator, 2)

button.MouseEnter:Connect(function()
if Pages[tabName].Visible == false then
Tween(button, TweenInfo.new(0.12), {
BackgroundColor3 = C.Panel3,
TextColor3 = C.White,
})
Tween(label, TweenInfo.new(0.12), {TextColor3 = C.White})
Tween(icon, TweenInfo.new(0.12), {TextColor3 = C.Accent})
end
PlayHover()
end)

button.MouseLeave:Connect(function()
if Pages[tabName].Visible == false then
Tween(button, TweenInfo.new(0.12), {
BackgroundColor3 = C.Panel2,
TextColor3 = C.Muted,
})
Tween(label, TweenInfo.new(0.12), {TextColor3 = C.Muted})
Tween(icon, TweenInfo.new(0.12), {TextColor3 = C.Muted})
else
Tween(button, TweenInfo.new(0.12), {
BackgroundColor3 = C.AccentDark,
})
end
end)

button.MouseButton1Click:Connect(function()
PlayClick()
SelectTab(tabName)
end)

TabButtons[tabName] = button
end

--==================================================
-- SIDEBAR FOOTER
--==================================================

local Status = Create("Frame", {
BackgroundTransparency = 1,
Size = UDim2.new(1, -20, 0, 48),
Position = UDim2.new(0, 10, 1, -62),
ZIndex = 20,
}, Sidebar)

local StatusDot = Create("Frame", {
BackgroundColor3 = C.Cyan,
Size = UDim2.fromOffset(7, 7),
Position = UDim2.fromOffset(4, 8),
BorderSizePixel = 0,
ZIndex = 22,
}, Status)

Round(StatusDot, 50)

local StatusText = Create("TextLabel", {
BackgroundTransparency = 1,
Text = "SYSTEM ONLINE • FLISIUM",
Font = Enum.Font.Code,
TextSize = 9,
TextColor3 = C.Muted,
TextXAlignment = Enum.TextXAlignment.Left,
Size = UDim2.new(1, -20, 0, 16),
Position = UDim2.fromOffset(18, 3),
ZIndex = 22,
}, Status)

local VersionText = Create("TextLabel", {
BackgroundTransparency = 1,
Text = "GREEN / GREY / BLACK // CLIENT",
Font = Enum.Font.Code,
TextSize = 8,
TextColor3 = C.Dim,
TextXAlignment = Enum.TextXAlignment.Left,
Size = UDim2.new(1, -20, 0, 16),
Position = UDim2.fromOffset(18, 19),
ZIndex = 22,
}, Status)

--==================================================
-- PAGE HELPERS
--==================================================

local function PageHeader(page, title, description)

local holder = Create("Frame", {
BackgroundTransparency = 1,
Size = UDim2.new(1, -10, 0, 48),
Position = UDim2.fromOffset(5, 2),
}, page)

Create("TextLabel", {
BackgroundTransparency = 1,
Text = title,
Font = Enum.Font.Code,
TextSize = 18,
TextColor3 = C.White,
TextXAlignment = Enum.TextXAlignment.Left,
Size = UDim2.new(1, 0, 0, 22),
Position = UDim2.fromOffset(0, 0),
}, holder)

Create("TextLabel", {
BackgroundTransparency = 1,
Text = description,
Font = Enum.Font.Code,
TextSize = 10,
TextColor3 = C.Muted,
TextXAlignment = Enum.TextXAlignment.Left,
Size = UDim2.new(1, 0, 0, 15),
Position = UDim2.fromOffset(0, 25),
}, holder)

return holder
end

local function CreateSectionLabel(page, text, y)

return Create("TextLabel", {
BackgroundTransparency = 1,
Text = string.upper(text),
Font = Enum.Font.Code,
TextSize = 9,
TextColor3 = C.Dim,
TextXAlignment = Enum.TextXAlignment.Left,
Size = UDim2.new(1, -10, 0, 20),
Position = UDim2.fromOffset(5, y),
}, page)
end

--==================================================
-- SIMPLE TOGGLE
--==================================================

local function CreateToggle(parent, text, y, callback)

local button = Create("TextButton", {
BackgroundColor3 = C.Panel2,
BorderSizePixel = 0,
Text = "",
AutoButtonColor = false,
Size = UDim2.new(1, -10, 0, 34),
Position = UDim2.fromOffset(5, y),
ZIndex = 30,
}, parent)

-- INTENTIONALLY SQUARE
Stroke(button, C.Border, 0, 1)

local label = Create("TextLabel", {
BackgroundTransparency = 1,
Text = text,
Font = Enum.Font.Code,
TextSize = 10,
TextColor3 = C.White,
TextXAlignment = Enum.TextXAlignment.Left,
Size = UDim2.new(1, -80, 1, 0),
Position = UDim2.fromOffset(13, 0),
ZIndex = 31,
}, button)

local toggle = Create("Frame", {
BackgroundColor3 = C.Panel3,
BorderSizePixel = 0,
Size = UDim2.fromOffset(28, 14),
Position = UDim2.new(1, -47, 0.5, -8),
ZIndex = 31,
}, button)

-- NO ROUNDED EDGE
Stroke(toggle, C.Border, 0, 1)

local state = false

local function SetState(value)
state = value

Tween(toggle, TweenInfo.new(0.14), {
BackgroundColor3 = state and C.Accent or C.Panel3,
})

Tween(label, TweenInfo.new(0.14), {
TextColor3 = C.White,
})

callback(state)
end

button.MouseEnter:Connect(function()
Tween(button, TweenInfo.new(0.12), {
BackgroundColor3 = C.Panel3,
})
end)

button.MouseLeave:Connect(function()
Tween(button, TweenInfo.new(0.12), {
BackgroundColor3 = C.Panel2,
})
end)

button.MouseButton1Click:Connect(function()
PlayClick()
SetState(not state)
end)

return {
Button = button,
Set = SetState,
Get = function()
return state
end,
}
end

--==================================================
-- VALUE BOX
--==================================================

local function CreateValueBox(parent, value, callback)

local box = Create("TextBox", {
BackgroundColor3 = C.Panel3,
BorderSizePixel = 0,
Text = tostring(value),
Font = Enum.Font.Code,
TextSize = 10,
TextColor3 = C.White,

ClearTextOnFocus = false,

Size = UDim2.fromOffset(75, 32),
Position = UDim2.new(1, -80, 0.5, -16),
ZIndex = 35,
}, parent)

Round(box, 7)
Stroke(box, C.Border, 0, 1)

local currentValue = value

box.FocusLost:Connect(function()
local number = tonumber(box.Text)

if number then
currentValue = number
callback(number)
else
box.Text = tostring(currentValue)
end
end)

return box
end

--==================================================
-- SLIDER
--==================================================

local function CreateSlider(parent, min, max, default, callback)

local holder = Create("Frame", {
BackgroundTransparency = 1,
Size = UDim2.new(1, -100, 0, 32),
Position = UDim2.fromOffset(5, 0),
ZIndex = 30,
}, parent)

local track = Create("Frame", {
BackgroundColor3 = C.Panel3,
BorderSizePixel = 0,
Size = UDim2.new(1, 0, 0, 6),
Position = UDim2.new(0, 0, 0.5, -3),
ZIndex = 31,
}, holder)

-- Slider track is intentionally square.
Stroke(track, C.Border, 0, 1)

local fill = Create("Frame", {
BackgroundColor3 = C.Accent,
BorderSizePixel = 0,
Size = UDim2.new(0, 0, 1, 0),
ZIndex = 32,
}, track)

Stroke(fill, C.Accent, 0, 1)

-- Real square drag handle. No UICorner.
local handle = Create("TextButton", {
BackgroundColor3 = C.Accent,
BorderSizePixel = 0,
Text = "",
AutoButtonColor = false,
Size = UDim2.fromOffset(12, 20),
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.new(0, 0, 0.5, 0),
ZIndex = 34,
}, track)

Stroke(handle, C.Border, 0, 1)

local dragging = false
local current = default

local function SetValue(value, fire)
value = Clamp(value, min, max)
current = value

local alpha = 0
if max ~= min then
alpha = (value - min) / (max - min)
end

fill.Size = UDim2.new(alpha, 0, 1, 0)
handle.Position = UDim2.new(alpha, 0, 0.5, 0)

if fire then
callback(value)
end
end

local function UpdateFromX(x)
local left = track.AbsolutePosition.X
local width = track.AbsoluteSize.X

if width <= 0 then
return
end

local alpha = Clamp((x - left) / width, 0, 1)
local value = min + ((max - min) * alpha)
SetValue(value, true)
end

local function BeginSlider(input)
if input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch then

dragging = true
UpdateFromX(input.Position.X)
end
end

track.InputBegan:Connect(BeginSlider)
handle.InputBegan:Connect(BeginSlider)

UserInputService.InputChanged:Connect(function(input)
if not dragging then
return
end

if input.UserInputType ~= Enum.UserInputType.MouseMovement
and input.UserInputType ~= Enum.UserInputType.Touch then
return
end

UpdateFromX(input.Position.X)
end)

UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch then
dragging = false
end
end)

SetValue(default, false)

return {
Set = function(value)
SetValue(value, true)
end,

SetSilent = function(value)
SetValue(value, false)
end,

Get = function()
return current
end,
}
end

--==================================================
-- MICRO INTERACTION POLISH
--==================================================

local function PolishButton(button)
    if not button or not button:IsA("GuiButton") then
        return
    end

    if not button:GetAttribute("FlisiumPolished") then
        button:SetAttribute("FlisiumPolished", true)

        local stroke = button:FindFirstChildOfClass("UIStroke")
        if not stroke then
            stroke = Stroke(button, C.Border, 0.35, 1)
        end

        button.MouseEnter:Connect(function()
            Tween(button, TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundColor3 = C.Panel3,
            })
            Tween(stroke, TweenInfo.new(0.14), {
                Color = C.Accent,
                Transparency = 0.05,
            })
        end)

        button.MouseLeave:Connect(function()
            Tween(button, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundColor3 = C.Panel2,
            })
            Tween(stroke, TweenInfo.new(0.16), {
                Color = C.Border,
                Transparency = 0.35,
            })
        end)
    end
end

--==================================================
-- PLAYER PAGE
--==================================================

local PlayerPage = Pages.Player

PageHeader(
PlayerPage,
"Player",
"Movement and character controls."
)

local WalkSpeedEnabled = false
local JumpPowerEnabled = false
local GravityEnabled = false
local FlyEnabled = false

local WalkSpeed = 16
local JumpPower = 50
local Gravity = 196.2
local FlySpeed = 50

local CollisionEnabled = true
local NoclipEnabled = false
local Invisible = false
local InvisibleTransparency = 1

local WalkToggle
local JumpToggle
local GravityToggle
local FlyToggle
local WalkSlider
local JumpSlider
local GravitySlider
local InvisibleSlider
local FlySlider
local WalkValueBox
local JumpValueBox
local GravityValueBox
local InvisibleValueBox
local FlyValueBox

local function GetCharacter()
return LocalPlayer.Character
end

local function GetHumanoid()
local character = GetCharacter()
if character then
return character:FindFirstChildOfClass("Humanoid")
end
end

local function ApplyMovement()
local humanoid = GetHumanoid()

if humanoid then
if WalkSpeedEnabled then
humanoid.WalkSpeed = WalkSpeed
else
humanoid.WalkSpeed = 16
end

if JumpPowerEnabled then
humanoid.UseJumpPower = true
humanoid.JumpPower = JumpPower
else
humanoid.UseJumpPower = true
humanoid.JumpPower = 50
end
end

if GravityEnabled then
Workspace.Gravity = Gravity
else
Workspace.Gravity = 196.2
end
end

--==================================================
-- RESPAWN
--==================================================

CreateSectionLabel(PlayerPage, "Character", 75)

local RespawnButton = Create("TextButton", {
BackgroundColor3 = C.Panel2,
BorderSizePixel = 0,
Text = "RESPAWN",
Font = Enum.Font.Code,
TextSize = 10,
TextColor3 = C.White,
AutoButtonColor = false,
Size = UDim2.new(1, -10, 0, 40),
Position = UDim2.fromOffset(5, 100),
ZIndex = 30,
}, PlayerPage)

Stroke(RespawnButton, C.Border, 0, 1)

RespawnButton.MouseEnter:Connect(function()
Tween(RespawnButton, TweenInfo.new(0.12), {BackgroundColor3 = C.Panel3})
end)

RespawnButton.MouseLeave:Connect(function()
Tween(RespawnButton, TweenInfo.new(0.12), {BackgroundColor3 = C.Panel2})
end)

RespawnButton.MouseButton1Click:Connect(function()
PlayClick()
local humanoid = GetHumanoid()
if humanoid then
humanoid.Health = 0
end
end)

CreateSectionLabel(PlayerPage, "Movement", 155)

--==================================================
-- MOVEMENT ROW FACTORY
--==================================================

local function CreateMovementRow(y, title, min, max, default, toggleCallback, sliderCallback, boxCallback)
local row = Create("Frame", {
BackgroundColor3 = C.Panel2,
BorderSizePixel = 0,
Size = UDim2.new(1, -10, 0, 82),
Position = UDim2.fromOffset(5, y),
}, PlayerPage)

Stroke(row, C.Border, 0, 1)

Create("TextLabel", {
BackgroundTransparency = 1,
Text = title,
Font = Enum.Font.Code,
TextSize = 10,
TextColor3 = C.White,
TextXAlignment = Enum.TextXAlignment.Left,
Size = UDim2.fromOffset(150, 25),
Position = UDim2.fromOffset(12, 8),
}, row)

local toggle = CreateToggle(row, "Enable", 0, toggleCallback)
toggle.Button.Position = UDim2.new(1, -210, 0, 6)
toggle.Button.Size = UDim2.fromOffset(95, 30)
toggle.Button:FindFirstChildOfClass("TextLabel").TextXAlignment = Enum.TextXAlignment.Center

local holder = Create("Frame", {
BackgroundTransparency = 1,
Size = UDim2.new(1, -105, 0, 30),
Position = UDim2.fromOffset(12, 44),
}, row)

local slider = CreateSlider(holder, min, max, default, sliderCallback)
local box = CreateValueBox(row, default, boxCallback)

return toggle, slider, box
end

WalkToggle, WalkSlider, WalkValueBox = CreateMovementRow(180, "WalkSpeed", 0, 200, WalkSpeed,
function(state)
WalkSpeedEnabled = state
ApplyMovement()
end,
function(value)
WalkSpeed = math.floor(value + 0.5)
WalkValueBox.Text = tostring(WalkSpeed)
if WalkSpeedEnabled then
ApplyMovement()
end
end,
function(value)
WalkSpeed = Clamp(value, 0, 200)
WalkValueBox.Text = tostring(WalkSpeed)
WalkSlider.SetSilent(WalkSpeed)
if WalkSpeedEnabled then
ApplyMovement()
end
end)

JumpToggle, JumpSlider, JumpValueBox = CreateMovementRow(270, "JumpPower", 0, 200, JumpPower,
function(state)
JumpPowerEnabled = state
ApplyMovement()
end,
function(value)
JumpPower = math.floor(value + 0.5)
JumpValueBox.Text = tostring(JumpPower)
if JumpPowerEnabled then
ApplyMovement()
end
end,
function(value)
JumpPower = Clamp(value, 0, 200)
JumpValueBox.Text = tostring(JumpPower)
JumpSlider.SetSilent(JumpPower)
if JumpPowerEnabled then
ApplyMovement()
end
end)

GravityToggle, GravitySlider, GravityValueBox = CreateMovementRow(360, "Gravity", 0, 300, Gravity,
function(state)
GravityEnabled = state
ApplyMovement()
end,
function(value)
Gravity = math.floor(value * 10 + 0.5) / 10
GravityValueBox.Text = tostring(Gravity)
if GravityEnabled then
ApplyMovement()
end
end,
function(value)
Gravity = Clamp(value, 0, 300)
GravityValueBox.Text = tostring(Gravity)
GravitySlider.SetSilent(Gravity)
if GravityEnabled then
ApplyMovement()
end
end)

--==================================================
-- FLY
--==================================================

CreateSectionLabel(PlayerPage, "Fly", 455)

local FlyRow = Create("Frame", {
BackgroundColor3 = C.Panel2,
BorderSizePixel = 0,
Size = UDim2.new(1, -10, 0, 82),
Position = UDim2.fromOffset(5, 480),
}, PlayerPage)

Stroke(FlyRow, C.Border, 0, 1)

Create("TextLabel", {
BackgroundTransparency = 1,
Text = "Fly",
Font = Enum.Font.Code,
TextSize = 10,
TextColor3 = C.White,
TextXAlignment = Enum.TextXAlignment.Left,
Size = UDim2.fromOffset(150, 25),
Position = UDim2.fromOffset(12, 8),
}, FlyRow)

FlyToggle = CreateToggle(FlyRow, "Enable", 0, function(state)
FlyEnabled = state
end)

FlyToggle.Button.Position = UDim2.new(1, -210, 0, 6)
FlyToggle.Button.Size = UDim2.fromOffset(95, 30)
FlyToggle.Button:FindFirstChildOfClass("TextLabel").TextXAlignment = Enum.TextXAlignment.Center

local FlyHolder = Create("Frame", {
BackgroundTransparency = 1,
Size = UDim2.new(1, -105, 0, 30),
Position = UDim2.fromOffset(12, 44),
}, FlyRow)

FlySlider = CreateSlider(FlyHolder, 10, 200, FlySpeed, function(value)
FlySpeed = math.floor(value + 0.5)
FlyValueBox.Text = tostring(FlySpeed)
end)

FlyValueBox = CreateValueBox(FlyRow, FlySpeed, function(value)
FlySpeed = Clamp(math.floor(value + 0.5), 10, 200)
FlyValueBox.Text = tostring(FlySpeed)
FlySlider.SetSilent(FlySpeed)
end)

--==================================================
-- OTHER CHARACTER SETTINGS
--==================================================

CreateSectionLabel(PlayerPage, "Other", 575)

CreateToggle(PlayerPage, "Player Collisions", 600, function(state)
CollisionEnabled = state

local character = GetCharacter()
if character then
for _, object in ipairs(character:GetDescendants()) do
if object:IsA("BasePart") then
object.CanCollide = state
end
end
end
end)

local InvisibleRow = Create("Frame", {
BackgroundColor3 = C.Panel2,
BorderSizePixel = 0,
Size = UDim2.new(1, -10, 0, 82),
Position = UDim2.fromOffset(5, 652),
}, PlayerPage)

Stroke(InvisibleRow, C.Border, 0, 1)

Create("TextLabel", {
BackgroundTransparency = 1,
Text = "Invisibility",
Font = Enum.Font.Code,
TextSize = 10,
TextColor3 = C.White,
TextXAlignment = Enum.TextXAlignment.Left,
Size = UDim2.fromOffset(150, 25),
Position = UDim2.fromOffset(12, 8),
}, InvisibleRow)

local function ApplyInvisible()
local character = GetCharacter()
if not character then return end

for _, object in ipairs(character:GetDescendants()) do
if object:IsA("BasePart") or object:IsA("Decal") or object:IsA("Texture") then
object.LocalTransparencyModifier = Invisible and InvisibleTransparency or 0
end
end
end

local InvisibleToggle = CreateToggle(InvisibleRow, "Enable", 0, function(state)
Invisible = state
ApplyInvisible()
end)

InvisibleToggle.Button.Position = UDim2.new(1, -210, 0, 6)
InvisibleToggle.Button.Size = UDim2.fromOffset(95, 30)
InvisibleToggle.Button:FindFirstChildOfClass("TextLabel").TextXAlignment = Enum.TextXAlignment.Center

local InvisibleHolder = Create("Frame", {
BackgroundTransparency = 1,
Size = UDim2.new(1, -105, 0, 30),
Position = UDim2.fromOffset(12, 44),
}, InvisibleRow)

InvisibleSlider = CreateSlider(InvisibleHolder, 0, 1, 1, function(value)
InvisibleTransparency = math.floor(value * 100) / 100
InvisibleValueBox.Text = string.format("%.2f", InvisibleTransparency)
if Invisible then
ApplyInvisible()
end
end)

InvisibleValueBox = CreateValueBox(InvisibleRow, 1, function(value)
InvisibleTransparency = Clamp(value, 0, 1)
InvisibleValueBox.Text = string.format("%.2f", InvisibleTransparency)
InvisibleSlider.SetSilent(InvisibleTransparency)
if Invisible then
ApplyInvisible()
end
end)

--==================================================
-- FLY + NOCLIP CONTROLLER
--==================================================

local FlyAttachment
local FlyVelocity

local function StopFly()
    if FlyVelocity then FlyVelocity:Destroy(); FlyVelocity = nil end
    if FlyAttachment then FlyAttachment:Destroy(); FlyAttachment = nil end
    local humanoid = GetHumanoid()
    if humanoid then
        humanoid.PlatformStand = false
        humanoid.AutoRotate = true
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

local function StartFly()
    local character = GetCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = GetHumanoid()
    if not root or not humanoid then return end
    StopFly()
    FlyAttachment = Instance.new("Attachment")
    FlyAttachment.Name = "FlisiumFlyAttachment"
    FlyAttachment.Parent = root
    FlyVelocity = Instance.new("LinearVelocity")
    FlyVelocity.Name = "FlisiumFlyVelocity"
    FlyVelocity.Attachment0 = FlyAttachment
    FlyVelocity.MaxForce = math.huge
    FlyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    FlyVelocity.VectorVelocity = Vector3.zero
    FlyVelocity.Parent = root
    humanoid.AutoRotate = false
    humanoid.PlatformStand = true
end

RunService.RenderStepped:Connect(function()
    local character = GetCharacter()
    if character then
        for _, object in ipairs(character:GetDescendants()) do
            if object:IsA("BasePart") then
                object.CanCollide = NoclipEnabled and false or CollisionEnabled
            end
        end
    end

    if not FlyEnabled then
        if FlyVelocity or FlyAttachment then StopFly() end
        return
    end

    local camera = Workspace.CurrentCamera
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = GetHumanoid()
    if not camera or not root or not humanoid then return end

    if not FlyVelocity or not FlyVelocity.Parent then StartFly() end
    if not FlyVelocity then return end

    local look = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector
    local direction = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += look end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= look end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += right end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= right end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.yAxis end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction -= Vector3.yAxis end
    if direction.Magnitude > 0 then direction = direction.Unit * FlySpeed else direction = Vector3.zero end
    FlyVelocity.VectorVelocity = direction
    root.AssemblyAngularVelocity = Vector3.zero
end)

--==================================================
-- CHARACTER MAINTENANCE
--==================================================

local function ApplyCharacterSettings(character)
local humanoid = character:WaitForChild("Humanoid", 5)

if humanoid then
if WalkSpeedEnabled then humanoid.WalkSpeed = WalkSpeed end
if JumpPowerEnabled then
humanoid.UseJumpPower = true
humanoid.JumpPower = JumpPower
end
end

task.wait(0.25)

for _, object in ipairs(character:GetDescendants()) do
if object:IsA("BasePart") then
object.CanCollide = CollisionEnabled
end
end

ApplyInvisible()
end

LocalPlayer.CharacterAdded:Connect(function(character)
task.spawn(function()
StopFly()
ApplyCharacterSettings(character)
end)
end)

local gravityUpdate = 0
RunService.Heartbeat:Connect(function(dt)
gravityUpdate += dt

local humanoid = GetHumanoid()
if humanoid then
if WalkSpeedEnabled then humanoid.WalkSpeed = WalkSpeed end
if JumpPowerEnabled then
humanoid.UseJumpPower = true
humanoid.JumpPower = JumpPower
end
end

if GravityEnabled and gravityUpdate >= 0.1 then
gravityUpdate = 0
Workspace.Gravity = Gravity
end
end)

--==================================================
-- VISUALS PAGE
--==================================================

local VisualsPage = Pages.Visuals

PageHeader(
VisualsPage,
"Visuals",
"Player and NPC visual overlays."
)

--==================================================
-- COLOR PICKER
--==================================================

local function CreateColorPicker(parent, initialColor, callback)

local button = Create("TextButton", {
BackgroundColor3 = initialColor,
Text = "",
AutoButtonColor = false,
Size = UDim2.fromOffset(34, 24),
Position = UDim2.new(1, -47, 0.5, -12),
ZIndex = 50,
}, parent)

Round(button, 6)
Stroke(button, C.Border, 0, 1)

local popup = Create("Frame", {
BackgroundColor3 = C.Panel,
BorderSizePixel = 0,
Size = UDim2.fromOffset(210, 210),
Position = UDim2.new(1, -215, 1, 5),
Visible = false,
ZIndex = 100,
}, parent)

Round(popup, 8)
Stroke(popup, C.Border, 0, 1)

local saturation = Create("ImageLabel", {
BackgroundColor3 = Color3.fromRGB(255, 0, 0),
Image = "rbxassetid://4155801252",
ImageColor3 = Color3.fromRGB(255, 0, 0),
Size = UDim2.fromOffset(170, 150),
Position = UDim2.fromOffset(10, 10),
ZIndex = 101,
}, popup)

-- Black overlay
local blackOverlay = Create("Frame", {
BackgroundColor3 = Color3.new(0, 0, 0),
BackgroundTransparency = 0,
BorderSizePixel = 0,
Size = UDim2.fromScale(1, 1),
ZIndex = 102,
}, saturation)

local blackGradient = Create("UIGradient", {
Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 1),
NumberSequenceKeypoint.new(1, 0),
}),
Rotation = 0,
}, blackOverlay)

local whiteGradient = Create("UIGradient", {
Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 0),
NumberSequenceKeypoint.new(1, 1),
}),
Rotation = 90,
}, saturation)

local hue = Create("Frame", {
BackgroundColor3 = Color3.new(1, 1, 1),
Size = UDim2.fromOffset(15, 150),
Position = UDim2.fromOffset(185, 10),
BorderSizePixel = 0,
ZIndex = 101,
}, popup)

local hueGradient = Create("UIGradient", {
Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 255, 0)),
ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
}),
Rotation = 90,
}, hue)

local hueValue = 0
local satValue = 1
local valValue = 1

local currentColor = initialColor

local function UpdateColor()

currentColor = Color3.fromHSV(
hueValue,
satValue,
valValue
)

button.BackgroundColor3 = currentColor
callback(currentColor)

saturation.ImageColor3 =
Color3.fromHSV(hueValue, 1, 1)
end

local function HookPicker(object, mode)

local dragging = false

object.InputBegan:Connect(function(input)

if input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch then

dragging = true

local pos = input.Position
local absolute = object.AbsolutePosition
local size = object.AbsoluteSize

if mode == "hue" then

hueValue = Clamp(
(pos.Y - absolute.Y) / size.Y,
0,
1
)

else

satValue = Clamp(
(pos.X - absolute.X) / size.X,
0,
1
)

valValue = 1 - Clamp(
(pos.Y - absolute.Y) / size.Y,
0,
1
)
end

UpdateColor()
end
end)

UserInputService.InputChanged:Connect(function(input)

if not dragging then
return
end

if input.UserInputType ~= Enum.UserInputType.MouseMovement
and input.UserInputType ~= Enum.UserInputType.Touch then
return
end

local pos = input.Position
local absolute = object.AbsolutePosition
local size = object.AbsoluteSize

if mode == "hue" then

hueValue = Clamp(
(pos.Y - absolute.Y) / size.Y,
0,
1
)

else

satValue = Clamp(
(pos.X - absolute.X) / size.X,
0,
1
)

valValue = 1 - Clamp(
(pos.Y - absolute.Y) / size.Y,
0,
1
)

end

UpdateColor()
end)

UserInputService.InputEnded:Connect(function(input)

if input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch then

dragging = false
end
end)
end

HookPicker(saturation, "sv")
HookPicker(hue, "hue")

button.MouseButton1Click:Connect(function()

PlayClick()

popup.Visible = not popup.Visible

if popup.Visible then
popup.ZIndex = 100
end
end)

return {
Button = button,

Set = function(color)
currentColor = color

local h, s, v = color:ToHSV()

hueValue = h
satValue = s
valValue = v

UpdateColor()
end,

Get = function()
return currentColor
end,
}
end

--==================================================
-- VISUAL STATE
--==================================================

local VisualSettings = {
Player = {
Highlight = false,
HighlightColor = Color3.fromRGB(255, 255, 255),

Tracers = false,
TracersColor = Color3.fromRGB(255, 255, 255),

Arrows = false,
ArrowsColor = Color3.fromRGB(255, 255, 255),

Box = false,
BoxColor = Color3.fromRGB(255, 255, 255),

Name = false,
NameColor = Color3.fromRGB(255, 255, 255),

Distance = false,
DistanceColor = Color3.fromRGB(255, 255, 255),
},

NPC = {
Highlight = false,
HighlightColor = Color3.fromRGB(255, 255, 255),

Tracers = false,
TracersColor = Color3.fromRGB(255, 255, 255),

Arrows = false,
ArrowsColor = Color3.fromRGB(255, 255, 255),

Box = false,
BoxColor = Color3.fromRGB(255, 255, 255),

Name = false,
NameColor = Color3.fromRGB(255, 255, 255),

Distance = false,
DistanceColor = Color3.fromRGB(255, 255, 255),
},
}

--==================================================
-- VISUAL ROW
--==================================================

local function CreateVisualRow(
page,
y,
text,
category,
setting,
colorSetting
)

local row = Create("Frame", {
BackgroundColor3 = C.Panel2,
BorderSizePixel = 0,
Size = UDim2.new(1, -10, 0, 34),
Position = UDim2.fromOffset(5, y),
}, page)

Stroke(row, C.Border, 0, 1)

local label = Create("TextLabel", {
BackgroundTransparency = 1,
Text = text,
Font = Enum.Font.Code,
TextSize = 10,
TextColor3 = C.White,
TextXAlignment = Enum.TextXAlignment.Left,
Size = UDim2.new(1, -160, 1, 0),
Position = UDim2.fromOffset(13, 0),
}, row)

local toggle = CreateToggle(
row,
"Enable",
0,
function(state)

VisualSettings[category][setting] = state
end
)

toggle.Button.Position = UDim2.new(1, -145, 0, 6)
toggle.Button.Size = UDim2.fromOffset(90, 30)

toggle.Button:FindFirstChildOfClass("TextLabel").TextXAlignment =
Enum.TextXAlignment.Center

local picker = CreateColorPicker(
row,
VisualSettings[category][colorSetting],
function(color)

VisualSettings[category][colorSetting] = color
end
)

return toggle, picker
end

--==================================================
-- PLAYER VISUALS
--==================================================

CreateSectionLabel(VisualsPage, "Players", 75)

CreateVisualRow(
VisualsPage,
102,
"Player Highlight",
"Player",
"Highlight",
"HighlightColor"
)

CreateVisualRow(
VisualsPage,
150,
"Player Tracers",
"Player",
"Tracers",
"TracersColor"
)

CreateVisualRow(
VisualsPage,
198,
"Player Arrows",
"Player",
"Arrows",
"ArrowsColor"
)

CreateVisualRow(
VisualsPage,
246,
"Player Box",
"Player",
"Box",
"BoxColor"
)

CreateVisualRow(
VisualsPage,
294,
"Player Name",
"Player",
"Name",
"NameColor"
)

CreateVisualRow(
VisualsPage,
342,
"Player Distance",
"Player",
"Distance",
"DistanceColor"
)

--==================================================
-- NPC VISUALS
--==================================================

CreateSectionLabel(VisualsPage, "NPC", 405)

CreateVisualRow(
VisualsPage,
432,
"NPC Highlight",
"NPC",
"Highlight",
"HighlightColor"
)

CreateVisualRow(
VisualsPage,
480,
"NPC Tracers",
"NPC",
"Tracers",
"TracersColor"
)

CreateVisualRow(
VisualsPage,
528,
"NPC Arrows",
"NPC",
"Arrows",
"ArrowsColor"
)

CreateVisualRow(
VisualsPage,
576,
"NPC Box",
"NPC",
"Box",
"BoxColor"
)

CreateVisualRow(
VisualsPage,
624,
"NPC Name",
"NPC",
"Name",
"NameColor"
)

CreateVisualRow(
VisualsPage,
672,
"NPC Distance",
"NPC",
"Distance",
"DistanceColor"
)

--==================================================
-- VISUAL GUI
--==================================================

local VisualGui = Create("ScreenGui", {
Name = "FlisiumVisuals",
ResetOnSpawn = false,
IgnoreGuiInset = true,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
DisplayOrder = 50,
}, PlayerGui)

--==================================================
-- VISUAL OBJECT STORAGE
--==================================================

local PlayerHighlights = {}
local NPCVisuals = {}

local function GetRoot(model)

return model:FindFirstChild("HumanoidRootPart")
or model.PrimaryPart
or model:FindFirstChildWhichIsA("BasePart")
end

local function IsPlayerCharacter(model)

for _, player in ipairs(Players:GetPlayers()) do

if player.Character == model then
return true
end

end

return false
end

local function IsNPC(model)

if not model:IsA("Model") then
return false
end

if IsPlayerCharacter(model) then
return false
end

local humanoid = model:FindFirstChildOfClass("Humanoid")

return humanoid ~= nil
end

--==================================================
-- BILLBOARD VISUAL
--==================================================

local function CreateBillboard(model)

local root = GetRoot(model)

if not root then
return nil
end

local billboard = Instance.new("BillboardGui")

billboard.Name = "FlisiumESP"
billboard.Adornee = root
billboard.AlwaysOnTop = true
billboard.Size = UDim2.fromOffset(180, 100)
billboard.StudsOffset = Vector3.new(0, 3.2, 0)
billboard.Enabled = true
billboard.Parent = VisualGui

local box = Instance.new("Frame")

box.Name = "Box"
box.BackgroundTransparency = 1
box.BorderSizePixel = 1
box.Size = UDim2.fromOffset(45, 65)
box.Position = UDim2.new(0.5, -22, 0, 5)
box.Visible = false
box.Parent = billboard

local name = Instance.new("TextLabel")

name.Name = "Name"
name.BackgroundTransparency = 1
name.Font = Enum.Font.Code
name.TextSize = 11
name.TextStrokeTransparency = 0.4
name.Size = UDim2.new(1, 0, 0, 18)
name.Position = UDim2.fromOffset(0, -16)
name.Text = model.Name
name.Visible = false
name.Parent = billboard

local distance = Instance.new("TextLabel")

distance.Name = "Distance"
distance.BackgroundTransparency = 1
distance.Font = Enum.Font.Code
distance.TextSize = 9
distance.TextStrokeTransparency = 0.4
distance.Size = UDim2.new(1, 0, 0, 16)
distance.Position = UDim2.new(0, 0, 0, 78)
distance.Visible = false
distance.Parent = billboard

return {
Gui = billboard,
Box = box,
Name = name,
Distance = distance,
}
end

--==================================================
-- TRACERS
--==================================================

local function CreateTracer()

local line = Create("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5),
BackgroundColor3 = Color3.new(1, 1, 1),
BorderSizePixel = 0,
Size = UDim2.fromOffset(1, 1),
Visible = false,
ZIndex = 40,
}, VisualGui)

return line
end

local PlayerTracers = {}
local NPCTracers = {}

local function DrawTracer(line, startPos, endPos, color)

local delta = endPos - startPos
local length = delta.Magnitude

if length <= 1 then
line.Visible = false
return
end

line.Visible = true
line.BackgroundColor3 = color

line.Position = UDim2.fromOffset(
(startPos.X + endPos.X) / 2,
(startPos.Y + endPos.Y) / 2
)

line.Size = UDim2.fromOffset(length, 1)

line.Rotation = math.deg(
math.atan2(delta.Y, delta.X)
)
end

--==================================================
-- ARROWS / EDGE DOTS
--==================================================

local PlayerArrows = {}
local NPCArrows = {}

local function CreateArrow()

local arrow = Create("TextLabel", {
BackgroundTransparency = 1,
Text = "•",
Font = Enum.Font.Code,
TextSize = 25,
TextColor3 = C.White,
TextStrokeTransparency = 0.2,
Visible = false,
AnchorPoint = Vector2.new(0.5, 0.5),
Size = UDim2.fromOffset(30, 30),
ZIndex = 45,
}, VisualGui)

return arrow
end

local function GetEdgePosition(screenPos, viewport, color)

local center = Vector2.new(
viewport.X / 2,
viewport.Y / 2
)

local direction = screenPos - center

if direction.Magnitude < 0.01 then
direction = Vector2.new(0, -1)
end

direction = direction.Unit

local margin = 25

local tx

if direction.X > 0 then
tx = (viewport.X / 2 - margin) / direction.X
else
tx = (-(viewport.X / 2 - margin)) / direction.X
end

local ty

if direction.Y > 0 then
ty = (viewport.Y / 2 - margin) / direction.Y
else
ty = (-(viewport.Y / 2 - margin)) / direction.Y
end

local t = math.min(math.abs(tx), math.abs(ty))

local point = center + direction * t

point = Vector2.new(
Clamp(point.X, margin, viewport.X - margin),
Clamp(point.Y, margin, viewport.Y - margin)
)

return point, color
end

--==================================================
-- VISUAL OBJECT UPDATE
--==================================================

local function UpdateModelVisual(
model,
settings,
storage,
tracerStorage,
arrowStorage,
isNPC
)

local root = GetRoot(model)

if not root then
return
end

-- Billboard
if not storage[model] then
storage[model] = CreateBillboard(model)
end

local visual = storage[model]

if not visual then
return
end

local camera = Workspace.CurrentCamera

if not camera then
return
end

local screenPos, onScreen =
camera:WorldToViewportPoint(root.Position)

-- Highlight
local highlightName = "FlisiumHighlight"

local highlight =
model:FindFirstChild(highlightName)

if settings.Highlight then

if not highlight then

highlight = Instance.new("Highlight")
highlight.Name = highlightName
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.FillTransparency = 0.82
highlight.OutlineTransparency = 0
highlight.Parent = model
end

highlight.FillColor =
settings.HighlightColor

highlight.OutlineColor =
settings.HighlightColor

highlight.Enabled = true

elseif highlight then

highlight.Enabled = false
end

-- Box
visual.Box.Visible = settings.Box

if settings.Box then
visual.Box.BorderColor3 = settings.BoxColor
end

-- Name
visual.Name.Visible = settings.Name

if settings.Name then

if isNPC then
visual.Name.Text = model.Name
else
local player = Players:GetPlayerFromCharacter(model)

if player then
visual.Name.Text = player.DisplayName
end
end

visual.Name.TextColor3 = settings.NameColor
end

-- Distance
visual.Distance.Visible = settings.Distance

if settings.Distance then

local character = LocalPlayer.Character
local localRoot =
character and GetRoot(character)

if localRoot then

local distance =
(localRoot.Position - root.Position).Magnitude

visual.Distance.Text =
string.format("%d studs", distance)

visual.Distance.TextColor3 =
settings.DistanceColor
end
end

-- Tracer
if not tracerStorage[model] then
tracerStorage[model] = CreateTracer()
end

local tracer = tracerStorage[model]

if settings.Tracers and onScreen and screenPos.Z > 0 then

local viewport = camera.ViewportSize

DrawTracer(
tracer,
Vector2.new(viewport.X / 2, viewport.Y - 30),
Vector2.new(screenPos.X, screenPos.Y),
settings.TracersColor
)

else

tracer.Visible = false
end

-- Arrow
if not arrowStorage[model] then
arrowStorage[model] = CreateArrow()
end

local arrow = arrowStorage[model]

if settings.Arrows and (not onScreen or screenPos.Z <= 0) then

local viewport = camera.ViewportSize

local worldPosition = root.Position

local projected, behind =
camera:WorldToViewportPoint(worldPosition)

if behind then
projected = Vector3.new(
- projected.X,
- projected.Y,
projected.Z
)
end

local point =
GetEdgePosition(
Vector2.new(projected.X, projected.Y),
viewport,
settings.ArrowsColor
)

arrow.Visible = true
arrow.Position =
UDim2.fromOffset(point.X, point.Y)

arrow.TextColor3 =
settings.ArrowsColor

else

arrow.Visible = false
end
end

--==================================================
-- REMOVE VISUAL
--==================================================

local function RemoveVisual(
model,
storage,
tracerStorage,
arrowStorage
)

local visual = storage[model]

if visual then

if visual.Gui then
visual.Gui:Destroy()
end

storage[model] = nil
end

local tracer = tracerStorage[model]

if tracer then
tracer:Destroy()
tracerStorage[model] = nil
end

local arrow = arrowStorage[model]

if arrow then
arrow:Destroy()
arrowStorage[model] = nil
end

local highlight =
model:FindFirstChild("FlisiumHighlight")

if highlight then
highlight:Destroy()
end
end

--==================================================
-- VISUAL UPDATE LOOP
--==================================================

local visualTimer = 0

RunService.RenderStepped:Connect(function(dt)

visualTimer += dt

if visualTimer < 0.08 then
return
end

visualTimer = 0

local camera = Workspace.CurrentCamera

if not camera then
return
end

-- Players
local activePlayers = {}

for _, player in ipairs(Players:GetPlayers()) do

if player ~= LocalPlayer
and player.Character then

local character = player.Character

activePlayers[character] = true

UpdateModelVisual(
character,
VisualSettings.Player,
PlayerHighlights,
PlayerTracers,
PlayerArrows,
false
)
end
end

for model in pairs(PlayerHighlights) do

if not activePlayers[model] then

RemoveVisual(
model,
PlayerHighlights,
PlayerTracers,
PlayerArrows
)
end
end

-- NPCs
local activeNPCs = {}

for _, object in ipairs(Workspace:GetChildren()) do

if IsNPC(object) then

activeNPCs[object] = true

UpdateModelVisual(
object,
VisualSettings.NPC,
NPCVisuals,
NPCTracers,
NPCArrows,
true
)
end
end

for model in pairs(NPCVisuals) do

if not activeNPCs[model] then

RemoveVisual(
model,
NPCVisuals,
NPCTracers,
NPCArrows
)
end
end
end)

--==================================================
-- PLAYER CHARACTER MAINTENANCE
--==================================================

local function ApplyCharacterSettings(character)

local humanoid =
character:WaitForChild("Humanoid", 5)

if humanoid then

if WalkSpeedEnabled then
humanoid.WalkSpeed = WalkSpeed
end

if JumpPowerEnabled then
humanoid.UseJumpPower = true
humanoid.JumpPower = JumpPower
end
end

task.wait(0.25)

for _, object in ipairs(character:GetDescendants()) do

if object:IsA("BasePart") then

object.CanCollide = NoclipEnabled and false or CollisionEnabled

if Invisible then
object.LocalTransparencyModifier =
InvisibleTransparency
end
end
end
end

LocalPlayer.CharacterAdded:Connect(function(character)
task.spawn(function()
ApplyCharacterSettings(character)
end)
end)

--==================================================
-- HEARTBEAT MOVEMENT
--==================================================

local gravityUpdate = 0

RunService.Heartbeat:Connect(function(dt)

gravityUpdate += dt

local humanoid = GetHumanoid()

if humanoid then

if WalkSpeedEnabled then
humanoid.WalkSpeed = WalkSpeed
end

if JumpPowerEnabled then
humanoid.UseJumpPower = true
humanoid.JumpPower = JumpPower
end
end

if GravityEnabled then

if gravityUpdate >= 0.1 then
gravityUpdate = 0
Workspace.Gravity = Gravity
end

end
end)

--==================================================
-- COMBAT PAGE
--==================================================

local CombatPage = Pages.Combat

PageHeader(
CombatPage,
"Combat",
"Targeting, FOV and tool-based trigger controls for your own experience."
)

local AimAssistEnabled = false
local FOVEnabled = true
local FOVRadius = 150
local AimSmoothness = 0
local AimSensitivity = 1
local TriggerbotEnabled = false
local TriggerbotDelay = 0.08
local TriggerbotRange = 1000
local TriggerbotLast = 0

local FOVCircle = Create("Frame", {
BackgroundTransparency = 1,
BorderSizePixel = 0,
Size = UDim2.fromOffset(FOVRadius * 2, FOVRadius * 2),
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromScale(0.5, 0.5),
Visible = true,
ZIndex = 5,
}, Gui)
Round(FOVCircle, 999)
Stroke(FOVCircle, C.White, 0.15, 1)

local FOVLabel = Create("TextLabel", {
BackgroundTransparency = 1,
Text = "FOV",
Font = Enum.Font.Code,
TextSize = 8,
TextColor3 = C.Muted,
AnchorPoint = Vector2.new(0.5, 1),
Position = UDim2.fromScale(0.5, 0.5),
Size = UDim2.fromOffset(50, 14),
Visible = true,
ZIndex = 6,
}, Gui)

local function UpdateFOVCircle()
FOVCircle.Size = UDim2.fromOffset(FOVRadius * 2, FOVRadius * 2)
FOVCircle.Visible = FOVEnabled
FOVLabel.Visible = FOVEnabled
end

CreateSectionLabel(CombatPage, "Aim Assist", 75)
CreateToggle(CombatPage, "Aim Assist", 105, function(state)
AimAssistEnabled = state
end)
CreateToggle(CombatPage, "FOV Circle", 155, function(state)
FOVEnabled = state
UpdateFOVCircle()
end)

local function CreateCombatValueRow(y, title, min, max, default, formatter, setter)
local row = Create("Frame", {
BackgroundColor3 = C.Panel2,
BorderSizePixel = 0,
Size = UDim2.new(1, -10, 0, 72),
Position = UDim2.fromOffset(5, y),
}, CombatPage)
Stroke(row, C.Border, 0, 1)
Create("TextLabel", {
BackgroundTransparency = 1,
Text = title,
Font = Enum.Font.Code,
TextSize = 10,
TextColor3 = C.White,
TextXAlignment = Enum.TextXAlignment.Left,
Size = UDim2.fromOffset(150, 25),
Position = UDim2.fromOffset(12, 8),
}, row)
local holder = Create("Frame", {
BackgroundTransparency = 1,
Size = UDim2.new(1, -105, 0, 30),
Position = UDim2.fromOffset(12, 38),
}, row)
local box
local slider = CreateSlider(holder, min, max, default, function(value)
setter(value)
if box then box.Text = formatter(value) end
end)
box = CreateValueBox(row, formatter(default), function(value)
local clamped = Clamp(value, min, max)
setter(clamped)
box.Text = formatter(clamped)
slider.SetSilent(clamped)
end)
return slider, box
end

local FOVSlider, FOVBox = CreateCombatValueRow(205, "FOV Radius", 25, 600, FOVRadius,
function(v) return tostring(math.floor(v + 0.5)) end,
function(v)
FOVRadius = math.floor(v + 0.5)
UpdateFOVCircle()
end)

local SmoothSlider, SmoothBox = CreateCombatValueRow(285, "Smoothness", 0, 1, AimSmoothness,
function(v) return string.format("%.2f", v) end,
function(v) AimSmoothness = Clamp(v, 0, 1) end)

local SensSlider, SensBox = CreateCombatValueRow(365, "Sensitivity", 0.1, 5, AimSensitivity,
function(v) return string.format("%.2f", v) end,
function(v) AimSensitivity = Clamp(v, 0.1, 5) end)

CreateSectionLabel(CombatPage, "Triggerbot", 445)
CreateToggle(CombatPage, "Triggerbot", 475, function(state)
TriggerbotEnabled = state
end)

local TriggerDelaySlider, TriggerDelayBox = CreateCombatValueRow(525, "Trigger Delay", 0, 0.5, TriggerbotDelay,
function(v) return string.format("%.2f s", v) end,
function(v) TriggerbotDelay = Clamp(v, 0, 0.5) end)

local TriggerRangeSlider, TriggerRangeBox = CreateCombatValueRow(605, "Trigger Range", 10, 1000, TriggerbotRange,
function(v) return tostring(math.floor(v + 0.5)) .. " studs" end,
function(v) TriggerbotRange = math.floor(v + 0.5) end)

local AimInfo = Create("Frame", {
BackgroundColor3 = C.Panel2,
BorderSizePixel = 0,
Size = UDim2.new(1, -10, 0, 82),
Position = UDim2.fromOffset(5, 685),
}, CombatPage)
Stroke(AimInfo, C.Border, 0, 1)
Create("TextLabel", {
BackgroundTransparency = 1,
Text = "Targeting",
Font = Enum.Font.Code,
TextSize = 12,
TextColor3 = C.White,
TextXAlignment = Enum.TextXAlignment.Left,
Size = UDim2.new(1, -24, 0, 20),
Position = UDim2.fromOffset(12, 9),
}, AimInfo)
Create("TextLabel", {
BackgroundTransparency = 1,
Text = "Shush/Silent Aim is intentionally omitted: a normal LocalScript cannot safely rewrite arbitrary weapon hit registration. Triggerbot uses Tool:Activate() when your equipped tool supports it.",
Font = Enum.Font.Code,
TextSize = 9,
TextColor3 = C.Muted,
TextXAlignment = Enum.TextXAlignment.Left,
TextWrapped = true,
Size = UDim2.new(1, -24, 0, 42),
Position = UDim2.fromOffset(12, 31),
}, AimInfo)

--==================================================
-- FOV / TARGETING
--==================================================

local function GetAimTarget()
local camera = Workspace.CurrentCamera
if not camera then return nil end
local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
local closest
local closestDistance = math.huge
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LocalPlayer and player.Character then
local character = player.Character
local humanoid = character:FindFirstChildOfClass("Humanoid")
local root = character:FindFirstChild("HumanoidRootPart")
if humanoid and humanoid.Health > 0 and root then
local screen, visible = camera:WorldToViewportPoint(root.Position)
if visible and screen.Z > 0 then
local distance = (Vector2.new(screen.X, screen.Y) - center).Magnitude
local worldDistance = (camera.CFrame.Position - root.Position).Magnitude
if distance <= FOVRadius and worldDistance <= TriggerbotRange and distance < closestDistance then
closestDistance = distance
closest = root
end
end
end
end
end
return closest
end

local function GetCrosshairTarget()
local camera = Workspace.CurrentCamera
if not camera then return nil end
local viewport = camera.ViewportSize
local ray = camera:ViewportPointToRay(viewport.X / 2, viewport.Y / 2)
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
params.FilterDescendantsInstances = {LocalPlayer.Character}
params.IgnoreWater = true
local result = Workspace:Raycast(ray.Origin, ray.Direction * TriggerbotRange, params)
if not result then return nil end
local model = result.Instance:FindFirstAncestorOfClass("Model")
if not model then return nil end
local player = Players:GetPlayerFromCharacter(model)
if not player or player == LocalPlayer then return nil end
local humanoid = model:FindFirstChildOfClass("Humanoid")
if not humanoid or humanoid.Health <= 0 then return nil end
return model
end

local function ActivateEquippedTool()
local character = LocalPlayer.Character
if not character then return false end
local tool = character:FindFirstChildOfClass("Tool")
if not tool then return false end
local ok = pcall(function()
tool:Activate()
end)
return ok
end

RunService.RenderStepped:Connect(function(dt)
local camera = Workspace.CurrentCamera
if not camera then return end
local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
FOVCircle.Position = UDim2.fromOffset(center.X, center.Y)
FOVLabel.Position = UDim2.fromOffset(center.X, center.Y - FOVRadius - 4)

if AimAssistEnabled then
local target = GetAimTarget()
if target then
local targetCFrame = CFrame.lookAt(camera.CFrame.Position, target.Position)
local alpha
if AimSmoothness <= 0 then
alpha = 1
else
alpha = Clamp((1 - AimSmoothness) * AimSensitivity * dt * 8, 0.01, 1)
end
camera.CFrame = camera.CFrame:Lerp(targetCFrame, alpha)
end
end

if TriggerbotEnabled and os.clock() - TriggerbotLast >= TriggerbotDelay then
local target = GetCrosshairTarget()
if target then
if ActivateEquippedTool() then
TriggerbotLast = os.clock()
end
end
end
end)

--==================================================
-- GAME PAGE
--==================================================

local GamePage = Pages.Game
PageHeader(GamePage, "Game", "Useful client-side utilities for your own experience.")
CreateSectionLabel(GamePage, "Utilities", 75)

local FPSLabel = Create("TextLabel", {
BackgroundColor3 = C.Panel2, BorderSizePixel = 0, Text = "FPS  --",
Font = Enum.Font.Code, TextSize = 10, TextColor3 = C.White,
TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, -10, 0, 34),
Position = UDim2.fromOffset(5, 102),
}, GamePage)
Stroke(FPSLabel, C.Border, 0, 1)

local PingLabel = Create("TextLabel", {
BackgroundColor3 = C.Panel2, BorderSizePixel = 0, Text = "Server: " .. game.JobId,
Font = Enum.Font.Code, TextSize = 10, TextColor3 = C.White,
TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
Size = UDim2.new(1, -10, 0, 34), Position = UDim2.fromOffset(5, 152),
}, GamePage)
Stroke(PingLabel, C.Border, 0, 1)

local RejoinButton = Create("TextButton", {
BackgroundColor3 = C.Panel2, BorderSizePixel = 0, Text = "RELOAD CHARACTER",
Font = Enum.Font.Code, TextSize = 10, TextColor3 = C.White, AutoButtonColor = false,
Size = UDim2.new(1, -10, 0, 34), Position = UDim2.fromOffset(5, 202),
}, GamePage)
Stroke(RejoinButton, C.Border, 0, 1)
RejoinButton.MouseButton1Click:Connect(function()
PlayClick()
local humanoid = GetHumanoid()
if humanoid then humanoid.Health = 0 end
end)

local FullscreenButton = Create("TextButton", {
BackgroundColor3 = C.Panel2, BorderSizePixel = 0, Text = "TOGGLE FULLSCREEN UI",
Font = Enum.Font.Code, TextSize = 10, TextColor3 = C.White, AutoButtonColor = false,
Size = UDim2.new(1, -10, 0, 34), Position = UDim2.fromOffset(5, 252),
}, GamePage)
Stroke(FullscreenButton, C.Border, 0, 1)
FullscreenButton.MouseButton1Click:Connect(function()
PlayClick()
Maximized = not Maximized
if Maximized then
Main.Size = UDim2.new(0.90, 0, 0.90, 0)
Main.Position = UDim2.new(0.05, 0, 0.05, 0)
else
Main.Size = NormalSize
Main.Position = NormalPosition
end
end)

local InfoBox = Create("Frame", {
BackgroundColor3 = C.Panel2, BorderSizePixel = 0, Size = UDim2.new(1, -10, 0, 92),
Position = UDim2.fromOffset(5, 302),
}, GamePage)
Stroke(InfoBox, C.Border, 0, 1)
Create("TextLabel", {
BackgroundTransparency = 1, Text = "CLIENT INFO", Font = Enum.Font.Code, TextSize = 10,
TextColor3 = C.Muted, TextXAlignment = Enum.TextXAlignment.Left,
Size = UDim2.new(1, -24, 0, 18), Position = UDim2.fromOffset(12, 8),
}, InfoBox)
local ClientInfo = Create("TextLabel", {
BackgroundTransparency = 1, Text = "Player: " .. LocalPlayer.DisplayName .. "\nUserId: " .. LocalPlayer.UserId .. "\nPlaceId: " .. game.PlaceId,
Font = Enum.Font.Code, TextSize = 10, TextColor3 = C.White, TextXAlignment = Enum.TextXAlignment.Left,
Size = UDim2.new(1, -24, 0, 60), Position = UDim2.fromOffset(12, 28),
}, InfoBox)

local fpsAccum, fpsFrames = 0, 0
RunService.RenderStepped:Connect(function(dt)
fpsAccum += dt
fpsFrames += 1
if fpsAccum >= 0.5 then
local fps = math.floor(fpsFrames / fpsAccum + 0.5)
FPSLabel.Text = "FPS  " .. fps
fpsAccum, fpsFrames = 0, 0
end
end)

--==================================================
-- SETTINGS PAGE
--==================================================

local SettingsPage = Pages.Settings

PageHeader(
SettingsPage,
"Settings",
"Flisium interface settings and session configs."
)

CreateSectionLabel(SettingsPage, "Interface", 90)

local ClockToggle = CreateToggle(SettingsPage, "Clock", 120, function(state)
ClockEnabled = state
if ClockTab then
if state then
ShowClock()
else
HideClock()
end
end
end)

CreateToggle(SettingsPage, "UI Sounds", 170, function(state)
UISoundsEnabled = state
end)

CreateToggle(SettingsPage, "Animations", 220, function(state)
-- Kept as a UI preference; core movement/target loops remain active.
end)

local SFXRow = Create("Frame", {
BackgroundColor3 = C.Panel2,
BorderSizePixel = 0,
Size = UDim2.new(1, -10, 0, 70),
Position = UDim2.fromOffset(5, 270),
}, SettingsPage)
Stroke(SFXRow, C.Border, 0, 1)

Create("TextLabel", {
BackgroundTransparency = 1,
Text = "SFX Volume",
Font = Enum.Font.Code,
TextSize = 10,
TextColor3 = C.White,
TextXAlignment = Enum.TextXAlignment.Left,
Size = UDim2.fromOffset(140, 25),
Position = UDim2.fromOffset(12, 8),
}, SFXRow)

local SFXBox
local SFXSlider = CreateSlider(Create("Frame", {
BackgroundTransparency = 1,
Size = UDim2.new(1, -105, 0, 30),
Position = UDim2.fromOffset(12, 38),
}, SFXRow), 0, 100, SFXVolume, function(value)
SFXVolume = math.floor(value + 0.5)
SFXBox.Text = tostring(SFXVolume) .. "%"
end)

SFXBox = CreateValueBox(SFXRow, 100, function(value)
SFXVolume = Clamp(math.floor(value + 0.5), 0, 100)
SFXBox.Text = tostring(SFXVolume) .. "%"
SFXSlider.SetSilent(SFXVolume)
end)
SFXBox.Text = "100%"

local UISizeRow = Create("Frame", {
BackgroundColor3 = C.Panel2,
BorderSizePixel = 0,
Size = UDim2.new(1, -10, 0, 70),
Position = UDim2.fromOffset(5, 350),
}, SettingsPage)
Stroke(UISizeRow, C.Border, 0, 1)

Create("TextLabel", {
BackgroundTransparency = 1,
Text = "UI Size",
Font = Enum.Font.Code,
TextSize = 10,
TextColor3 = C.White,
TextXAlignment = Enum.TextXAlignment.Left,
Size = UDim2.fromOffset(140, 25),
Position = UDim2.fromOffset(12, 8),
}, UISizeRow)

UIScaleObject = Create("UIScale", {Scale = 1}, Main)

local UISizeBox
local UISizeSlider = CreateSlider(Create("Frame", {
BackgroundTransparency = 1,
Size = UDim2.new(1, -105, 0, 30),
Position = UDim2.fromOffset(12, 38),
}, UISizeRow), 50, 150, 100, function(value)
UISize = math.floor(value + 0.5)
UIScaleObject.Scale = UISize / 100
UISizeBox.Text = tostring(UISize) .. "%"
end)

UISizeBox = CreateValueBox(UISizeRow, 100, function(value)
UISize = Clamp(math.floor(value + 0.5), 50, 150)
UISizeBox.Text = tostring(UISize) .. "%"
UISizeSlider.SetSilent(UISize)
UIScaleObject.Scale = UISize / 100
end)
UISizeBox.Text = "100%"

--==================================================
-- CONFIG SYSTEM (SESSION ONLY)
--==================================================

CreateSectionLabel(SettingsPage, "Configs", 435)

local ConfigNameBox = Create("TextBox", {
BackgroundColor3 = C.Panel3,
BorderSizePixel = 0,
Text = "",
PlaceholderText = "Config name...",
Font = Enum.Font.Code,
TextSize = 10,
TextColor3 = C.White,
PlaceholderColor3 = C.Muted,
ClearTextOnFocus = false,
Size = UDim2.new(1, -10, 0, 34),
Position = UDim2.fromOffset(5, 462),
}, SettingsPage)
Round(ConfigNameBox, 5)
Stroke(ConfigNameBox, C.Border, 0, 1)

local ConfigDropdown = Create("TextButton", {
BackgroundColor3 = C.Panel2,
BorderSizePixel = 0,
Text = "Select Config",
Font = Enum.Font.Code,
TextSize = 10,
TextColor3 = C.White,
AutoButtonColor = false,
Size = UDim2.new(1, -10, 0, 34),
Position = UDim2.fromOffset(5, 504),
}, SettingsPage)
Stroke(ConfigDropdown, C.Border, 0, 1)

local ConfigList = Create("ScrollingFrame", {
BackgroundColor3 = C.Panel,
BorderSizePixel = 0,
Size = UDim2.new(1, -10, 0, 100),
Position = UDim2.fromOffset(5, 542),
CanvasSize = UDim2.fromOffset(0, 0),
AutomaticCanvasSize = Enum.AutomaticSize.Y,
ScrollBarThickness = 1,
Visible = false,
ZIndex = 100,
}, SettingsPage)
Stroke(ConfigList, C.Border, 0, 1)

Create("UIListLayout", {
Padding = UDim.new(0, 2),
SortOrder = Enum.SortOrder.LayoutOrder,
}, ConfigList)

local RenameBox = Create("TextBox", {
BackgroundColor3 = C.Panel3,
BorderSizePixel = 0,
Text = "",
PlaceholderText = "New config name...",
Font = Enum.Font.Code,
TextSize = 10,
TextColor3 = C.White,
PlaceholderColor3 = C.Muted,
ClearTextOnFocus = false,
Size = UDim2.new(1, -10, 0, 34),
Position = UDim2.fromOffset(5, 652),
}, SettingsPage)
Round(RenameBox, 5)
Stroke(RenameBox, C.Border, 0, 1)

local function CaptureConfig()
local data = {
WalkSpeed = WalkSpeed,
WalkSpeedEnabled = WalkSpeedEnabled,
JumpPower = JumpPower,
JumpPowerEnabled = JumpPowerEnabled,
Gravity = Gravity,
GravityEnabled = GravityEnabled,
FlySpeed = FlySpeed,
FlyEnabled = FlyEnabled,
CollisionEnabled = CollisionEnabled,
NoclipEnabled = NoclipEnabled,
Invisible = Invisible,
InvisibleTransparency = InvisibleTransparency,
ClockEnabled = ClockEnabled,
UISoundsEnabled = UISoundsEnabled,
SFXVolume = SFXVolume,
UISize = UISize,
AimAssistEnabled = AimAssistEnabled,
FOVEnabled = FOVEnabled,
FOVRadius = FOVRadius,
AimSmoothness = AimSmoothness,
AimSensitivity = AimSensitivity,
TriggerbotEnabled = TriggerbotEnabled,
TriggerbotDelay = TriggerbotDelay,
TriggerbotRange = TriggerbotRange,
}

return data
end

local function ApplyConfig(data)
if not data then return end

WalkSpeed = data.WalkSpeed or WalkSpeed
WalkSpeedEnabled = data.WalkSpeedEnabled or false
JumpPower = data.JumpPower or JumpPower
JumpPowerEnabled = data.JumpPowerEnabled or false
Gravity = data.Gravity or Gravity
GravityEnabled = data.GravityEnabled or false
FlySpeed = data.FlySpeed or FlySpeed
FlyEnabled = data.FlyEnabled or false
CollisionEnabled = data.CollisionEnabled ~= false
NoclipEnabled = data.NoclipEnabled or false
Invisible = data.Invisible or false
InvisibleTransparency = data.InvisibleTransparency or InvisibleTransparency
ClockEnabled = data.ClockEnabled ~= false
UISoundsEnabled = data.UISoundsEnabled ~= false
SFXVolume = Clamp(data.SFXVolume or SFXVolume, 0, 100)
UISize = Clamp(data.UISize or UISize, 50, 150)
AimAssistEnabled = data.AimAssistEnabled or false
FOVEnabled = data.FOVEnabled ~= false
FOVRadius = Clamp(data.FOVRadius or FOVRadius, 25, 600)
AimSmoothness = Clamp(data.AimSmoothness or AimSmoothness, 0, 1)
AimSensitivity = Clamp(data.AimSensitivity or AimSensitivity, 0.1, 5)
TriggerbotEnabled = data.TriggerbotEnabled or false
TriggerbotDelay = Clamp(data.TriggerbotDelay or TriggerbotDelay, 0, 0.5)
TriggerbotRange = Clamp(data.TriggerbotRange or TriggerbotRange, 10, 1000)

WalkSlider.SetSilent(WalkSpeed)
JumpSlider.SetSilent(JumpPower)
GravitySlider.SetSilent(Gravity)
FlySlider.SetSilent(FlySpeed)
InvisibleSlider.SetSilent(InvisibleTransparency)
FOVSlider.SetSilent(FOVRadius)
SmoothSlider.SetSilent(AimSmoothness)
SensSlider.SetSilent(AimSensitivity)
TriggerDelaySlider.SetSilent(TriggerbotDelay)
TriggerRangeSlider.SetSilent(TriggerbotRange)

WalkValueBox.Text = tostring(WalkSpeed)
JumpValueBox.Text = tostring(JumpPower)
GravityValueBox.Text = tostring(Gravity)
FlyValueBox.Text = tostring(FlySpeed)
InvisibleValueBox.Text = string.format("%.2f", InvisibleTransparency)
FOVBox.Text = tostring(FOVRadius)
SmoothBox.Text = string.format("%.2f", AimSmoothness)
SensBox.Text = string.format("%.2f", AimSensitivity)
TriggerDelayBox.Text = string.format("%.2f s", TriggerbotDelay)
TriggerRangeBox.Text = tostring(TriggerbotRange) .. " studs"
SFXBox.Text = tostring(SFXVolume) .. "%"
UISizeBox.Text = tostring(UISize) .. "%"
UIScaleObject.Scale = UISize / 100

if ClockTab then
if ClockEnabled then ShowClock() else HideClock() end
end

ApplyMovement()
ApplyInvisible()
UpdateFOVCircle()
end

local function RefreshConfigList()
for _, child in ipairs(ConfigList:GetChildren()) do
if child:IsA("TextButton") then
child:Destroy()
end
end

for name in pairs(Configs) do
local button = Create("TextButton", {
BackgroundColor3 = C.Panel2,
BorderSizePixel = 0,
Text = name,
Font = Enum.Font.Code,
TextSize = 10,
TextColor3 = C.White,
AutoButtonColor = false,
Size = UDim2.new(1, -4, 0, 28),
ZIndex = 101,
}, ConfigList)

button.MouseButton1Click:Connect(function()
SelectedConfig = name
ConfigDropdown.Text = name
ConfigList.Visible = false
PlayClick()
end)
end
end

local function MakeConfigAction(text, x, callback)
local button = Create("TextButton", {
BackgroundColor3 = C.Panel2,
BorderSizePixel = 0,
Text = text,
Font = Enum.Font.Code,
TextSize = 9,
TextColor3 = C.White,
AutoButtonColor = false,
Size = UDim2.new(0.5, -7, 0, 32),
Position = UDim2.new(x, x == 0 and 5 or 2, 0, 0),
ZIndex = 30,
}, SettingsPage)
Stroke(button, C.Border, 0, 1)
button.MouseButton1Click:Connect(function()
PlayClick()
callback()
end)
return button
end

local ConfigButtons = Create("Frame", {
BackgroundTransparency = 1,
Size = UDim2.new(1, -10, 0, 70),
Position = UDim2.fromOffset(5, 694),
}, SettingsPage)

local function ConfigAction(text, y, side, callback)
local button = Create("TextButton", {
BackgroundColor3 = C.Panel2,
BorderSizePixel = 0,
Text = text,
Font = Enum.Font.Code,
TextSize = 9,
TextColor3 = C.White,
AutoButtonColor = false,
Size = UDim2.new(0.5, -7, 0, 30),
Position = UDim2.new(side == 0 and 0 or 0.5, side == 0 and 0 or 7, 0, y),
ZIndex = 30,
}, ConfigButtons)
Stroke(button, C.Border, 0, 1)
button.MouseButton1Click:Connect(function() PlayClick(); callback() end)
end

ConfigAction("SAVE / CREATE", 0, 0, function()
local name = ConfigNameBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
if name == "" then return end
Configs[name] = CaptureConfig()
SelectedConfig = name
ConfigDropdown.Text = name
RefreshConfigList()
end)

ConfigAction("OVERWRITE", 0, 1, function()
if SelectedConfig then
Configs[SelectedConfig] = CaptureConfig()
end
end)

ConfigAction("RUN CONFIG", 35, 0, function()
if SelectedConfig then
ApplyConfig(Configs[SelectedConfig])
end
end)

ConfigAction("DELETE", 35, 1, function()
if SelectedConfig then
Configs[SelectedConfig] = nil
SelectedConfig = nil
ConfigDropdown.Text = "Select Config"
RefreshConfigList()
end
end)

local RenameButton = Create("TextButton", {
BackgroundColor3 = C.Panel2,
BorderSizePixel = 0,
Text = "RENAME CONFIG",
Font = Enum.Font.Code,
TextSize = 9,
TextColor3 = C.White,
AutoButtonColor = false,
Size = UDim2.new(1, -10, 0, 30),
Position = UDim2.fromOffset(5, 772),
ZIndex = 30,
}, SettingsPage)
Stroke(RenameButton, C.Border, 0, 1)
RenameButton.MouseButton1Click:Connect(function()
PlayClick()
if not SelectedConfig then return end
local newName = RenameBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
if newName == "" or newName == SelectedConfig then return end
if Configs[newName] then return end
Configs[newName] = Configs[SelectedConfig]
Configs[SelectedConfig] = nil
SelectedConfig = newName
ConfigDropdown.Text = newName
RefreshConfigList()
end)

ConfigDropdown.MouseButton1Click:Connect(function()
ConfigList.Visible = not ConfigList.Visible
end)

RefreshConfigList()

--==================================================
-- REFERENCE TWO-COLUMN LAYOUT
--==================================================

local function BuildReferenceColumns()
    local thresholds = {
        Combat = 445,
        Visuals = 405,
        Player = 455,
        Game = math.huge,
        Settings = 435,
    }

    for pageName, page in pairs(Pages) do
        local threshold = thresholds[pageName] or math.huge

        -- Two subtle panels behind the feature columns.
        local divider = Create("Frame", {
            Name = "ColumnDivider",
            BackgroundColor3 = C.Border,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 1, 1, -8),
            Position = UDim2.new(0.5, 0, 0, 4),
            ZIndex = 1,
        }, page)

        local left = Create("Frame", {
            Name = "LeftColumn",
            BackgroundColor3 = C.Panel,
            BackgroundTransparency = 0.18,
            BorderSizePixel = 0,
            Size = UDim2.new(0.5, -6, 1, -8),
            Position = UDim2.fromOffset(0, 4),
            ZIndex = 0,
        }, page)
        local right = Create("Frame", {
            Name = "RightColumn",
            BackgroundColor3 = C.Panel,
            BackgroundTransparency = 0.18,
            BorderSizePixel = 0,
            Size = UDim2.new(0.5, -6, 1, -8),
            Position = UDim2.new(0.5, 6, 0, 4),
            ZIndex = 0,
        }, page)
        Stroke(left, C.Border, 0.65, 1)
        Stroke(right, C.Border, 0.65, 1)

        for _, child in ipairs(page:GetChildren()) do
            if child:IsA("GuiObject") and child ~= divider and child ~= left and child ~= right then
                local y = child.Position.Y.Offset
                local isHeader = y < 70
                if isHeader then
                    child.Size = UDim2.new(1, -10, child.Size.Y.Scale, child.Size.Y.Offset)
                    child.Position = UDim2.fromOffset(5, math.max(2, y))
                else
                    local rightSide = (y >= threshold)
                    local newX = rightSide and (page.AbsoluteSize.X * 0.5 + 6) or 5
                    local newY = rightSide and (y - threshold + 70) or y
                    child.Position = UDim2.new(rightSide and 0.5 or 0, rightSide and 6 or 5, 0, newY)
                    child.Size = UDim2.new(0.5, -16, child.Size.Y.Scale, child.Size.Y.Offset)
                end
            end
        end

        -- Recreate header width after columns are in place.
        for _, child in ipairs(page:GetChildren()) do
            if child:IsA("Frame") and child.Name == "ColumnDivider" then
                child.ZIndex = 2
            end
        end
    end
end

BuildReferenceColumns()

--==================================================
-- OPEN/CLOSE ANIMATION
--==================================================


ShowClock = function()
if not ClockEnabled then
ClockTab.Visible = false
return
end

ClockTab.Visible = true

ClockTab.BackgroundTransparency = 1

Tween(
ClockTab,
TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
{
BackgroundTransparency = 0,
}
)
end

HideClock = function()

Tween(
ClockTab,
TweenInfo.new(0.2),
{
BackgroundTransparency = 1,
}
)

task.delay(0.22, function()

if ClockTab then
ClockTab.Visible = false
end
end)
end

MinButton.MouseButton1Click:Connect(function()
PlayClick()
if Minimized then
Minimized = false
Maximized = false
Content.Visible = true
Main.BackgroundTransparency = 0
Main.Size = NormalSize
Main.Position = Maximized and UDim2.new(0.07, 0, 0.07, 0) or NormalPosition
if ClockEnabled then ShowClock() end
else
Minimized = true
HideClock()
Content.Visible = false
Main.Size = UDim2.fromOffset(CONFIG.Width, 64)
end
end)

MaxButton.MouseButton1Click:Connect(function()
if Minimized then return end
PlayClick()
Maximized = not Maximized
if Maximized then
Main.AnchorPoint = Vector2.new(0, 0)
Tween(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
Size = UDim2.new(0.90, 0, 0.90, 0),
Position = UDim2.new(0.05, 0, 0.05, 0),
})
else
Tween(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
Size = NormalSize,
Position = NormalPosition,
})
end
end)

--==================================================
-- CLOSE SLINGSHOT
--==================================================

CloseButton.MouseButton1Click:Connect(function()

if not Opened then
return
end

Opened = false

PlaySound(CONFIG.CloseSound, 0.6)

local originalPosition = Main.Position

-- Small pull to the right
Tween(
Main,
TweenInfo.new(
0.14,
Enum.EasingStyle.Quad,
Enum.EasingDirection.Out
),
{
Position = UDim2.new(
originalPosition.X.Scale,
originalPosition.X.Offset + 35,
originalPosition.Y.Scale,
originalPosition.Y.Offset
)
}
).Completed:Wait()

-- Slingshot toward the left while shrinking
local closeTween = Tween(
Main,
TweenInfo.new(
0.38,
Enum.EasingStyle.Back,
Enum.EasingDirection.In
),
{
Position = UDim2.new(
originalPosition.X.Scale,
originalPosition.X.Offset - 500,
originalPosition.Y.Scale,
originalPosition.Y.Offset
),

Size = UDim2.fromOffset(40, 40),
BackgroundTransparency = 1,
}
)

closeTween.Completed:Wait()

Gui.Enabled = false

-- Bring back with RightShift
end)

--==================================================
-- RIGHT SHIFT REOPEN
--==================================================

UserInputService.InputBegan:Connect(function(input, processed)

if processed then
return
end

if input.KeyCode == Enum.KeyCode.RightShift then

if not Opened then

Opened = true
Gui.Enabled = true

Main.BackgroundTransparency = 1
Main.Size = UDim2.fromOffset(40, 40)

Main.Position = UDim2.new(
0.5,
-20,
0.5,
-20
)

Tween(
Main,
TweenInfo.new(
0.45,
Enum.EasingStyle.Back,
Enum.EasingDirection.Out
),
{
BackgroundTransparency = 0,
Size = NormalSize,
Position = NormalPosition,
}
)

ShowClock()
end
end
end)

--==================================================
-- CLOCK UPDATE
--==================================================

task.spawn(function()

while Gui.Parent do

local now = DateTime.now():ToLocalTime()

ClockText.Text =
string.format(
"%02d:%02d:%02d",
now.Hour,
now.Minute,
now.Second
)

task.wait(1)
end
end)

--==================================================
-- AMBIENT UI VFX
--==================================================

task.spawn(function()
    while Main.Parent do
        Tween(MainStroke, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Thickness = 1.8, Color = C.Accent}).Completed:Wait()
        Tween(MainStroke, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Thickness = 1, Color = C.Border}).Completed:Wait()
    end
end)

--==================================================
-- FINAL UI POLISH PASS
--==================================================

for _, object in ipairs(Main:GetDescendants()) do
    if (object:IsA("TextButton") or object:IsA("ImageButton"))
        and not TabButtons[object.Name] then
        PolishButton(object)
    end
end

-- Keep the most important surfaces consistently rounded.
for _, object in ipairs(Main:GetDescendants()) do
    if object:IsA("Frame") or object:IsA("TextButton") or object:IsA("TextBox") then
        if object.BackgroundTransparency < 1 and not object:FindFirstChildOfClass("UICorner") then
            local width = object.AbsoluteSize.X
            local height = object.AbsoluteSize.Y
            if width > 120 and height >= 28 and height <= 110 then
                Round(object, 7)
            end
        end
    end
end

--==================================================
-- INITIAL STATE
--==================================================

SelectTab("Player")
UpdateFOVCircle()
ShowClock()

-- Initial movement state
ApplyMovement()

print("[Flisium] Loaded successfully.")
