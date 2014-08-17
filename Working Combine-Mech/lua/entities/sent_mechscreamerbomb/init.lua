
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.ActivateDel = CurTime()
ENT.MissileTime = CurTime() + 5	
ENT.DestPos = NULL
ENT.Activated = false
ENT.ScreamSound = NULL
ENT.SoundDel = CurTime()
ENT.TimeAdd = 5
ENT.ActiveTime = CurTime()
ENT.StartTime = CurTime()
ENT.ActiveEffect = NULL
ENT.TeslaEff = NULL
ENT.TeslaDel = CurTime()

function ENT:SpawnFunction( ply, tr )
--------Spawning the entity and getting some sounds i use.   
 	if ( !tr.Hit ) then return end 
 	 
 	local SpawnPos = tr.HitPos + tr.HitNormal * 10 
 	 
 	local ent = ents.Create( "sent_MechScreamerBomb" )
	ent:SetPos( SpawnPos ) 
 	ent:Spawn()
 	ent:Activate() 
 	ent.Owner = ply
	
	self.DestPos = self.Entity.FollowPos	
	self.ActivateDel = self.Entity.ActivateDel
	return ent 
 	 
end

function ENT:Initialize()

	self.Entity:SetModel("models/props_junk/PopCan01a.mdl")
	self.Entity:SetColor(255, 255, 255, 0)
	self.Entity:SetOwner(self.Owner)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)

    local phys = self.Entity:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	phys:EnableGravity(false)
	phys:EnableDrag( false )	
		
	self.Trail = util.SpriteTrail(self.Entity, 0, Color(255,0,0,255), false, 4, 0, 3, 1/(15+1)*0.5, "trails/laser.vmt")
	self.MissileTime = CurTime() + 5
	
	self.DestPos = self.Entity.FollowPos
	self.ActivateDel = self.Entity.ActivateDel	
	
	local redSprite = ents.Create("env_sprite");
	redSprite:SetPos( self.Entity:GetPos() );
	redSprite:SetKeyValue( "renderfx", "14" )	
	redSprite:SetKeyValue( "model", "sprites/glow1.vmt")
	redSprite:SetKeyValue( "scale","1")
	redSprite:SetKeyValue( "spawnflags","1")
	redSprite:SetKeyValue( "angles","0 0 0")
	redSprite:SetKeyValue( "rendermode","9")
	redSprite:SetKeyValue( "renderamt","255")
	redSprite:SetKeyValue( "rendercolor", "255 0 0" )				
	redSprite:Spawn()	
	redSprite:SetParent( self.Entity )	
	
	self.ScreamSound = CreateSound(self.Entity,"combine mech/ScreamIdle.wav")
	self.ScreamSound:Play()
	self.SoundDel = CurTime() + 2
	
	
	self.TeslaEff = ents.Create( "point_tesla" )
	self.TeslaEff:SetKeyValue( "targetname", "teslapoint" )
	self.TeslaEff:SetKeyValue( "texture" ,"sprites/flare1.vmt" )
	self.TeslaEff:SetKeyValue( "m_Color" ,"255 50 50" )
	self.TeslaEff:SetKeyValue( "m_flRadius" ,"80" )
	self.TeslaEff:SetKeyValue( "beamcount_min" ,"5" )
	self.TeslaEff:SetKeyValue( "beamcount_max", "8" )
	self.TeslaEff:SetKeyValue( "thick_min", "2" )
	self.TeslaEff:SetKeyValue( "thick_max", "3" )
	self.TeslaEff:SetKeyValue( "lifetime_min" ,"0.05" )
	self.TeslaEff:SetKeyValue( "lifetime_max", "0.1" )
	self.TeslaEff:SetKeyValue( "interval_min", "0.1" )
	self.TeslaEff:SetKeyValue( "interval_max" ,"0.25" )
	self.TeslaEff:SetPos( self.Entity:GetPos() )
	self.TeslaEff:Spawn()
	self.TeslaEff:SetParent( self.Entity )
	self.TeslaEff:Fire( "DoSpark","",0 )	
end

-------------------------------------------PHYS COLLIDE
function ENT:PhysicsCollide( data, phys ) 
	ent = data.HitEntity

	if self.Activated == false && self.ActivateDel < CurTime() then
		self.Activated = true
		self.ActiveTime = CurTime() + self.TimeAdd
		self.StartTime = CurTime()

		self.ActiveEffect = ents.Create("env_rotorwash_emitter")
		self.ActiveEffect:SetPos(self.Entity:GetPos())
		self.ActiveEffect:SetParent(self.Entity)
		self.ActiveEffect:Activate()	

		local effectdata = EffectData()
		effectdata:SetEntity(self.Entity)
		util.Effect("mech_ScreamerEff",effectdata)
		
		
		self.TeslaEff:SetKeyValue( "m_flRadius" ,"300" )
		self.Entity:EmitSound("combine mech/ScreamerCountDown.wav")			
	end
	
end

-------------------------------------------PHYS UPDATE
function ENT:PhysicsUpdate( physics )

	--Sparks, yay!
	if self.TeslaDel < CurTime() then
		self.TeslaDel = CurTime() + 0.1
		self.TeslaEff:Fire( "DoSpark","",0 )	
	end
	
	
	if self.target != NULL then
		self.DestPos = self.target:GetPos()
	end

	if self.ActivateDel < CurTime() then
		local pos = self.Entity:GetPos()
		local dir = (self.DestPos - pos):GetNormalized()
	
		self.Entity:GetPhysicsObject():ApplyForceCenter(dir * 50)
	end

	if self.SoundDel < CurTime() then
		self.SoundDel = CurTime() + 4
		self.ScreamSound:Stop()
		self.ScreamSound:Play()
	end
	
	local pitch = self.Entity:GetVelocity():Length()
	pitch = pitch / 10
	local pitch = math.Clamp( pitch, 50, 200 )
	
	self.ScreamSound:ChangePitch(pitch,0)
	

	local dist = self.DestPos:Distance(self.Entity:GetPos())
	
	if dist < 100 && self.Activated == false then
		self.Activated = true
		self.ActiveTime = CurTime() + self.TimeAdd
		self.StartTime = CurTime()	
		
		self.ActiveEffect = ents.Create("env_rotorwash_emitter")
		self.ActiveEffect:SetPos(self.Entity:GetPos())
		self.ActiveEffect:SetParent(self.Entity)
		self.ActiveEffect:Activate()		

		local effectdata = EffectData()
		effectdata:SetEntity(self.Entity)
		util.Effect("mech_ScreamerEff",effectdata)	
		self.TeslaEff:SetKeyValue( "m_flRadius" ,"300" )		
		self.Entity:EmitSound("combine mech/ScreamerCountDown.wav")			
	end	
		
	if self.Activated == true && self.ActiveTime > CurTime() then
	
		local percent = (CurTime() - self.StartTime) / self.TimeAdd
	
	self.Entity:GetPhysicsObject():SetVelocity(self.Entity:GetPhysicsObject():GetVelocity() * 0.1)
	
		local maxDist = 300
		for k, v in pairs(ents.FindInSphere( self.Entity:GetPos(), maxDist )) do

			local phys = v:GetPhysicsObject()
			local useEff = false
			
			if phys && phys:IsValid() then
				local dir = (self.Entity:GetPos() - v:GetPos()):GetNormalized()
				local dist = self.Entity:GetPos():Distance(v:GetPos())
				local force = dist / maxDist
				phys:ApplyForceCenter(dir * force * percent * phys:GetMass() * 100 )
				useEff = true
			end
			
			if v:IsPlayer() then
				local dir = (self.Entity:GetPos() - v:GetPos()):GetNormalized()
				local dist = self.Entity:GetPos():Distance(v:GetPos())
				local force = dist / maxDist
				v:SetVelocity(dir * force * percent * 200 )	
				useEff = true				
			elseif v:IsNPC() then
				local hp = v:Health() - 1
				v:Fire("sethealth", ""..hp.."", 0)	
				useEff = true				
			end
			
			
			if useEff == true then
				local effectdata = EffectData()
				effectdata:SetEntity( v )
				effectdata:SetStart( self.Entity:GetPos() )
				effectdata:SetOrigin( v:GetPos() )
				effectdata:SetAngles( v:GetAngles() )
				effectdata:SetScale( 15 )
				effectdata:SetMagnitude( 15 )
				util.Effect( "TeslaHitBoxes", effectdata )			
			end
			
			
		end
	
	elseif self.Activated == true && self.ActiveTime < CurTime() then
		self.Entity:Remove()
	end
	
	
end
-------------------------------------------THINK
function ENT:Think()

	self.Entity:GetPhysicsObject():Wake()
	
end
-------------------------------------------REMOVE
function ENT:OnRemove()
	self.ScreamSound:Stop()
	self.ActiveEffect:Remove()
	self.TeslaEff:Remove()
	
	self.ExplodeOnce = 1
	local expl = ents.Create("env_explosion")
	expl:SetKeyValue("spawnflags",128)
	expl:SetPos(self.Entity:GetPos())
	expl:Spawn()
	expl:Fire("explode","",0)

	util.BlastDamage( self.Entity, self.Entity, self.Entity:GetPos(), 300, 200)	
end

function ENT:Activate()
	
end

