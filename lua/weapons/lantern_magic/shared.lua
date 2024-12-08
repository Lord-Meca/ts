
AddCSLuaFile()

SWEP.PrintName = "Lanterne Magique du Corps | Projection"
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

SWEP.selectedNames = {}



function SWEP:Deploy()
	self.Owner:SetModel("models/falko_naruto_foc/body_upper/ame_ninja_npc.mdl")
end


function SWEP:Initialize()

    self:SetHoldType( "none" )
    self.selectedClones = {}
end


function SWEP:PrimaryAttack()

end

function createClone(ply, self)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    local clone = ents.Create("prop_dynamic")

    if not IsValid(clone) then return end

    clone:SetModel(ply:GetModel())
    clone:SetPos(ply:GetPos() + ply:GetRight() * 50 + Vector(0, 0, 5)) 
    clone:SetAngles(ply:GetAngles())
    clone:SetKeyValue("solid", "6")
    clone:Spawn()

    clone:SetColor(ply:GetColor())
    clone:SetMaterial(ply:GetMaterial())
    clone:SetSkin(ply:GetSkin())

    for i = 0, ply:GetNumBodyGroups() - 1 do
        clone:SetBodygroup(i, ply:GetBodygroup(i))
    end


    if clone:LookupSequence("kisame_ninjutsu_sharkbomb_charge_loop") >= 0 then
        clone:ResetSequence("kisame_ninjutsu_sharkbomb_charge_loop")
    end

    self.selectedClones[clone] = ply

end

function openSelectMenu(self)
    if SERVER then
        util.AddNetworkString("teleportSelectedPlayers")
        util.AddNetworkString("removeHolographicEffect")
    end

    if CLIENT then
        local frame = vgui.Create("DFrame")
        frame:SetTitle("Technique de la Lanterne Magique")
        frame:SetSize(300, 250)
        frame:Center()
        frame:MakePopup()

        local list = vgui.Create("DListView", frame)
        list:Dock(FILL)
        list:SetMultiSelect(true)
        list:AddColumn("Joueurs :")

        local playersList = {}

        for _, player in pairs(player.GetAll()) do
            if player ~= LocalPlayer() then
                table.insert(playersList, player:Nick())
                list:AddLine(player:Nick())
            end
        end

        local validateButton = vgui.Create("DButton", frame)
        validateButton:SetText("Valider")
        validateButton:Dock(BOTTOM)
        validateButton.DoClick = function()
            self.selectedNames = {}
            local selectedLines = list:GetSelected()

            if selectedLines then
                for _, line in ipairs(selectedLines) do
                    local playerName = line:GetValue(1)
                    table.insert(self.selectedNames, playerName)
                end
            end

            net.Start("teleportSelectedPlayers")
            net.WriteTable(self.selectedNames)
            net.WriteEntity(self)
            net.SendToServer()

            self:SetHoldType("anim_invoke")
            self.Owner:SetAnimation(PLAYER_ATTACK1)

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

function holographicPlayer(ply, selectedNames, owner,self)
    if SERVER then

        if not IsValid(ply) or not IsValid(owner) then return end

        local originalColor = ply:GetColor()
        local originalRenderMode = ply:GetRenderMode()

        ply:SetRenderMode(RENDERMODE_TRANSCOLOR)

        net.Start("removeHolographicEffect")
        net.WriteTable(selectedNames)
        net.WriteInt(originalRenderMode, 8)
        net.Send(ply)

        local interval = 0.005
        local elapsed = 0

        timer.Create("HolographicEffect_" .. ply:EntIndex(), interval, 0, function()
            if not IsValid(ply) or not IsValid(owner) then
                timer.Remove("HolographicEffect_" .. ply:EntIndex())
                return
            end

            elapsed = elapsed + interval

            local hue = (elapsed * 360) % 360
            local color = HSVToColor(hue, 1,0.7)
            color.a = math.random(80, 100) 

            ply:SetColor(color)
       
            -- local distance = (ply:GetPos() - owner:GetPos()):Length()
            -- if distance > 2000 then
                
            --     if ply:GetColor().r == color.r and ply:GetColor().g == color.g and ply:GetColor().b == color.b and ply:GetColor().a == color.a then
         
            --         ply:SetPos(owner:GetPos() + Vector(math.random(20, 150), math.random(10, 150), 0))
            --     end
   
            -- end
        end)
    end
end


function reCallPlayers(self)
    for clone, ply in pairs(self.selectedClones) do
        if IsValid(clone) then

            timer.Simple(0.5, function()

                ply:SetCollisionGroup(COLLISION_GROUP_NONE)
                
                ply:GodDisable()
                ply:SetPos(clone:GetPos())
                ParticleEffect("nrp_tool_invocation", clone:GetPos(), Angle(0,0,0), nil)
                clone:Remove()

                
            end)
            
        end
    end

    self.selectedClones = {}
    timer.Simple(0.5, function()
        if self.selectedNames and #self.selectedNames > 0 then
            net.Start("removeHolographicEffect")
            net.WriteTable(self.selectedNames)
            net.SendToServer()

    
        end
    end)
end

function SWEP:SecondaryAttack()
    reCallPlayers(self)
    self.Owner:SetCollisionGroup(COLLISION_GROUP_NONE)
    self:SetHoldType("anim_invoke")
    self.Owner:SetAnimation(PLAYER_ATTACK1)
end



net.Receive("removeHolographicEffect", function(len, ply)
    local selectedNames = net.ReadTable()
    local originalRenderMode = net.ReadInt(8) 

    for _, playerName in ipairs(selectedNames) do
        for _, player in pairs(player.GetAll()) do
            if IsValid(player) and player:Nick() == playerName then
                
                timer.Remove("HolographicEffect_" .. player:EntIndex())
                player:SetColor(Color(255, 255, 255, 255))


                if originalRenderMode == nil then
                    return 
                end
                
                if IsValid(ply) then
                    ply:SetRenderMode(RENDERMODE_TRANSCOLOR)
                end
            end
        end
    end
end)

net.Receive("teleportSelectedPlayers", function(len, ply)
    local selectedNames = net.ReadTable()
    local self = net.ReadEntity()
    local owner = self.Owner

    for _, playerName in ipairs(selectedNames) do
        for _, player in pairs(player.GetAll()) do
            if player:Nick() == playerName then
                holographicPlayer(player,selectedNames,owner,self)

                if SERVER then
                    createClone(player, self)
                end

                player:GodEnable()

                player:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
                ply:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
                
                player:SetPos(ply:GetPos() + Vector(math.random(20, 150), math.random(10, 150)))
                --player:SetPos(ply:GetPos() + Vector(0,math.random(20, 150),20) + ply:EyeAngles():Forward()*math.random(100,300), 0)
                ParticleEffect("[5]_blackexplosion8", player:GetPos(), Angle(0, 0, 0), nil)
            end
        end
    end
end)


function SWEP:Reload()
	local ply = self.Owner

	--if not ply:IsOnGround() then return end

	if CurTime() < self.NextSpecialMove then return end
	self.NextSpecialMove = CurTime() + 1

    openSelectMenu(self)

end

function SWEP:Think()
    
    for _, ply in ipairs(player.GetAll()) do
        if ply:IsBot() then
            ply:SetModel("models/falko_naruto_foc/body_upper/ichiraku.mdl")
            ply:SetMaxHealth(2000)
            ply:SetHealth(2000)
        end
    end

    self:NextThink(CurTime())
    return true

end
