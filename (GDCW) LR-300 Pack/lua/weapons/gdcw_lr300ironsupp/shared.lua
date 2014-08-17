// Variables that are used on both client and server
SWEP.Category				= "Haven's Sweps"
SWEP.Author				= "Haven"
SWEP.Contact				= "Haven"
SWEP.Purpose				= "Medium Ranged Combat"
SWEP.Instructions			= " "
SWEP.MuzzleAttachment			= "1" 	-- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellEjectAttachment		= "2" 	-- Should be "2" for CSS models or "1" for hl2 models
SWEP.DrawCrosshair			= false

SWEP.ViewModelFOV			= 78
SWEP.ViewModelFlip			= true
SWEP.ViewModel				= "models/weapons/v_rif_l30s.mdl"
SWEP.WorldModel				= "models/weapons/w_rif_l30s_silencer.mdl"
SWEP.Base 				= "gdcw2_base_assault"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.Primary.Sound			= Sound("weapons/lr300/m4a1-1.wav")
SWEP.Primary.Round			= ("gdcwa_5.56x45_Nato2")
SWEP.Primary.RPM			= 825					// This is in Rounds Per Minute
SWEP.Primary.ClipSize			= 30						// Size of a clip
SWEP.Primary.DefaultClip		= 120
SWEP.Primary.ConeSpray			= 2.5					// Hip fire accuracy
SWEP.Primary.ConeIncrement		= 0.5					// Rate of innacuracy
SWEP.Primary.ConeMax			= 12.0					// Maximum Innacuracy
SWEP.Primary.ConeDecrement		= 1.6					// Rate of accuracy
SWEP.Primary.KickUp			= 0.7			// Maximum up recoil (rise)
SWEP.Primary.KickDown			= 0.1					// Maximum down recoil (skeet)
SWEP.Primary.KickHorizontal		= 0.3				// Maximum up recoil (stock)
SWEP.Primary.Automatic			= true						// Automatic/Semi Auto
SWEP.Primary.Ammo			= "ar2"

SWEP.Secondary.ClipSize			= 1						// Size of a clip
SWEP.Secondary.DefaultClip		= 1						// Default number of bullets in a clip
SWEP.Secondary.Automatic		= false						// Automatic/Semi Auto
SWEP.Secondary.Ammo			= ""
SWEP.Secondary.IronFOV			= 70						// How much you 'zoom' in. Less is more! 	

SWEP.data 				= {}						// The starting firemode
SWEP.data.ironsights			= 1

SWEP.IronSightsPos = Vector(2.72, -2.441, 1.654)
SWEP.IronSightsAng = Vector(-3.031, -0.101, 0)
SWEP.SightsPos = Vector(2.72, -2.441, 1.654)
SWEP.SightsAng = Vector(-3.031, -0.101, 0)
SWEP.RunSightsPos = Vector(-2.641, -1, -0.394)
SWEP.RunSightsAng = Vector(-25.4, -52, 26.18)
SWEP.Offset = {
Pos = {
Up = -0.6,
Right = 1.0,
Forward = -2.5,
},
Ang = {
Up = 0,
Right = 6.5,
Forward = 0,
}
}

function SWEP:DrawWorldModel( )
local hand, offset, rotate

if not IsValid( self.Owner ) then
self:DrawModel( )
return
end

if not self.Hand then
self.Hand = self.Owner:LookupAttachment( "anim_attachment_rh" )
end

hand = self.Owner:GetAttachment( self.Hand )

if not hand then
self:DrawModel( )
return
end

offset = hand.Ang:Right( ) * self.Offset.Pos.Right + hand.Ang:Forward( ) * self.Offset.Pos.Forward + hand.Ang:Up( ) * self.Offset.Pos.Up

hand.Ang:RotateAroundAxis( hand.Ang:Right( ), self.Offset.Ang.Right )
hand.Ang:RotateAroundAxis( hand.Ang:Forward( ), self.Offset.Ang.Forward )
hand.Ang:RotateAroundAxis( hand.Ang:Up( ), self.Offset.Ang.Up )

self:SetRenderOrigin( hand.Pos + offset )
self:SetRenderAngles( hand.Ang )

self:DrawModel( )
end

function SWEP:Deploy()

if game.SinglePlayer() then self.Single=true
else
self.Single=false
end
	self:SetWeaponHoldType("ar2")                          	// Hold type styles; ar2 pistol shotgun rpg normal melee grenade smg slam fist melee2 passive knife
	self:SetIronsights(false, self.Owner)					// Set the ironsight false
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW_SILENCED )
	if !self.Owner:IsNPC() then self.ResetSights = CurTime() + self.Owner:GetViewModel():SequenceDuration() end
	return true
	end


function SWEP:PrimaryAttack()
	if self:CanPrimaryAttack() then
		self:FireRocket()
		self.Weapon:EmitSound(self.Primary.Sound)
		self.Weapon:TakePrimaryAmmo(1)
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK_SILENCED )
		local fx 		= EffectData()
		fx:SetEntity(self.Weapon)
		fx:SetOrigin(self.Owner:GetShootPos())
		fx:SetNormal(self.Owner:GetAimVector())
		fx:SetAttachment(self.MuzzleAttachment)
		util.Effect("gdcw_muzzle_sup",fx)
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		self.Owner:MuzzleFlash()
		self.Weapon:SetNextPrimaryFire(CurTime()+1/(self.Primary.RPM/60))

	end
end

function SWEP:Reload()

	self.Weapon:DefaultReload(ACT_VM_RELOAD_SILENCED) 
	if !self.Owner:IsNPC() then
	self.ResetSights = CurTime() + self.Owner:GetViewModel():SequenceDuration() end


	if ( self.Weapon:Clip1() < self.Primary.ClipSize ) and !self.Owner:IsNPC() then
	-- When the current clip < full clip and the rest of your ammo > 0, then

		self.Owner:SetFOV( 0, 0.3 )
		-- Zoom = 0

		self:SetIronsights(false)
		-- Set the ironsight to false

end
	
end

function SWEP:IronSight()

	if !self.Owner:IsNPC() then
	if self.ResetSights and CurTime() >= self.ResetSights then
	self.ResetSights = nil
	self:SendWeaponAnim(ACT_VM_IDLE_SILENCED)
	end end

	if self.Owner:KeyDown(IN_USE) and self:CanPrimaryAttack() || self.Owner:KeyDown(IN_SPEED) then		// If you hold E and you can shoot then
	self.Weapon:SetNextPrimaryFire(CurTime()+0.3)				// Make it so you can't shoot for another quarter second
	self:SetWeaponHoldType("passive")                          			// Hold type styles; ar2 pistol shotgun rpg normal melee grenade smg
	self.IronSightsPos = self.RunSightsPos					// Hold it down
	self.IronSightsAng = self.RunSightsAng					// Hold it down
	self:SetIronsights(true, self.Owner)					// Set the ironsight true
	self.Owner:SetFOV( 0, 0.3 )
	end								

	if self.Owner:KeyReleased(IN_USE) || self.Owner:KeyReleased (IN_SPEED) then	// If you release E then
	self:SetWeaponHoldType("ar2")                          				// Hold type styles; ar2 pistol shotgun rpg normal melee grenade smg slam fist melee2 passive knife
	self:SetIronsights(false, self.Owner)					// Set the ironsight true
	self.Owner:SetFOV( 0, 0.3 )
	end								// Shoulder the gun

	if self.Owner:KeyPressed(IN_WALK) then		// If you are holding ALT (walking slow) then
	self:SetWeaponHoldType("shotgun")                      	// Hold type styles; ar2 pistol shotgun rpg normal melee grenade smg slam fist melee2 passive knife
	end					// Hold it at the hip (NO RUSSIAN WOOOT!)

	if !self.Owner:KeyDown(IN_USE) and !self.Owner:KeyDown(IN_SPEED) then
	-- If the key E (Use Key) is not pressed, then

		if self.Owner:KeyPressed(IN_ATTACK2) then
				if !self.Owner:KeyDown(IN_DUCK) and !self.Owner:KeyDown(IN_WALK) then
				self:SetWeaponHoldType("rpg") else self:SetWeaponHoldType("ar2")  
				end  
			self.Owner:SetFOV( self.Secondary.IronFOV, 0.3 )
			self.IronSightsPos = self.SightsPos					// Bring it up
			self.IronSightsAng = self.SightsAng					// Bring it up
			self:SetIronsights(true, self.Owner)
			-- Set the ironsight true

			if CLIENT then return end
 		end
	end

	if self.Owner:KeyReleased(IN_ATTACK2) and !self.Owner:KeyDown(IN_USE) and !self.Owner:KeyDown(IN_SPEED) then
	-- If the right click is released, then
		self:SetWeaponHoldType("ar2")                      // Hold type styles; ar2 pistol shotgun rpg normal melee grenade smg slam fist melee2 passive knife

		self.Owner:SetFOV( 0, 0.3 )

		self:SetIronsights(false, self.Owner)
		-- Set the ironsight false

		if CLIENT then return end
	end

		if self.Owner:KeyDown(IN_ATTACK2) and !self.Owner:KeyDown(IN_USE) and !self.Owner:KeyDown(IN_SPEED) then
		self.SwayScale 	= 0.05
		self.BobScale 	= 0.05
		else
		self.SwayScale 	= 1.0
		self.BobScale 	= 1.0
		end
end

function SWEP:Think()

self:IronSight()

	if !self.Owner:IsNPC() then
	if self.Idle and CurTime() >= self.Idle then
	self.Idle = nil
	self:SendWeaponAnim(ACT_VM_IDLE_SILENCED)
	end end

	if	(self.Primary.Cone>0.09)	then
	self.Primary.Cone = self.Primary.Cone - self.Primary.ConeDecrement	end

if (self.Owner:WaterLevel() > 2) then
		self.Weapon:SetNextPrimaryFire(CurTime() + 1)
//		self.Weapon:EmitSound("Default.ClipEmpty_Pistol")
		return false
	end

end
