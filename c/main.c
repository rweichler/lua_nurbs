#include "global.h"

int main(int argc, char *argv[])
{
    glut_setup(argc, argv);
    bool success = lua_bootstrap("lua/init.lua");
    if(!success) {
        return 1;
    }
    glut_run();

    return 0;
}
