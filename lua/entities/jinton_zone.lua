AddCSLuaFile()

DEFINE_BASECLASS("base_gmodentity")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Cube de protection Jinton | Kekkei Genkai"
ENT.Author = "Lord_Meca"
ENT.Category = "TypeShit | Entities"

ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SpawnFunction(ply, tr, ClassName)
    if not tr.Hit then return end

    local SpawnPos = tr.HitPos + tr.HitNormal * 16

    local ent = ents.Create(ClassName)
    if not IsValid(ent) then return end

    ent:SetPos(SpawnPos)
    ent:Spawn()
    ent:Activate()

    ent.Owner = ply


    return ent
end


function ENT:Initialize()
    if CLIENT then return end

    self:SetModel("models/fsc/billy/cubeonoki.mdl")
    self:SetHealth(100)
    self:SetModelScale(0.1) 
    self:DropToFloor()
    self:SetPos(self:GetPos()+Vector(0,0,150))

    self.playersTakenDamage = {}
    self:SetNWBool("Active", true)

    self.TargetScale = 5 
    self.ScaleSpeed = 0.2

    self:startAnim()
    self:startTimer() 

end

function ENT:startAnim()
    self.ThinkFunction = function()
        local currentScale = self:GetModelScale()
        if currentScale < self.TargetScale then
            local newScale = math.min(currentScale + self.ScaleSpeed, self.TargetScale)
            self:SetModelScale(newScale)

      
        else

            self:SetModelScale(self.TargetScale)
            self.ThinkFunction = function() self:DamageNearbyPlayers() end
        end
    end
end

function ENT:DamageNearbyPlayers()
    if not self:GetNWBool("Active") then return end

    local radius = 250
    local damageInterval = 1

    for _, player in ipairs(ents.FindInSphere(self:GetPos(), radius)) do
        if player:IsPlayer() and player:Alive() and player ~= self.Owner and not table.HasValue(self.playersTakenDamage, player) then
     
            local damageInfo = DamageInfo()
            damageInfo:SetDamage(100)
            damageInfo:SetDamageType(DMG_BLAST)
            damageInfo:SetAttacker(self.Owner)
            damageInfo:SetInflictor(self)

         

            table.insert(self.playersTakenDamage, player)

            timer.Create("JintonZoneDamageTimer_" .. player:EntIndex(), damageInterval, 0, function()
                if not IsValid(player) or not player:Alive() then
                    timer.Remove("JintonZoneDamageTimer_" .. player:EntIndex())
                    return
                end

  
                player:TakeDamageInfo(damageInfo)

            
                net.Start("DisplayDamage")
                net.WriteInt(100, 32)
                net.WriteEntity(player)
                net.WriteColor(Color(51, 125, 255, 255))
                net.Send(self.Owner)
            end)
        end
    end
end

function ENT:startTimer()
    timer.Simple(10, function()
        if not IsValid(self) then return end

        for _, player in ipairs(self.playersTakenDamage or {}) do
            if IsValid(player) then
                print("fin")
                --player:SetNWBool("freezePlayer", false)
            end
        end

        table.Empty(self.playersTakenDamage)
        self:SetNWBool("Active", false)
        self:Remove()
    end)
end

function ENT:Think()
    if self.ThinkFunction then
        self.ThinkFunction()
    end

    self:NextThink(CurTime())
    return true
end
