if SERVER then

    AddCSLuaFile()
    util.AddNetworkString("OpenMenuScroll")
    util.AddNetworkString("RemoveScroll")
end

DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Parchemin Piégé"
ENT.Author = "Lord_Meca"

ENT.Category = "TypeShit | Entities"

ENT.Spawnable = true
ENT.AdminOnly = false

local mudrasList = {"Rat", "Lièvre", "Tigre", "Serpent",
                    "Chien", "Buffle", "Dragon", "Coq", 
                    "Singe", "Sanglier", "Chèvre"}


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

    self:SetModel("models/foc_props_map/rouleau_15/foc_rouleau_15.mdl")
    self:SetSolid(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetUseType(SIMPLE_USE)
    self:SetHealth(100)
    self:DropToFloor()

end


if CLIENT then
    net.Receive("OpenMenuScroll", function()

        local scroll = net.ReadEntity()
        local ply = net.ReadEntity()

        local mudrasListCopy = {}
        for _, mudra in ipairs(mudrasList) do
            table.insert(mudrasListCopy, mudra)
        end
        
        local mudras = {}
        for i = 1, 8 do
            if #mudrasListCopy == 0 then break end 
        
            local rdmIndex = math.random(1, #mudrasListCopy) 
            local rdmMudra = mudrasListCopy[rdmIndex]
        
            table.insert(mudras, rdmMudra) 
            table.remove(mudrasListCopy, rdmIndex) 
        end
        

        if #mudras ~= 8 then return end

        surface.CreateFont("Large", {
            font = "Arial",
            size = 50,
            weight = 500,
        })

        local frame = vgui.Create("DFrame")
        frame:SetSize(ScrW() - 400, ScrH() - 400)
        frame:SetPos(200, 150)
        frame:SetTitle("")
        frame:MakePopup()
        frame:SetDraggable(false)
        frame:ShowCloseButton(false)

        frame.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 143))
            draw.RoundedBox(0, 0, 0, 200, 90, Color(46, 20, 27, 255))
            draw.RoundedBox(0, 0, 600, 200, 200, Color(46, 20, 27, 255))
            draw.RoundedBox(0, 0, 95, 200, 500, Color(31, 41, 44, 255))

            local x, y = (w / 5), (h / 2) + 320

            local matrix = Matrix()
            matrix:Translate(Vector(x, y, 0))
            matrix:Rotate(Angle(0, -90, 0))
            matrix:Translate(Vector(-x, -y, 0))

            cam.PushModelMatrix(matrix)

            draw.SimpleText("以離ッョソルホ留個と模おのソモオオ露", "Large", x, y, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            cam.PopModelMatrix()
        end

        local progressBar = vgui.Create("DPanel", frame)
        progressBar:SetSize(frame:GetWide() - 500, 50)
        progressBar:SetPos(350, frame:GetTall()-300)

        local targetZone = {
            x = math.random(100, progressBar:GetWide() - 200),
            width = 50,
        }

        local barPosition = 0
        local barSpeed = 400
        local direction = 1
        local targetZoneColor = Color(31, 41, 44, 255)

        progressBar.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,150))
            draw.RoundedBox(0, targetZone.x, 0, targetZone.width, h, targetZoneColor)
            draw.RoundedBox(0, barPosition, 0, 10, h, Color(75,33,44))
        end

        local correctMudras = {}
        local currentMudra = 1

        local function resetBar()
            targetZone.x = math.random(100, progressBar:GetWide() - 200)
            barPosition = 0
            direction = 1
        end

        frame.Think = function()
            local delta = FrameTime()
            barPosition = barPosition + (barSpeed * direction * delta)

            if barPosition <= 0 or barPosition >= progressBar:GetWide() - 10 then
                direction = -direction
            end
        end

        local mudraHistoryPanel = vgui.Create("DPanel", frame)
        mudraHistoryPanel:SetPos(frame:GetWide()-1170, 450)
        mudraHistoryPanel:SetSize(frame:GetWide() -498, 100)
        mudraHistoryPanel.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(75,33,44)) 
        end
        
        local function updateMudraHistory()
            mudraHistoryPanel:Clear()
            local x = 50
            for _, mudra in ipairs(correctMudras) do
                local mudraLabel = vgui.Create("DLabel", mudraHistoryPanel)
                mudraLabel:SetPos(x, 25)
                mudraLabel:SetFont("Large")
                mudraLabel:SetTextColor(Color(200, 200, 200)) 
                mudraLabel:SetText(mudra)
                mudraLabel:SizeToContents()
                x = x + mudraLabel:GetWide() + 20 
            end
        end
        
        frame.OnKeyCodePressed = function(_, key)
            if key == KEY_SPACE then
                if barPosition >= targetZone.x and barPosition <= targetZone.x + targetZone.width then
                    table.insert(correctMudras, mudras[currentMudra])
                    updateMudraHistory() 
        
                    currentMudra = currentMudra + 1
                    if currentMudra > #mudras then
                        ply:EmitSound("HealthKit.Touch")
                        frame:Close()
                        return
                    end
                    

                    resetBar()
                else
                    ply:EmitSound(Sound("ambient/explosions/explode_4.wav"))
                  
                    net.Start("RemoveScroll")
                    net.WriteEntity(scroll)
                    net.SendToServer()
            
                    frame:Close()


                end
            end
        end
        
        local mudraLabel = vgui.Create("DLabel", frame)
        mudraLabel:SetPos((ScrW()/2)-200, 300)
        mudraLabel:SetFont("Large")
        mudraLabel:SetTextColor(Color(255, 255, 255))
        mudraLabel:SetText(mudras[currentMudra])
        mudraLabel:SetContentAlignment(5) 
        
        mudraLabel.Paint = function(self, w, h)
            surface.SetFont("Large")
            local textWidth, textHeight = surface.GetTextSize(self:GetText())
            local bgColor = Color(75, 33, 44)
            if self:IsHovered() then
                bgColor = Color(46, 20, 27, 255)
            end
            draw.RoundedBox(10, (w - textWidth - 20) / 2, (h - textHeight - 10) / 2, textWidth + 20, textHeight + 10, bgColor)
        end
        
        mudraLabel.Think = function()
            mudraLabel:SetText(mudras[currentMudra])
            mudraLabel:SizeToContentsX(20)
            mudraLabel:SizeToContentsY(10)
        end
        
    end)
end

if SERVER then
    net.Receive("RemoveScroll", function()
        local scroll = net.ReadEntity()

        ParticleEffect("nrp_explosion", scroll:GetPos(), Angle(0,0,0), nil)
        scroll:Remove()
    end)
end


function ENT:Use(activator, caller)
    if caller:IsPlayer() then
        local cooldown = 0.5 

        if self.NextUseTime == nil then
            self.NextUseTime = 0
        end

        if CurTime() < self.NextUseTime then
            return
        end
     
        self.NextUseTime = CurTime() + cooldown

        local scroll = self
        net.Start("OpenMenuScroll")
        net.WriteEntity(scroll)
        net.WriteEntity(activator)
        net.Send(caller)
  


    end
end


-- if CLIENT then
--     function ENT:Draw()
--         self:DrawModel()
        
     
--         local pos = self:GetPos()
--         local ang = self:GetAngles()
--         ang:RotateAroundAxis(ang:Up(), 90) 

--         local text = "Parchemin Piégé"
--         local font = "DermaLarge"
--         local textWidth, textHeight = surface.GetTextSize(text)
--         local bgPadding = 10 

--         cam.Start3D2D(pos + Vector(0, 0, 80), Angle(0, LocalPlayer():EyeAngles().y - ang.y, 90), 0.2)
      
--             draw.RoundedBox(8, -textWidth / 2 - bgPadding, -textHeight / 2 - bgPadding, textWidth + 2 * bgPadding, textHeight + 2 * bgPadding, Color(0, 0, 0, 200))

           
--             draw.SimpleText(text, font, 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
--         cam.End3D2D()


--     end

  
-- end

