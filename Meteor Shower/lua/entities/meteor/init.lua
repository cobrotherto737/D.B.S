AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self.Entity:SetModel( "models/props_phx/mk-82.mdl" )
	self.Entity:SetName("Meteor")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
	Trail = ents.Create("env_fire_trail")
	Trail:SetAngles( self.Entity:GetAngles() )
	Trail:SetPos( self.Entity:GetPos() )
	Trail:SetParent( self.Entity )
	Trail:Spawn()
	Trail:Activate()
	self.Phys = self.Entity:GetPhysicsObject()
end

function ENT:KeyValue( key, value )
	if ( key == "Force" ) then
		self.Force = value
	end
	if ( key == "Damage" ) then
		self.Damage = value
	end
	if ( key == "Magnitude" ) then
		self.Magnitude = value
	end
end

function ENT:PhysicsUpdate()
	if self.Once then
		self.Entity:Remove()
	else
		self.Phys:SetVelocity( self.Entity:GetForward() * self.Force )
	end
end

function ENT:Think()
end

function ENT:Boom()
	if not self.Once then
		local Pos = self.Entity:GetPos()
		local Scale = self.Magnitude / 100.0
		local effectdata = EffectData()
		effectdata:SetStart( Pos )
		effectdata:SetOrigin( Pos )
		effectdata:SetScale( Scale )
		util.Effect( "meteor_explosion", effectdata ) 
		util.BlastDamage( self.Entity, self.Entity, self.Entity:GetPos(), self.Magnitude, self.Damage )
		self.Entity:EmitSound("ambient/explosions/explode_4.wav", 90*Scale, 100)
	end
	self.Once = true
end

function ENT:PhysicsCollide( data, phys )
	self.Entity:Boom()
end