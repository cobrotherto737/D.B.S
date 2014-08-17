// Variables that are used on both client and server
SWEP.Category				= "Haven's Sweps"
SWEP.Author				= "Haven"
SWEP.Contact				= "Haven"
SWEP.Purpose				= "Close Quarters Combat"
SWEP.Instructions			= " "
SWEP.MuzzleAttachment			= "1" 	-- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellEjectAttachment		= "2" 	-- Should be "2" for CSS models or "1" for hl2 models
SWEP.DrawCrosshair			= false

SWEP.ViewModelFOV			= 68
SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/weapons/v_pist_python.mdl"
SWEP.WorldModel				= "models/weapons/w_pist_python.mdl"
SWEP.Base 				= "gdcw2_base_assault"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.Primary.Sound			= Sound("weapons/python/deagle-1.wav")
SWEP.Primary.Round			= ("gdcwa_9x33mmr2")
SWEP.Primary.RPM			= 300					// This is in Rounds Per Minute
SWEP.Primary.ClipSize			= 6						// Size of a clip
SWEP.Primary.DefaultClip		= 42
SWEP.Primary.ConeSpray			= 1.6					// Hip fire accuracy
SWEP.Primary.ConeIncrement		= 0.8					// Rate of innacuracy
SWEP.Primary.ConeMax			= 6.0					// Maximum Innacuracy
SWEP.Primary.ConeDecrement		= 0.8					// Rate of accuracy
SWEP.Primary.KickUp			= 3.0				// Maximum up recoil (rise)
SWEP.Primary.KickDown			= 0.1					// Maximum down recoil (skeet)
SWEP.Primary.KickHorizontal		= 1.0				// Maximum up recoil (stock)
SWEP.Primary.Automatic			= false						// Automatic/Semi Auto
SWEP.Primary.Ammo			= "357"

SWEP.Secondary.ClipSize			= 1						// Size of a clip
SWEP.Secondary.DefaultClip		= 1						// Default number of bullets in a clip
SWEP.Secondary.Automatic		= false						// Automatic/Semi Auto
SWEP.Secondary.Ammo			= ""
SWEP.Secondary.IronFOV			= 58						// How much you 'zoom' in. Less is more! 	

SWEP.data 				= {}						// The starting firemode
SWEP.data.ironsights			= 1

SWEP.IronSightsPos = Vector(-2.745, -2.85, 1.72)
SWEP.IronSightsAng = Vector(0.837, 0, 0)
SWEP.SightsPos = Vector(-2.745, -2.85, 1.72)
SWEP.SightsAng = Vector(0.837, 0, 0)
SWEP.RunSightsPos = Vector(-1.025, 2.598, -0.394)
SWEP.RunSightsAng = Vector(-17.362, 25.729, -32.244)
SWEP.Offset = {
Pos = {
Up = -1.1,
Right = 1.0,
Forward = -3.0,
},
Ang = {
Up = 5,
Right = 6.5,
Forward = 0,
}
}


function SWEP:Initialize()

	util.PrecacheSound(self.Primary.Sound)
	self.Reloadaftershoot = 0 				-- Can't reload when firing
	if !self.Owner:IsNPC() then
		self:SetWeaponHoldType("revolver")                          	-- Hold type style ("ar2" "pistol" "shotgun" "rpg" "normal" "melee" "grenade" "smg")
	end
	if SERVER and self.Owner:IsNPC() then
		self:SetWeaponHoldType("revolver")                          	-- Hold type style ("ar2" "pistol" "shotgun" "rpg" "normal" "melee" "grenade" "smg")
		self:SetNPCMinBurst(3)			
		self:SetNPCMaxBurst(10)			// None of this really matters but you need it here anyway
		self:SetNPCFireRate(1/(self.Primary.RPM/60))	
		self:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_VERY_GOOD )
	end
end



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

function SWEP:IronSight()

	if !self.Owner:IsNPC() then
	if self.ResetSights and CurTime() >= self.ResetSights then
	self.ResetSights = nil
	self:SendWeaponAnim(ACT_VM_IDLE)
	end end

	if self.Owner:KeyDown(IN_USE) and self:CanPrimaryAttack() || self.Owner:KeyDown(IN_SPEED) then		// If you hold E and you can shoot then
	self.Weapon:SetNextPrimaryFire(CurTime()+0.3)				// Make it so you can't shoot for another quarter second
	self:SetWeaponHoldType("normal")                          			// Hold type styles; ar2 pistol shotgun rpg normal melee grenade smg
	self.IronSightsPos = self.RunSightsPos					// Hold it down
	self.IronSightsAng = self.RunSightsAng					// Hold it down
	self:SetIronsights(true, self.Owner)					// Set the ironsight true
	self.Owner:SetFOV( 0, 0.3 )
	end								

	if self.Owner:KeyReleased(IN_USE) || self.Owner:KeyReleased (IN_SPEED) then	// If you release E then
	self:SetWeaponHoldType("revolver")                          				// Hold type styles; ar2 pistol shotgun rpg normal melee grenade smg slam fist melee2 passive knife
	self:SetIronsights(false, self.Owner)					// Set the ironsight true
	self.Owner:SetFOV( 0, 0.3 )
	end								// Shoulder the gun

	if self.Owner:KeyPressed(IN_WALK) then		// If you are holding ALT (walking slow) then
	self:SetWeaponHoldType("revolver")                      	// Hold type styles; ar2 pistol shotgun rpg normal melee grenade smg slam fist melee2 passive knife
	end					// Hold it at the hip (NO RUSSIAN WOOOT!)

	if !self.Owner:KeyDown(IN_USE) and !self.Owner:KeyDown(IN_SPEED) then
	-- If the key E (Use Key) is not pressed, then

		if self.Owner:KeyPressed(IN_ATTACK2) then
				if !self.Owner:KeyDown(IN_DUCK) and !self.Owner:KeyDown(IN_WALK) then
				self:SetWeaponHoldType("revolver") else self:SetWeaponHoldType("revolver")  
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
		self:SetWeaponHoldType("revolver")                      // Hold type styles; ar2 pistol shotgun rpg normal melee grenade smg slam fist melee2 passive knife

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
