AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Sélecteur de personnage"
ENT.Author = "Lord_Meca"
ENT.Category = "TypeShit | Entities"

ENT.Spawnable = true
ENT.AdminOnly = false


function ENT:SpawnFunction(ply, tr, ClassName)
    if not tr.Hit then return end
    local SpawnPos = tr.HitPos + tr.HitNormal * 16

    local ent = ents.Create(ClassName)
    ent:SetPos(SpawnPos)
    ent:Spawn()
    ent:Activate()

    return ent
end


function ENT:Initialize()
    if CLIENT then return end

    self:SetModel("models/falko_pomme_suspicieuse/falko_pomme_suspicieuse.mdl")
    self:SetSolid(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetUseType(SIMPLE_USE)
    self:SetHealth(100)
    self:DropToFloor()

end

function ENT:Think()
    self:SetSequence("walk_all")
    self:NextThink(CurTime() + 1)
    return true
end

function ENT:Use(activator, caller)
    if activator:IsPlayer() then
        local cooldown = 2 

        if self.NextUseTime == nil then
            self.NextUseTime = 0
        end

        if CurTime() < self.NextUseTime then
          
            return
        end
        self.NextUseTime = CurTime() + cooldown

        activator:ConCommand("ts_characters")

    end
end


if CLIENT then
    function ENT:Draw()
        self:DrawModel()
        
     
        local pos = self:GetPos()
        local ang = self:GetAngles()
        ang:RotateAroundAxis(ang:Up(), 90) 

        local text = "Personnages"
        local font = "DermaLarge"
        local textWidth, textHeight = surface.GetTextSize(text)
        local bgPadding = 10 

        cam.Start3D2D(pos + Vector(0, 0, 80), Angle(0, LocalPlayer():EyeAngles().y - ang.y, 90), 0.2)
      
            draw.RoundedBox(8, -textWidth / 2 - bgPadding, -textHeight / 2 - bgPadding, textWidth + 2 * bgPadding, textHeight + 2 * bgPadding, Color(0, 0, 0, 200))

           
            draw.SimpleText(text, font, 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()


    end

  
end

