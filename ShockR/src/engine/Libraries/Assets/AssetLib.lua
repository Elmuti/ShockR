local eng = {}
eng.Sounds = {}
eng.Player = {}


	
	-- private sounds
	
	
	-- Another Dimension   http://www.roblox.com/asset/?id=179830750
	-- HingeCreak1   http://www.roblox.com/asset/?id=177721424
	-- HingeCreak2   http://www.roblox.com/asset/?id=177721486
	-- BabyWhine   http://www.roblox.com/asset/?id=177616514
	-- AS   http://www.roblox.com/asset/?id=
	-- AS   http://www.roblox.com/asset/?id=
	-- AS   http://www.roblox.com/asset/?id=
	-- AS   http://www.roblox.com/asset/?id=
	-- AS   http://www.roblox.com/asset/?id=
	-- AS   http://www.roblox.com/asset/?id=
	-- AS   http://www.roblox.com/asset/?id=
	-- AS   http://www.roblox.com/asset/?id=
	-- AS   http://www.roblox.com/asset/?id=







eng.Soundsheets = {
	["sfx1"] = {
		SoundId = "rbxassetid://443752838";
		Tracks = {
			["amb_bank_air_conditioner"] = {Start = 0.1; Duration = 3.240;};
			["beep"] =                     {Start = 3.5; Duration = 0.215;};
			["button9"] =                  {Start = 4.0; Duration = 0.275;};
			["combine_button3"] =          {Start = 4.5; Duration = 0.745;};
			["deep_boil"] =  			   {Start = 5.5; Duration = 5.510;};
			["fire_med_loop1"] = 		   {Start = 11.2; Duration = 15.74623;};
			["force_field_loop1"] = 	   {Start = 16.0; Duration = 2.520;};
			["heartbeatloop"] = 		   {Start = 18.7; Duration = 0.715;};
			["jet_flyby_02"] = 			   {Start = 19.7; Duration = 8.4825;};
			["lap_loop1"] =                {Start = 28.5; Duration = 3.4375;};
			["lever7"] =                   {Start = 32.1; Duration = 0.250;};
			["light_power_on_switch_01"] = {Start = 32.5; Duration = 4.515;};
			["pipes_active_loop"] =        {Start = 37.2; Duration = 7.230;};
			["pl_drown1"] =                {Start = 44.8; Duration = 0.845;};
			["pl_fallpain1"] =             {Start = 45.9; Duration = 0.4625;};
			["steam_loop1"] =              {Start = 46.6; Duration = 2.136;};
		};
	}
}






--Bullet hit flecks for different materials
eng.fleks = {
	["tile"] = {
		"http://www.roblox.com/asset/?id=313873049";
		"http://www.roblox.com/asset/?id=313873050";
		"http://www.roblox.com/asset/?id=313873056";
		"http://www.roblox.com/asset/?id=313873057";
		"http://www.roblox.com/asset/?id=313873060";
		"http://www.roblox.com/asset/?id=313873061";
		"http://www.roblox.com/asset/?id=313873062";
		"http://www.roblox.com/asset/?id=313873065";
		"http://www.roblox.com/asset/?id=313873069";
		"http://www.roblox.com/asset/?id=313873070";
		"http://www.roblox.com/asset/?id=313873074";
		"http://www.roblox.com/asset/?id=313873075";
		"http://www.roblox.com/asset/?id=313873079";
	};
	["cardboard"] = {
		"http://www.roblox.com/asset/?id=313873215";
		"http://www.roblox.com/asset/?id=313873214";
		"http://www.roblox.com/asset/?id=313873217";
		"http://www.roblox.com/asset/?id=313873219";
	};
	["concrete"] = {
		"http://www.roblox.com/asset/?id=313873245";
		"http://www.roblox.com/asset/?id=313873247";
		"http://www.roblox.com/asset/?id=313873249";
		"http://www.roblox.com/asset/?id=313873248";
		"http://www.roblox.com/asset/?id=313873251";
	};
	["metal"] = {
		"http://www.roblox.com/asset/?id=313873318";
		"http://www.roblox.com/asset/?id=313873317";
		"http://www.roblox.com/asset/?id=313873314";
		"http://www.roblox.com/asset/?id=313873316";
	};
	["wood"] = {
		"http://www.roblox.com/asset/?id=313873613";
		"http://www.roblox.com/asset/?id=313873612";
		"http://www.roblox.com/asset/?id=313873610";
		"http://www.roblox.com/asset/?id=313873611";
	};
	["fabric"] = {
		"http://www.roblox.com/asset/?id=313875613";
		"http://www.roblox.com/asset/?id=313875611";
		"http://www.roblox.com/asset/?id=313875607";
	};
	["glass"] = {
		"http://www.roblox.com/asset/?id=314013718";
		"http://www.roblox.com/asset/?id=314013719";
	}
}


eng.PlayerFootsteps = {
	Concrete = {"http://www.roblox.com/asset/?id=142548009", "http://www.roblox.com/asset/?id=142548001", "http://www.roblox.com/asset/?id=142548015", "http://www.roblox.com/asset/?id=142335214"};
	Cobblestone = {"http://www.roblox.com/asset/?id=142548009", "http://www.roblox.com/asset/?id=142548001", "http://www.roblox.com/asset/?id=142548015", "http://www.roblox.com/asset/?id=142335214"};
	Metal = {"http://www.roblox.com/asset/?id=178711774";};
	CorrodedMetal = {"http://www.roblox.com/asset/?id=178711762";};
	DiamondPlate = {"http://www.roblox.com/asset/?id=145180178";};
	Foil = {"http://www.roblox.com/asset/?id=145180178";};
	Grass = {"http://www.roblox.com/asset/?id=145180183";};
	Ice = {"http://www.roblox.com/asset/?id=145180170";};
	Plastic = {"http://www.roblox.com/asset/?id=142548009", "http://www.roblox.com/asset/?id=142548001", "http://www.roblox.com/asset/?id=142548015", "http://www.roblox.com/asset/?id=142335214"};
	SmoothPlastic = {"http://www.roblox.com/asset/?id=145180170";};
	Slate = {"http://www.roblox.com/asset/?id=142548009", "http://www.roblox.com/asset/?id=142548001", "http://www.roblox.com/asset/?id=142548015", "http://www.roblox.com/asset/?id=142335214"};
	Wood = {"http://www.roblox.com/asset/?id=178711820";};
	WoodPlanks = {"http://www.roblox.com/asset/?id=178711820";};
	Water = {"http://www.roblox.com/asset/?id=178711791";};
	Snow = {"http://www.roblox.com/asset/?id=145536125";};
	Brick = {"http://www.roblox.com/asset/?id=142548009", "http://www.roblox.com/asset/?id=142548001", "http://www.roblox.com/asset/?id=142548015", "http://www.roblox.com/asset/?id=142335214"};
	Sand = {"http://www.roblox.com/asset/?id=145180183"};
	Fabric = {"http://www.roblox.com/asset/?id=133705377";};
	Granite = {"http://www.roblox.com/asset/?id=142548009", "http://www.roblox.com/asset/?id=142548001", "http://www.roblox.com/asset/?id=142548015", "http://www.roblox.com/asset/?id=142335214"};
	Marble = {"http://www.roblox.com/asset/?id=142548009", "http://www.roblox.com/asset/?id=142548001", "http://www.roblox.com/asset/?id=142548015", "http://www.roblox.com/asset/?id=142335214"};
	Pebble = {"http://www.roblox.com/asset/?id=142548009", "http://www.roblox.com/asset/?id=142548001", "http://www.roblox.com/asset/?id=142548015", "http://www.roblox.com/asset/?id=142335214"};
}


local defaultHitParticle = {
		Smoke = true;
		Fleks = true;
		Type = "Emit";
		NumP = 1;
		DurP = 0;
		NumF = {3, 6};
		EmId = "";
};

eng.BulletHitParticleData = {
	["concrete"] = defaultHitParticle;
	["metal"] = {
		Smoke = true;
		Fleks = false;
		Type = "Emit";
		NumP = 15;
		DurP = 0;
		NumF = {3, 6};
		EmId = "BulletSparkEmitter";
	};
	["wood"] = {
		Smoke = false;
		Fleks = true;
		Type = "Emit";
		NumP = 1;
		DurP = 0;
		NumF = {3, 6};
		EmId = "";
	};
	["glass"] = defaultHitParticle;
	["dirt"] = defaultHitParticle;
	["tile"] = defaultHitParticle;
	["flesh"] = {
		Smoke = false;
		Fleks = false;
		Type = "Emit";
		NumP = 3;
		DurP = 0;
		NumF = {3, 6};
		EmId = "BloodEmitter_Splash";
	};
	["snow"] = {
		Smoke = true;
		Fleks = false;
		Type = "Emit";
		NumP = 1;
		DurP = 0;
		NumF = {3, 6};
		EmId = "";
	};
	["fabric"] = defaultHitParticle;
	["grass"] = defaultHitParticle;
	["water"] = {
		Smoke = false;
		Fleks = false;
		Type = "Enable";
		NumP = 1;
		DurP = 0.125;
		NumF = {3, 6};
		EmId = "WaterSplashEmitter";
	};
}







eng.Textures = {
	["wall_brick_white"] = "http://www.roblox.com/asset/?id=185546217";
	["floor_metal_tile"] = "http://www.roblox.com/asset/?id=172192490";
	["wall_metal_grate"] = "http://www.roblox.com/asset/?id=172192540";
	["wall_scifi_metal"] = "http://www.roblox.com/asset/?id=172192560";
	["ceil_plaster_tile"] = "http://www.roblox.com/asset/?id=172192511";
	["door_scp_left"] = "http://www.roblox.com/asset/?id=128743810";
	["door_scp_right"] = "http://www.roblox.com/asset/?id=128743798";	
}


eng.Spritesheets = {
	["test"] = {size=64, tiles=16, id="http://www.roblox.com/asset/?id=184681878"},
	["fire"] = {size=64, tiles=16, id="http://www.roblox.com/asset/?id=184681880"},
	["smoke"] = {size=128, tiles=2, id="http://www.roblox.com/asset/?id=184681886"},
	["blood"] = {size=64, tiles=3, id="http://www.roblox.com/asset/?id=184681875"}
}

eng.Smokesprites = {
	"http://www.roblox.com/asset/?id=185041571",
	"http://www.roblox.com/asset/?id=185041566",
	"http://www.roblox.com/asset/?id=185041565",
	"http://www.roblox.com/asset/?id=185041562",
	"http://www.roblox.com/asset/?id=185041549"
}
--[[
eng.Gibs = {
	["concrete"] = game.ReplicatedStorage.Orakel.Models.Gibs.gib_concrete,
	["metal"] = game.ReplicatedStorage.Orakel.Models.Gibs.gib_metal,
	["wood"] = game.ReplicatedStorage.Orakel.Models.Gibs.gib_wood,
	["glass"] = game.ReplicatedStorage.Orakel.Models.Gibs.gib_glass,
	["dirt"] = game.ReplicatedStorage.Orakel.Models.Gibs.gib_dirt,
	["tile"] = game.ReplicatedStorage.Orakel.Models.Gibs.gib_tile,
	["flesh"] = game.ReplicatedStorage.Orakel.Models.Gibs.gib_flesh,
	["snow"] = game.ReplicatedStorage.Orakel.Models.Gibs.gib_snow,
	["fabric"] = game.ReplicatedStorage.Orakel.Models.Gibs.gib_fabric,
	["grass"] = game.ReplicatedStorage.Orakel.Models.Gibs.gib_grass
}
]]
eng.ParticleGibs = {
  


}

--Dust mote particles
eng.Particles = {
  ["dustmote_burn"] = "http://www.roblox.com/asset/?id=241751503";
  ["dustmote"] = "http://www.roblox.com/asset/?id=241559211";
}

--Blood particle textures
eng.Blood = {
	["Torso"] = {"http://www.roblox.com/asset/?id=313082866"};
	["Limb"] = {"http://www.roblox.com/asset/?id=313082863"};
}

--bullet hit decals for different materials
eng.Decals = {
	["concrete"] = {
		"http://www.roblox.com/asset/?id=141998923",
		"http://www.roblox.com/asset/?id=141998929",
		"http://www.roblox.com/asset/?id=141998897",
		"http://www.roblox.com/asset/?id=141998951",
		"http://www.roblox.com/asset/?id=141998944"
	},
	["metal"] = {
		"http://www.roblox.com/asset/?id=141998965",
		"http://www.roblox.com/asset/?id=141998976"
	},
	["wood"] = {
		"http://www.roblox.com/asset/?id=325331664";
		"http://www.roblox.com/asset/?id=325331659";
		"http://www.roblox.com/asset/?id=325331660";
		"http://www.roblox.com/asset/?id=325331654";
		"http://www.roblox.com/asset/?id=325331655";
	},
	["glass"] = {
		"http://www.roblox.com/asset/?id=142081271",
		"http://www.roblox.com/asset/?id=142081276",
		"http://www.roblox.com/asset/?id=142081279"
	},
	["dirt"] = {
		"http://www.roblox.com/asset/?id=142186664",
		"http://www.roblox.com/asset/?id=142186677"
	},
	["tile"] = {
		"http://www.roblox.com/asset/?id=143590273",
		"http://www.roblox.com/asset/?id=143590281",
		"http://www.roblox.com/asset/?id=143590284",
		"http://www.roblox.com/asset/?id=143590290",
		"http://www.roblox.com/asset/?id=143590268"
	},
	["flesh"] = {
		"http://www.roblox.com/asset/?id=156459241",
		"http://www.roblox.com/asset/?id=156459246"
	},
	["snow"] = {
		"http://www.roblox.com/asset/?id=142186664",
		"http://www.roblox.com/asset/?id=142186677"
	},
	["fabric"] = {
		"http://www.roblox.com/asset/?id=142186664",
		"http://www.roblox.com/asset/?id=142186677"
	},
	["grass"] = {
		"http://www.roblox.com/asset/?id=142186664",
		"http://www.roblox.com/asset/?id=142186677"
	};
	["water"] = {
		"";
	};
}

--bullet impact sounds for different materials
eng.Sounds.Impact = {
	["concrete"] = "http://www.roblox.com/asset/?id=142082166",
	["metal"] = "http://www.roblox.com/asset/?id=142082170",
	["wood"] = "http://www.roblox.com/asset/?id=142082171",
	["glass"] = "http://www.roblox.com/asset/?id=142082167",
	["dirt"] = "http://www.roblox.com/asset/?id=142082166",
	["tile"] = "http://www.roblox.com/asset/?id=142082166",
	["flesh"] = "http://www.roblox.com/asset/?id=144884872",
	["snow"] = "http://www.roblox.com/asset/?id=142082166",
	["fabric"] = "http://www.roblox.com/asset/?id=142082166",
	["grass"] = "http://www.roblox.com/asset/?id=142082166",
	["water"] = "http://www.roblox.com/asset/?id=325343416"
}


eng.Sounds.WaterImpact = {
	["small"] = "http://www.roblox.com/asset/?id=142431247",
	["large"] = "http://www.roblox.com/asset/?id=137304720",
}

eng.Sounds.Door = {
	["metal_door_open"] = "http://www.roblox.com/asset/?id=144467622";
	["metal_door_close"] = "http://www.roblox.com/asset/?id=144467617";
	["metal_large_start"] = "";
	["metal_large_move"] = "";
	["garage_move"] = "http://www.roblox.com/asset/?id=315064424";
	["garage_stop"] = "http://www.roblox.com/asset/?id=315102223";--"http://www.roblox.com/asset/?id=219648962";
	["drawbridge_move"] = "http://www.roblox.com/asset/?id=219648765";
	["drawbridge_stop"] = "http://www.roblox.com/asset/?id=219650752";
}

eng.Sounds.Alarm = {
	["klaxon1"] = "http://www.roblox.com/asset/?id=145453683";
	["siren"] = "http://www.roblox.com/asset/?id=164450351";
}

eng.Sounds.Button = {
	["Beep"] = "http://www.roblox.com/asset/?id=142638577";
	["Click"] = "http://www.roblox.com/asset/?id=156286438";
	["Switch"] = "http://www.roblox.com/asset/?id=154904310";
	["Invalid"] = "http://www.roblox.com/asset/?id=219914630";
}

eng.Sounds.Spark = {
	["spark1"] = "http://www.roblox.com/asset/?id=184211520",
	["spark2"] = "http://www.roblox.com/asset/?id=184211507",
	["spark3"] = "http://www.roblox.com/asset/?id=184211494",
	["spark4"] = "http://www.roblox.com/asset/?id=157325701", --zap long
	["spark5"] = "http://www.roblox.com/asset/?id=177862373",
	["spark6"] = "http://www.roblox.com/asset/?id=177862344"
}

--Object destruction sounds for different materials
eng.Sounds.Destroy = {
	["concrete"] = "http://www.roblox.com/asset/?id=142082166",
	["metal"] = "http://www.roblox.com/asset/?id=132758217",
	["wood"] = "http://www.roblox.com/asset/?id=142082171",
	["glass"] = "http://www.roblox.com/asset/?id=144884907",
	["dirt"] = "http://www.roblox.com/asset/?id=142082166",
	["tile"] = "http://www.roblox.com/asset/?id=142082166",
	["flesh"] = "http://www.roblox.com/asset/?id=142082166",
	["snow"] = "http://www.roblox.com/asset/?id=142082166",
	["fabric"] = "http://www.roblox.com/asset/?id=142082166",
	["grass"] = "http://www.roblox.com/asset/?id=142082166"
}

eng.Sounds.Explosion = {
	["c4"] = "http://www.roblox.com/asset/?id=133680244",
	["crumble"] = "http://www.roblox.com/asset/?id=134854740",
	["grenade"] = "http://www.roblox.com/asset/?id=142070127"
}

	-- ["concrete"] = {
	-- 	"http://www.roblox.com/asset/?id=142335214",
	-- 	"http://www.roblox.com/asset/?id=142548009",
	-- 	"http://www.roblox.com/asset/?id=142548015",
	-- 	"http://www.roblox.com/asset/?id=142548001"
	-- },


--player footstep sounds for different materials
eng.Player.Sounds = {
	["concrete"] = "http://www.roblox.com/asset/?id=142335214",
	["metal"] = "http://www.roblox.com/asset/?id=145180178",
	["wood"] = "rbxasset://sounds/woodgrass3.ogg",
	["glass"] = "http://www.roblox.com/asset/?id=145180170",
	["dirt"] = "http://www.roblox.com/asset/?id=145180183",
	["tile"] = "http://www.roblox.com/asset/?id=142335214",
	["flesh"] = "http://www.roblox.com/asset/?id=142335214",
	["snow"] = "http://www.roblox.com/asset/?id=19326880",
	["jump"] = "http://www.roblox.com/asset/?id=130778269",
	["ladder"] = "http://www.roblox.com/asset/?id=145180175",
	["fabric"] = "http://www.roblox.com/asset/?id=133705377",
	["grass"] = "http://www.roblox.com/asset/?id=16720281"
}

eng.Sounds.Misc = {
	["electric_buzz"] = "rbxassetid://405691050";
}

--Player hurt sounds for different types of damage
eng.Player.Hurt = {
	["FREEZE"] = "http://www.roblox.com/asset/?id=268249319";
	["BURN"] = "http://www.roblox.com/asset/?id=220194580";
	["FALL"] = "http://www.roblox.com/asset/?id=220194573";
	["DROWN"] = "http://www.roblox.com/asset/?id=220194561";
	["BLAST"] = "http://www.roblox.com/asset/?id=220194573";
	["BULLET"] = "http://www.roblox.com/asset/?id=144884872";
	["DEATH"] = {
		"http://www.roblox.com/asset/?id=132236792";
		"http://www.roblox.com/asset/?id=132236803";
	}
}

eng.HurtSounds = {
	HurtHuman = {"rbxassetid://132236768", "rbxassetid://132236764", "rbxassetid://132236747"};
	DieHuman = {"rbxassetid://132236792", "rbxassetid://132236803"};
	
	HurtHumanFemale = {"rbxassetid://"};
	DieHumanFemale = {"rbxassetid://"};
	
	HurtRobot = {"rbxassetid://"};
	DieRobot = {"rbxassetid://"};
}

eng.RealMaterial = {
	Names = {
		["snow"] = {"snow"};
		["flesh"] = {"head", "right arm", "left arm", "right leg", "left leg", "torso", "flesh"};
		["water"] = {"water"};
	};
	Mats = {
		["fabric"] = {Enum.Material.Fabric};
		["concrete"] = {Enum.Material.Concrete, Enum.Material.Slate, Enum.Material.Granite, Enum.Material.Pebble, Enum.Material.Plastic, Enum.Material.Cobblestone};
		["tile"] = {Enum.Material.Brick, Enum.Material.Marble};
		["glass"] = {Enum.Material.Ice, Enum.Material.SmoothPlastic, Enum.Material.Neon};
		["metal"] = {Enum.Material.CorrodedMetal, Enum.Material.DiamondPlate, Enum.Material.Foil, Enum.Material.Metal};
		["wood"] = {Enum.Material.Wood, Enum.Material.WoodPlanks};
		["dirt"] = {Enum.Material.Sand};
		["grass"] = {Enum.Material.Grass};
		["water"] = {Enum.Material.Water};
	};
	
	IsPartOf = function(self, val, tab)
		for k, v in pairs(tab) do
			if v == val then
				return true
			end
		end
		return false
	end;
	
	Get = function(self, p)
		local mat, nam
		local isPart = pcall(function() local a = p.BrickColor end)
		local isMat = string.find(tostring(p), "Enum.")
		if isMat ~= nil then
			mat = p
			nam = ""
		elseif isPart then
			mat = p.Material
			nam = p.Name
		else
			mat = p
			nam = ""
		end
		
		if self:IsPartOf(nam:lower(), self.Names["snow"]) then
			return "snow"
		elseif self:IsPartOf(nam:lower(), self.Names["water"]) then
			return "water"
		elseif self:IsPartOf(nam:lower(), self.Names["flesh"]) then
			return "flesh"
		end
		for real, enumTab in pairs(self.Mats) do
			for _, enum in pairs(enumTab) do
				if mat == enum then
					return real
				end
			end
		end
		return nil
	end;
}


return eng