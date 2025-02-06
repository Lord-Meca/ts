
AddCSLuaFile()

SWEP.PrintName = "Monture Dragon | Invocation"
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
	self.Owner:SetModel("models/falko_naruto_foc/body_upper/sogeki_man_secte2.mdl")
end


function SWEP:Initialize()

    self:SetHoldType( "normal" )

    self.dragonActive = nil
    self.attachedEntity = nil

end


function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

local function detachEntity(self)
    if IsValid(self.attachedEntity) then
        self.attachedEntity:SetParent(nil)
        self.attachedEntity:SetMoveType(MOVETYPE_WALK)
        self.attachedEntity.isAttached = false
        self.attachedEntity = nil
    end
end

-- local function invokeDragon(ply, self)
--     if not IsValid(ply) then return end

--     local modelEntity = ents.Create("prop_dynamic")
--     local speed = 15
--     local duration = 10

--     if not IsValid(modelEntity) then return end

--     modelEntity:SetModel("models/oldjimmy/dragon/mokuton_dragon.mdl")

--     local playerAngles = ply:EyeAngles()
--     local spawnOffset = playerAngles:Forward() * 20 
--                         + playerAngles:Right() * 20 
--                         + playerAngles:Up() * -10

--     local spawnPos = ply:GetPos() + spawnOffset
--     modelEntity:SetPos(spawnPos)
--     modelEntity:SetMaterial("models/fsc/billy/waterdragon/mi_wep_eff_supersharkbomb_f_01")
--     modelEntity:SetColor(Color(255,223,127))
--     modelEntity:SetAngles(playerAngles)
   
--     modelEntity:SetModelScale(4)
--     modelEntity:Spawn()
--     self.dragonActive = modelEntity
--     --util.SpriteTrail(modelEntity, 0, Color(255,255,255), false, 100, 100, 1, 50, "trails/laser.vmt")
--     ParticleEffectAttach("[8]_lightning_armor", PATTACH_POINT_FOLLOW, modelEntity, 0)

--     local anim = modelEntity:LookupSequence("swim_passive_a_swimw")
--     if anim > 0 then
--         modelEntity:ResetSequence(anim)
--         modelEntity:SetPlaybackRate(1)
--     end

--     modelEntity:SetSolid(SOLID_NONE)
--     modelEntity:SetMoveType(MOVETYPE_NONE)

--     ply:SetMoveType(MOVETYPE_NONE)

--     local function moveDragon()
--         if not IsValid(modelEntity) or not IsValid(ply) then return end

--         local playerAngles = ply:EyeAngles()
--         local direction = playerAngles:Forward()

--         local newPos = modelEntity:GetPos() + direction * speed
--         modelEntity:SetPos(newPos)

--         local currentAngles = modelEntity:GetAngles()
--         local targetAngles = Angle(playerAngles.p, playerAngles.y, 0)
--         modelEntity:SetAngles(LerpAngle(0.1, currentAngles, targetAngles)) 

--         local playerOffset = playerAngles:Forward() * -100 + Vector(0,0,200)
--         ply:SetPos(modelEntity:GetPos() + playerOffset)

--         timer.Simple(0.01, moveDragon)
--     end

--     moveDragon()

--     timer.Simple(duration, function()
--         if IsValid(modelEntity) and IsValid(ply) then
--             ParticleEffect("nrp_tool_invocation", modelEntity:GetPos(), modelEntity:GetAngles(), modelEntity)
--             ply:EmitSound("ambient/explosions/explode_9.wav")
--             self:SetHoldType("normal")
--             ply:SetMoveType(MOVETYPE_WALK)
--             ply:SetVelocity(Vector(0, 0, 200)) 
--             if IsValid(self.attachedEntity) then
--                 detachEntity(self) 
--             end
--             modelEntity:Remove()
--             self.dragonActive = nil
--         end
--     end)
-- end

local function invokeDragon(ply, self)
    if not IsValid(ply) then return end

    local modelEntity = ents.Create("prop_dynamic")
    local speed = 15
    local duration = 10

    if not IsValid(modelEntity) then return end

    modelEntity:SetModel("models/fsc/billy/aigleninja7.mdl")

    local playerAngles = ply:EyeAngles()
    local spawnOffset = playerAngles:Forward() * 20 
                        + playerAngles:Right() * 20 
                        + playerAngles:Up() * -10

    local spawnPos = ply:GetPos() + spawnOffset
    modelEntity:SetPos(spawnPos)
    modelEntity:SetAngles(playerAngles)
   
    modelEntity:SetModelScale(1.3)
    modelEntity:Spawn()
    self.dragonActive = modelEntity

    local anim = modelEntity:LookupSequence("sumnj02_bank_up_start")
    if anim > 0 then
        modelEntity:ResetSequence(anim)
        modelEntity:SetPlaybackRate(1)
    end

    modelEntity:SetSolid(SOLID_NONE)
    modelEntity:SetMoveType(MOVETYPE_NONE)

    ply:SetMoveType(MOVETYPE_NONE)

    local function moveDragon()
        if not IsValid(modelEntity) or not IsValid(ply) then return end

        local playerAngles = ply:EyeAngles()
        local direction = playerAngles:Forward()

        local newPos = modelEntity:GetPos() + direction * speed
        modelEntity:SetPos(newPos)

        local currentAngles = modelEntity:GetAngles()
        local targetAngles = Angle(playerAngles.p, playerAngles.y, 0)
        modelEntity:SetAngles(LerpAngle(0.1, currentAngles, targetAngles)) 

        local playerOffset = playerAngles:Forward() * -100 + Vector(0,0,50)
        ply:SetPos(modelEntity:GetPos() + playerOffset)

        timer.Simple(0.01, moveDragon)
    end

    moveDragon()

    timer.Simple(duration, function()
        if IsValid(modelEntity) and IsValid(ply) then
            ParticleEffect("nrp_tool_invocation", modelEntity:GetPos(), modelEntity:GetAngles(), modelEntity)
            ply:EmitSound("ambient/explosions/explode_9.wav")
            self:SetHoldType("normal")
            ply:SetMoveType(MOVETYPE_WALK)
            ply:SetVelocity(Vector(0, 0, 200))

            if IsValid(self.attachedEntity) then
                detachEntity(self) 
            end
            modelEntity:Remove()
            
            self.dragonActive = nil

        end
    end)
end

local function attachEntityToDragon(entity, dragon,self)
    if not IsValid(entity) or not IsValid(dragon) then return end

    if IsValid(self.attachedEntity) then
        detachEntity(self)
    end

    self.attachedEntity = entity
    self.attachedEntity.isAttached = true
    self.attachedEntity:SetParent(dragon)
    self.attachedEntity:SetMoveType(MOVETYPE_NONE) 

    hook.Add("Think", "AttachEntityThink_" .. entity:EntIndex(), function()
        if not IsValid(self.attachedEntity) or not IsValid(dragon) then
            hook.Remove("Think", "AttachEntityThink_" .. entity:EntIndex())
            return
        end

        local dragonPos = dragon:GetPos()
        local offset = Vector(0, 0, -30) 
        self.attachedEntity:SetPos(dragonPos + offset)
    end)


end

function SWEP:Reload()
    local ply = self.Owner

    if CurTime() < self.NextSpecialMove then return end
    self.NextSpecialMove = CurTime() + 2

    if IsValid(self.dragonActive) then
 
        if IsValid(self.attachedEntity) then
            detachEntity(self)
            return
        end

        for _, entity in pairs(ents.FindInSphere(ply:GetPos(), 200)) do
            if IsValid(entity) and (entity:IsPlayer() or entity:IsNPC()) and entity ~= ply then
                attachEntityToDragon(entity, self.dragonActive,self)

                self.dragonActive:ResetSequence(self.dragonActive:LookupSequence("sumnj02_fly_start"))
                self.dragonActive:SetPlaybackRate(1)

                timer.Simple(0.5, function()
                    self.dragonActive:ResetSequence(self.dragonActive:LookupSequence("sumnj02_bank_up_start"))
                    self.dragonActive:SetPlaybackRate(1)
                end)

          

                return
            end
        end

        return
    else
     

        self:SetHoldType("anim_invoke")
        ply:SetAnimation(PLAYER_RELOAD)

        timer.Simple(1, function()
            self:SetHoldType("anim_invoke")
            ply:SetAnimation(PLAYER_ATTACK1)
        end)

        if SERVER then
            timer.Simple(1.5, function()
                ply:EmitSound("ambient/explosions/explode_9.wav")

                local modelEntity = ents.Create("prop_physics")
                if IsValid(modelEntity) then
                    modelEntity:SetModel("models/foc_props_jutsu/jutsu_invocation/foc_jutsu_invocation.mdl")
                    modelEntity:SetPos(ply:GetPos() + Vector(0, 0, 4))
                    modelEntity:SetAngles(Angle(180, 0, 0))
                    modelEntity:SetColor(Color(0, 0, 0, 255))
                    modelEntity:SetModelScale(1)
                    modelEntity:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
                    modelEntity:SetRenderMode(RENDERMODE_TRANSCOLOR)
                    modelEntity:SetKeyValue("solid", "0")
                    modelEntity:Spawn()

                    local physObj = modelEntity:GetPhysicsObject()
                    if IsValid(physObj) then
                        physObj:EnableMotion(false)
                    end

                    timer.Simple(0.5, function()
                        invokeDragon(ply, self)
                        self:SetHoldType("anim_ninjutsu4")

                        timer.Simple(0.7, function()
                            if IsValid(ply) then
                                ply:StopParticles()
                            end

                            if IsValid(modelEntity) then
                                modelEntity:Remove()
                            end
                        end)
                    end)
                end
            end)
        end
    end
end
