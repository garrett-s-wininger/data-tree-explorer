#include <locale.h>
#include <ncurses.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

void run(void) {
    // Screen initialization
    setlocale(LC_ALL, "");
    initscr();

    // Terminal configuration
    cbreak();
    noecho();
    noqiflush();
    keypad(stdscr, TRUE);

    // Main loop
    printw("Hello world!");
    
    while (TRUE) {
        const chtype input_char = getch();
        const char * const translated_key = keyname(input_char);
        const char * const vim_quit = "q";
        
        if (translated_key) {
            if (strncmp(translated_key, vim_quit, 3) == 0) {
                break;
            }
        }
    }

    // Cleanup
    endwin();
}
