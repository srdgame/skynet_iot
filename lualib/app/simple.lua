local class = require 'middleclass'

local app = class('BASIC_APP_CLASS')

function app:initialize(name, sys, conf)
	self._name = name
	self._sys = sys
	self._conf = conf or {}
	self._api = self._sys:data_api()
	self._log = sys:logger()
end

function app:on_start()
	self._log:trace("Default simple application on_start used.")
end

function app:on_close(reason)
	self._log:trace("Default simple application on_stop used.")
end

local function __map_handler(handler, app, func)
	local f = app[func]
	if f then
		handler[func] = function(...)
			return f(app, ...)
		end
	end
end

function app:_map_handler()
	local handler = {}
	__map_handler(handler, self, 'on_input')
	__map_handler(handler, self, 'on_input_em')
	__map_handler(handler, self, 'on_output')
	__map_handler(handler, self, 'on_output_result')
	__map_handler(handler, self, 'on_command')
	__map_handler(handler, self, 'on_command_result')
	__map_handler(handler, self, 'on_ctrl')
	__map_handler(handler, self, 'on_ctrl_result')
	__map_handler(handler, self, 'on_comm')
	__map_handler(handler, self, 'on_stat')
	__map_handler(handler, self, 'on_event')
	return handler, handler.on_input ~= nil
end

function app:start()
	self._api:set_handler(self:_map_handler())

	--- Set the proper run function
	self.run = self.on_run

	return self:on_start()
end

function app:close(reason)
	return self:on_close(reason)
end

--- Utilities functions
--- Generate unique id, depends on gateway id and hashing from key
function app:gen_sn(key)
	return string.format('%s.%s', self._sys:id(), self._sys:gen_sn(key))
end

return app

