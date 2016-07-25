#include <GLUT/glut.h>
#include <OpenGL/gl.h>
#include <string.h>
#include <math.h>
#include <luajit.h>
#include <lauxlib.h>
#include <lualib.h>
#include <stdlib.h>
#include <stdbool.h>

lua_State *L;

#define SCREEN_WIDTH 1000
#define SCREEN_HEIGHT 750

int lf_display, lf_drag, lf_click, lf_keypress;
void luacall(int args);

void glut_setup(int argc, char *argv[]);
void glut_run();

bool lua_bootstrap(const char *path);

void bspline_bootstrap();
