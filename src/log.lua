-- log.lua
-- Minimal BSD-style logger for Lua 5.4 (stderr, file, syslog)

local log = {}

-- severity order
local LEVELS = {
    debug = 0,
    info  = 1,
    warn  = 2,
    err   = 3,
}

local level_names = {
    [0] = "DEBUG",
    [1] = "INFO",
    [2] = "WARN",
    [3] = "ERR",
}

-- defaults
local current_level = LEVELS.info
local backend = "stderr"   -- stderr | file | syslog

local logfile = nil
local logfile_path = nil

local syslog_facility = "daemon"

local function timestamp()
    return os.date("%Y-%m-%d %H:%M:%S")
end

local function stderr_log(level, msg)
    io.stderr:write(string.format(
        "[%s] [%s] %s\n",
        timestamp(),
        level_names[level],
        msg
    ))
end

local function file_log(level, msg)
    if not logfile then return end
    logfile:write(string.format(
        "[%s] [%s] %s\n",
        timestamp(),
        level_names[level],
        msg
    ))
    logfile:flush()
end

local function syslog_log(level, msg)
    local pri = ({
        [LEVELS.debug] = "debug",
        [LEVELS.info]  = "info",
        [LEVELS.warn]  = "warning",
        [LEVELS.err]   = "err",
    })[level]

    os.execute(string.format(
        "logger -p %s.%s -- %q",
        syslog_facility,
        pri,
        msg
    ))
end

local function emit(level, msg)
    if level < current_level then
        return
    end

    if backend == "stderr" then
        stderr_log(level, msg)
    elseif backend == "file" then
        file_log(level, msg)
    elseif backend == "syslog" then
        syslog_log(level, msg)
    end
end

-- public API

function log.set_level(name)
    assert(LEVELS[name], "invalid log level: " .. tostring(name))
    current_level = LEVELS[name]
end

function log.use_stderr()
    backend = "stderr"
end

function log.use_file(path)
    assert(path, "log file path required")

    local f, err = io.open(path, "a")
    if not f then
        error("cannot open log file: " .. err)
    end

    logfile = f
    logfile_path = path
    backend = "file"
end

function log.use_syslog(facility)
    backend = "syslog"
    if facility then
        syslog_facility = facility
    end
end

function log.close()
    if logfile then
        logfile:close()
        logfile = nil
        logfile_path = nil
    end
end

function log.debug(msg) emit(LEVELS.debug, msg) end
function log.info(msg)  emit(LEVELS.info,  msg) end
function log.warn(msg)  emit(LEVELS.warn,  msg) end
function log.err(msg)   emit(LEVELS.err,   msg) end

return log

