
AddCSLuaFile()

SWEP.PrintName = "Espionnage du Crapeau | Invocation"
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

function SWEP:Deploy()
	self.Owner:SetModel("models/falko_naruto_foc/body_upper/man_anbublackops_ame_hood_01.mdl")
end


function SWEP:Initialize()

    self:SetHoldType( "none" )

end


function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end



local function controlToad(ply)

    local modelEntity = ents.Create("prop_dynamic")

    if not IsValid(modelEntity) then return end

    modelEntity:SetModel("models/warwax/gamabunta.mdl")

    local spawnOffset = Vector(200, 0, 0)
    local playerAngles = ply:EyeAngles()
    spawnOffset = playerAngles:Right() * -100
    local spawnPos = ply:GetPos() + spawnOffset

    modelEntity:SetPos(spawnPos)
    modelEntity:SetAngles(Angle(0, playerAngles.yaw, 0))
    modelEntity:SetModelScale(2)
    modelEntity:Spawn()

    local animID = modelEntity:LookupSequence("idle")
    if animID < 0 then return end

    modelEntity:SetSequence(animID)
    modelEntity:SetCycle(0)
    modelEntity:SetPlaybackRate(2)


    timer.Simple(5, function()
        ParticleEffect("nrp_tool_invocation", modelEntity:GetPos(), modelEntity:GetAngles(), modelEntity)
        ply:EmitSound("ambient/explosions/explode_9.wav")
        timer.Simple(1, function()
            if IsValid(modelEntity) then
                modelEntity:Remove()
            end
        end)
    end)
end

function SWEP:Reload()
    local player = self:GetOwner()
    if not IsValid(player) then return end

    if CurTime() < self.NextSpecialMove then return end
    self.NextSpecialMove = CurTime() + 10

    if not self.hasSetView then

        self.targetPos = player:GetPos()
        self.targetAngles = player:EyeAngles()

        self.hasSetView = true

       
    else
        self.originalPos = player:GetPos()
        self.originalAngles = player:EyeAngles()
        if not IsValid(player) then return end

        player:SetPos(self.targetPos)
        player:SetEyeAngles(self.targetAngles)

        timer.Simple(3, function()
            if IsValid(player) then
           
                player:SetEyeAngles(self.originalAngles)
                player:SetPos(self.originalPos)

                self.hasSetView = false
            end
        end)
    end
end