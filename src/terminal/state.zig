pub const ApplicationState = struct { should_quit: bool, data_lines: u64 };

pub fn quit(state: *ApplicationState) void {
    state.*.should_quit = true;
}
