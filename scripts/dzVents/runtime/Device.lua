local utils = require('Utils')
local Adapters = require('Adapters')

local function Device(domoticz, data)

	local self = {}
	local state
	local adapterManager = Adapters()


	function self.update(...)
		-- generic update method for non-switching devices
		-- each part of the update data can be passed as a separate argument e.g.
		-- device.update(12,34,54) will result in a command like
		-- ['UpdateDevice'] = '<id>|12|34|54'
		local command = self.id
		for i, v in ipairs({ ... }) do
			command = command .. '|' .. tostring(v)
		end

		domoticz.sendCommand('UpdateDevice', command)
	end


	function self.dump()
		domoticz.logDevice(self)
	end


	self['name'] = data.name
	self['id'] = data.id
	self['_data'] = data
	self['baseType'] = data.baseType


	-- process generic first
	adapterManager.genericAdapter.process(self, data, domoticz, utils, adapterManager)

	-- get a specific adapter for the current device
	local adapters = adapterManager.getDeviceAdapters(self)

	for i, adapter in pairs(adapters) do
		utils.log('Processing adapter for ' .. self.name .. ': ' .. adapter.name, utils.LOG_DEBUG)
		adapter.process(self, data, domoticz, utils, adapterManager)
	end

	if (_G.TESTMODE) then
		function self._getUtilsInstance()
			return utils
		end
	end

	return self
end

return Device