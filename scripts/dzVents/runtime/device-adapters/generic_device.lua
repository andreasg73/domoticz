local Time = require('Time')
local TimedCommand = require('TimedCommand')

-- some states will be 'booleanized'
local function stateToBool(state, _states)
	state = string.lower(state)
	local info = _states[state]
	local b
	if (info) then
		b = _states[state]['b']
	end

	if (b == nil) then b = false end
	return b
end

local function setStateAttribute(state, device, _states)
	local level;
	if (state and string.find(state, 'Set Level')) then
		level = string.match(state, "%d+") -- extract dimming value
		state = 'On' -- consider the device to be on
	end

	if (level) then
		device['level'] = tonumber(level)
	end

	if (state ~= nil) then -- not all devices have a state like sensors
		if (type(state) == 'string') then -- just to be sure
			device['state'] = state
			device['bState'] = stateToBool(state, _states)
		else
			device['state'] = state
		end
	end

	return device
end

return {

	baseType = 'device',

	match = function (device)
		return true -- generic always matches
	end,

	process = function (device, data, domoticz, utils, adapterManager)

		local _states = adapterManager.states

		if (data.baseType == 'device') then

			device['changed'] = data.changed
			device['description'] = data.description
			device['deviceType'] = data.deviceType
			device['hardwareName'] = data.hardwareName
			device['hardwareType'] = data.hardwareType
			device['hardwareId'] = data.hardwareID
			device['hardwareTypeVal'] = data.hardwareTypeValue
			device['switchType'] = data.switchType
			device['switchTypeValue'] = data.switchTypeValue
			device['timedOut'] = data.timedOut
			device['batteryLevel'] = data.batteryLevel
			device['signalLevel'] = data.signalLevel
			device['deviceSubType'] = data.subType
			device['lastUpdate'] = Time(data.lastUpdate)
			device['rawData'] = data.rawData
		end

		if (data.baseType == 'group' or data.baseType == 'scene') then
			device['lastUpdate'] = Time(data.lastUpdate)
			device['rawData'] = { [1] = data.data._state }
		end


		setStateAttribute(data.data._state, device, _states)

		function device.setState(newState)
			-- generic state update method
			return TimedCommand(domoticz, device.name, newState)
		end


		for attribute, value in pairs(data.data) do
			device[attribute] = value
		end

		return device

	end

}