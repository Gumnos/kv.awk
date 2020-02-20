#!/usr/bin/awk -f
function usage(msg, err) {
	print msg
	print " kv.awk <storename> <command> [args]" > "/dev/stderr"
	exit err
}

function warn(s) {
	print "WARN: " s > "/dev/stderr"
}

function debug(s) {
	if (DEBUG)
		print "DEBUG: " s > "/dev/stderr"
}

function shift(n) {
	for (i=0; i<ARGC - n; i++) {
		debug("Moving " (i+n) " [" ARGV[i+n] "] to " i " [" ARGV[i] "]")
		ARGV[i] = ARGV[i+n]
	}
	for (; i < ARGC; i++) {
		debug("Deleting " i)
		delete ARGV[i]
	}
	ARGC -= n
}

function dir_exists(d) {
	s = "test -d " d 
	result = !system(s)
	debug("dir_exists: " s "->" result)
	return result
}

function file_exists(d) {
	s = "test -r " d 
	result = !system(s)
	debug("file_exists: " s "->" result)
	return result
}

function mkdir(d) {
	s = "mkdir -p " d
	result = !system(s)
	debug("mkdir: " s "->" result)
	return result
}

function get_loc() {
	d = "HOME" in ENVIRON ? ENVIRON["HOME"] "/.config/kv.awk" : "."
	debug("Storing in " d)
	# make it if it doesn't exist
	if (! dir_exists(d)) {
		mkdir(d)
	}
	return d
}

function read_existing(data, fname) {
	delete data
	if (file_exists(fname)) {
		debug("read_existing: " fname " exists")
		while (getline value < fname) {
			if (value !~ /\t/) continue
			key = toupper(value)
			sub(/\t.*$/, "", key)
			sub(/^ */, "", key)
			if (length(key) == 0) continue
			if (key ~ /^ *[;#]/) continue
			sub(/^[^\t]*\t/, "", value)
			if (length(value) == 0) continue
			debug("KEY: [" key "]")
			debug("VALUE: [" value "]")
			if (key in data) {
				warn("duplicate key [" key "]")
				continue
			}
			data[key] = value
		}
		close(fname)
	}
}

function write_back_out(store) {
	debug("Write back out to " store)
	i = 0
	print "# Key <tab> Value" > store
	for (k in data) {
		print k "\t" data[k] >> store
		++i
	}
	close(store)
	debug("Wrote " i " item(s)")
}

function set() {
	if (ARGC != 2)
		usage("SET takes 2 arguments (key & value)", 1)
	k = toupper(ARGV[0])
	v = ARGV[1]
	if (data[k] == v)
		return 0
	data[k] = v
	return 1
}

function list() {
	debug("LIST")
	for (k in data)
		print k "\t" data[k]
	return 0
}

function get() {
	debug("GET: " s)
	if (ARGC) {
		for (i=0; i<ARGC; i++) {
			k = toupper(ARGV[i])
			if (k in data) print data[k]
		}
	} else {
		list()
	}
	return 0
}

function rm() {
	if (!ARGC)
		usage("RM takes at least argument (key)", 1)
	deleted = 0
	for (i=0; i<ARGC; i++) {
		k = toupper(ARGV[i])
		if (k in data) {
			debug("deleting ["k"]")
			delete data[k]
			++deleted
		}
	}
	debug("Deleted " deleted)
	return deleted > 0
}

function main() {
	DEBUG = tolower(ENVIRON["DEBUG"]) == "y"
	shift(1) # get rid of the awk

	if (ARGC < 1)
		usage("No location specified", 1)

	store = get_loc() "/" ARGV[0] ".txt"
	shift(1)

	if (ARGC < 1)
		usage("Specify command (GET, SET, LIST, DELETE)", 1)
	cmd = tolower(ARGV[0])
	debug("command: " cmd)
	shift(1)

	read_existing(data, store)

	changed = 0
	if (cmd == "add" || cmd == "set") changed = set()
	else if (cmd == "get") get()
	else if (cmd == "list" || cmd == "ls") list()
	else if (cmd == "delete" || cmd == "del" || cmd == "rm") changed = rm()
	else {
		usage("Unknown command: " cmd, 1)
	}
	if (changed)
		write_back_out(store)
	return 0
}

BEGIN{
	exit main()
}
