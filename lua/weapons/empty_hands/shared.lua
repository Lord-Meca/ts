
AddCSLuaFile()

SWEP.PrintName = "Mains"
SWEP.Author = "Lord_Meca"
SWEP.Instructions = ""

SWEP.Base = "weapon_base"

SWEP.Category = "Other"

SWEP.Spawnable = true
SWEP.AdminSpawnable = false

SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = ""

SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
    self:SetHoldType( "none" )
	self.plyindirction = false
	self.duringattacktime = 0
    self.duringattack = false
	self.dodgetime = 0
end


if SERVER then return end

local selectedWeapons = {}
local isMenuOpen = false
local frame = nil


net.Receive("EquipWeapons", function(len, ply)
    local weaponsString = net.ReadString()
    local weaponsTable = {}

    for weapon in string.gmatch(weaponsString, "([^,]+)") do
        table.insert(weaponsTable, weapon)
    end

    for _, weaponClass in ipairs(weaponsTable) do
        if table.Count(selectedWeapons) == 6 then return end
        table.insert(selectedWeapons, string.Replace(weaponClass, "'", "")) 
    end
    

end)

local function OpenWeaponMenu()

	if isMenuOpen then

        if IsValid(frame) then
            frame:Close()
			
        end
        isMenuOpen = false
        return
    end
	
	isMenuOpen = true

    frame = vgui.Create("DFrame")
    frame:SetSize(400, 300)
    frame:Center()
    frame:SetTitle("armes")
    frame:MakePopup()

	frame.OnClose = function()
        isMenuOpen = false
    end

    local weaponList = vgui.Create("DScrollPanel", frame)
    weaponList:Dock(FILL)

    for _, weapon in ipairs(weapons.GetList()) do
        if weapon.Category == "TypeShit | Armes" or weapon.Category == "TypeShit | Invocations" then
            local button = vgui.Create("DButton", weaponList)
            button:Dock(TOP)
            button:SetText(weapon.PrintName or weapon.ClassName)
            button:DockMargin(0, 0, 0, 5)

            button.DoClick = function()
                if #selectedWeapons < 6 then
                    table.insert(selectedWeapons, weapon.ClassName) 
                    
				end
            end

			
        end
    end

	local resetButton = vgui.Create("DButton", frame)
	resetButton:SetText("reset")
	resetButton:SetColor(Color(255,0,0))
	resetButton:Dock(BOTTOM)
	resetButton.DoClick = function()
		table.Empty(selectedWeapons)
	end
end

hook.Add("HUDPaint", "drawSlots", function()


    local startX = ScrW() - 1300
    local startY = ScrH() - 100 
    local boxWidth = 100
    local boxHeight = 50
    local padding = 10

    for i = 1, 6 do
        local x = startX + (i - 1) * (boxWidth + padding)
        local y = startY

        draw.RoundedBox(8, x, y, boxWidth, boxHeight, Color(0, 0, 0, 200))


        local text = selectedWeapons[i] and weapons.Get(selectedWeapons[i]).PrintName or "rien"
        draw.SimpleText("[" .. i .. "] " .. text, "DermaDefault", x + boxWidth / 2, y + boxHeight / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)


hook.Add("PlayerButtonDown", "equipWeapons", function(ply, button)
    local slot = nil

    if button == KEY_1 then slot = 1
    elseif button == KEY_2 then slot = 2
    elseif button == KEY_3 then slot = 3
    elseif button == KEY_4 then slot = 4
    elseif button == KEY_5 then slot = 5
    elseif button == KEY_6 then slot = 6 end

    if slot and selectedWeapons[slot] then
        local weaponClass = selectedWeapons[slot]
        RunConsoleCommand("gm_giveswep", weaponClass) 
        RunConsoleCommand("use", weaponClass) 

    end
end)

hook.Add("PlayerButtonDown", "openWeaponMenu", function(ply, button)
    if button == KEY_F4 then 

		OpenWeaponMenu()
		


    end
end)
