AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Etui du serpent | Entité"
ENT.Author = "Lord_Meca"
ENT.Category = "TypeShit | Entities"

ENT.Spawnable = true
ENT.AdminOnly = false

ENT.NextUseTime = 0

ENT.DefaultModel = "models/hunter/plates/plate.mdl"

ENT.WeaponModel = nil
ENT.WeaponClass = nil

ENT.holstered = false 
ENT.animationPlaying = false 

function ENT:SpawnFunction(ply, tr, ClassName)
    if not tr.Hit then return end
    local SpawnPos = tr.HitPos + tr.HitNormal * 16 

    local ent = ents.Create(ClassName)
    ent:SetPos(SpawnPos - Vector(0, 0, 25))
    ent:Spawn()
    ent:Activate()

    return ent
end

function ENT:Initialize()
    if CLIENT then return end

 

    self:SetModel("models/foc/ska/multiplesnakemode.mdl")
    --:SetMaterial("wallpaper6")
    
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_BBOX)
   
    if self.WeaponModel == nil then
        local modelWeapon = ents.Create("prop_physics")
        modelWeapon:SetModel(self.DefaultModel)
        modelWeapon:SetPos(self:GetPos()+Vector(-40,30,60))
        modelWeapon:SetAngles(Angle(90,0,0))
        modelWeapon:SetModelScale(1)
        modelWeapon:Spawn()
        modelWeapon:SetMoveType(MOVETYPE_NOCLIP)
        modelWeapon:SetNoDraw(true)
    
        self.WeaponModel = modelWeapon

        local seq = self:LookupSequence("multiplesnakemodegrab")

        if seq and seq >= 0 then
            self:SetSequence(seq)
            self:ResetSequenceInfo()
            self:SetPlaybackRate(1)
            self:SetCycle(0)
            self.animationPlaying = true 
    
            local duration = self:SequenceDuration(seq)
    
            timer.Simple(0.5, function()
                if IsValid(self) then
                    self.animationPlaying = false
                    self.holstered = false
                end
            end)
        end
    end



end

function ENT:Think()
    
    if self.animationPlaying then
       
        local rate = self:GetPlaybackRate()
        self:SetCycle(math.Clamp(self:GetCycle() + FrameTime() * rate, 0, 1))

        if (rate > 0 and self:GetCycle() >= 1) or (rate < 0 and self:GetCycle() <= 0) then
            self:SetPlaybackRate(0) 
            self.animationPlaying = false 

     
            self.holstered = rate < 0
        end
    end

    self:NextThink(CurTime())
    return true
end

function ENT:Use(activator, caller)

    if CurTime() < (self.NextUseTime or 0) then return end
    self.NextUseTime = CurTime() + 5

    if not activator:IsPlayer() or self.animationPlaying then return end

    local seq = self:LookupSequence("multiplesnakemodegrab")
    if not (seq and seq >= 0) then return end

    self:SetSequence(seq)
    self:ResetSequenceInfo()
    self.animationPlaying = true

    if self.holstered then
       
        self:HandleDeploy(activator)
    else
       
        self:HandleHolster(activator)
    end
end

function ENT:HandleDeploy(activator)
    self:SetPlaybackRate(1)
    self:SetCycle(0)

    local modelWeapon = self:GetWeaponModel(self)
    modelWeapon:SetNoDraw(false)

    self:MoveModelWeapon(modelWeapon, Vector(0, 0, 2), 40)

    timer.Simple(0.8, function()
        if IsValid(self) then
            self.animationPlaying = false
            self.holstered = false

            activator:Give(self.WeaponClass)
            RunConsoleCommand("gm_giveswep", self.WeaponClass) 
            RunConsoleCommand("use", self.WeaponClass) 
        
        end
    end)

    timer.Simple(3, function()
        if IsValid(self) then
        

            activator:EmitSound("ambient/explosions/explode_9.wav")
            ParticleEffect("nrp_tool_invocation", self:GetPos(), Angle(0, 0, 0), nil)
  
            self:Remove()

            
        end
    end)
end

function ENT:HandleHolster(activator)
  

    local modelWeapon = self:GetWeaponModel(self)

    if modelWeapon:GetModel() == self.DefaultModel then
        local activeWeapon = activator:GetActiveWeapon()
        if IsValid(activeWeapon) and activeWeapon.Category == "TypeShit | Armes" then
            modelWeapon:SetModel(activeWeapon:GetModel())
            self.WeaponClass = activeWeapon:GetClass()
            
            activeWeapon:Remove()
            activator:SetNWString("snakeHolstered_model", activeWeapon:GetModel())
            activator:SetNWString("snakeHolstered_class", activeWeapon:GetClass())
        else
            return
        end

    end

    self:SetPlaybackRate(-1)
    self:SetCycle(1)
    modelWeapon:SetNoDraw(false)
    self:MoveModelWeapon(modelWeapon, Vector(0, 0, -2), 40)

    timer.Simple(2.5, function()
        if IsValid(self) then
            activator:EmitSound("ambient/explosions/explode_9.wav")
            ParticleEffect("nrp_tool_invocation", self:GetPos(), Angle(0, 0, 0), nil)

            self:Remove()
        end
    end)

    self.holstered = true
end

function ENT:MoveModelWeapon(modelWeapon, direction, steps)
    if not IsValid(modelWeapon) then return end

    local interval = 0.05
    timer.Create("MoveModelWeapon_" .. modelWeapon:EntIndex(), interval, steps, function()
        if IsValid(modelWeapon) then
            local currentPos = modelWeapon:GetPos()
            modelWeapon:SetPos(currentPos + direction)
        end
    end)
end


function ENT.GetWeaponModel(self)
    return self.WeaponModel
end

function ENT:OnRemove()
    local modelWeapon = self:GetWeaponModel(self)
    if IsValid(modelWeapon) then

        modelWeapon:Remove()
    end
    
    
end
