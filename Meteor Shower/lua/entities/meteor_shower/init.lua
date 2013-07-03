AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()	
end

function ENT:KeyValue( key, value )
	if ( key == "Meteor" ) then
		self.Meteor = tonumber(value)
	end
	if ( key == "Delay" ) then
		self.Delay = tonumber(value)
	end
	if ( key == "Repeat" ) then
		self.Repeat = tonumber(value)
	end
	if ( key == "Radius" ) then
		self.Radius = tonumber(value)
	end
	if ( key == "Spread" ) then
		self.Spread = tonumber(value)
	end
	if ( key == "Force" ) then
		self.MtForce = tonumber(value)
	end
	if ( key == "Damage" ) then
		self.MtDamage = tonumber(value)
	end
	if ( key == "Magnitude" ) then
		self.MtMagnitude = tonumber(value)
	end
end

function ENT:AcceptInput( name, activator, caller )
	if name == "Enable" then
		self.TmpRepeat = -1
		self.TmpDelay = 0
	end
	if name == "Disable" then
		self.TmpRepeat = 0
		self.TmpDelay = 0
	end
	if name == "Trigger" then
		self.TmpRepeat = self.Repeat
		self.TmpDelay = 0
	end
end

function ENT:Think()
	if self.TmpRepeat != 0 then
		if self.TmpDelay < CurTime() then
			for i=1, self.Meteor do
				local Ang = math.random(0, 360)
				local Dist = math.random(0, self.Radius)
				local Offset = self.Entity:GetUp()*math.sin(Ang)*Dist
					+ self.Entity:GetRight()*math.cos(Ang)*Dist
				local Pos = self.Entity:GetPos() + Offset
				local Dir = self.Entity:GetForward()
					+ self.Entity:GetUp()*math.Rand(self.Spread,self.Spread*-1)
					+ self.Entity:GetRight()*math.Rand(self.Spread,self.Spread*-1)
				local Angles = Dir:Angle()
				local Met=ents.Create("meteor")
				Met:SetPos(Pos)
				Met:SetAngles(Angles)
				Met:SetKeyValue("Force",self.MtForce)
				Met:SetKeyValue("Damage",self.MtDamage)
				Met:SetKeyValue("Magnitude",self.MtMagnitude)
				Met:Spawn()
				Met:Activate()
			end
			self.TmpDelay = CurTime() + self.Delay
			if self.TmpRepeat > 0 then self.TmpRepeat = self.TmpRepeat - 1 end
		end
	end
end