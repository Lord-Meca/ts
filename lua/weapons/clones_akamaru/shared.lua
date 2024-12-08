
AddCSLuaFile()

SWEP.PrintName = "Attaque des 2 chiens | Invocation"
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

SWEP.PlayerStates = {} 
SWEP.PlayerState = {
	DEFAULT = 0,
    READY_ATTACK = 1,
    ATTACKING = 2,
    COMEBACK = 3
}

function SWEP:Deploy()
	self.Owner:SetModel("models/falko_naruto_foc/body_upper/man_anbublackops_ame_hood_01.mdl")
end


function SWEP:Initialize()

    self:SetHoldType( "none" )
    self:SetPlayerState(self.Owner, self.PlayerState.DEFAULT)
    self.listEntities = {}
    self.targetPlayer = nil
end

function SWEP:SetPlayerState(ply, state)
    if not IsValid(ply) then return end
    self.PlayerStates[ply] = state
end

function SWEP:GetPlayerState(ply)
    if not IsValid(ply) then return nil end
    return self.PlayerStates[ply]
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end



local function invokeAkamarus(ply,self)
    local attackList = {"akamaruadulteattaque1", "akamaruadulteattaque2", "akamaruadulteattaque5", "akamaruadulteattaque4"}

    -- local function getGroundPos(pos)
    --     local trace = util.TraceLine({
    --         start = pos + Vector(0, 0, 10), 
    --         endpos = pos + Vector(0, 0, -50), 
    --         filter = modelEntity
    --     })

    --     return trace.HitPos
    -- end


    for i = 1, 2 do
        local modelEntity = ents.Create("prop_dynamic")
    
        if not IsValid(modelEntity) then return end
    
        modelEntity:SetModel("models/fsc/billy/chienninja6.mdl")
    
        local spawnOffset = Vector(200, 0, 0)
        local playerAngles = ply:EyeAngles()
        local spawnOffset
    
        if i == 1 then
            spawnOffset = playerAngles:Right() * -100
        else
            spawnOffset = playerAngles:Right() * 100
        end
    
        local spawnPos = ply:GetPos() + spawnOffset
    
        modelEntity:SetPos(spawnPos)
        modelEntity:SetAngles(Angle(0, playerAngles.yaw, 0))
        modelEntity:SetModelScale(1)
        modelEntity:Spawn()
    
        local animID = modelEntity:LookupSequence("akamaruadulteidle")
        if animID < 0 then return end
    
        modelEntity:SetSequence(animID)
        modelEntity:SetCycle(0)
        modelEntity:SetPlaybackRate(0.5)

        table.insert(self.listEntities, modelEntity)
    end
    
    local moveTimer = timer.Create("AkamaruMove_" .. ply:Nick(), 0.1, 0, function()

        if self:GetPlayerState(ply) == 2 then
 
            if not IsValid(self.targetPlayer) then return end
            
            local target = self.targetPlayer
            local targetPos = target:GetPos()

            local allDogsReached = true

            for _, modelEntity in ipairs(self.listEntities) do
                if IsValid(modelEntity) then
                    local modelPos = modelEntity:GetPos()
 
                    local directionToTarget = (targetPos - modelPos):GetNormalized()
        
                    local moveSpeed = 500
                    local moveOffset = directionToTarget * moveSpeed * 0.1
                    local newPos = (modelPos + moveOffset)
                    modelEntity:SetPos(newPos)
        
                    local newAngles = (targetPos - modelPos):Angle()
                    modelEntity:SetAngles(Angle(0, newAngles.yaw, 0))

                    if (targetPos - modelPos):Length() < 30 then

                        local randomAnimAttack = attackList[math.random(1, #attackList)]

                        local damageInfo = DamageInfo()
                        damageInfo:SetDamage(50) 
                        damageInfo:SetAttacker(modelEntity) 
                        damageInfo:SetInflictor(self) 
                        target:TakeDamageInfo(damageInfo)

                        ParticleEffect("blood_advisor_puncture",target:GetPos() + target:GetForward() * 0 + Vector( 0, 0, 20 ),Angle(0,45,0),nil)
                        ParticleEffect("nrp_kenjutsu_slash",target:GetPos() + target:GetForward() * 0 + Vector( 0, 0, 20 ),Angle(0,45,0),nil)

                        modelEntity:SetSequence(modelEntity:LookupSequence(randomAnimAttack))
                        modelEntity:SetCycle(0)
                        modelEntity:SetPlaybackRate(1)
        
                        net.Start("DisplayDamage")
                        net.WriteInt(50, 32)
                        net.WriteEntity(target)
                        net.WriteColor(Color(249, 148, 6, 255))
                        net.Send(ply)
        
                    else
           
                        allDogsReached = false
                    end
                end
            end

            if allDogsReached then
                timer.Simple(0.5, function()
                    for _, entity in ipairs(self.listEntities) do 
                        if IsValid(entity) then
                            ParticleEffect("nrp_tool_invocation", entity:GetPos(), entity:GetAngles(), entity)
                            if IsValid(ply) then
                                ply:EmitSound("ambient/explosions/explode_9.wav")
                            end
                
                            timer.Simple(1, function()
                                if IsValid(entity) then
                                    entity:Remove()
                                end
                            end)
                        end
                    end
            
                    table.Empty(self.listEntities)
                    self.targetPlayer = nil
                    timer.Remove("AkamaruMove_" .. ply:Nick())
                end)


            end
        
        
        
        elseif self:GetPlayerState(ply) == 3 then

            local playerPos = ply:GetPos()
        
            for _, modelEntity in ipairs(self.listEntities) do
                if IsValid(modelEntity) then
        
                    local modelPos = modelEntity:GetPos()
        
                    local directionToPlayer = (playerPos - modelPos):GetNormalized() 
    
                    local moveSpeed = 700
                    local moveOffset = directionToPlayer * moveSpeed * 0.1

                    modelEntity:SetPos(modelPos + moveOffset)

                    local newAngles = (playerPos - modelPos):Angle()
                    modelEntity:SetAngles(Angle(0, newAngles.yaw, 0)) 

                    if (playerPos - modelPos):Length() < 100 then

                        modelEntity:SetSequence(modelEntity:LookupSequence("akamaruadulteidlebase"))
                        modelEntity:SetCycle(0)
                        modelEntity:SetPlaybackRate(1)

                    end
                end
            end
        end
    end)
    
    timer.Simple(20, function()
        self:SetPlayerState(ply, self.PlayerState.DEFAULT)
        for _, entity in ipairs(self.listEntities) do 
            if IsValid(entity) then
                ParticleEffect("nrp_tool_invocation", entity:GetPos(), entity:GetAngles(), entity)
                if IsValid(ply) then
                    ply:EmitSound("ambient/explosions/explode_9.wav")
                end
    
                timer.Simple(1, function()
                    if IsValid(entity) then
                        entity:Remove()
                    end
                end)
            end
        end

        table.Empty(self.listEntities)
        self.targetPlayer = nil
    end)
    
    
   
end
local function DrawRadius3D(ply, radius)
    local model = "models/props_phx/construct/metal_dome360.mdl"  
    local circle = ClientsideModel(model, RENDERGROUP_TRANSLUCENT)
    if not IsValid(circle) then return end

    circle:SetModelScale(radius / 50, 0)
    circle:SetMaterial("models/wireframe")  
    circle:SetColor(Color(255,0,0,255))
    circle:SetPos(ply:GetPos())
    circle:SetAngles(Angle(0, 0, 0))

    timer.Simple(3, function()
        if IsValid(circle) then
            circle:Remove()
        end
    end)
end
function SWEP:Reload()
    local ply = self.Owner
    local maxDistance = 2000
    local radius = 300
  
    if not ply:IsOnGround() then return end

	if CurTime() < self.NextSpecialMove then return end
	self.NextSpecialMove = CurTime() + 1

	local particleName = "nrp_tool_invocation"
	local attachment = ply:LookupBone("ValveBiped.Bip01_R_Foot")

    local currentState = self:GetPlayerState(ply)

    if currentState == 0 or currentState == nil then
        local trace = ply:GetEyeTrace()
        local target = trace.Entity
        if not (IsValid(target) and target:IsPlayer() and trace.HitPos:DistToSqr(ply:GetPos()) <= maxDistance ^ 2) then

            local hitPos = trace.HitPos
            for _, ent in ipairs(ents.FindInSphere(hitPos, radius)) do
                if ent:IsPlayer() and ent ~= ply then
                    target = ent
                    break
                end
            end

            if not (IsValid(target) and target:IsPlayer()) then
                return
            end
        end
        --DrawRadius3D(target, radius)
        self.targetPlayer = target


        self:SetHoldType("anim_invoke")
        ply:SetAnimation(PLAYER_RELOAD)
        timer.Simple(1, function()
            self:SetHoldType("anim_invoke")
            ply:SetAnimation(PLAYER_ATTACK1)
        end)



        if SERVER then

            util.AddNetworkString("DisplayDamage")

            timer.Simple(1.5, function()
                ply:Freeze(true)
                ply:EmitSound("ambient/explosions/explode_9.wav")
                if attachment then
                    ParticleEffectAttach(particleName, PATTACH_ABSORIGIN_FOLLOW, ply, attachment)
                end


                local modelEntity = ents.Create("prop_physics")
                if IsValid(modelEntity) then
                    modelEntity:SetModel("models/foc_props_jutsu/jutsu_sceau_piege/foc_jutsu_sceau_piege.mdl")
                    
                    modelEntity:SetPos(ply:GetPos() + Vector(0, 0, 0)) 
                    modelEntity:SetAngles(Angle(0, 0, 0))
                    modelEntity:SetColor(Color(0,0,0,255))
                    modelEntity:SetModelScale(4)
                    modelEntity:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE) 
                    modelEntity:SetRenderMode(RENDERMODE_TRANSCOLOR)
                    modelEntity:SetKeyValue("solid", "0")
                        
                    modelEntity:Spawn()

                    local physObj = modelEntity:GetPhysicsObject()
                    if IsValid(physObj) then
                        physObj:EnableMotion(false)
                    end

                

                    timer.Simple(0.5, function()
                        self:SetPlayerState(ply, self.PlayerState.READY_ATTACK)
                        invokeAkamarus(ply,self)

                        
                        timer.Simple(0.7, function() 
                            if IsValid(ply) then
                                ply:StopParticles()
                                ply:Freeze(false)
                            end

                            if IsValid(modelEntity) then
                                modelEntity:Remove()
                            end
                        end)
                    end)


                end





            end)
        end
    elseif currentState == 1 or currentState == 3 then

        self:SetPlayerState(ply, self.PlayerState.ATTACKING)
        
        for _, entity in ipairs(self.listEntities) do 
            if IsValid(entity) then
                local animID = entity:LookupSequence("akamaruadulte_run_base")
                if animID < 0 then return end
            
                entity:SetSequence(animID)
                entity:SetCycle(0)
                entity:SetPlaybackRate(1)
            end
        end  

    elseif currentState == 2 then

        self:SetPlayerState(ply, self.PlayerState.COMEBACK)
        
        for _, entity in ipairs(self.listEntities) do 
            if IsValid(entity) then
                local animID = entity:LookupSequence("akamaruadulte_run_base")
                if animID < 0 then return end
            
                entity:SetSequence(animID)
                entity:SetCycle(0)
                entity:SetPlaybackRate(1)
            end
        end  

    end

end
