use fmt;
use io;
use os::exec;
use os;
use path;
use strings;
use time::chrono;
use time::date;

export fn main() void = {
	const now = date::now();
	let buf: [32]u8 = [0...];
	const now = date::bsformat(buf, "%H:%M:%S", &now)!;

	fmt::printf("[{}] {} ", now, os::hostname())!;

	let cwd = os::getcwd();
	const home = os::getenv("HOME") as str;
	if (cwd == home) {
		fmt::printf("~")!;
		return;
	} else if (cwd == "/") {
		fmt::printf("/")!;
		return;
	} else if (strings::hasprefix(cwd, home)) {
		cwd = strings::sub(cwd, len(home), strings::end);
		fmt::printf("~")!;
	};

	let buf = path::init()!;
	path::set(&buf, cwd)!;

	let iter = path::iter(&buf), nitem = 0z;
	path::nextiter(&iter); // Skip root
	for (path::nextiter(&iter) is str; nitem += 1) void;

	let iter = path::iter(&buf);
	path::nextiter(&iter); // Skip root
	for (let i = 0z; i < nitem; i += 1) {
		const item = path::nextiter(&iter) as str;
		if (i + 1 < nitem) {
			fmt::printf("/{}", strings::sub(item, 0, 1))!;
		} else {
			fmt::printf("/{}", item)!;
		};
	};

	if (is_k8s_path(home)) {
		show_k8s_ctx();
	};
};

fn is_k8s_path(home: str) bool = {
	const cwd = os::getcwd();
	const prefixes = [
		"sources/bikeshed",
		"sources/gensokyo",
	];
	for (const pfx .. prefixes) {
		const path = path::init(home, pfx)!;
		if (strings::hasprefix(cwd, path::string(&path))) {
			return true;
		};
	};
	return false;
};

fn show_k8s_ctx() void = {
	const (rd, wr) = exec::pipe();
	const cmd = match (exec::cmd("kubectl", "config", "current-context")) {
	case let cmd: exec::command =>
		yield cmd;
	case =>
		return;
	};
	exec::addfile(&cmd, os::stdout_file, wr)!;
	const proc = exec::start(&cmd)!;
	io::close(wr)!;
	const data = io::drain(rd)!;
	io::close(rd)!;
	exec::wait(&proc)!;
	const ctx = strings::trim(strings::fromutf8(data)!);
	fmt::printf(" [\x1b[93m{}\x1b[m]", ctx)!;
};

