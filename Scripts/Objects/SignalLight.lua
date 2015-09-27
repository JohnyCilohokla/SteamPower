include("Scripts/Objects/CLPlaceableObject.lua")

-------------------------------------------------------------------------------
SignalLight = CLPlaceableObject.Subclass("SignalLight")

-------------------------------------------------------------------------------
function SignalLight:Constructor(args)
	
	self:Mixin(SignalInterface, nil)
end

-------------------------------------------------------------------------------
function SignalLight:OnSignalChanged(state)
	CL.out("SignalLight:OnSignalChanged( " .. tostring(state) .. " )")
	local light = self:NKGetLight()
	if (light ~= nil) then
		if state then
			light:NKSetRadius(10)
			light:NKSetFlicker(true)
		else
			light:NKSetRadius(0)
			light:NKSetFlicker(false)
		end
	end
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(SignalLight)

