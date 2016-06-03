#include <GLUT/glut.h>
#include <OpenGL/gl.h>
#include <string.h>
#include <math.h>
#include <luajit.h>
#include <lauxlib.h>
#include <lualib.h>

#define DELTA 1
#define ROTATION_DELTA M_PI/24
const unsigned int SCREEN_WIDTH = 800;
const unsigned int SCREEN_HEIGHT = 600;

char buffer[SCREEN_WIDTH*SCREEN_HEIGHT*4];
char black_buffer[SCREEN_WIDTH*SCREEN_HEIGHT*3];

float camera[3] = {DELTA*5, DELTA*5, -DELTA*20};
//float camera[3] = {0, 0, 0};
float rotation[2] = {0, 0};

lua_State *L;
int lua_display, lua_drag, lua_click;


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

void glut_display()
{
    glClear(GL_COLOR_BUFFER_BIT);
    glLoadIdentity();

    glDrawPixels(SCREEN_WIDTH, SCREEN_HEIGHT, GL_RGB, GL_UNSIGNED_BYTE, black_buffer);

    gluPerspective(45.0f,SCREEN_WIDTH/SCREEN_HEIGHT, 0.5f, 300000.0f);

    lua_rawgeti(L, LUA_REGISTRYINDEX, lua_display);
    lua_call(L, 0, 0);

    glutSwapBuffers();
}

void glut_click(int button, int state, int x, int y)
{
    lua_rawgeti(L, LUA_REGISTRYINDEX, lua_click);
    lua_pushnumber(L, button);
    lua_pushnumber(L, state);
    lua_pushnumber(L, x);
    lua_pushnumber(L, y);
    lua_call(L, 4, 0);
}

void glut_hover(int x, int y)
{

}

void glut_drag(int x, int y)
{
    lua_rawgeti(L, LUA_REGISTRYINDEX, lua_drag);
    lua_pushnumber(L, x);
    lua_pushnumber(L, y);
    lua_call(L, 2, 0);
}

void glut_keyboard(unsigned char key, int x, int y)
{
    float a = rotation[0];
    switch(key) {
    case 'w':
        camera[2] += cosf(a)*DELTA;
        camera[0] += sinf(a)*DELTA;
    break;
    case 'a':
        camera[0] -= cosf(a)*DELTA;
        camera[2] += sinf(a)*DELTA;
    break;
    case 's':
        camera[2] -= cosf(a)*DELTA;
        camera[0] -= sinf(a)*DELTA;
    break;
    case 'd':
        camera[0] += cosf(a)*DELTA;
        camera[2] -= sinf(a)*DELTA;
    break;
    case 'r':
        camera[1] += DELTA;
    break;
    case 'f':
        camera[1] -= DELTA;
    break;
    case ' ':
        rotation[0] = 0;
        rotation[1] = 0;
    break;
    default:
    return;
    }
    glutPostRedisplay();
}

void glut_special_keyboard(int key, int x, int y)
{
    switch(key) {
    case GLUT_KEY_UP:
        rotation[1] += ROTATION_DELTA;
    break;
    case GLUT_KEY_DOWN:
        rotation[1] -= ROTATION_DELTA;
    break;
    case GLUT_KEY_LEFT:
        rotation[0] -= ROTATION_DELTA;
    break;
    case GLUT_KEY_RIGHT:
        rotation[0] += ROTATION_DELTA;
    break;
    default:
    return;
    }
    if(rotation[1] > M_PI/2) {
        rotation[1] = M_PI/2;
    } else if(rotation[1] < -M_PI/2) {
        rotation[1] = -M_PI/2;
    }
    while(rotation[0] > 2*M_PI) {
        rotation[0] -= 2*M_PI;
    }
    while(rotation[0] < -2*M_PI) {
        rotation[0] += 2*M_PI;
    }
    glutPostRedisplay();
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
    luaL_dofile(L, "ui.lua");

    lua_getglobal(L, "display");
    lua_display = luaL_ref(L, LUA_REGISTRYINDEX);

    lua_getglobal(L, "drag");
    lua_drag = luaL_ref(L, LUA_REGISTRYINDEX);

    lua_getglobal(L, "click");
    lua_click = luaL_ref(L, LUA_REGISTRYINDEX);

    glutMainLoop();

    return 0;
}
