// Variables that are used on both client and server
SWEP.Category				= "Haven's Sweps"
SWEP.Author				= "Haven"
SWEP.Contact				= "Haven"
SWEP.Purpose				= "Close Quarters Combat"
SWEP.Instructions			= " "
SWEP.MuzzleAttachment			= "1" 	-- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellEjectAttachment		= "2" 	-- Should be "2" for CSS models or "1" for hl2 models
SWEP.DrawCrosshair			= false

SWEP.ViewModelFOV			= 70
SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/weapons/v_rif_ark7.mdl"
SWEP.WorldModel				= "models/weapons/w_rif_ark7.mdl"
SWEP.Base 				= "gdcw2_base_assault"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.Primary.Sound			= Sound("weapons/ark7/ak47-1.wav")
SWEP.Primary.Round			= ("gdcwa_7.62x45_Nato2")
SWEP.Primary.RPM			= 700					// This is in Rounds Per Minute
SWEP.Primary.ClipSize			= 30						// Size of a clip
SWEP.Primary.DefaultClip		= 120
SWEP.Primary.ConeSpray			= 2.3					// Hip fire accuracy
SWEP.Primary.ConeIncrement		= 1.4					// Rate of innacuracy
SWEP.Primary.ConeMax			= 8.0					// Maximum Innacuracy
SWEP.Primary.ConeDecrement		= 1.6					// Rate of accuracy
SWEP.Primary.KickUp			= 1			// Maximum up recoil (rise)
SWEP.Primary.KickDown			= 0.1					// Maximum down recoil (skeet)
SWEP.Primary.KickHorizontal		= 0.7				// Maximum up recoil (stock)
SWEP.Primary.Automatic			= true						// Automatic/Semi Auto
SWEP.Primary.Ammo			= "ar2"

SWEP.Secondary.ClipSize			= 1						// Size of a clip
SWEP.Secondary.DefaultClip		= 1						// Default number of bullets in a clip
SWEP.Secondary.Automatic		= false						// Automatic/Semi Auto
SWEP.Secondary.Ammo			= ""
SWEP.Secondary.IronFOV			= 60						// How much you 'zoom' in. Less is more! 	

SWEP.data 				= {}						// The starting firemode
SWEP.data.ironsights			= 1

SWEP.IronSightsPos = Vector(-2.52, -3.08, 1.12)
SWEP.IronSightsAng = Vector(0.4, 0.11, -0.5)
SWEP.SightsPos = Vector(-2.52, -3.08, 1.12)
SWEP.SightsAng = Vector(0.4, 0.11, -0.5)
SWEP.RunSightsPos = Vector(2.829, -2.926, -1.501)
SWEP.RunSightsAng = Vector(-19.361, 64.291, -32.039)
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