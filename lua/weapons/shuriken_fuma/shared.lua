
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
    self.attachedModels = {}

    --AttachModelToPlayer(self.Owner,self)
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
    ent:SetModel("models/naruto_demonwind_shuriken.mdl")
    ent:SetPos(startPos + ply:EyeAngles():Forward() * 100)
    ent:SetModelScale(1)
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



-- function AttachModelToPlayer(ply,self)
--     if CLIENT then
--         if not IsValid(ply) or not ply:IsPlayer() then return end

--         if self.attachedModels[ply] and IsValid(self.attachedModels[ply]) then return end

--         local model = ClientsideModel("models/foc_props_arme/arme_shuriken_fuma/foc_arme_shuriken_fuma.mdl")
--         model:SetNoDraw(false)
--         model:SetModelScale(1, 0)

--         self.attachedModels[ply] = model

--         hook.Add("PostPlayerDraw", model, function()
--             if not IsValid(ply) or not ply:Alive() then
--                 if IsValid(self.attachedModels[ply]) then
--                     self.attachedModels[ply]:Remove()
--                     self.attachedModels[ply] = nil
--                 end
--                 hook.Remove("PostPlayerDraw", model)
--                 return
--             end

--             local boneId = ply:LookupBone("ValveBiped.Bip01_Spine2")
--             if not boneId then return end

--             local bonePos, boneAng = ply:GetBonePosition(boneId)
--             if not bonePos or not boneAng then return end

--             local offsetPos = Vector(10, 7, 0)
--             local offsetAng = Angle(45, 0, 90)

--             local newPos = bonePos + boneAng:Forward() * offsetPos.x + boneAng:Right() * offsetPos.y + boneAng:Up() * offsetPos.z
--             local newAng = boneAng
--             newAng:RotateAroundAxis(boneAng:Right(), offsetAng.p)
--             newAng:RotateAroundAxis(boneAng:Up(), offsetAng.y)
--             newAng:RotateAroundAxis(boneAng:Forward(), offsetAng.r)

--             model:SetPos(newPos)
--             model:SetAngles(newAng)
--         end)
--     end
-- end

-- function RemoveModelFromPlayer(ply,self)
--     if CLIENT and self.attachedModels[ply] then
--         if IsValid(self.attachedModels[ply]) then
--             self.attachedModels[ply]:Remove()
--         end
--         self.attachedModels[ply] = nil
--     end
-- end
function SWEP:PrimaryAttack()

   

    local maxDistance = 50
    local ply = self.Owner
    local trace = ply:GetEyeTrace()
    local target = trace.Entity

    if not (IsValid(target) and target:IsPlayer() and trace.HitPos:DistToSqr(ply:GetPos()) <= maxDistance ^ 2) then
        return 
    end

    ply:ChatPrint(target:Name() .. " etrangle")
    
end


function SWEP:Reload()
	local ply = self.Owner

	if CurTime() < self.NextSpecialMove then return end
	self.NextSpecialMove = CurTime() + 0.5

    if not self.shurikenLaunched then
        self:SetHoldType("anim_launch")
        ply:SetAnimation(PLAYER_ATTACK1)


    end

    if not self.shurikenLaunched then
       
        if SERVER then
            launchShuriken(ply,self)
        end
    else
        if IsValid(self.shurikenEnt) then
            local newPos = self.shurikenEnt:GetPos()
            local shuriken = self.shurikenEnt

            shuriken:Remove()

            ply:SetPos(newPos)
  

            ply:EmitSound("ambient/explosions/explode_9.wav",50,100,1)
  
          
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


