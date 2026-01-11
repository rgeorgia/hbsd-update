-- config.lua

local config = {}

local log = require("log")
log.set_level("debug")
log.use_file("/var/log/hbsd-update.log")

-- file_exists.
function config.file_exists(file_name)
  local f = io.open(file_name, "r") -- Try to open the file in read mode
  return f ~= nil and io.close(f)
end

local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

local function strip_quotes(s)
    return (s:gsub('^"(.*)"$', '%1'))
end

-- Read the /etc/hbsd-update.conf file and populate the table
local function read_hbsd_update_conf(path, config_file)
    local f, err = io.open(path, "r")
    if not f then
        return nil, err
    end
	log.debug("Reading file: " .. path)

    for line in f:lines() do
        line = trim(line)

        -- skip empty lines and comments
        if line ~= "" and not line:match("^#") then
            local key, value = line:match("^([^=]+)=(.+)$")
            if key and value then
                key   = trim(key)
                value = strip_quotes(trim(value))

                -- only override known keys
                if config_file[key] ~= nil then
                    config_file[key] = value
                end
            end
        end
    end

    f:close()
    return true
end

-- log the table data
local function log_config_table(log, tbl, title)
    if title then
        log.info(title)
    end

    -- stable order for readable logs
    local keys = {}
    for k in pairs(tbl) do
        keys[#keys + 1] = k
    end
    table.sort(keys)

    for _, k in ipairs(keys) do
        log.info(string.format("%s=%s", k, tostring(tbl[k])))
    end
end

function config.get_config_data()

		local config_file = {
			dnsrec      = "$(uname -m).master.14-stable.hardened.hardenedbsd.updates.hardenedbsd.org",
			kernel      = "HARDENEDBSD",
			capath      = "/usr/share/keys/hbsd-update/trusted",
			branch      = "hardened/14-stable/master",
			baseurl     = "https://updates.hardenedbsd.org/pub/HardenedBSD/updates/${branch}/$(uname -m)",
			dnssec      = "yes",
			force_ipv4  = "no",
			force_ipv6  = "no",
		}

		local hbsd_update_conf_path = "/etc/hbsd-update.conf"
		local ok, err = read_hbsd_update_conf(hbsd_update_conf_path, config_file)

		if not ok then
			log.debug("/etc/hbsd-update.conf not found: " .. err)
			return nil, err
		end
		log_config_table(log, config_file, "Loaded hbsd-update configuration:")
		
		return config_file, nil
end

return config
