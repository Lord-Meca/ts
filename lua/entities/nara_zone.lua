AddCSLuaFile()

DEFINE_BASECLASS("base_gmodentity")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Zone d'ombre | Nara"
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

    self:SetModel("models/hunter/tubes/circle4x4.mdl")
    self:SetMaterial("models/debug/debugwhite")
    self:SetColor(Color(0, 0, 0))
    self:SetHealth(100)
    self:SetModelScale(0.1) 
    self:DropToFloor()

    self.playersFrozen = {}
    self:SetNWBool("Active", true)

    self.TargetScale = 4 
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

            local alpha = math.Clamp((newScale / self.TargetScale) * 255, 0, 255)
            self:SetColor(Color(0, 0, 0, alpha))
        else

            self:SetModelScale(self.TargetScale)
            self.ThinkFunction = function() self:FreezeNearbyPlayers() end
        end
    end
end

function ENT:FreezeNearbyPlayers()
    if not self:GetNWBool("Active") then return end

    local radius = 400 
    for _, player in ipairs(ents.FindInSphere(self:GetPos(), radius)) do
        if player:IsPlayer() and player ~= self.Owner and not table.HasValue(self.playersFrozen, player) then
            player:Freeze(true)
            table.insert(self.playersFrozen, player)
        end
    end
end

function ENT:startTimer()
    timer.Simple(4, function()
        if not IsValid(self) then return end

        for _, player in ipairs(self.playersFrozen or {}) do
            if IsValid(player) then
                player:Freeze(false)
            end
        end

        table.Empty(self.playersFrozen)
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
