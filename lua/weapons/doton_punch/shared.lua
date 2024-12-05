
AddCSLuaFile()

SWEP.PrintName = "Frappe de Roche"
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
	self.Owner:SetModel("models/falko_naruto_foc/body_upper/man_anbublackops_ame_hood_03.mdl")
end


function SWEP:Initialize()

    self:SetHoldType( "none" )

	self.targetedPlayers = {}

end


function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end


local function dotonPunch(ply, self)
    if not SERVER then return end

    util.AddNetworkString("DisplayDamage")

    local startPos = self.hitPos - Vector(0, 0, 500) 
    local endPos = self.hitPos 

    local modelEntity = ents.Create("prop_physics")
    if IsValid(modelEntity) then
        modelEntity:SetModel("models/foc/billy/statu_arm.mdl")
        modelEntity:SetMaterial("dirt1")
        modelEntity:SetPos(startPos)

        modelEntity:SetAngles(Angle(0, math.random(0, 180), 0))
        modelEntity:SetModelScale(0.5)
        modelEntity:SetCollisionGroup(COLLISION_GROUP_NONE)
        modelEntity:SetKeyValue("solid", "6")
        modelEntity:SetMoveType(MOVETYPE_NONE)
        modelEntity:Spawn()

        local physObj = modelEntity:GetPhysicsObject()
        if IsValid(physObj) then
            physObj:EnableMotion(false)
            physObj:Wake()
        end


        local particleInit = ents.Create("info_particle_system")

        if IsValid(particleInit) then
            particleInit:SetKeyValue("effect_name", "nrp_deiton_slipper")
            particleInit:SetKeyValue("start_active", "1")
            particleInit:SetPos(endPos)
            particleInit:Spawn()
            particleInit:Activate()
        end

        local animationDuration = 0.3 
        local updateInterval = 0.05
        local startTime = CurTime()
        ply:EmitSound(Sound( "physics/concrete/concrete_break3.wav"))

        local soundPlayed = false
        local damageDealt = false

        timer.Create("animDotonPunch_" .. modelEntity:EntIndex(), updateInterval, 0, function()
            if not IsValid(modelEntity) then return end
            
            local elapsed = CurTime() - startTime
            local progress = math.Clamp(elapsed / animationDuration, 0, 1)

            local newPos = LerpVector(progress, startPos, endPos)
            modelEntity:SetPos(newPos)

            if self.targetedPlayers and progress >= 0.3 then
                for _, target in ipairs(self.targetedPlayers) do
                    if IsValid(target) and target:IsPlayer() or target:IsNPC() then

                        local force = Vector(0, 0, 250)
                        target:SetVelocity(force)
                        ParticleEffect("nrp_hit_main", target:GetPos(), Angle(0, 0, 0), nil)

                       
                        if not soundPlayed then
                            ply:EmitSound(Sound("physics/body/body_medium_break2.wav"))
                            soundPlayed = true
                        end

                        if not damageDealt then
                            local damageInfo = DamageInfo()
                            damageInfo:SetDamage(50)
                            damageInfo:SetAttacker(ply)
                            damageInfo:SetInflictor(self)
                            target:TakeDamageInfo(damageInfo)

                            net.Start("DisplayDamage")
                            net.WriteInt(50, 32)
                            net.WriteEntity(target)
                            net.WriteColor(Color(249,148,6,255))
                            net.Send(ply)

                            damageDealt = true
                        end
                    end
                end
            end

            if progress >= 1 then
                timer.Remove("animDotonPunch_" .. modelEntity:EntIndex())
            end
        end)



        timer.Simple(5, function()
            if IsValid(modelEntity) then
                for i = 1, 3 do
                    local particleFinal = ents.Create("info_particle_system")
                    if IsValid(particleFinal) then
                        particleFinal:SetKeyValue("effect_name", "nrp_deiton_bubbles")
                        particleFinal:SetKeyValue("start_active", "1")
                        particleFinal:SetPos(modelEntity:GetPos() + Vector(0, 0, (120 * i)))
                        particleFinal:Spawn()
                        particleFinal:Activate()
            
                       
                    end
                end
       
           
                modelEntity:Remove()
                ply:EmitSound(Sound( "physics/concrete/concrete_break2.wav"))
                if IsValid(particleInit) then
                    particleInit:Remove()
                end
            end
        end)
    end
end

local function dotonPunchWall(ply, self)
    if not SERVER then return end

    util.AddNetworkString("DisplayDamage")

    local startPos = self.hitPos - Vector(0, 0, 500) 
    local endPos = self.hitPos 

    local modelEntity = ents.Create("prop_physics")
    if IsValid(modelEntity) then
        modelEntity:SetModel("models/foc/billy/statu_arm.mdl")
        modelEntity:SetMaterial("dirt1")
        modelEntity:SetPos(startPos)

        modelEntity:SetAngles(Angle(0, math.random(0, 180), 0))
        modelEntity:SetModelScale(0.5)
        modelEntity:SetCollisionGroup(COLLISION_GROUP_NONE)
        modelEntity:SetKeyValue("solid", "6")
        modelEntity:SetMoveType(MOVETYPE_NONE)
        modelEntity:Spawn()

        local physObj = modelEntity:GetPhysicsObject()
        if IsValid(physObj) then
            physObj:EnableMotion(false)
            physObj:Wake()
        end


        local particleInit = ents.Create("info_particle_system")

        if IsValid(particleInit) then
            particleInit:SetKeyValue("effect_name", "nrp_deiton_slipper")
            particleInit:SetKeyValue("start_active", "1")
            particleInit:SetPos(endPos)
            particleInit:Spawn()
            particleInit:Activate()
        end

        local animationDuration = 0.3 
        local updateInterval = 0.05
        local startTime = CurTime()
        ply:EmitSound(Sound( "physics/concrete/concrete_break3.wav"))

        local soundPlayed = false
        local damageDealt = false

        timer.Create("animDotonPunch_" .. modelEntity:EntIndex(), updateInterval, 0, function()
            if not IsValid(modelEntity) then return end
            
            local elapsed = CurTime() - startTime
            local progress = math.Clamp(elapsed / animationDuration, 0, 1)

            local newPos = LerpVector(progress, startPos, endPos)
            modelEntity:SetPos(newPos)

            if self.targetedPlayers and progress >= 0.3 then
                for _, target in ipairs(self.targetedPlayers) do
                    if IsValid(target) and target:IsPlayer() or target:IsNPC() then

                        local force = Vector(0, 0, 90)
                        target:SetVelocity(force)

                        if not soundPlayed then
                            ply:EmitSound(Sound("physics/body/body_medium_break2.wav"))
                            soundPlayed = true
                        end

                        if not damageDealt then
                            local damageInfo = DamageInfo()
                            damageInfo:SetDamage(50)
                            damageInfo:SetAttacker(ply)
                            damageInfo:SetInflictor(self)
                            target:TakeDamageInfo(damageInfo)

                            net.Start("DisplayDamage")
                            net.WriteInt(50, 32)
                            net.WriteEntity(target)
                            net.WriteColor(Color(249,148,6,255))
                            net.Send(ply)

                            damageDealt = true
                        end
                    end
                end
            end

            if progress >= 1 then
                timer.Remove("animDotonPunch_" .. modelEntity:EntIndex())
            end
        end)



        timer.Simple(5, function()
            if IsValid(modelEntity) then
                for i = 1, 3 do
                    local particleFinal = ents.Create("info_particle_system")
                    if IsValid(particleFinal) then
                        particleFinal:SetKeyValue("effect_name", "nrp_deiton_bubbles")
                        particleFinal:SetKeyValue("start_active", "1")
                        particleFinal:SetPos(modelEntity:GetPos() + Vector(0, 0, (120 * i)))
                        particleFinal:Spawn()
                        particleFinal:Activate()
            
                       
                    end
                end
       
           
                modelEntity:Remove()
                ply:EmitSound(Sound( "physics/concrete/concrete_break2.wav"))
                if IsValid(particleInit) then
                    particleInit:Remove()
                end
            end
        end)
    end
end
function SWEP:Reload()
    local ply = self.Owner
    local maxDistance = 3000
    local radius = 300

    if CurTime() < self.NextSpecialMove then return end
    self.NextSpecialMove = CurTime() + 1
    self:SetHoldType("anim_ninjutsu1")
    ply:SetAnimation(PLAYER_RELOAD)

    local trace = ply:GetEyeTrace()

    -- if trace.Hit and trace.HitNormal then
    --     local normal = trace.HitNormal
      
    --     if math.abs(normal.z) < 0.1 then
    --         print("Vous visez un mur.")
        
           
    --     end
    -- end

    if not (trace.HitPos:DistToSqr(ply:GetPos()) <= maxDistance ^ 2) then return end

    self.hitPos = trace.HitPos 
    self.targetedPlayers = {} 

    timer.Simple(0.4, function()
        for _, ent in ipairs(ents.FindInSphere(self.hitPos, radius)) do
            if ent:IsPlayer() and ent ~= ply or ent:IsNPC() then
                table.insert(self.targetedPlayers, ent)
            end
        end

        dotonPunch(ply, self)
    end)
end

