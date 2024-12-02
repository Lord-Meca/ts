
AddCSLuaFile()

SWEP.PrintName = "Shuriken Fûma | Invocation"
SWEP.Author = "Lord_Meca"
SWEP.Instructions = ""

SWEP.Base = "weapon_base"

SWEP.Category = "TypeShit | Invocations"

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
SWEP.NextSpecialMove = 0

function SWEP:Deploy()
	self.Owner:SetModel("models/falko_naruto_foc/body_upper/man_anbublackops_hood_03.mdl")
end


function SWEP:Initialize()

    self:SetHoldType( "none" )
    
    self.shurikenLaunched = false
    self.shurikenEnt = nil

end


function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()
    if self.shurikenLaunched and IsValid(self.shurikenEnt) then
        timer.Simple(0.1,function()
            local ent = self.shurikenEnt
            ParticleEffect("nrp_tool_invocation", self.shurikenEnt:GetPos(), Angle(0,0,0), nil)
            self.Owner:EmitSound("ambient/explosions/explode_9.wav",50,100,1)
            
            ent:Remove()

            self.shurikenEnt = nil
            self.shurikenLaunched = false  
         
        end)
    end
end
function launchShuriken(ply, self)
    local startPos = ply:GetShootPos()
    local aimDir = ply:GetAimVector()

    local speed = 1500
    local velocity = aimDir * speed  

    local ent = ents.Create("prop_physics")
    ent:SetModel("models/fsc/billy/cubeonoki.mdl")
    ent:SetPos(startPos + ply:EyeAngles():Forward() * 100)
    ent:SetAngles(aimDir:Angle())

    ent:Spawn()

    self.shurikenLaunched = true

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableGravity(false)
        phys:EnableMotion(true) 
        phys:SetVelocity(velocity)
    end

    hook.Add("Think", "shurikenMove" .. ent:EntIndex(), function()
        if not IsValid(ent) then return end

        local currentAngles = ent:GetAngles()
        local newAngles = currentAngles + Angle(0, 10, 0) 
        ent:SetAngles(newAngles)

        local trace = util.TraceLine({
            start = ent:GetPos(),
            endpos = ent:GetPos() + velocity * 0.2,
            filter = ent
        })

        if trace.Hit then

            local effectdata = EffectData()
            effectdata:SetOrigin(trace.HitPos)
            effectdata:SetNormal(trace.HitNormal)
            util.Effect("cball_explode", effectdata) 

            self.shurikenLaunched = false
            self.shurikenEnt = nil

            ply:EmitSound("physics/metal/metal_box_break1.wav",50,100,0.5)

            ent:Remove() 
            hook.Remove("Think", "shurikenMove" .. ent:EntIndex()) 
        else

            ent:SetPos(ent:GetPos() + velocity * FrameTime())
            self.shurikenEnt = ent
         
        end
    end)
end


-- if SERVER then return end

-- local function AttachModelToPlayer(ply)
--     if not IsValid(ply) or not ply:IsPlayer() then return end

--     -- Création d'un modèle côté client
--     local model = ClientsideModel("models/naruto_demonwind_shuriken.mdl") -- Change le chemin pour ton modèle
--     model:SetNoDraw(false) -- Pour afficher le modèle
--     model:SetModelScale(1, 0) -- Ajuste l'échelle si nécessaire

--     -- Définir la position et l'angle de l'attachement
--     hook.Add("PostPlayerDraw", model, function()
--         if not IsValid(ply) or not ply:Alive() then
--             model:Remove()
--             hook.Remove("PostPlayerDraw", model)
--             return
--         end

--         local boneId = ply:LookupBone("ValveBiped.Bip01_Spine2") -- Bone du dos
--         if not boneId then return end

--         local bonePos, boneAng = ply:GetBonePosition(boneId)
--         if not bonePos or not boneAng then return end

--         -- Position et rotation relative
--         local offsetPos = Vector(0, 7, 0) -- Ajuste les valeurs pour le positionnement
--         local offsetAng = Angle(45, 0, 90) -- Ajuste l'angle

--         -- Applique l'offset
--         local newPos = bonePos + boneAng:Forward() * offsetPos.x + boneAng:Right() * offsetPos.y + boneAng:Up() * offsetPos.z
--         local newAng = boneAng
--         newAng:RotateAroundAxis(boneAng:Right(), offsetAng.p)
--         newAng:RotateAroundAxis(boneAng:Up(), offsetAng.y)
--         newAng:RotateAroundAxis(boneAng:Forward(), offsetAng.r)

--         -- Met à jour la position et l'angle du modèle
--         model:SetPos(newPos)
--         model:SetAngles(newAng)
--     end)
-- end

-- -- Ajout pour un joueur spécifique (par exemple, le joueur local)
-- hook.Add("Think", "AttachWeaponModelToPlayer", function()
--     local ply = LocalPlayer()
--     if IsValid(ply) and ply:Alive() then
--         if not self.shurikenLaunched then
--             AttachModelToPlayer(ply)
--             hook.Remove("Think", "AttachWeaponModelToPlayer") 
--         end
--     end
-- end)


function SWEP:Reload()
	local ply = self.Owner

	if CurTime() < self.NextSpecialMove then return end
	self.NextSpecialMove = CurTime() + 0.5

    if not self.shurikenLaunched then
        self:SetHoldType("anim_launch")
        ply:SetAnimation(PLAYER_ATTACK1)
    end
 

    if SERVER then

        if not self.shurikenLaunched then

            launchShuriken(ply,self)
        else
            if IsValid(self.shurikenEnt) then
                local newPos = self.shurikenEnt:GetPos()
                local shuriken = self.shurikenEnt

                shuriken:Remove()

                ply:SetPos(newPos)


                ply:EmitSound("ambient/explosions/explode_9.wav",50,100,1)
           

            end
            
        end
    end
    
    if self.shurikenLaunched and IsValid(self.shurikenEnt) then
        timer.Simple(0.1,function()
            ParticleEffect("nrp_tool_invocation", ply:GetPos(), Angle(0,0,0), nil)
    
            self.shurikenEnt = nil
            self.shurikenLaunched = false
        end)
    end
    
end


