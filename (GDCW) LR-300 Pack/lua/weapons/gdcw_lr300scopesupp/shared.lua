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
SWEP.ViewModel				= "models/weapons/v_rif_l3ss.mdl"
SWEP.WorldModel				= "models/weapons/w_rif_l3ss_silencer.mdl"
SWEP.Base 				= "gdcw2_base_rifleman_supp"              //Using a seperate base for silenced animations
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
SWEP.Secondary.ScopeZoom			= 4	
SWEP.Secondary.UseACOG		= true

SWEP.data 				= {}						// The starting firemode
SWEP.data.ironsights			= 1
SWEP.ScopeScale 			= 0.6

SWEP.IronSightsPos = Vector(2.759, -6.378, 0.36)
SWEP.IronSightsAng = Vector(0, 0, 0)
SWEP.SightsPos = Vector(2.759, -6.378, 0.36)
SWEP.SightsAng = Vector(0, 0, 0)
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
