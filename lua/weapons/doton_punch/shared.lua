
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
    self.NextSpecialMove = CurTime() + 5
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


local sphereRadius = 600
local physicsForce = Vector(0, 0, -100000)
local damagePerSecond = 10

if SERVER then
    util.AddNetworkString("UpdateSpiritualPressureEffects")
    util.AddNetworkString("ApplySpiritualPressureScreenShake")
    util.AddNetworkString("CreateHadesClawblastEffect")
end

function SWEP:Initialize()
    self:SetHoldType("normal")
    self.IsActive = false
    self.IsSelfActive = false
    self.NextNetworkUpdate = 0
    self.NextPhysicsUpdate = 0
    self.NextDamageUpdate = 0
end

function SWEP:Deploy()
    self:SetHoldType("normal")
    local owner = self:GetOwner()
    if IsValid(owner) then
        owner:DrawViewModel(false)
        owner.OriginalWalkSpeed = owner:GetWalkSpeed()
        owner.OriginalRunSpeed = owner:GetRunSpeed()
    end
    self.NextNetworkUpdate = 0
    self.NextPhysicsUpdate = 0
    self.NextDamageUpdate = 0
    return true
end

function SWEP:PrimaryAttack()
    if not self.IsActive then
        self:StartSpiritualPressure(false)
    end
end

function SWEP:SecondaryAttack()
    if not self.IsSelfActive then
        self:StartSpiritualPressure(true)
    end
end

function SWEP:Think()
    if self.IsActive and not self:GetOwner():KeyDown(IN_ATTACK) then
        self:StopSpiritualPressure(false)
    elseif self.IsSelfActive and not self:GetOwner():KeyDown(IN_ATTACK2) then
        self:StopSpiritualPressure(true)
    end
    
    if self.IsActive or self.IsSelfActive then
        self:UpdateSpiritualPressure()
        self:UpdatePhysics()
        self:UpdateDamage()
    end
end

function SWEP:StartSpiritualPressure(self_affect)
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if self_affect then
        self.IsSelfActive = true
    else
        self.IsActive = true
    end

    owner:SetNWBool("SpiritualPressureHaloEffect", true)
    owner:EmitSound("ambient/atmosphere/cave_hit1.wav", 100, 80, 1, CHAN_STATIC)

    if SERVER then
        net.Start("CreateHadesClawblastEffect")
        net.WriteEntity(owner)
        net.Broadcast()
    end

    self:UpdateSpiritualPressure(true)
end

function SWEP:UpdateSpiritualPressure(force)
    if not SERVER then return end
    
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local currentTime = CurTime()
    if not force and currentTime < self.NextNetworkUpdate then return end
    
    self.NextNetworkUpdate = currentTime + 0.1

    local pos = owner:GetPos()

    if self.IsSelfActive then
        owner:SetWalkSpeed(owner:GetSlowWalkSpeed())
        owner:SetRunSpeed(owner:GetSlowWalkSpeed())
    end

    for _, ent in ipairs(ents.FindInSphere(pos, sphereRadius)) do
        if ent:IsPlayer() and ent ~= owner then
            ent:ConCommand("+duck")
            net.Start("ApplySpiritualPressureScreenShake")
            net.Send(ent)
        elseif ent:IsNPC() and ent:GetClass():find("npc_") then
            ent:SetSchedule(SCHED_FORCED_GO_RUN)
        end
    end

    net.Start("UpdateSpiritualPressureEffects")
    net.WriteBool(self.IsActive or self.IsSelfActive)
    net.WriteVector(pos)
    net.WriteFloat(sphereRadius)
    net.WriteEntity(owner)
    net.WriteBool(self.IsSelfActive)
    net.SendPVS(pos)
end

function SWEP:IsHumanoidNPC(npc)
    if not IsValid(npc) or not npc:IsNPC() then return false end
    
    local boneCount = npc:GetBoneCount()
    if boneCount == 0 then return false end
    
    local humanoidBones = {
        "ValveBiped.Bip01_Spine",
        "ValveBiped.Bip01_L_Thigh",
        "ValveBiped.Bip01_R_Thigh",
        "ValveBiped.Bip01_L_UpperArm",
        "ValveBiped.Bip01_R_UpperArm"
    }
    
    local foundBones = 0
    for _, boneName in ipairs(humanoidBones) do
        if npc:LookupBone(boneName) then
            foundBones = foundBones + 1
        end
    end
    
    return foundBones >= 3
end

function SWEP:UpdatePhysics()
    if not SERVER then return end
    
    local currentTime = CurTime()
    if currentTime < (self.NextPhysicsUpdate or 0) then return end
    
    self.NextPhysicsUpdate = currentTime + 0.05

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local pos = owner:GetPos()

    for _, ent in ipairs(ents.FindInSphere(pos, sphereRadius)) do
        if IsValid(ent) then
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) and phys:IsMoveable() then
                local entPos = ent:GetPos()
                local distance = entPos:Distance(pos)
                local forceMult = math.pow(1 - (distance / sphereRadius), 2)
                local force = physicsForce * forceMult
                phys:ApplyForceCenter(force)
                
                phys:SetVelocity(phys:GetVelocity() * 0.95)
                phys:AddAngleVelocity(phys:GetAngleVelocity() * -0.1)
            end
            
            if ent:IsNPC() and ent:GetClass():find("npc_") then
                if self:IsHumanoidNPC(ent) then
                    if not ent.OriginalPos then
                        ent.OriginalPos = ent:GetPos()
                    end
                    local currentPos = ent:GetPos()
                    local maxDownwardPos = ent.OriginalPos - Vector(0, 0, 20)
                    
                    if currentPos.z > maxDownwardPos.z then
                        ent:SetPos(currentPos + Vector(0, 0, -1))
                    else
                        ent:SetPos(Vector(currentPos.x, currentPos.y, maxDownwardPos.z))
                    end
                else
                    ent:SetPos(ent:GetPos() + Vector(0, 0, -1))
                end
            end
        end
    end
end

function SWEP:UpdateDamage()
    if not SERVER then return end
    
    local currentTime = CurTime()
    if currentTime < (self.NextDamageUpdate or 0) then return end
    
    self.NextDamageUpdate = currentTime + 1

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local pos = owner:GetPos()

    for _, ent in ipairs(ents.FindInSphere(pos, sphereRadius)) do
        if IsValid(ent) and ent ~= owner then
            local damage = DamageInfo()
            damage:SetDamage(damagePerSecond)
            damage:SetDamageType(DMG_CRUSH)
            damage:SetAttacker(owner)
            damage:SetInflictor(self)
            ent:TakeDamageInfo(damage)
        end
    end
end

function SWEP:StopSpiritualPressure(self_affect)
    if not SERVER then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if self_affect then
        self.IsSelfActive = false
    else
        self.IsActive = false
    end
    
    if not self.IsActive and not self.IsSelfActive then
        owner:StopSound("ambient/atmosphere/cave_hit1.wav")
        owner:SetNWBool("SpiritualPressureHaloEffect", false)
    end

    if self_affect then
        self:ResetOwnerSpeed(owner)
    end

    for _, ent in ipairs(ents.FindInSphere(owner:GetPos(), sphereRadius)) do
        if ent:IsPlayer() and ent ~= owner then
            ent:ConCommand("-duck")
        elseif ent:IsNPC() and ent:GetClass():find("npc_") then
            ent:SetSchedule(SCHED_NONE)
        end
    end

    if not self.IsActive and not self.IsSelfActive then
        net.Start("UpdateSpiritualPressureEffects")
        net.WriteBool(false)
        net.SendPVS(owner:GetPos())
    end
end

function SWEP:ResetOwnerSpeed(owner)
    owner:SetWalkSpeed(owner.OriginalWalkSpeed or 200)
    owner:SetRunSpeed(owner.OriginalRunSpeed or 400)
end

function SWEP:Holster()
    local owner = self:GetOwner()
    if IsValid(owner) then
        owner:DrawViewModel(true)
    end
    self:StopSpiritualPressure(false)
    self:StopSpiritualPressure(true)
    if IsValid(owner) then
        self:ResetOwnerSpeed(owner)
    end
    return true
end

function SWEP:OnRemove()
    self:StopSpiritualPressure(false)
    self:StopSpiritualPressure(true)
    local owner = self:GetOwner()
    if IsValid(owner) then
        self:ResetOwnerSpeed(owner)
    end
end

if CLIENT then
    local effectCenter = Vector(0, 0, 0)
    local effectRadius = 0
    local isEffectActive = false
    local effectOwner = nil
    local isSelfAffecting = false

    net.Receive("UpdateSpiritualPressureEffects", function()
        isEffectActive = net.ReadBool()
        if isEffectActive then
            effectCenter = net.ReadVector()
            effectRadius = net.ReadFloat()
            effectOwner = net.ReadEntity()
            isSelfAffecting = net.ReadBool()
        else
            effectOwner = nil
            isSelfAffecting = false
        end
    end)

    net.Receive("ApplySpiritualPressureScreenShake", function()
        util.ScreenShake(LocalPlayer():GetPos(), 5, 5, 0.5, 0)
    end)

    net.Receive("CreateHadesClawblastEffect", function()
        local owner = net.ReadEntity()
        if IsValid(owner) then
            ParticleEffect("HADES_CLAWBLAST01", owner:GetPos(), owner:GetAngles(), owner)
        end
    end)

    local function IsPlayerAffected()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        if ply == effectOwner and not isSelfAffecting then return false end
        return ply:GetPos():DistToSqr(effectCenter) <= effectRadius * effectRadius
    end

    local function DrawSpiritualPressureLines(center, radius)
        for i = 1, 50 do
            local angle = math.random() * math.pi * 2
            local distance = math.sqrt(math.random()) * radius
            local x = math.cos(angle) * distance
            local y = math.sin(angle) * distance
            
            local startPos = center + Vector(x, y, radius)
            local endPos = center + Vector(x, y, -radius)
            local color = i % 2 == 0 and Color(255, 255, 255, 150) or Color(0, 0, 0, 150)
            render.DrawLine(startPos, endPos, color, true)
        end
    end

    hook.Add("PreDrawHalos", "SpiritualPressureHaloEffect", function()
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetNWBool("SpiritualPressureHaloEffect", false) then
                halo.Add({ply}, Color(154, 120, 255), 3, 3, 5, true, true)
            end
        end
    end)

    hook.Add("RenderScreenspaceEffects", "SpiritualPressureEffect", function()
        if isEffectActive and IsPlayerAffected() then
            DrawColorModify({
                ["$pp_colour_addr"] = 0,
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = -0.1,
                ["$pp_colour_contrast"] = 1.2,
                ["$pp_colour_colour"] = 0.4,
                ["$pp_colour_mulr"] = 0,
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0
            })

            DrawToyTown(2, ScrH() / 2)
            DrawSharpen(1.5, 1.5)
            DrawMotionBlur(0.2, 0.8, 0.01)
        end
    end)

    hook.Add("PostDrawTranslucentRenderables", "SpiritualPressureLines", function()
        if isEffectActive and IsPlayerAffected() then
            DrawSpiritualPressureLines(effectCenter, effectRadius)
        end
    end)
end

