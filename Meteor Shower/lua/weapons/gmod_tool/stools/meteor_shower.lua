TOOL.Category		= "Meteor shower"
TOOL.Name			= "Meteor Shower"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.AdminOnly		= true

if ( CLIENT ) then
    language.Add( "Tool.meteor.shower.name", "Meteor Shower" )
    language.Add( "Tool.meteor.shower.desc", "Launch a meteor shower!" )
    language.Add( "Tool.meteor.shower.0", "Primary: Launch a shower from sky" )
end

TOOL.ClientConVar[ "meteor" ] = "2"
TOOL.ClientConVar[ "delay" ] = "1"
TOOL.ClientConVar[ "repeat" ] = "10"
TOOL.ClientConVar[ "radius" ] = "512"
TOOL.ClientConVar[ "spread" ] = "0.05"
TOOL.ClientConVar[ "force" ] = "1000"
TOOL.ClientConVar[ "damage" ] = "150"
TOOL.ClientConVar[ "magnitude" ] = "100"

function TOOL:LeftClick( trace )
	if (!trace.HitPos) then return false end
	if (CLIENT) then return true end

	if self.AdminOnly && !self:GetOwner():IsAdmin() && !self:GetOwner():IsSuperAdmin() then
		ply:PrintMessage(HUD_PRINTTALK,"ADMIN ONLY")
		return false
	end

	local Meteor = math.Round(self:GetClientNumber("meteor"))
	local Delay = self:GetClientNumber("delay")
	local Repeat = math.Round(self:GetClientNumber("repeat"))
	local Radius = self:GetClientNumber("radius")
	local Spread = self:GetClientNumber("spread")
	local Force = self:GetClientNumber("force")
	local Damage = self:GetClientNumber("damage")
	local Magnitude = self:GetClientNumber("magnitude")

    if Meteor < 1 || Meteor > 5
	|| Delay < 0.2 || Delay > 10
	|| Repeat < 1 || Repeat > 30
	|| Radius < 50 || Radius > 5000
	|| Spread < 0 || Spread > 0.5
	|| Force < 10 || Force > 10000
	|| Damage < 10 || Damage > 1000
	|| Magnitude < 10 || Magnitude > 500 then
		ply:PrintMessage(HUD_PRINTTALK,"Invalid values")
		return false
	end

	local Met = ents.Create("meteor_shower")
	Met:SetKeyValue("Meteor", Meteor)
	Met:SetKeyValue("Delay", Delay)
	Met:SetKeyValue("Repeat", Repeat)
	Met:SetKeyValue("Radius", Radius)
	Met:SetKeyValue("Spread", Spread)
	Met:SetKeyValue("Force", Force)
	Met:SetKeyValue("Damage", Damage)
	Met:SetKeyValue("Magnitude", Magnitude)

	local pos = trace.HitPos
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos+( Vector( 0, 0, 1 ) * 5000 )
	tracedata.filter = self:GetOwner()
	local traceB = util.TraceLine(tracedata)
	Met:SetPos( traceB.HitPos + traceB.HitNormal * 16 )
	Met:SetAngles( Vector( 0, 0, -1 ):Angle() )
	Met:Spawn()
	Met:Activate()
	Met:Fire("Trigger","",0)
	timer.Simple( (Repeat+1)*Delay+0.1, function() Met:Remove() end)
end

function TOOL:RightClick( trace )
	return false
end

function TOOL:Think()
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", { Text = "Meteor shower", Description = "Launch meteors from the sky." })
	panel:AddControl("Slider", {
		Label = "Nb. of Meteors in a wave",
		Type = "Integer",
		Min = "1",
		Max = "5",
		Command = "meteor_shower_meteor"
	})
	panel:AddControl("Slider", {
		Label = "Delay between 2 waves",
		Type = "Float",
		Min = "0.2",
		Max = "10",
		Command = "meteor_shower_delay"
	})
	panel:AddControl("Slider", {
		Label = "Nb. of waves",
		Type = "Integer",
		Min = "1",
		Max = "30",
		Command = "meteor_shower_repeat"
	})
	panel:AddControl("Slider", {
		Label = "Radius of shower",
		Type = "Integer",
		Min = "50",
		Max = "5000",
		Command = "meteor_shower_radius"
	})
	panel:AddControl("Slider", {
		Label = "Meteors Spread",
		Type = "Float",
		Min = "0",
		Max = "0.5",
		Command = "meteor_shower_spread"
	})
	panel:AddControl("Slider", {
		Label = "Meteor Force",
		Type = "Integer",
		Min = "10",
		Max = "10000",
		Command = "meteor_shower_force"
	})
	panel:AddControl("Slider", {
		Label = "Explosion Damage",
		Type = "Integer",
		Min = "10",
		Max = "1000",
		Command = "meteor_shower_damage"
	})
	panel:AddControl("Slider", {
		Label = "Explosion Magnitude",
		Type = "Integer",
		Min = "10",
		Max = "500",
		Command = "meteor_shower_magnitude"
	})
end