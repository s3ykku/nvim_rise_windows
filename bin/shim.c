#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    // Увеличим буфер для безопасности
    char cmd[32768] = "zig cc";
    
    for (int i = 1; i < argc; i++) {
        // Пропускаем проблемный флаг таргета, который валит Zig
        if (strstr(argv[i], "-target") || strstr(argv[i], "msvc")) {
            continue;
        }
        
        // Если флаг начинается с '/', меняем его на '-' (для совместимости с Zig)
        if (argv[i][0] == '/') {
            strcat(cmd, " -");
            strcat(cmd, &argv[i][1]);
        } else {
            strcat(cmd, " ");
            strcat(cmd, argv[i]);
        }
    }
    
    return system(cmd);
}