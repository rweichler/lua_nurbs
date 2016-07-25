#include "global.h"

float camera_position[3] = {0, 0, 0};
float camera_rotation[2] = {0, 0}; //pitch and yaw only, no roll

float *l_ffi_camera_position()
{
    return camera_position;
}

float *l_ffi_camera_rotation()
{
    return camera_rotation;
}

void l_ffi_draw_line(float x1, float y1, float z1, float x2, float y2, float z2)
{
    float p[2][3] = {{x1, y1, z1}, {x2, y2, z2}};
    for(int i = 0; i < 2; i++) {
        for(int j = 0; j < 3; j++) {
            p[i][j] -= camera_position[j];
        }
    }

    //rotate left-right
    float a = camera_rotation[0];
    for(int i = 0; i < 2; i++) {
        float x = p[i][0];
        float z = p[i][2];
        p[i][0] = x*cosf(a) - z*sinf(a);
        p[i][2] = x*sinf(a) + z*cosf(a);
    }

    //rotate up-down
    float b = camera_rotation[1];
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

void l_ffi_fill_rect(int x, int y, int width, int height, char r, char g, char b) 
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

void l_ffi_draw_text(const char *str, int x, int y)
{
    glMatrixMode( GL_MODELVIEW );
    glPushMatrix();
    glLoadIdentity();
    glRasterPos2f( 2.0*x/SCREEN_WIDTH - 1, 1 - 20.0/SCREEN_HEIGHT - 2.0*y/SCREEN_HEIGHT);
    for (int i = 0; i < strlen(str); i++) {
        glutBitmapCharacter(GLUT_BITMAP_9_BY_15, str[i]);
    }
    glPopMatrix();
}
