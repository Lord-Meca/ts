AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Mailbox"
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

    util.AddNetworkString("openMailBoxMenu")
    util.AddNetworkString("startCrowSequence")

    self:SetModel("models/foc_props_map/nid_oiseau/foc_nid_oiseau.mdl")
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

function crowSequence(ply)

    local modelEntity = ents.Create("prop_dynamic")
    local moveTimeLeft = 5
    local takeoffTime = 5

    if not IsValid(modelEntity) then return end

    modelEntity:SetModel("models/crow.mdl")

    local spawnPos = ply:GetPos() + Vector(0, 0, 350) + ply:EyeAngles():Forward() * 100

    modelEntity:SetPos(spawnPos)
    modelEntity:SetModelScale(1)
    modelEntity:Spawn()

    modelEntity:SetSequence(modelEntity:LookupSequence("land"))
    modelEntity:SetCycle(0)
    modelEntity:SetPlaybackRate(1)

    local direction = ply:EyeAngles():Up()
    local moveDistancePerSecond = 1

    local function getGroundPos(pos)
        local trace = util.TraceLine({
            start = pos + Vector(0, 0, 10), 
            endpos = pos + Vector(0, 0, -50), 
            filter = modelEntity
        })

        return trace.HitPos
    end

    local moveTimer = timer.Create("CrowMove_" .. modelEntity:EntIndex(), 0.150, 0, function()
        if IsValid(modelEntity) then
            local currentPos = modelEntity:GetPos()
            local newPos = currentPos + direction * moveDistancePerSecond * 0.1
            local groundPos = getGroundPos(newPos)

            if math.abs(currentPos.z - groundPos.z) < 5 then

                local moveTimer2 = timer.Create("CrowMoveToPlayer_" .. modelEntity:EntIndex(), 0.1, 0, function()
                    if IsValid(modelEntity) then
                        local currentPos = modelEntity:GetPos()
                        local playerPos = ply:GetPos()

                        local adjustedPlayerPos = Vector(playerPos.x, playerPos.y, currentPos.z)
                        local directionToPlayer = (adjustedPlayerPos - currentPos):GetNormalized()

                        local distanceToPlayer = (playerPos - currentPos):Length()
                        local moveSpeed = math.min(200, distanceToPlayer * 5)
                        local moveOffset = directionToPlayer * moveSpeed * 0.1

                        modelEntity:SetPos(currentPos + moveOffset)

                        local newAngles = (playerPos - currentPos):Angle()
                        modelEntity:SetAngles(Angle(0, newAngles.yaw, 0)) 

                        if distanceToPlayer < 50 then
                            modelEntity:SetSequence(modelEntity:LookupSequence("idle01"))
                            modelEntity:SetCycle(0)
                            modelEntity:SetPlaybackRate(1)

                            timer.Remove("CrowMoveToPlayer_" .. modelEntity:EntIndex())

                            timer.Simple(1, function()
                                startTakeoff(modelEntity, ply)
                            end)
                         
                        end
                    else
                        timer.Remove("CrowMoveToPlayer_" .. modelEntity:EntIndex())
                    end
                end)

                modelEntity:SetSequence(modelEntity:LookupSequence("run"))
                modelEntity:SetCycle(0)
                modelEntity:SetPlaybackRate(1)
                timer.Remove("CrowMove_" .. modelEntity:EntIndex())
                return
            end

            modelEntity:SetPos(groundPos)
        else
            timer.Remove("CrowMove_" .. modelEntity:EntIndex())
        end
    end)


end

function startTakeoff(modelEntity, ply)
    if not IsValid(modelEntity) then return end


    modelEntity:SetSequence(modelEntity:LookupSequence("takeoff"))
    modelEntity:SetCycle(0)
    modelEntity:SetPlaybackRate(1)

    timer.Simple(0.5, function()
        if IsValid(modelEntity) then
            modelEntity:SetSequence(modelEntity:LookupSequence("fly01"))
            modelEntity:SetCycle(0)
            modelEntity:SetPlaybackRate(1)
        end
    end)

    local direction = Vector(math.random(1,5),math.random(1,5), 1) 
    local moveSpeed = 200 

    local moveTimer = timer.Create("CrowTakeoff_" .. modelEntity:EntIndex(), 0.1, 50, function()
        if IsValid(modelEntity) then
            local currentPos = modelEntity:GetPos()
            local newPos = currentPos + direction * moveSpeed * 0.1

            local newAngles = direction:Angle()
            modelEntity:SetAngles(Angle(0, newAngles.yaw, 0))

            modelEntity:SetPos(newPos)
        else
            timer.Remove("CrowTakeoff_" .. modelEntity:EntIndex())
        end
    end)

    timer.Simple(5, function()
        if IsValid(modelEntity) then
            modelEntity:Remove()
        end
        timer.Remove("CrowTakeoff_" .. modelEntity:EntIndex())
    end)
end


function openSelectMenu(self)
    if CLIENT then
        local frame = vgui.Create("DFrame")
        frame:SetTitle("Mailbox")
        frame:SetSize(300, 250)
        frame:Center()
        frame:MakePopup()

        local comboBox = vgui.Create("DComboBox", frame)
        comboBox:Dock(TOP)
        comboBox:SetValue("Joueurs :")

        for _, player in pairs(player.GetAll()) do
            if player ~= LocalPlayer() then
                comboBox:AddChoice(player:Nick() .. " | " .. player:UniqueID(), player) 
            end
        end

        local validateButton = vgui.Create("DButton", frame)
        validateButton:SetText("Valider")
        validateButton:Dock(BOTTOM)
        validateButton.DoClick = function()
            local selectedPlayer = comboBox:GetSelected() 
            if selectedPlayer then
                local playerName, playerId = string.match(selectedPlayer, "(.-)%s*|%s*(%d+)")
               
                local target = player.GetByUniqueID(playerId)
       
                
                net.Start("startCrowSequence")
                net.WriteEntity(target)
                net.SendToServer()

            end
            frame:Close()
        end

        local closeButton = vgui.Create("DButton", frame)
        closeButton:SetText("Fermer")
        closeButton:Dock(BOTTOM)
        closeButton.DoClick = function()
            frame:Close()
        end
    end
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
   
        net.Start("openMailBoxMenu")
        net.Send(activator)

    end
end

net.Receive("openMailBoxMenu", function()
    openSelectMenu(self)
end)

net.Receive("startCrowSequence", function()
    crowSequence(net.ReadEntity())
end)

if CLIENT then

    function ENT:Draw()
        self:DrawModel()
        
     
        local pos = self:GetPos()
        local ang = self:GetAngles()
        ang:RotateAroundAxis(ang:Up(), 90) 

        local text = "Mailbox"
        local font = "DermaLarge"
        local textWidth, textHeight = surface.GetTextSize(text)
        local bgPadding = 10 

        cam.Start3D2D(pos + Vector(0, 0, 80), Angle(0, LocalPlayer():EyeAngles().y - ang.y, 90), 0.2)
      
            draw.RoundedBox(8, -textWidth / 2 - bgPadding, -textHeight / 2 - bgPadding, textWidth + 2 * bgPadding, textHeight + 2 * bgPadding, Color(0, 0, 0, 200))

           
            draw.SimpleText(text, font, 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()


    end

  
end

