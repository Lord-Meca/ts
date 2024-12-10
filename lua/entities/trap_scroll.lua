if SERVER then

    AddCSLuaFile()
    util.AddNetworkString("OpenMenuScroll")
end

DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Parchemin Piégé"
ENT.Author = "Lord_Meca"

ENT.Category = "TypeShit | Entities"

ENT.Spawnable = true
ENT.AdminOnly = false

local mudrasList = {"Rat", "Lièvre", "Tigre", "Serpent",
                    "Chien", "Buffle", "Dragon", "Coq"}


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

function OpenScrollMenu(ply)
    

end

if CLIENT then
    net.Receive("OpenMenuScroll", function()

        local mudrasListCopy = {}
        for _, mudra in ipairs(mudrasList) do
            table.insert(mudrasListCopy, mudra)
        end
        local mudras = {}
        for i = 1,3 do
            local rdmMudra = mudrasListCopy[math.random(1, #mudrasListCopy)]

            if rdmMudra ~= nil then

                table.insert(mudras, rdmMudra)
                table.remove(mudrasListCopy, rdmMudra.id)


            end
        end

        if #mudras ~= 3 then return end

        surface.CreateFont("Large", {
            font = "Arial", 
            size = 50,
            weight = 500,  

        })
        
        local frame = vgui.Create("DFrame")
        frame:SetSize(ScrW()-400, ScrH()-400)
        frame:SetPos(200, 150)
        frame:SetTitle("")
        frame:MakePopup()
        frame:SetDraggable(false)
        frame:ShowCloseButton(false)
    
        frame.Paint = function(self, w, h)
            
            draw.RoundedBox(0, 0, 0, w, h, Color(255,255,255,143)) 
            draw.RoundedBox(0, 0, 0, 200, 90, Color(46,20,27,255)) 
          
            draw.RoundedBox(0, 0, 600, 200, 200, Color(46,20,27,255)) 
            draw.RoundedBox(0, 0, 95, 200, 500, Color(31,41,44, 255)) 
            --draw.RoundedBox(0, 100, -100, 150, 100, Color(30,27,28,255)) 

            local x,y = (w/5), (h/2)+320

            local matrix = Matrix()
            matrix:Translate(Vector(x,y,0))
            matrix:Rotate(Angle(0,-90,0))
            matrix:Translate(Vector(-x, -y, 0))

            cam.PushModelMatrix(matrix)

                draw.SimpleText("以離ッョソルホ留個と模おのソモオオ露", "Large", x, y, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
             
            cam.PopModelMatrix()
        end

        local submitButton = vgui.Create("DButton", frame)
        submitButton:SetPos(50, 620)
        submitButton:SetSize(100, 30)
        submitButton:SetText("debug")
        submitButton.DoClick = function()


            frame:Close()
        end

        local stepX = 200
        local correctMudras = {}
        local actualPos = 1

        for _, mudra in ipairs(mudras) do
     
            local mudraButton = vgui.Create("DButton", frame)
            mudraButton:SetPos(300+stepX, 300)
            mudraButton:SetSize(200, 100)
            mudraButton:SetFont("Large")
            mudraButton:SetTextColor(Color(255,255,255))
            mudraButton:SetText(mudra)

            mudraButton.Paint = function(self, w, h)
                local bgColor = Color(75,33,44)  
                if self:IsHovered() then
                    bgColor = Color(46,20,27,255)  
                end
                draw.RoundedBox(10, 0, 0, w, h, bgColor) 
            
            end

            mudraButton.DoClick = function()
                local mudraName = mudraButton:GetText()
                for k,v in ipairs(mudras) do
                    --print(k .. " | " .. v)
                    
                  

                    if k == actualPos and v == mudraName then
                        actualPos = actualPos +1
                        table.insert(correctMudras, mudraName)
                        
                        if actualPos > 3 then
                            print("mudras réussi !")
                            
                            table.Empty(correctMudras)
                            actualPos = 1
                            table.Empty(mudras)

                            frame:Close()
                        end

                    end
                    

                end

            end

            stepX = stepX +250
        end



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
        
        net.Start("OpenMenuScroll")
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

