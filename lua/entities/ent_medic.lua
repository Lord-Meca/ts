AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Médecin"
ENT.Author = "Lord_Meca"
ENT.Information = "Médecin"
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

    self:SetModel("models/falko_naruto_foc/animal/katsuyu.mdl")
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

        activator:SetHealth(3000)
        activator:SetMaxHealth(3000)
        activator:EmitSound("HealthKit.Touch") 
        self.NextUseTime = CurTime() + cooldown

       

        
    end
end


if CLIENT then
    function ENT:Draw()
        self:DrawModel()
        
     
        local pos = self:GetPos()
        local ang = self:GetAngles()
        ang:RotateAroundAxis(ang:Up(), 90) 

        local text = "Médecin"
        local font = "DermaLarge"
        local textWidth, textHeight = surface.GetTextSize(text)
        local bgPadding = 10 

        cam.Start3D2D(pos + Vector(0, 0, 80), Angle(0, LocalPlayer():EyeAngles().y - ang.y, 90), 0.2)
      
            draw.RoundedBox(8, -textWidth / 2 - bgPadding, -textHeight / 2 - bgPadding, textWidth + 2 * bgPadding, textHeight + 2 * bgPadding, Color(0, 0, 0, 200))

           
            draw.SimpleText(text, font, 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()


    end

  
end

