resource.AddFile( "models/weapons/v_pfinger.mdl" )
resource.AddFile( "models/weapons/v_pfinger.vvd" )
resource.AddFile( "models/weapons/v_pfinger.dx80.vtx" )
resource.AddFile( "models/weapons/v_pfinger.dx90.vtx" )
resource.AddFile( "models/weapons/v_pfinger.sw.vtx" )

resource.AddFile( "models/weapons/w_pfinger.mdl" )
resource.AddFile( "models/weapons/w_pfinger.vvd" )
resource.AddFile( "models/weapons/w_pfinger.dx80.vtx" )
resource.AddFile( "models/weapons/w_pfinger.dx90.vtx" )
resource.AddFile( "models/weapons/w_pfinger.sw.vtx" )

SWEP.PrintName			= "HaaX Gun 2.0"			
SWEP.Author				= "Joeii82"
SWEP.Instructions		= "Left mouse (Primary) to fire a Computer! Right mouse (Secondary) to Rapid-fire a Computer!"

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot				= 1
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true

SWEP.ViewModel			= "models/weapons/v_pfinger.mdl"
SWEP.WorldModel			= "models/weapons/w_pfinger.mdl"
SWEP.ViewModelFOV 		= 95

local ShootSound = Sound( "vo/npc/male01/hacks01.wav" )
local ShootSound02 = Sound( "vo/npc/male01/hacks02.wav" )

--
-- Called when the left mouse button is pressed
--
function SWEP:PrimaryAttack()

	-- This weapon is 'automatic'. This function call below defines
	-- the rate of fire. Here we set it to shoot every 0.5 seconds.
	self.Weapon:SetNextPrimaryFire( CurTime() + 2.5 )	

	-- Call 'ThrowChair' on self with this model
	local ent = self:ThrowMonitor( "models/props_lab/monitor02.mdl" )

end
 

--
-- Called when the rightmouse button is pressed
--
function SWEP:SecondaryAttack()

	-- Note we don't call SetNextSecondaryFire here because it's not
	-- automatic and so we let them fire as fast as they can click.	

	-- Call 'ThrowChair' on self with this model
	local ent = self:ThrowChair( "models/props_lab/monitor02.mdl" )

end

--
-- A custom function we added. When you call this the player will fire a chair!
--
function SWEP:ThrowChair( model_file )

	-- 
	-- Play the shoot sound we precached earlier!
	--
	
	local Num = math.random(1,2)
	
	if Num == 1 then
		self:EmitSound( ShootSound )
	elseif Num == 2 then
		self:EmitSound( ShootSound02 )
	
	end
 
	--
	-- If we're the client ) then this is as much as we want to do.
	-- We play the sound above on the client due to prediction.
	-- ( if ( we didn't they would feel a ping delay during multiplayer )
	--
	if ( CLIENT ) then return end

	--
	-- Create a prop_physics entity
	--
	local ent = ents.Create( "prop_physics" )

	--
	-- Always make sure that created entities are actually created!
	--
	if (  !IsValid( ent ) ) then return end

	--
	-- Set the entity's model to the passed in model
	--
	ent:SetModel( model_file )
 
	--
	-- Set the position to the player's eye position plus 16 units forward.
	-- Set the angles to the player'e eye angles. Then spawn it.
	--
	ent:SetPos( self.Owner:EyePos() + ( self.Owner:GetAimVector() * 16 ) )
	ent:SetAngles( self.Owner:EyeAngles() )
	ent:Spawn()

	--
	-- Now get the physics object. Whenever we get a physics object
	-- we need to test to make sure its valid before using it.
	-- If it isn't ) then we'll remove the entity.
	--
	local phys = ent:GetPhysicsObject()
	if (  !IsValid( phys ) ) then ent:Remove() return end
 
	--
	-- Now we apply the force - so the chair actually throws instead 
	-- of just falling to the ground. You can play with this value here
	-- to adjust how fast we throw it.
	--
	local velocity = self.Owner:GetAimVector()
	velocity = velocity * 3000
	velocity = velocity + ( VectorRand() * 2 ) -- a random element
	velocity = velocity * phys:GetMass()
	phys:ApplyForceCenter( velocity )
 
	--
	-- Assuming we're playing in Sandbox mode we want to add this
	-- entity to the cleanup and undo lists. This is done like so.
	--
	cleanup.Add( self.Owner, "props", ent )
 
	undo.Create( "Monitor" )
		undo.AddEntity( ent )
		undo.SetPlayer( self.Owner )
	undo.Finish()
	
	timer.Simple(2.5, function() ent:Remove() end)	
	return ent
	
end

	function SWEP:ThrowMonitor( model_file )

	-- 
	-- Play the shoot sound we precached earlier!
	--
	
	local Num = math.random(1,2)
	
	if Num == 1 then
		self:EmitSound( ShootSound )
	elseif Num == 2 then
		self:EmitSound( ShootSound02 )
	
	end
 
	--
	-- If we're the client ) then this is as much as we want to do.
	-- We play the sound above on the client due to prediction.
	-- ( if ( we didn't they would feel a ping delay during multiplayer )
	--
	if ( CLIENT ) then return end

	--
	-- Create a prop_physics entity
	--
	local ent = ents.Create( "prop_physics" )

	--
	-- Always make sure that created entities are actually created!
	--
	if (  !IsValid( ent ) ) then return end

	--
	-- Set the entity's model to the passed in model
	--
	ent:SetModel( model_file )
 
	--
	-- Set the position to the player's eye position plus 16 units forward.
	-- Set the angles to the player'e eye angles. Then spawn it.
	--
	ent:SetPos( self.Owner:EyePos() + ( self.Owner:GetAimVector() * 16 ) )
	ent:SetAngles( self.Owner:EyeAngles() )
	ent:Spawn()

	--
	-- Now get the physics object. Whenever we get a physics object
	-- we need to test to make sure its valid before using it.
	-- If it isn't ) then we'll remove the entity.
	--
	local phys = ent:GetPhysicsObject()
	if (  !IsValid( phys ) ) then ent:Remove() return end
 
	--
	-- Now we apply the force - so the chair actually throws instead 
	-- of just falling to the ground. You can play with this value here
	-- to adjust how fast we throw it.
	--
	local velocity = self.Owner:GetAimVector()
	velocity = velocity * 3000
	velocity = velocity + ( VectorRand() * 2 ) -- a random element
	velocity = velocity * phys:GetMass()
	phys:ApplyForceCenter( velocity )
 
	--
	-- Assuming we're playing in Sandbox mode we want to add this
	-- entity to the cleanup and undo lists. This is done like so.
	--
	cleanup.Add( self.Owner, "props", ent )
 
	undo.Create( "Monitor" )
		undo.AddEntity( ent )
		undo.SetPlayer( self.Owner )
	undo.Finish()
	
	timer.Simple(10.0, function() ent:Remove() end)	
	return ent
	
end