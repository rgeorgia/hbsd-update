-- Environment / global variables

local env_vars = {}

local system_cmd = {
		["AWK"] = "/usr/bin/awk", 
		["BEADM"] = "/usr/local/sbin/beadm",
		["CAT"] = "/bin/cat",
		["CHFLAGS"] = "/bin/chflags",
		["CERTCTL"] = "/usr/sbin/certctl",
		["DRILL"] = "/usr/bin/drill",
		["ETCUPDATE"] = "/usr/sbin/etcupdate",
		["FETCH"] = "/usr/bin/fetch",
		["FIND"] = "/usr/bin/find",
		["GREP"] = "/usr/bin/grep",
		["JLS"] = "/usr/sbin/jls",
		["KLDXREF"] = "/usr/sbin/kldxref",
		["MKTEMP"] = "/usr/bin/mktemp",
		["OPENSSL"] = "/usr/bin/openssl",
		["PWD_MKDB"] = "/usr/sbin/pwd_mkdb",
		["SED"] = "/usr/bin/sed",
		["SHA256"] = "/sbin/sha256",
		["SHA512"] = "/sbin/sha512",
		["SYSCTL"] = "/sbin/sysctl",
		["TAIL"] = "/usr/bin/tail",
		["TAR"] = "/usr/bin/tar",
		["UNBOUND_HOST"] = "/usr/sbin/unbound-host",
}

local dnssec = {
	["dnssec_key"] = "/usr/share/keys/hbsd-update/trusted/dnssec.key"
	["revoke_dir"] = "/usr/share/keys/hbsd-update/revoked"
}


return env_vars
