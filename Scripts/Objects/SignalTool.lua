include("Scripts/Objects/Equipable.lua")
include("Scripts/Mixins/Usable.lua")

-------------------------------------------------------------------------------
SignalTool = Equipable.Subclass("SignalTool")

-------------------------------------------------------------------------------
function SignalTool:Constructor(args)
	self.m_source = nil
end

-------------------------------------------------------------------------------
function SignalTool:SecondaryAction(args)
	if args.targetObj then
		local targetInstace = args.targetObj:NKGetInstance()
		if targetInstace and targetInstace:InstanceOf(SignalInterface) then
			if self.m_source then
				self.m_source:AddSignalListener(targetInstace)
				self.m_source = nil
			else
				self.m_source = targetInstace
			end
		end
		return true
	else
		return false
	end
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(SignalTool)

