local config = require("config")
local log = require("log")
local cli = require("cli")

log.set_level("debug")
log.use_file("/var/log/hbsd-update.log")

local opts, args = cli.parse_args(arg)
local status_code = {["ok"] = 0, ["app"] = 1, ["system"] = 2}

if opts.help then
    cli.usage(io.stdout)
    os.exit(status_code.ok)
end

-- logging verbosity
if opts.verbose then
    log.set_level("debug")
end

print(opts.no_dnssec)

-- select config file
-- opts.config_path already defaults to /etc/hbsd-update.conf unless overridden by -c
log.info("Using config: " .. opts.config_path)

config_data, err = config.get_config_data()
if err ~= nil then
	log.err(err)
	log.err("Exiting..." .. status_code.app)
	os.exit(status_code.app)
end

os.exit(status_code.ok)
