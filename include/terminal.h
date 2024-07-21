#include <locale.h>
#include <ncurses.h>

void init(void) {
    // Screen initialization
    setlocale(LC_ALL, "");
    initscr();

    // Terminal configuration
    cbreak();
    noecho();
    noqiflush();
    keypad(stdscr, TRUE);

    // Clear sreen
    refresh();
}

void deinit(void) {
    endwin();
}

const char* getInput(void) {
    const chtype input_char = getch();
    return keyname(input_char);
}

void print(const char *data) {
    printw(data);
}
