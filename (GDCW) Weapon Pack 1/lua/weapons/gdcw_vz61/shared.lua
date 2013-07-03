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
SWEP.ViewModelFlip			= true
SWEP.ViewModel				= "models/weapons/v_smg_vz-61.mdl"
SWEP.WorldModel				= "models/weapons/w_smg_vz-61.mdl"
SWEP.Base 				= "gdcw2_base_assault"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.Primary.Sound			= Sound("weapons/vz61/mac10-1.wav")
SWEP.Primary.Round			= ("gdcwa_7.65x17mm_browning_sr2")
SWEP.Primary.RPM			= 950					// This is in Rounds Per Minute
SWEP.Primary.ClipSize			= 20						// Size of a clip
SWEP.Primary.DefaultClip		= 140
SWEP.Primary.ConeSpray			= 2.3					// Hip fire accuracy
SWEP.Primary.ConeIncrement		= 1.4					// Rate of innacuracy
SWEP.Primary.ConeMax			= 10.0					// Maximum Innacuracy
SWEP.Primary.ConeDecrement		= 1.4					// Rate of accuracy
SWEP.Primary.KickUp			= 1.1				// Maximum up recoil (rise)
SWEP.Primary.KickDown			= 0.2					// Maximum down recoil (skeet)
SWEP.Primary.KickHorizontal		= 0.9				// Maximum up recoil (stock)
SWEP.Primary.Automatic			= true						// Automatic/Semi Auto
SWEP.Primary.Ammo			= "smg1"

SWEP.Secondary.ClipSize			= 1						// Size of a clip
SWEP.Secondary.DefaultClip		= 1						// Default number of bullets in a clip
SWEP.Secondary.Automatic		= false						// Automatic/Semi Auto
SWEP.Secondary.Ammo			= ""
SWEP.Secondary.IronFOV			= 58						// How much you 'zoom' in. Less is more! 	

SWEP.data 				= {}						// The starting firemode
SWEP.data.ironsights			= 1

SWEP.IronSightsPos = Vector(4.349, -6.22, 2.539)
SWEP.IronSightsAng = Vector(1.677, 0, 0)
SWEP.SightsPos = Vector(4.349, -6.22, 2.539)
SWEP.SightsAng = Vector(1.677, 0, 0)
SWEP.RunSightsPos = Vector(-3.84, -1.241, -2.8)
SWEP.RunSightsAng = Vector(-14.5, -42.901, 23.6)
SWEP.Offset = {
Pos = {
Up = -2.1,
Right = 2.0,
Forward = -5.6,
},
Ang = {
Up = 10,
Right = 10.5,
Forward = 0,
}
}

function SWEP:Initialize()

	util.PrecacheSound(self.Primary.Sound)
	self.Reloadaftershoot = 0 				-- Can't reload when firing
	if !self.Owner:IsNPC() then
		self:SetWeaponHoldType("smg")                          	-- Hold type style ("ar2" "pistol" "shotgun" "rpg" "normal" "melee" "grenade" "smg")
	end
	if SERVER and self.Owner:IsNPC() then
		self:SetWeaponHoldType("smg")                          	-- Hold type style ("ar2" "pistol" "shotgun" "rpg" "normal" "melee" "grenade" "smg")
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