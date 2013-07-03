// Variables that are used on both client and server
SWEP.Category				= "Haven's Sweps"
SWEP.Author				= "Haven"
SWEP.Contact				= "Haven"
SWEP.Purpose				= "Long range scouting"
SWEP.Instructions				= "Anti medium armored vehicle , long range Anti Materiel Rifle, "
SWEP.MuzzleAttachment			= "1" 	-- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellEjectAttachment			= "2" 	-- Should be "2" for CSS models or "1" for hl2 models
SWEP.DrawCrosshair			= false	

SWEP.ViewModelFOV			= 72
SWEP.ViewModelFlip			= true
SWEP.ViewModel				= "models/weapons/v_snip_sak.mdl"
SWEP.WorldModel				= "models/weapons/w_snip_sak.mdl"
SWEP.Base 				= "gdcw2_base_rifleman"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.Primary.Sound			= Sound("weapons/sako/awp1nm.wav")
SWEP.Primary.Round			= ("gdcwa_8.58x70mm2")
SWEP.Primary.RPM			= 30				// This is in Rounds Per Minute
SWEP.Primary.ClipSize			= 6					// Size of a clip
SWEP.Primary.DefaultClip		= 36					// Default number of bullets in a clip
SWEP.Primary.ConeSpray			= 3.0					// Hip fire accuracy
SWEP.Primary.ConeIncrement		= 6.0					// Rate of innacuracy
SWEP.Primary.ConeMax			= 6.0					// Maximum Innacuracy
SWEP.Primary.ConeDecrement		= 0.1					// Rate of accuracy
SWEP.Primary.KickUp			= 1						// Maximum up recoil (rise)
SWEP.Primary.KickDown			= 0.6						// Maximum down recoil (skeet)
SWEP.Primary.KickHorizontal		= 0.5						// Maximum up recoil (stock)
SWEP.Primary.Automatic			= false					// Automatic/Semi Auto
SWEP.Primary.Ammo			= "357"

SWEP.Secondary.ClipSize			= 1					// Size of a clip
SWEP.Secondary.DefaultClip		= 1					// Default number of bullets in a clip
SWEP.Secondary.Automatic		= false					// Automatic/Semi Auto
SWEP.Secondary.Ammo			= ""
SWEP.Secondary.ScopeZoom		= 10	
SWEP.Secondary.UseRangefinder		= true	
SWEP.Secondary.UseParabolic		= true	

SWEP.data 				= {}					-- The starting firemode
SWEP.data.ironsights			= 1
SWEP.ScopeScale 			= 0.7
SWEP.Velocity				= 550

SWEP.IronSightsPos = Vector (2.799, -0.805, 0.36)
SWEP.IronSightsAng = Vector (0, 0, 0)
SWEP.SightsPos = Vector (2.799, -0.805, 0.36)
SWEP.SightsAng = Vector (0, 0, 0)
SWEP.RunSightsPos = Vector (-1.44, -0.124, 0)
SWEP.RunSightsAng = Vector (-22, -47.126, 21.799)

SWEP.Offset = {
Pos = {
Up = 2.1,
Right = 1.0,
Forward = -3.0,
},
Ang = {
Up = 4,
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

function SWEP:PrimaryAttack()
	if self:CanPrimaryAttack() then
		self:FireRocket()
		self.Weapon:EmitSound(self.Primary.Sound)
		self.Weapon:TakePrimaryAmmo(1)
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Weapon:SetNextPrimaryFire(CurTime()+2)
if (self:GetIronsights() == true) then
timer.Simple(0.5, function()
                self.Weapon:EmitSound("weapons/sako/boltback.wav",100,math.random(90,100))
    end)
timer.Simple(1.0, function()
                self.Weapon:EmitSound("weapons/sako/boltforward.wav",100,math.random(90,100))
    end)
end
		local fx 		= EffectData()
		fx:SetEntity(self.Weapon)
		fx:SetOrigin(self.Owner:GetShootPos())
		fx:SetNormal(self.Owner:GetAimVector())
		fx:SetAttachment(self.MuzzleAttachment)
		util.Effect("gdcw_muzzle",fx)
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		self.Owner:MuzzleFlash()
	
	end
end