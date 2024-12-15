
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

SWEP.ChargeTime = 1 
SWEP.NextSpecialMove = 0


function SWEP:Initialize()
    self:SetHoldType( "normal" )
	self.plyindirction = false
	self.duringattacktime = 0
    self.duringattack = false
	self.dodgetime = 0

    self.IsCharge = false
    self.ChargeStartTime = 0


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



-- function SWEP:PrimaryAttack()

--     local ply = self.Owner

--     self.Weapon:SetNextPrimaryFire(CurTime() + 1 )

--     if not self.IsCharge then

--         self:SetHoldType("sword_parade")
--         ply:SetAnimation(PLAYER_ATTACK1)

--         self.IsCharge = true
--         self.ChargeStartTime = CurTime()

--         if not SERVER then return end
            
--         local startPos = ply:GetShootPos()
--         local aimDir = ply:GetAimVector()
        
--         local damage = 75
--         local speed = 100
--         local velocity = aimDir * speed  
    
--         local ent = ents.Create("prop_physics")
--         ent:SetModel("models/hunter/misc/sphere025x025.mdl")
--         ent:SetPos(startPos + ply:EyeAngles():Forward()*100)
--         ent:SetModelScale(0.4)
--         ent:SetMaterial("grey_textures/endocore")
--         ent:Spawn()
    
--         util.SpriteTrail(ent, 0, Color(15,252,252), false, 30, 30, 1, 50, "trails/laser.vmt")
    
--         local phys = ent:GetPhysicsObject()
--         if IsValid(phys) then
--             phys:EnableGravity(false)
--             phys:EnableMotion(true)
--             phys:SetVelocity(velocity)
--         end
    
--         hook.Add("Think", "rasendanMove" , function()
--             local trace = util.TraceLine({
--                 start = ent:GetPos(),
--                 endpos = ent:GetPos() + velocity * 0.2,
--                 filter = ent
--             })
    
--             if trace.Hit then
--                 local effectdata = EffectData()
--                 effectdata:SetOrigin(trace.HitPos)
--                 effectdata:SetNormal(trace.HitNormal)
--                 ParticleEffect("ice_breath_target",trace.HitPos, Angle(0,0,0),nil)
    
    
    
--                 -- for _, ent in ipairs(ents.FindInSphere(trace.HitPos, 200)) do
--                 --     if ent:IsPlayer() or ent:IsNPC() and ent ~= ply then
--                 -- 		ply:EmitSound(AttackHit1, 50, 100, 0.5)
--                 -- 		local damageInfo = DamageInfo()
--                 -- 		damageInfo:SetDamage(damage) 
--                 -- 		damageInfo:SetAttacker(ent) 
--                 -- 		damageInfo:SetInflictor(self) 
--                 -- 		ent:TakeDamageInfo(damageInfo)
    
                          
--                 -- 		net.Start("DisplayDamage")
--                 -- 		net.WriteInt(damage, 32)
--                 -- 		net.WriteEntity(ent)
--                 -- 		net.WriteColor(Color(51,125,255,255))
--                 -- 		net.Send(ply)
    
--                 --         break
--                 --     end
--                 -- end
    
--                 ent:Remove()
--                 hook.Remove("Think", "rasendanMove" )
--             else
--                 ent:SetPos(ent:GetPos() + velocity * FrameTime())
--             end
--         end)

--     end
-- end
-- function SWEP:Think()
--     if self.IsCharge then
--         local ply = self.Owner

--         if not ply:KeyDown(IN_ATTACK) then
 
--             self.IsCharge = false
--             return
--         end

--         local elapsedTime = CurTime() - self.ChargeStartTime
--         local percentage = math.Clamp((elapsedTime / self.ChargeTime) * 100, 0, 100)

--         ply:PrintMessage(HUD_PRINTCENTER, math.floor(percentage) .. "%")

--         if elapsedTime >= self.ChargeTime then
          

--             ply:SetAnimation(PLAYER_RELOAD)
      
--             self.IsCharge = false

            
      
--         end
--     end
-- end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()

    if CurTime() < self.NextSpecialMove then return end
    self.NextSpecialMove = CurTime() + 2

    local ply = self.Owner

	local force = Vector(0, 0, 750)
	
    local maxDistance = 800

    local trace = ply:GetEyeTrace()
    local target = trace.Entity

    if not (IsValid(target) and target:IsPlayer() and trace.HitPos:DistToSqr(ply:GetPos()) <= maxDistance ^ 2) then
        return
    end

    target:SetVelocity(force)
    ply:SetVelocity(force)
end


-- hook.Add("PostPlayerDraw", "WeaponHolster", function(ply)
--     if ply:GetActiveWeapon():GetClass() ~= "empty_hands" then
--         return
--     end

--     if IsValid(ply) and ply:Alive() then
--         local arme = ply:GetActiveWeapon()
--         if not IsValid(arme) then
--             return
--         end

--         local model = ClientsideModel("models/naruto/epee/epee10/foc_nr_epee10_bane.mdl")
--         if IsValid(model) then
--             model:SetNoDraw(true)
          
--         end
--         local bone = ply:LookupBone("ValveBiped.Bip01_Spine2")
--         if not bone then
--             return
--         end

--         local matrix = ply:GetBoneMatrix(bone)
--         if not matrix then
--             return
--         end

--         local pos = matrix:GetTranslation()
--         local ang = matrix:GetAngles()

--         pos = pos + ang:Forward() * 40 + ang:Up() * 25 + ang:Right() * -18
--         ang:RotateAroundAxis(ang:Forward(), 180)
--         ang:RotateAroundAxis(ang:Right(), 30)
--         ang:RotateAroundAxis(ang:Up(), 180)

--         model:SetRenderOrigin(pos)
--         model:SetRenderAngles(ang)
--         model:DrawModel()
--     end
-- end)
