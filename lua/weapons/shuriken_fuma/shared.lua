
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

SWEP.StrangleTime = 3 
SWEP.RagdollTime = 5 

function SWEP:Deploy()
	self.Owner:SetModel("models/falko_naruto_foc/body_upper/man_anbublackops_hood_03.mdl")
end


function SWEP:Initialize()

    self:SetHoldType( "none" )
    
    self.shurikenLaunched = false
    self.shurikenEnt = nil


    self.IsStrangling = false
    self.StrangleStartTime = 0
    self.StrangleTarget = nil

end

local attachModelEnt = nil

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
function launchShuriken(ply, self,damage)
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
    
    util.SpriteTrail(ent, 0, Color(255,255,255), false, 10, 10, 1, 50, "trails/laser.vmt")

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
            util.Effect("StunstickImpact", effectdata) 

            for _, entity in ipairs(ents.FindInSphere(trace.HitPos, 150)) do
                if entity:IsPlayer() or entity:IsNPC() then
				
                    if entity ~= ply then
                        
                        local damageInfo = DamageInfo()
                        damageInfo:SetDamage(damage) 
                        damageInfo:SetAttacker(ent) 
                        damageInfo:SetInflictor(self)

                        
                        entity:TakeDamageInfo(damageInfo)
                        

                        net.Start("DisplayDamage")
                        net.WriteInt(damage, 32)
                        net.WriteEntity(entity)
                        net.WriteColor(Color(249,148,6,255))
                        net.Send(ply)
                    end
                    break
                end
            end

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



function AttachModelToPlayer(ply)
    if CLIENT then
        if not IsValid(ply) or not ply:IsPlayer() then return end

        if attachModelEnt and IsValid(attachModelEnt) then return end

        local model = ClientsideModel("models/naruto_demonwind_shuriken.mdl")
        --local model = ClientsideModel("models/fsc/billy/doublebrassusanoo.mdl")
        model:SetNoDraw(false)
        --model:SetColor(Color(math.random(0,255),math.random(0,255),math.random(0,255)))
        model:SetModelScale(1, 0)

        attachModelEnt = model

        hook.Add("PostPlayerDraw", model, function()
            if not IsValid(ply) or not ply:Alive() then
                if IsValid(attachModelEnt) then
                    attachModelEnt:Remove()
                    attachModelEnt = nil
                end
                hook.Remove("PostPlayerDraw", model)
                return
            end

            local boneId = ply:LookupBone("ValveBiped.Bip01_Spine2")
            if not boneId then return end

            local bonePos, boneAng = ply:GetBonePosition(boneId)
            if not bonePos or not boneAng then return end

            --local offsetPos = Vector(-30, -5, 0)
            --local offsetAng = Angle(0, 90, 90)
            local offsetPos = Vector(10, 7, 0)
            local offsetAng = Angle(45, 0, 90)

            local newPos = bonePos + boneAng:Forward() * offsetPos.x + boneAng:Right() * offsetPos.y + boneAng:Up() * offsetPos.z
            local newAng = boneAng
            newAng:RotateAroundAxis(boneAng:Right(), offsetAng.p)
            newAng:RotateAroundAxis(boneAng:Up(), offsetAng.y)
            newAng:RotateAroundAxis(boneAng:Forward(), offsetAng.r)

            model:SetPos(newPos)
            model:SetAngles(newAng)
        end)

        timer.Simple(5,function()
            RemoveModelFromPlayer(ply,self)
        end)
    end
end

function RemoveModelFromPlayer(ply)
    if CLIENT and attachModelEnt then
        if IsValid(attachModelEnt) then
            attachModelEnt:Remove()
        end
        attachModelEnt = nil
    end
end
function SWEP:PrimaryAttack()
    local maxDistance = 150
    local ply = self.Owner
    local trace = ply:GetEyeTrace()
    local target = trace.Entity

    if not (IsValid(target) and target:IsPlayer() and trace.HitPos:DistToSqr(ply:GetPos()) <= maxDistance ^ 2) then
        return
    end

    if not self.IsStrangling then

        
        self:SetHoldType("anim_ninjutsu1")
        ply:SetAnimation(PLAYER_ATTACK1)

        self.IsStrangling = true
        self.StrangleStartTime = CurTime()
        self.StrangleTarget = target
        target:Freeze(true) 
    end
end

function SWEP:Think()
    if self.IsStrangling then
        local ply = self.Owner
        local trace = ply:GetEyeTrace()
        local target = self.StrangleTarget

        if not ply:KeyDown(IN_ATTACK) or not (IsValid(target) and target:IsPlayer()) then
 
            self:CancelStrangle()
            return
        end

        local elapsedTime = CurTime() - self.StrangleStartTime
        local percentage = math.Clamp((elapsedTime / self.StrangleTime) * 100, 0, 100)

        ply:PrintMessage(HUD_PRINTCENTER, math.floor(percentage) .. "%")

        if elapsedTime >= self.StrangleTime then
      
            self:ApplyRagdollEffect(target)
            self.IsStrangling = false
      
        end
    end
end

function SWEP:CancelStrangle()

    if self.StrangleTarget and IsValid(self.StrangleTarget) then
        self.StrangleTarget:Freeze(false) 
    end
    self.IsStrangling = false
    self.StrangleTarget = nil
end

function SWEP:ApplyRagdollEffect(target)
    if not SERVER then return end
    if not IsValid(target) then return end

    target:Freeze(false) 

    local ragdoll = ents.Create("prop_ragdoll")
    ragdoll:SetModel(target:GetModel())
    ragdoll:SetPos(target:GetPos())
    ragdoll:SetAngles(target:GetAngles())
    ragdoll:Spawn()

    target:Spectate(OBS_MODE_CHASE)
    target:SpectateEntity(ragdoll)
    target:SetParent(ragdoll)

    timer.Simple(self.RagdollTime, function()
        if not IsValid(target) or not IsValid(ragdoll) then return end
        target:UnSpectate()
        target:SetParent(nil)
        target:Spawn()
        target:SetPos(ragdoll:GetPos())
        ragdoll:Remove()

        self.StrangleTarget = nil
    end)
end

function SWEP:Reload()
    local ply = self:GetOwner() 
    if not IsValid(ply) or not ply:IsPlayer() then return end

    self:SetHoldType("anim_launch") 

    if CurTime() < (self.NextSpecialMove or 0) then return end
    self.NextSpecialMove = CurTime() + 0.5

    if not self.shurikenLaunched then

        ply:SetAnimation(PLAYER_ATTACK1)

        if SERVER then
            util.AddNetworkString("DisplayDamage")
            launchShuriken(ply, self,120)
        end
    else

        timer.Simple(0.01, function()
            if IsValid(ply) then
                ply:SetAnimation(PLAYER_RELOAD)
              
            end
        end)

        if IsValid(self.shurikenEnt) then

            if IsValid(self.StrangleTarget) then
                
                local strangleTarget = self.StrangleTarget
                timer.Simple(1, function()
                    strangleTarget:SetPos(ply:GetPos())

                    
                end)
               
                
            end

            local newPos = self.shurikenEnt:GetPos()
            self.shurikenEnt:Remove()
            ply:SetPos(newPos)

            ply:EmitSound("ambient/explosions/explode_9.wav", 50, 100, 1)
        end
    end

    if self.shurikenLaunched and IsValid(self.shurikenEnt) then
        timer.Simple(0.1, function()
            if IsValid(ply) then
                ParticleEffect("[5]_blackexplosion8", ply:GetPos(), Angle(0, 0, 0), nil)
                self.shurikenEnt = nil
                self.shurikenLaunched = false
            end
        end)
    end
end

