include("Scripts/Objects/CLPlaceableObject.lua")

-------------------------------------------------------------------------------
if (RubberTree == nil) then
	RubberTree = CLPlaceableObject.Subclass("RubberTree")
	
end
	RubberTree.CLConnectors = {}
	RubberTree.CLConnectors["Bottom"] = { pos = vec3.new(0,1.1,0), rotation = quat.new(0.707107,-0.707107,0,0), opposite = quat.new(0.707107,0.707107,0,0), types = {"liquidDropOut"}}
	--RubberTree.Passive = true


-------------------------------------------------------------------------------
function RubberTree:Constructor(args)
	self:Mixin(ConnectorInterface, args)
end

-------------------------------------------------------------------------------
function RubberTree:Spawn()
end

-------------------------------------------------------------------------------
function RubberTree:Update(dt)
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(RubberTree)
