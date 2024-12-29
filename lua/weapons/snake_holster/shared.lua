
AddCSLuaFile()

SWEP.PrintName = "Etui du Serpent | Invocation"
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

SWEP.SnakeEntity = nil

function SWEP:Deploy()
	self.Owner:SetModel("models/falko_naruto_foc/body_upper/man_coat_12.mdl")
end


function SWEP:Initialize()
    self:SetHoldType( "normal" )

end

function SWEP:PrimaryAttack()
end

function invokeHolsterSnake(ply,self)

	if not ply:GetNWBool("snakeHolstered") then
	
		local entity = ents.Create("ent_snake_holster")

		entity:SetPos(ply:GetPos()+Vector(100,0,0)) 
		entity:Spawn()

		self.SnakeEntity = entity
		ply:SetNWBool("snakeHolstered", true)
	else
		
		local modelWeapon = ents.Create("prop_physics")
		modelWeapon:SetModel(ply:GetNWString("snakeHolstered_model"))

		modelWeapon:SetAngles(Angle(90,0,0))
		modelWeapon:SetModelScale(1)
		modelWeapon:Spawn()
		modelWeapon:SetMoveType(MOVETYPE_NOCLIP)
		modelWeapon:SetNoDraw(true)
	

		local entity = ents.Create("ent_snake_holster")

		entity.holstered = true
		entity.WeaponModel = modelWeapon
		entity.WeaponClass = ply:GetNWString("snakeHolstered_class")
		

		entity:SetPos(ply:GetPos()+Vector(100,0,0)) 
		entity:Spawn()
		modelWeapon:SetPos(entity:GetPos()+Vector(-40,30,-30))
		self.SnakeEntity = entity
		ply:SetNWBool("snakeHolstered", false)

	
	end


	
end

function SWEP:Reload()

	local ply = self:GetOwner() 
	
    if not IsValid(ply) or not ply:IsPlayer() or not ply:IsOnGround() then return end

    if CurTime() < (self.NextSpecialMove or 0) then return end
    self.NextSpecialMove = CurTime() + 1

	self:SetHoldType("anim_invoke")
    ply:SetAnimation(PLAYER_RELOAD)
	timer.Simple(1, function()
		self:SetHoldType("anim_invoke")
		ply:SetAnimation(PLAYER_ATTACK1)
	end)

	if SERVER then
		util.AddNetworkString("DisplayDamage")
		timer.Simple(1.5, function()
			ply:SetNWBool("freezePlayer", true)
			ply:EmitSound("ambient/explosions/explode_9.wav")

			ParticleEffect("nrp_tool_invocation", ply:GetPos(), Angle(0,0,0), nil)

			local modelEntity = ents.Create("prop_physics")
			if IsValid(modelEntity) then
				modelEntity:SetModel("models/foc_props_jutsu/jutsu_sceau_piege/foc_jutsu_sceau_piege.mdl")
				
				modelEntity:SetPos(ply:GetPos() + Vector(0, 0, 0)) 
				modelEntity:SetAngles(Angle(0, 0, 0))
				modelEntity:SetColor(Color(0,0,0,255))
				modelEntity:SetModelScale(4)
				modelEntity:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE) 
				modelEntity:SetRenderMode(RENDERMODE_TRANSCOLOR)
				modelEntity:SetKeyValue("solid", "0")
					
				modelEntity:Spawn()

				local physObj = modelEntity:GetPhysicsObject()
				if IsValid(physObj) then
					physObj:EnableMotion(false)
				end

			

                timer.Simple(0.5, function()
					invokeHolsterSnake(ply,self)
                    timer.Simple(0.7, function() 
                        if IsValid(ply) then
                            ply:StopParticles()
                			ply:SetNWBool("freezePlayer", false)
                        end

                        if IsValid(modelEntity) then
                            modelEntity:Remove()
                        end
                    end)
                end)


			end





		end)
	end


end

