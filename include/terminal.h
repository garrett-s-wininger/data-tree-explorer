#include <locale.h>
#include <ncurses.h>
#include <stdio.h>

enum OutputColorPair {
    DEFAULT_COLORS = 0,
    NULL_COLORS
};

void init(void) {
    // Screen initialization
    setlocale(LC_ALL, "");
    initscr();

    // Color configuration
    if (has_colors() == FALSE) {
        fprintf(
            stderr,
            "[WARN] No color support detected on terminal.\n"
        );
    } else {
        start_color();
        init_pair(NULL_COLORS, COLOR_RED, COLOR_BLACK);
    }

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

void print(const char *data, enum OutputColorPair output_color_pair) {
    if (has_colors() == TRUE && output_color_pair != DEFAULT_COLORS) {
        attron(COLOR_PAIR(output_color_pair));
    }

    printw(data);

    if (has_colors() == TRUE && output_color_pair != DEFAULT_COLORS) {
        attroff(COLOR_PAIR(output_color_pair));
    }

    refresh();
}
