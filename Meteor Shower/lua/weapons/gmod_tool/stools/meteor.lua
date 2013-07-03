TOOL.Category		= "Meteor shower"
TOOL.Name			= "Meteor"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.AdminOnly		= true

if ( CLIENT ) then
    language.Add( "Tool.meteor.name", "Meteor" )
    language.Add( "Tool.meteor.desc", "Launch meteors!" )
    language.Add( "Tool.meteor.0", "Primary: Launch from sky - Secondary: Launch from toolgun" )
end
    
TOOL.ClientConVar[ "force" ] = "1000"
TOOL.ClientConVar[ "damage" ] = "150"
TOOL.ClientConVar[ "magnitude" ] = "100"

function TOOL:LaunchMeteor( trace )
	if self.AdminOnly && !self:GetOwner():IsAdmin() && !self:GetOwner():IsSuperAdmin() then
		ply:PrintMessage(HUD_PRINTTALK,"ADMIN ONLY")
		return false
	end

	local Force = self:GetClientNumber("force")
	local Damage = self:GetClientNumber("damage")
	local Magnitude = self:GetClientNumber("magnitude")

	if Force < 10 || Force > 10000
	|| Damage < 10 || Damage > 1000
	|| Magnitude < 10 || Magnitude > 500 then
		ply:PrintMessage(HUD_PRINTTALK,"Invalid values")
		return false
	end

	local Met = ents.Create("meteor")
	Met:SetKeyValue("Force", Force)
	Met:SetKeyValue("Damage", Damage)
	Met:SetKeyValue("Magnitude", Magnitude)

	return true, Met
end

function TOOL:LeftClick( trace )
	if (!trace.HitPos) then return false end
	if (CLIENT) then return true end
	local Return, Met = self:LaunchMeteor( trace )
	if not Return then return false end
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
end

function TOOL:RightClick( trace )
	local Return, Met = self:LaunchMeteor( trace )
	if (CLIENT) then return false end
	if not Return then return false end
	Met:SetOwner( self:GetOwner() )
	Met:SetPos( self:GetOwner():GetShootPos() )
	Met:SetAngles( self:GetOwner():GetAngles() )
	Met:Spawn()
	Met:Activate()
end

function TOOL:Think()
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", { Text = "#Tool_meteor_name", Description = "#Tool_meteor_desc" })
	panel:AddControl("Slider", {
		Label = "Meteor Force",
		Type = "Float",
		Min = "10",
		Max = "10000",
		Command = "meteor_force"
	})
	panel:AddControl("Slider", {
		Label = "Explosion Damage",
		Type = "Integer",
		Min = "10",
		Max = "1000",
		Command = "meteor_damage"
	})
	panel:AddControl("Slider", {
		Label = "Explosion Magnitude",
		Type = "Integer",
		Min = "10",
		Max = "500",
		Command = "meteor_magnitude"
	})
end