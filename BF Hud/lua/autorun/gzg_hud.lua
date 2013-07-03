

if SERVER then
	
hook.Add("PlayerDeath","Starting",function(ply)

	umsg.Start( "flashoff" );
	umsg.End();

end)

hook.Add("PlayerSpawn","Starting",function(ply)

	umsg.Start( "flashon" );
	umsg.End();

end)

hook.Add("EntityTakeDamage","Sahek",function( target, dmginfo )

	if ( target:IsPlayer() ) then
 
		umsg.Start( "shake_view" );
		umsg.Entity(target)
		umsg.Bool(true)
		umsg.End();

		timer.Simple(0.75,function() if target:IsValid() then
			
		umsg.Start( "shake_view" );
		umsg.Entity(target)
		umsg.Bool(false)
		umsg.End();

		end end)
		
	end

end)

end



if CLIENT then


	if ( !ConVarExists( "gzg_hudpos" ) ) then
		CreateConVar( "gzg_hudpos", "70", { FCVAR_REPLICATED, FCVAR_ARCHIVE } )
	end

	if ( !ConVarExists( "gzg_vignette" ) ) then
		CreateConVar( "gzg_vignette", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE } )
	end

	if ( !ConVarExists( "gzg_hide_sleep" ) ) then
		CreateConVar( "gzg_hide_sleep", "0", { FCVAR_REPLICATED, FCVAR_ARCHIVE } )
	end


local multiplo_fixture = 0;

local ribbon = surface.GetTextureID("vgui/vgui") 
local nmb = surface.GetTextureID("vgui/counter") 
local bar = surface.GetTextureID("vgui/bar") 
local grenade = surface.GetTextureID("vgui/grenade")
local upward = surface.GetTextureID("vgui/up") 
local crouch = surface.GetTextureID("vgui/down") 
local life = surface.GetTextureID("vgui/life_beccon") 
local health = surface.GetTextureID("vgui/life") 
local armor = surface.GetTextureID("vgui/armor") 
local health_metter = surface.GetTextureID("vgui/heart_measure") 
local blur = surface.GetTextureID("vgui/vignette") 
local black = surface.GetTextureID("vgui/black_blur")
local healt_tick = Material("vgui/heart_measure")
local move_up = false
local y_factor = 70
local x_factor = 150
local hud_refix = 0
local cur_state = Color(25,150,255)
local cur_state_wep = Color(25,150,255)
local reactivator = 0	
local r_ch = 0
local g_ch = 0
local b_ch = 0
local alpha_ch = { 30,120 }
local Shaking = false

function surface.DrawPartialTexturedRect( x, y, w, h, partx, party, partw, parth, texw, texh )
    --[[ 
        Arguments:
        x: Where is it drawn on the x-axis of your screen
        y: Where is it drawn on the y-axis of your screen
        w: How wide must the image be?
        h: How high must the image be?
        partx: Where on the given texture's x-axis can we find the image you want?
        party: Where on the given texture's y-axis can we find the image you want?
        partw: How wide is the partial image in the given texture?
        parth: How high is the partial image in the given texture?
        texw: How wide is the texture?
        texh: How high is the texture?
    ]]--
     
    -- Verify that we recieved all arguments
    if not( x && y && w && h && partx && party && partw && parth && texw && texh ) then
         
        return;
    end;
     
    -- Get the positions and sizes as percentages / 100
    local percX, percY = partx / texw, party / texh;
    local percW, percH = partw / texw, parth / texh;
     
    -- Process the data
    local vertexData = {
        {
            x = x,
            y = y,
            u = percX,
            v = percY
        },
        {
            x = x + w,
            y = y,
            u = percX + percW,
            v = percY
        },
        {
            x = x + w,
            y = y + h,
            u = percX + percW,
            v = percY + percH
        },
        {
            x = x,
            y = y + h,
            u = percX,
            v = percY + percH
        }
    };
         
    surface.DrawPoly( vertexData );
end;
 
-- A function to draw a certain part of a texture
function draw.DrawPartialTexturedRect( x, y, w, h, partx, party, partw, parth, texturename )
    --[[ 
        Arguments:
        - Also look at the arguments of the surface version of this
        texturename: What is the name of the texture?
    ]]--
     
    -- Verify that we recieved all arguments
    if not( x && y && w && h && partx && party && partw && parth && texturename ) then
         
        return;
    end;
     
    -- Get the texture
    local texture = surface.GetTextureID(texturename);
     
    -- Get the positions and sizes as percentages / 100
    local texW, texH = surface.GetTextureSize( texture );
    local percX, percY = partx / texW, party / texH;
    local percW, percH = partw / texW, parth / texH;
     
    -- Process the data
    local vertexData = {
        {
            x = x,
            y = y,
            u = percX,
            v = percY
        },
        {
            x = x + w,
            y = y,
            u = percX + percW,
            v = percY
        },
        {
            x = x + w,
            y = y + h,
            u = percX + percW,
            v = percY + percH
        },
        {
            x = x,
            y = y + h,
            u = percX,
            v = percY + percH
        }
    };
     
    surface.SetTexture( texture );
    surface.SetDrawColor( 255, 255, 255, 255  * multiplo_fixture );
    surface.DrawPoly( vertexData );
end;

local sSetTextPos = surface.SetTextPos;
local sDrawText = surface.DrawText;
local cPushModelMatrix = cam.PushModelMatrix;
local cPopModelMatrix = cam.PopModelMatrix;
 
local mat = Matrix();
local matAng = Angle(0, 0, 0);
local matTrans = Vector(0, 0, 0);
local matScale = Vector(0, 0, 0);

local function drawSpecialText(txt, posX, posY, scaleX, scaleY, ang)
    matAng.y = ang;
    mat:SetAngles(matAng);
    matTrans.x = posX;
    matTrans.y = posY;
    mat:SetTranslation(matTrans);
    matScale.x = scaleX;
    matScale.y = scaleY;
    mat:Scale(matScale);
    sSetTextPos(0, 0);
    cPushModelMatrix(mat);
        sDrawText(txt);
    cPopModelMatrix();
end



surface.CreateFont( "BF3",
	{
		font      = "Euro Caps",
		size      = 80,
		weight    = 700,
		underline = 0,
		additive  = true,
		blursize = 1
	}

 )

surface.CreateFont( "BF3_a",
	{
		font      = "Euro Caps",
		size      = 45,
		weight    = 700,
		underline = 1,
		additive  = true,
		blursize = 1
	}

 )


surface.CreateFont( "BF3_Blur",
	{
		font      = "Euro Caps",
		size      = 80,
		weight    = 800,
		underline = 5,
		strikeout = false,
		blursize = 15
	}

 )

surface.CreateFont( "BF3_Blur_a",
	{
		font      = "Euro Caps",
		size      = 45,
		weight    = 800,
		underline = 5,
		strikeout = false,
		blursize = 9
	}

 )



hook.Add("HUDPaint","Battlefield3Paint",function()

	if GetConVar("cl_drawhud"):GetInt() > 0 then

		y_factor = GetConVar("gzg_hudpos"):GetInt()



				
				if hud_refix > -50 and LocalPlayer():Alive() then
			
					hud_refix = hud_refix - 50

						if hud_refix < -50 then
				
							hud_refix = -50

						end

				end




		if LocalPlayer():GetNWBool("Death") == true then
			

			if multiplo_fixture >= 0 and LocalPlayer():GetNWBool("Respawn") == false then
			
			multiplo_fixture = multiplo_fixture - 0.25

			if multiplo_fixture < 0 then
				
				multiplo_fixture = 0

			end

			elseif multiplo_fixture != 0 then

				LocalPlayer():SetNWBool("Death",false)

			end

		end

		if LocalPlayer():GetNWBool("Respawn") == true and LocalPlayer():GetNWBool("Death") == false then
			
			multiplo_fixture = 0
			cur_state = Color(25,150,255)
			LocalPlayer():SetNWBool("Respawn",false)

		end

		if multiplo_fixture <= 1 and LocalPlayer():Alive() then
			
			multiplo_fixture = multiplo_fixture + 0.25

			if multiplo_fixture > 1 then
				
				multiplo_fixture = 1

			end

		end

		if hud_refix < 128 and LocalPlayer():Alive() and move_up == false then
			
			hud_refix = hud_refix + 40

			if hud_refix > 128 then
				
				hud_refix = 128

			end

		end

		if GetConVar("gzg_vignette"):GetInt() > 0 then

			for i=0, GetConVar("gzg_vignette"):GetInt() do 

				surface.SetTexture(blur)
				surface.SetDrawColor(255,255,255,150)
				surface.DrawTexturedRect(  0, 0, ScrW(),ScrH())

			end

		end
	

		surface.SetTexture(black)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRectRotated(  ScrW() - 340 + x_factor - math.cos(RealTime() * math.random(0,20)) * 0.75, ScrH() - y_factor + hud_refix - math.sin(RealTime() * math.random(0,20)) * 0.75, 256,128 * multiplo_fixture,0 )

		surface.SetTexture(ribbon)

		surface.SetDrawColor(cur_state_wep.r,cur_state_wep.g,cur_state_wep.b,alpha_ch[2] - math.sin(RealTime() * 50) * 5)
		surface.DrawTexturedRectRotated(  ScrW() - 340 + x_factor - math.cos(RealTime() * math.random(0,20)) * 0.75, ScrH() - y_factor + hud_refix - math.sin(RealTime() * math.random(0,20)) * 0.75, 256,128 * multiplo_fixture,0 )

		surface.SetDrawColor(0,0,255 ,alpha_ch[1])
		surface.DrawTexturedRectRotated( b_ch + ScrW() - 338+ x_factor + math.sin(RealTime() * 50) * 5, ScrH() - y_factor + hud_refix + r_ch, 256,128 * multiplo_fixture,-3 )

		surface.SetDrawColor(0,255 ,0,math.sin(RealTime() * 0.3) * 25)
		surface.DrawTexturedRectRotated( - g_ch + ScrW() - 334+ x_factor - math.sin(RealTime() * math.random(0,20)) * 2.75, ScrH() - y_factor + hud_refix  - math.sin(RealTime() * math.random(0,20)) * 2.75 + g_ch, 256,128 * multiplo_fixture,0 )

		surface.SetDrawColor(0,255 ,0,alpha_ch[1])
		surface.DrawTexturedRectRotated(g_ch + ScrW() - 334+ x_factor + math.sin(RealTime() * math.random(0,20)) * 5, ScrH() - y_factor + hud_refix - b_ch, 256,128 * multiplo_fixture,0 )

		surface.SetDrawColor(255 ,0,0,alpha_ch[1])
		surface.DrawTexturedRectRotated( r_ch+ ScrW() - 342+ x_factor - math.sin(RealTime() * 0.3) * 5, ScrH() - y_factor + hud_refix, 256,128 * multiplo_fixture,-3 )

		surface.SetTexture(nmb)
		surface.SetDrawColor(255,255,255,110 - math.sin(RealTime() * 50) * 5)
		surface.DrawTexturedRectRotated(  ScrW() - 340 + 53, ScrH() - y_factor + hud_refix - 20 - math.sin(RealTime() * math.random(0.1,.2)) * 0.1, 42,42 *multiplo_fixture,-2)
		surface.DrawTexturedRectRotated(  ScrW() - 340 + 93, ScrH() - y_factor + hud_refix - 18 - math.sin(RealTime() * math.random(0.1,0.2)) * 0.1, 42,42*multiplo_fixture,-2 )
		surface.DrawTexturedRectRotated(  ScrW() - 340 + 132, ScrH() - y_factor + hud_refix - 16 - math.sin(RealTime() * math.random(0.1,0.2)) * 0.1, 42,42*multiplo_fixture,-2 )

		
		surface.DrawTexturedRectRotated(  ScrW() - 340 + 190, ScrH() - y_factor + hud_refix - 12 - math.sin(RealTime() * math.random(0.1,.2)) * 0.1, 24,24*multiplo_fixture,-2)
		surface.DrawTexturedRectRotated(  ScrW() - 340 + 212, ScrH() - y_factor + hud_refix - 10 - math.sin(RealTime() * math.random(0.1,0.2)) * 0.1, 24,24*multiplo_fixture,-2 )
		surface.DrawTexturedRectRotated(  ScrW() - 340 + 232, ScrH() - y_factor + hud_refix - 8 - math.sin(RealTime() * math.random(0.1,0.2)) * 0.1, 24,24*multiplo_fixture,-2 )
		

		if LocalPlayer():Alive() then

		
		if(LocalPlayer():GetActiveWeapon() == NULL or LocalPlayer():GetActiveWeapon() == "Camera") then return end

			if LocalPlayer():GetActiveWeapon():Clip1() == 0 and LocalPlayer():GetActiveWeapon():GetClass() != "weapon_physcannon" then
				

				cur_state_wep = Color(255,51,0)

			else

				cur_state_wep = Color(25,150,255)

			end

		if LocalPlayer():GetActiveWeapon():Clip1() > 9 and LocalPlayer():GetActiveWeapon():Clip1() > -1 then
		draw.SimpleText( LocalPlayer():GetActiveWeapon():Clip1(), "BF3_Blur", ScrW() - x_factor - 82, ScrH() - y_factor + hud_refix - 60, Color(0,204,255,255),1,2 )
		draw.SimpleText( "", "BF3", ScrW() - x_factor + 20, ScrH() - y_factor + hud_refix - 35, Color(255,255,255,255),1,2 )
		drawSpecialText(LocalPlayer():GetActiveWeapon():Clip1(),ScrW() - x_factor - 112,ScrH() - y_factor + hud_refix - 60,1,1,3)
		
		elseif LocalPlayer():GetActiveWeapon():Clip1() > -1 then

		draw.SimpleText( LocalPlayer():GetActiveWeapon():Clip1(), "BF3_Blur", ScrW() - x_factor - 55, ScrH() - y_factor + hud_refix - 57, Color(0,204,255,255),1,2 )
		draw.SimpleText( "", "BF3", ScrW() - x_factor + 20, ScrH() - y_factor + hud_refix - 35, Color(255,255,255,255),1,2 )
		drawSpecialText(LocalPlayer():GetActiveWeapon():Clip1(),ScrW() - x_factor - 75,ScrH() - y_factor + hud_refix - 57,1,1,3)

		end


		if LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()) > 99 then
		draw.SimpleText( "", "BF3_a", ScrW() - x_factor + 20, ScrH() - y_factor + hud_refix - 35, Color(255,255,255,255),1,2 )
		drawSpecialText(LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()),ScrW() - x_factor - 5,ScrH() - y_factor + hud_refix - 35,1,1,3)
		draw.SimpleText( LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()), "BF3_Blur_a", ScrW() - x_factor+ 25, ScrH() - y_factor + hud_refix - 35, Color(0,204,255,255),1,2 )
		
		elseif LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()) > 9 then

		draw.SimpleText( "", "BF3_a", ScrW() - x_factor + 20, ScrH() - y_factor + hud_refix - 35, Color(255,255,255,255),1,2 )
		drawSpecialText(LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()),ScrW() - x_factor + 14,ScrH() - y_factor + hud_refix - 32,1,1,3)
		draw.SimpleText( LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()), "BF3_Blur_a", ScrW() - x_factor+ 32, ScrH() - y_factor + hud_refix - 28, Color(0,204,255,255),1,2 )
		
		elseif LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()) > -1 then

		draw.SimpleText( "", "BF3_a", ScrW() - x_factor + 20, ScrH() - y_factor + hud_refix - 35, Color(255,255,255,255),1,2 )
		drawSpecialText(LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()),ScrW() - x_factor + 34,ScrH() - y_factor + hud_refix - 32,1,1,3)
		draw.SimpleText( LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()), "BF3_Blur_a", ScrW() - x_factor+ 43, ScrH() - y_factor + hud_refix - 30, Color(0,204,255,255),1,2 )
		
		end
			
		surface.SetTexture(grenade)
		surface.SetDrawColor(255,255,255,255 * multiplo_fixture)
		surface.DrawTexturedRectRotated(  ScrW() - x_factor - 24, ScrH() - y_factor + hud_refix + 23, 28,32 * multiplo_fixture,-3 )

		draw.SimpleText( "", "BF3_a", ScrW() - x_factor + 20, ScrH() - y_factor + hud_refix - 35, Color(255,255,255,255),1,2 )
		drawSpecialText("x"..LocalPlayer():GetAmmoCount("grenade"),ScrW() - x_factor - 6,ScrH() - y_factor + hud_refix - 0,1,multiplo_fixture,3)
		draw.SimpleText(LocalPlayer():GetAmmoCount("grenade"), "BF3_Blur_a", ScrW() - x_factor+ 34, ScrH() - y_factor + hud_refix - 35, Color(0,204,255,255),1,2 )
		
		surface.SetTexture(bar)
		surface.SetDrawColor(255,255,255,255  * multiplo_fixture)
		surface.DrawTexturedRectRotated(  ScrW() - 326 + x_factor, ScrH() - y_factor + hud_refix - 12, 24,35,-3 )

		surface.SetTexture(bar )
		surface.SetDrawColor(Color(cur_state.r,cur_state.g,cur_state.b,255  * multiplo_fixture))
		surface.DrawTexturedRectRotated(  205, ScrH() - y_factor - 12, 24,35,-3 )


		if LocalPlayer():Crouching() then
			
			surface.SetTexture(crouch)
			surface.SetDrawColor(255,255,255,255  * multiplo_fixture)
			surface.DrawTexturedRectRotated(  ScrW() - 360	 + x_factor, ScrH() - y_factor + hud_refix + 24, 48,48 *multiplo_fixture,-3 )

		else

			surface.SetTexture(upward)
			surface.SetDrawColor(255,255,255,255  * multiplo_fixture)
			surface.DrawTexturedRectRotated(  ScrW() - 360	 + x_factor, ScrH() - y_factor + hud_refix + 24, 48,40 *multiplo_fixture,-3 )
		end


		surface.SetTexture(black)
		surface.SetDrawColor(255,255,255,100)
		surface.DrawTexturedRectRotated(  30 + x_factor - math.cos(RealTime() * math.random(0,20)) * 0.75, ScrH() - y_factor  - 10 - math.sin(RealTime() * math.random(0,20)) * 0.75, -256,96 * multiplo_fixture,0 )

		
		for i= 0, 3 do
			
			healt_tick:SetFloat( "$speed", 1.3 - LocalPlayer():Health() / 100 )
			surface.SetTexture(health_metter)
			surface.SetDrawColor(cur_state.r + 30,cur_state.g + 30,cur_state.b + 30,255 - math.sin(RealTime() * 50) * 5)
			surface.DrawPartialTexturedRect( i * 64 - 100 +x_factor - math.cos(RealTime() * math.random(0,20)) * 0.75, ScrH() - y_factor  - 128 + (LocalPlayer():Health() / 100) * 60 - 25 - math.sin(RealTime() * math.random(0,20)) * 0.75, 64, 40 - (((LocalPlayer():Health() / 100) * 60) -60) * multiplo_fixture, 0, 0, 64, 64,128,64 );
		
		end

		surface.SetTexture(ribbon)
		surface.SetDrawColor(cur_state.r,cur_state.g,cur_state.b,90 - math.sin(RealTime() * 50) * 5)
		surface.DrawTexturedRectRotated(  30 + x_factor - math.cos(RealTime() * math.random(0,20)) * 0.75, ScrH() - y_factor + (LocalPlayer():Health() / 100) * 10  - 90 - math.sin(RealTime() * math.random(0,20)) * 0.75, -256,130 - (LocalPlayer():Health() / 100) * 60 * multiplo_fixture,0 )


		surface.SetTexture(ribbon)
		surface.SetDrawColor(cur_state.r,cur_state.g,cur_state.b,110 - math.sin(RealTime() * 50) * 5)
		surface.DrawTexturedRectRotated(  30 + x_factor - math.cos(RealTime() * math.random(0,20)) * 0.75, ScrH() - y_factor + (LocalPlayer():Health() / 100) * 10  - 30 - math.sin(RealTime() * math.random(0,20)) * 0.75, -256,130 - (LocalPlayer():Health() / 100) * 30 * multiplo_fixture,0 )

		surface.SetDrawColor(0,0,cur_state.b,30)
		surface.DrawTexturedRectRotated(  30 + x_factor + math.sin(RealTime() * 50) * 5, ScrH() - y_factor - 10, -256,96,-3 )

		surface.SetDrawColor(0,cur_state.g,0,math.sin(RealTime() * 0.3) * 25)
		surface.DrawTexturedRectRotated(  30 + x_factor - math.sin(RealTime() * math.random(0,20)) * 2.75, ScrH() - y_factor - 10 - math.sin(RealTime() * math.random(0,20)) * 2.75,- 256,96,0 )

		surface.SetDrawColor(0,cur_state.g,0,20)
		surface.DrawTexturedRectRotated(  30 + x_factor + math.sin(RealTime() * math.random(0,20)) * 2.75, ScrH() - y_factor - 10, -256,96,0 )

		surface.SetDrawColor(255,0,0,15)
		surface.DrawTexturedRectRotated(  30 + x_factor - math.sin(RealTime() * 40) * 2, ScrH() - y_factor- 10, -256,96,0 )

		surface.SetTexture(nmb)
		surface.SetDrawColor(255,255,255,255 - math.sin(RealTime() * 50) * 5)
		surface.DrawTexturedRectRotated(  90, ScrH() - y_factor - 10 - math.sin(RealTime() * math.random(0.1,.2)) * 0.1, 42,42  * multiplo_fixture,2)
		surface.DrawTexturedRectRotated(  130, ScrH() - y_factor - 12 - math.sin(RealTime() * math.random(0.1,.2)) * 0.1, 42,42  * multiplo_fixture,2)
		surface.DrawTexturedRectRotated(  170, ScrH() - y_factor - 14 - math.sin(RealTime() * math.random(0.1,.2)) * 0.1, 42,42  * multiplo_fixture,2)

		surface.DrawTexturedRectRotated(  235, ScrH() - y_factor - 11 - math.sin(RealTime() * math.random(0.1,.2)) * 0.1, 24,24 * multiplo_fixture,2)
		surface.DrawTexturedRectRotated(  256, ScrH() - y_factor - 12 - math.sin(RealTime() * math.random(0.1,.2)) * 0.1, 24,24* multiplo_fixture,2)
		surface.DrawTexturedRectRotated(  277, ScrH() - y_factor - 13 - math.sin(RealTime() * math.random(0.1,.2)) * 0.1, 24,24* multiplo_fixture,2)


		if LocalPlayer():Health() >= 100 then
		cur_state = Color(25,150,255)
    	draw.SimpleText( LocalPlayer():Health(), "BF3_Blur", 120, ScrH() - y_factor - 50, Color(255,255,255, 100* multiplo_fixture),1,2 )
		draw.SimpleText( "", "BF3", ScrW() - x_factor + 20, ScrH() - y_factor - 35, Color(255,255,255,255 * multiplo_fixture),1,2 )
		drawSpecialText(LocalPlayer():Health(),73,ScrH() - y_factor - 51 + (multiplo_fixture/500 *100)  ,1,multiplo_fixture,-2)

		elseif LocalPlayer():Health() >= 11 then

    	draw.SimpleText( LocalPlayer():Health(), "BF3_Blur", 150, ScrH() - y_factor - 55, Color(255,255,255,100),1,2 )
		draw.SimpleText( "", "BF3", ScrW() - x_factor + 20, ScrH() - y_factor  - 35, Color(255,255,255,255),1,2 )
		drawSpecialText(LocalPlayer():Health(),113,ScrH() - y_factor - 51,1,multiplo_fixture,-2)

		elseif LocalPlayer():Health() <= 10 then

		draw.SimpleText( LocalPlayer():Health(), "BF3_Blur", 170, ScrH() - y_factor - 55, Color(255,255,255,100),1,2 )
		draw.SimpleText( "", "BF3", ScrW() - x_factor + 20, ScrH() - y_factor - 35, Color(255,255,255,255),1,2 )
		drawSpecialText(LocalPlayer():Health(),150,ScrH() - y_factor - 55,1,1,-2)

		end

		if LocalPlayer():Armor() >= 100 then
		cur_state = Color(25,150,255)
    	draw.SimpleText( LocalPlayer():Armor(), "BF3_Blur_a", 250, ScrH() - y_factor - 35, Color(0255,204,255,255),1,2 )
		draw.SimpleText( "", "BF3_a", ScrW() - x_factor + 20, ScrH() - y_factor  - 35, Color(255,255,255,255),1,2 )
		drawSpecialText(LocalPlayer():Armor(),224,ScrH() - y_factor - 34,1,multiplo_fixture,-2)

		elseif LocalPlayer():Armor() >= 10 then

    	draw.SimpleText( LocalPlayer():Armor(), "BF3_Blur_a", 260, ScrH() - y_factor - 35, Color(255,204,255,255),1,2 )
		draw.SimpleText( "", "BF3_a", ScrW() - x_factor + 20, ScrH() - y_factor - 35, Color(255,255,255,255),1,2 )
		drawSpecialText(LocalPlayer():Armor(),246,ScrH() - y_factor - 35,1,multiplo_fixture,-2)

		elseif LocalPlayer():Armor() < 10 then

		draw.SimpleText( LocalPlayer():Armor(), "BF3_Blur_a", 275, ScrH() - y_factor - 35, Color(255,204,255,255),1,2 )
		draw.SimpleText( "", "BF3_a", ScrW() - x_factor + 20, ScrH() - y_factor - 35, Color(255,255,255,255),1,2 )
		drawSpecialText(LocalPlayer():Armor(),265,ScrH() - y_factor - 36,1,multiplo_fixture,-2)

		end

		if LocalPlayer():Health() > 99 and LocalPlayer():Health() < 100 then

			cur_state = Color(25,150,255)

		elseif LocalPlayer():Health() > 75 and LocalPlayer():Health() < 100 then

			cur_state = Color(25,150,255)

		elseif LocalPlayer():Health() > 50 and LocalPlayer():Health() < 75 then

			cur_state = Color(228,255,122)

    	elseif LocalPlayer():Health() >= 11 and LocalPlayer():Health() < 50 then

			cur_state = Color(224,112,0)

		elseif LocalPlayer():Health() <= 10 then

			cur_state = Color(255,0,0,255)

    	end

    	if shaking == true then
    		
    		r_ch = math.tan(RealTime() * 100) * math.random(-40,40)
    		g_ch = math.tan(RealTime() * 100) * math.random(-40,40)
    		b_ch = math.tan(RealTime() * 100) * math.random(-40,40)
    		cur_state.r = math.tan(RealTime() * 100) * 200
    		cur_state.g = cur_state.g -math.tan(RealTime() * 100) * 50
    		cur_state.b = cur_state.b -math.tan(RealTime() * 100) * 50
    		alpha_ch[1] = math.tan(RealTime() * 100) * 75
    		alpha_ch[2] = math.tan(RealTime() * 100) * 20

    	else

    		alpha_ch[1] = 30
			alpha_ch[2] = 120
    		r_ch = 0
    		g_ch = 0
    		b_ch = 0

    	end

     	if wepshaking == true then
    		
    		r_ch = math.tan(RealTime() * 100) * math.random(-40,40)
    		g_ch = math.tan(RealTime() * 100) * math.random(-40,40)
    		b_ch = math.tan(RealTime() * 100) * math.random(-40,40)

    	else

    		r_ch = 0
    		g_ch = 0
    		b_ch = 0

    	end

	end
end


end)


local tohide = { -- This is a table where the keys are the HUD items to hide
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true
}
local function HUDShouldDraw(name) -- This is a local function because all functions should be local unless another file needs to run it
	if (tohide[name]) then     -- If the HUD name is a key in the table
		return false;      -- Return false.
	end
end
hook.Add("HUDShouldDraw", "HUDDisabler", HUDShouldDraw)

local function StartFocus( data )
 
	LocalPlayer():SetNWBool("Respawn",true)
	cur_state = Color(25,150,255)

end
usermessage.Hook( "flashon", StartFocus );

local function EndFocus( data )
 
	LocalPlayer():SetNWBool("Death",true)
 
end
usermessage.Hook( "flashoff", EndFocus );

local function Shake( data )

 	if data:ReadEntity() == LocalPlayer() then

 		shaking = data:ReadBool()
	
	end
 
end
usermessage.Hook( "shake_view", Shake );



end
