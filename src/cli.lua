-- cli.lua (or embed into hbsd-update.lua)

local function usage(out)
    out = out or io.stdout
    out:write([[
OPTIONS:
    -4              Force IPv4
    -6              Force IPv6
    -b BEname       Install updates to ZFS Boot Environment <BEname>
    -C              Check the current local and remote version
    -c config       Use a non-default config file
    -d              Do not use DNSSEC validation
    -f              Fetch only
    -F              Download only
    -h              Show this help screen
    -I              Interactively remove obsolete files
    -i              Ignore version check
    -j jailname     Install updates to jail <jailname>
    -K backupkern   Backup the previous kernel to <backupkern>
    -k kernel       Use kernel <kernel>
    -m              JSON output of version (requires -C)
    -n              Do not install kernel
    -o              Do not remove obsolete files/directories
    -R              Use system nameserver for the DNS-based version check
    -r path         Bootstrap root directory <path>
    -s              Install sources (if present)
    -t tmpdir       Temporary directory (example: /root/tmp)
    -U              Allow unsigned updates
    -v version      Use a different version
    -V              Verbose output
]])
end

local function die(msg, code)
    io.stderr:write("hbsd-update: " .. msg .. "\n")
    io.stderr:write("Try 'hbsd-update -h' for help.\n")
    os.exit(code or 1)
end

local function parse_args(argv)
    local opts = {
        -- defaults (match your config defaults / behavior)
        force_ipv4 = false,
        force_ipv6 = false,
        be_name = nil,
        check_version = false,   -- -C
        config_path = "/etc/hbsd-update.conf",
        no_dnssec = false,       -- -d
        fetch_only = false,      -- -f
        download_only = false,   -- -F
        interactive_obsolete = false, -- -I
        ignore_version = false,  -- -i
        jail_name = nil,
        backupkern = nil,
        kernel = nil,            -- overrides config kernel
        json = false,            -- -m
        no_kernel = false,       -- -n
        no_obsolete_rm = false,  -- -o
        system_nameserver = false, -- -R
        bootstrap_root = nil,    -- -r
        install_sources = false, -- -s
        tmpdir = nil,            -- -t
        allow_unsigned = false,  -- -U
        version = nil,           -- -v
        verbose = false,         -- -V
        help = false,            -- -h
    }

    local positional = {}

    -- which flags require a value
    local needs_value = {
        b = "be_name",
        c = "config_path",
        j = "jail_name",
        K = "backupkern",
        k = "kernel",
        r = "bootstrap_root", -- mountpoint
        t = "tmpdir",
        v = "version",
    }

    -- flags that are boolean
    local bool_flag = {
        ["4"] = function() opts.force_ipv4 = true end,
        ["6"] = function() opts.force_ipv6 = true end,
        C = function() opts.check_version = true end,
        d = function() opts.no_dnssec = true end,
        f = function() opts.fetch_only = true end,
        F = function() opts.download_only = true end,
        h = function() opts.help = true end,
        I = function() opts.interactive_obsolete = true end,
        i = function() opts.ignore_version = true end,
        m = function() opts.json = true end,
        n = function() opts.no_kernel = true end,
        o = function() opts.no_obsolete_rm = true end,
        R = function() opts.system_nameserver = true end,
        s = function() opts.install_sources = true end,
        U = function() opts.allow_unsigned = true end,
        V = function() opts.verbose = true end,
    }

    local i = 1
    while i <= #argv do
        local a = argv[i]

        if a == "--" then
            -- rest are positional
            for j = i + 1, #argv do
                positional[#positional + 1] = argv[j]
            end
            break
        end

        if a:sub(1, 1) ~= "-" or a == "-" then
            positional[#positional + 1] = a
            i = i + 1
        else
            -- handle short options, possibly bundled: -CFV or -c/etc/file
            local s = a:sub(2)
            local k = 1
            while k <= #s do
                local opt = s:sub(k, k)

                -- value-taking option?
                local field = needs_value[opt]
                if field then
                    local attached = s:sub(k + 1) -- rest of the same argv token
                    local val
                    if attached ~= "" then
                        val = attached
                        k = #s -- consume remainder
                    else
                        i = i + 1
                        if i > #argv then
                            die("option -" .. opt .. " requires an argument", 2)
                        end
                        val = argv[i]
                    end
                    opts[field] = val
                    break -- done with this token (value consumed)
                end

                -- boolean option?
                local fn = bool_flag[opt]
                if fn then
                    fn()
                else
                    die("unknown option: -" .. opt, 2)
                end

                k = k + 1
            end

            i = i + 1
        end
    end

    -- post-parse validation and normalization

    if opts.force_ipv4 and opts.force_ipv6 then
        die("cannot use -4 and -6 together", 2)
    end

    if opts.json and not opts.check_version then
        die("-m requires -C", 2)
    end

    if opts.fetch_only and opts.download_only then
        die("cannot use -f and -F together", 2)
    end

    return opts, positional
end

return {
    parse_args = parse_args,
    usage = usage,
}

