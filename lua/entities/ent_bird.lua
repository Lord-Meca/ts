AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.PrintName = "L'oiseau Ninja"
ENT.Author = "Lord_Meca"
ENT.Information = "Invocation"
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

    entity = ent

    return ent
end


function ENT:Initialize()

    if CLIENT then return end

    self:SetModel("models/fsc/billy/aigleninja7.mdl")
    self:SetSolid(SOLID_BBOX)
    self:SetModelScale(0.8)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetUseType(SIMPLE_USE)
    self:SetHealth(100)
    self:DropToFloor()

    local sequenceId = self:LookupSequence("sumnj02_fly_start")
    if sequenceId >= 0 then
        self:SetSequence(sequenceId)
        self:SetPlaybackRate(0.2)
        self:SetCycle(0)
    end
end

function ENT:Think()

    if self:GetSequence() == 1 then return end

    local currentCycle = self:GetCycle()
    local playbackRate = self:GetPlaybackRate()

    local newCycle = currentCycle + FrameTime() * playbackRate
    if newCycle >= 1 then
        newCycle = 0
    end

    self:SetCycle(newCycle)
    self:NextThink(CurTime())

    return true
end

function ENT:Use(activator, caller)
    util.AddNetworkString("OpenMenu")

    if activator:IsPlayer() then


        net.Start("OpenMenu")
        net.WriteEntity(self)
        net.Send(activator)
    end
end


net.Receive("OpenMenu", function()
    
    local ent = net.ReadEntity()

    local frame = vgui.Create("DFrame")
    frame:SetTitle("Menu Bird")
    frame:SetSize(300, 200)
    frame:Center()
    frame:MakePopup()

    local list = vgui.Create("DListView", frame)
    list:Dock(FILL)
    list:SetMultiSelect(false)
    list:AddColumn("les actions")

    list:AddLine("ne bouge pas")
    list:AddLine("suis moi")
    list:AddLine("monter")


    list.OnRowSelected = function(_, index, pnl)
        
        if index == 1 then
            ent:SetSequence("sumnj02_fly_start")
            ent:SetCycle(0)
        elseif index == 2 then
            ent:SetSequence("sumnj02_fly_loop")

            
        end

        frame:Close()
    end

  
    local closeButton = vgui.Create("DButton", frame)
    closeButton:SetText("Fermer")
    closeButton:Dock(BOTTOM)
    closeButton.DoClick = function()

        frame:Close()
    end
end)






