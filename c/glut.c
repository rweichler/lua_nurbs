#include "global.h"

void glut_display()
{
    glClear(GL_COLOR_BUFFER_BIT);
    glLoadIdentity();

    gluPerspective(45.0f, SCREEN_WIDTH*1.0/SCREEN_HEIGHT, 0.5f, 300000.0f);

    lua_rawgeti(L, LUA_REGISTRYINDEX, lf_display);
    luacall(0);

    glutSwapBuffers();

}

void glut_click(int button, int state, int x, int y)
{
    lua_rawgeti(L, LUA_REGISTRYINDEX, lf_click);
    lua_pushnumber(L, button);
    lua_pushnumber(L, state);
    lua_pushnumber(L, x);
    lua_pushnumber(L, y);
    luacall(4);
}

void glut_hover(int x, int y)
{
}

void glut_drag(int x, int y)
{
    lua_rawgeti(L, LUA_REGISTRYINDEX, lf_drag);
    lua_pushnumber(L, x);
    lua_pushnumber(L, y);
    luacall(2);
}

void glut_keydown(unsigned char key, int x, int y)
{
    lua_rawgeti(L, LUA_REGISTRYINDEX, lf_keypress);
    char str[2] = {key, '\0'};
    lua_pushstring(L, str);
    lua_pushboolean(L, true);
    luacall(2);
}

void glut_keyup(unsigned char key, int x, int y)
{
    lua_rawgeti(L, LUA_REGISTRYINDEX, lf_keypress);
    char str[2] = {key, '\0'};
    lua_pushstring(L, str);
    lua_pushboolean(L, false);
    luacall(2);
}

#define MAP(GLUT, STR) \
    case GLUT:\
    str = STR;\
    break

void glut_special_keyboard(int key, int x, int y)
{
    lua_rawgeti(L, LUA_REGISTRYINDEX, lf_keypress);
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
    } else {
        //send the nice pretty string
        lua_pushstring(L, str);
    }
    lua_pushboolean(L, true);
    luacall(2);
}

void glut_setup(int argc, char *argv[])
{
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_SINGLE);
    glutInitWindowSize(SCREEN_WIDTH, SCREEN_HEIGHT);
    glutInitWindowPosition(0, 0);
    glutCreateWindow("Project 4");

    glutDisplayFunc(glut_display);
    glutMouseFunc(glut_click);
    glutMotionFunc(glut_drag);
    glutPassiveMotionFunc(glut_hover);
    glutKeyboardFunc(glut_keydown);
    glutKeyboardUpFunc(glut_keyup);
    glutSpecialFunc(glut_special_keyboard);
}

void glut_run()
{
    glutMainLoop();
}
