include("Scripts/Objects/CLPlaceableObject.lua")

-------------------------------------------------------------------------------
if (ElevatorTop == nil) then
	ElevatorTop = CLPlaceableObject.Subclass("ElevatorTop")
end
	ElevatorTop.CLConnectors = {}
	ElevatorTop.CLConnectors["Bottom"] = { pos = vec3.new(0,0.428,0), rotation = quat.new(0.707107,-0.707107,0,0), opposite = quat.new(0.707107,0.707107,0,0), types = {"itemLogicalIn"}}

-------------------------------------------------------------------------------
function ElevatorTop:Constructor(args)
	self:Mixin(ConnectorInterface, args)
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(ElevatorTop)
