-- SteamPower

-------------------------------------------------------------------------------
if SteamPower == nil then
	SteamPower = EternusEngine.ModScriptClass.Subclass("SteamPower")
end

-------------------------------------------------------------------------------
function SteamPower:Constructor(  )
	CL.println("TUG SteamPower:Constructor")
end

 -------------------------------------------------------------------------------
 -- Called once from C++ at engine initialization time
function SteamPower:Initialize()
	CL.println("TUG SteamPower:Initialize")

	Eternus.GameState:RegisterSlashCommand("SteamPower", self, "Info")
	
	CL.println("TUG SteamPower:Initialize Archetypes")
	
	-- Parse archetypes
	Eternus.CraftingSystem:ParseArchetypesFile("Data/Archetypes/SteamPower.txt")
	
	CL.println("TUG SteamPower:Initialize Crafting")

	Eternus.CraftingSystem:ParseRecipeFile("Data/Crafting/Steampower_Components.txt", "SteamPower")
	Eternus.CraftingSystem:ParseRecipeFile("Data/Crafting/Steampower_Crafting Stations.txt", "SteamPower")
	Eternus.CraftingSystem:ParseRecipeFile("Data/Crafting/Steampower_Frames.txt", "SteamPower")
	Eternus.CraftingSystem:ParseRecipeFile("Data/Crafting/Steampower_PlasterCasts.txt", "SteamPower")
	Eternus.CraftingSystem:ParseRecipeFile("Data/Crafting/Steampower_PotteryFiring.txt", "SteamPower")
	Eternus.CraftingSystem:ParseRecipeFile("Data/Crafting/Steampower_PotteryWheel.txt", "SteamPower")
	Eternus.CraftingSystem:ParseRecipeFile("Data/Crafting/Steampower_Tools.txt", "SteamPower")
	
end

-------------------------------------------------------------------------------
-- Called from C++ when the current game enters 
function SteamPower:Enter()	
	--CL.println("TUG SteamPower:Enter")
end

-------------------------------------------------------------------------------
-- Called from C++ when the game leaves it current mode
function SteamPower:Leave()
	--CL.println("TUG SteamPower:Leave")
end


-------------------------------------------------------------------------------
-- Called from C++ every update tick
function SteamPower:Process(dt)
	--CL.println("TUG SteamPower:Process")
end


function SteamPower:Info(args)
	CL.println("TUG SteamPower:Info")
end

function SteamPower:ModifyBiomeData(biomeName, biome)
	if biomeName == "SwamplandsBiome" then
		CL.println("Inject into SwamplandsBiome")
		biome.Objects["Rubber Tree"] =
										{
											density = 2,
											minScale = 1.0,
											maxScale = 1.0,
											chance = 0.02
										}
	end
	if (biome and biome.Objects) then
		biome.Objects["Limestone Rock02"] =
										{
											density = 1,
											minScale = 1.0,
											maxScale = 1.0,
											chance = 0.01
										}
		biome.Objects["Limestone Rock04"] =
										{
											density = 1,
											minScale = 1.0,
											maxScale = 1.0,
											chance = 0.01
										}
		biome.Objects["Limestone Rock05"] =
										{
											density = 1,
											minScale = 1.0,
											maxScale = 1.0,
											chance = 0.01
										}
		biome.Objects["Limestone Rock06"] =
										{
											density = 1,
											minScale = 1.0,
											maxScale = 1.0,
											chance = 0.01
										}
	end
end

EntityFramework:RegisterModScript(SteamPower)