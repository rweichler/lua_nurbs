#include <GLUT/glut.h>
#include <OpenGL/gl.h>
#include <string.h>
#include <math.h>
#include <luajit.h>
#include <lauxlib.h>
#include <lualib.h>
#include <stdlib.h>
#include "tinyspline.h"

const unsigned int SCREEN_WIDTH = 1024;
const unsigned int SCREEN_HEIGHT = 768;

char buffer[SCREEN_WIDTH*SCREEN_HEIGHT*4];
char black_buffer[SCREEN_WIDTH*SCREEN_HEIGHT*3];

float camera[3] = {0, 0, 0};
float rotation[2] = {0, 0};

lua_State *L;
int lua_display, lua_drag, lua_click, lua_keypress;

float *l_camera()
{
    return camera;
}

float *l_rotation()
{
    return rotation;
}

void luacall(int args, int ret)
{
    if(lua_pcall(L, args, ret, 0) != 0) {
        printf("%s\n", lua_tostring(L, -1));
        exit(1);
    }
}

void draw_line(float p1[3], float p2[3])
{
    float p[2][3];
    for(int i = 0; i < 3; i++) {
        p[0][i] = p1[i] - camera[i];
        p[1][i] = p2[i] - camera[i];
    }

    //rotate left-right
    float a = rotation[0];
    for(int i = 0; i < 2; i++) {
        float x = p[i][0];
        float z = p[i][2];
        p[i][0] = x*cosf(a) - z*sinf(a);
        p[i][2] = x*sinf(a) + z*cosf(a);
    }

    //rotate up-down
    float b = rotation[1];
    for(int i = 0; i < 2; i++) {
        float y = p[i][1];
        float z = p[i][2];
        p[i][1] = y*cosf(b) - z*sinf(b);
        p[i][2] = y*sinf(b) + z*cosf(b);
    }

    glLineWidth(1);
    glBegin(GL_LINES);
    for(int i = 0; i < 2; i++) {
        glVertex3f(p[i][0], p[i][1], -p[i][2]);
    }
    glEnd();
}
void l_draw_line(float x1, float y1, float z1, float x2, float y2, float z2)
{
    float p1[3] = {x1, y1, z1};
    float p2[3] = {x2, y2, z2};
    draw_line(p1, p2);
}

void l_fill_rect(int x, int y, int width, int height, char r, char g, char b) 
{
    glWindowPos2i(x, SCREEN_HEIGHT - y - height);
    char buf[width*height*3];
    for(int i = 0; i < width*height; i++) {
        buf[i*3] = r;
        buf[i*3 + 1] = g;
        buf[i*3 + 2] = b;
    }
    glDrawPixels(width, height, GL_RGB, GL_UNSIGNED_BYTE, buf);
}

void l_draw_text(const char *str, int x, int y)
{
    glWindowPos2i(0, 0);
    glRasterPos2f(0.5, 0.5);
    for(int i = 0; i < strlen(str); i++) {
        glutBitmapCharacter(GLUT_BITMAP_9_BY_15, str[i]);
    }
    //glRasterPos2f(0, 0);
}

void glut_display()
{
    glClear(GL_COLOR_BUFFER_BIT);
    glLoadIdentity();

    glDrawPixels(SCREEN_WIDTH, SCREEN_HEIGHT, GL_RGB, GL_UNSIGNED_BYTE, black_buffer);

    gluPerspective(45.0f, SCREEN_WIDTH*1.0/SCREEN_HEIGHT, 0.5f, 300000.0f);

    lua_rawgeti(L, LUA_REGISTRYINDEX, lua_display);
    luacall(0, 0);

    glutSwapBuffers();

    l_draw_text("FUCK YOU", 0, 0);
}

void glut_click(int button, int state, int x, int y)
{
    lua_rawgeti(L, LUA_REGISTRYINDEX, lua_click);
    lua_pushnumber(L, button);
    lua_pushnumber(L, state);
    lua_pushnumber(L, x);
    lua_pushnumber(L, y);
    luacall(4, 0);
}

void glut_hover(int x, int y)
{
}

void glut_drag(int x, int y)
{
    lua_rawgeti(L, LUA_REGISTRYINDEX, lua_drag);
    lua_pushnumber(L, x);
    lua_pushnumber(L, y);
    luacall(2, 0);
}

void glut_keyboard(unsigned char key, int x, int y)
{
    lua_rawgeti(L, LUA_REGISTRYINDEX, lua_keypress);
    char str[2] = {key, '\0'};
    lua_pushstring(L, str);
    luacall(1, 0);
}

#define MAP(GLUT, STR) \
    case GLUT:\
    str = STR;\
    break

void glut_special_keyboard(int key, int x, int y)
{
    lua_rawgeti(L, LUA_REGISTRYINDEX, lua_keypress);
    const char *str = NULL;
    switch(key) {
        MAP(GLUT_KEY_UP, "up");
        MAP(GLUT_KEY_DOWN, "down");
        MAP(GLUT_KEY_LEFT, "left");
        MAP(GLUT_KEY_RIGHT, "right");
    }

    if(str == NULL) {
        //send the ugly raw key int
        lua_pushnumber(L, key);
        luacall(1, 0);
    } else {
        //send the nice pretty string
        lua_pushstring(L, str);
        luacall(1, 0);
    }
}

float curve_pts[4];
float *l_evaluate_spline(tsBSpline *spline, float u)
{
    tsDeBoorNet net;
    const tsError err = ts_bspline_evaluate(spline, u, &net);
    if (err < 0) {
        luaL_error(L, "%s\n", ts_enum_str(err));
    }

    for(int i = 0; i < spline->dim; i++) {
        curve_pts[i] = net.result[i];
    }

    return curve_pts;
}

int main(int argc, char *argv[])
{
    memset(black_buffer, 0x00, sizeof(black_buffer));
    memset(buffer, 0x00, sizeof(buffer));
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_SINGLE);
    glutInitWindowSize(SCREEN_WIDTH, SCREEN_HEIGHT);
    glutInitWindowPosition(0, 0);
    glutCreateWindow("Project 4");

    glutDisplayFunc(glut_display);
    glutMouseFunc(glut_click);
    glutMotionFunc(glut_drag);
    glutPassiveMotionFunc(glut_hover);
    glutKeyboardFunc(glut_keyboard);
    glutSpecialFunc(glut_special_keyboard);

    L = luaL_newstate();
    luaL_openlibs(L);

    lua_pushnumber(L, SCREEN_WIDTH);
    lua_setglobal(L, "SCREEN_WIDTH");

    lua_pushnumber(L, SCREEN_HEIGHT);
    lua_setglobal(L, "SCREEN_HEIGHT");

    luaL_loadfile(L, "ui.lua");
    if(lua_isstring(L, -1)) {
        printf("%s\n", lua_tostring(L, -1));
        return 1;
    }
    luacall(0, 0);

    lua_getglobal(L, "display");
    lua_display = luaL_ref(L, LUA_REGISTRYINDEX);

    lua_getglobal(L, "drag");
    lua_drag = luaL_ref(L, LUA_REGISTRYINDEX);

    lua_getglobal(L, "click");
    lua_click = luaL_ref(L, LUA_REGISTRYINDEX);

    lua_getglobal(L, "keypress");
    lua_keypress = luaL_ref(L, LUA_REGISTRYINDEX);

    glutMainLoop();

    return 0;
}
