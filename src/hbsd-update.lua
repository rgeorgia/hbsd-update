local config = require("config")
local log = require("log")

log.set_level("debug")
log.use_file("/var/log/hbsd-update.log")
local status_code = {["ok"] = 0, ["app"] = 1, ["system"] = 2}

config_data, err = config.get_config_data()
if err ~= nil then
	log.err(err)
	log.err("Exiting..." .. status_code.app)
	os.exit(status_code.app)
end

