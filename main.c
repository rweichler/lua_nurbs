#include <GLUT/glut.h>
#include <OpenGL/gl.h>
#include <string.h>
#include <math.h>

const unsigned int SCREEN_WIDTH = 800;
const unsigned int SCREEN_HEIGHT = 600;

char buffer[SCREEN_WIDTH*SCREEN_HEIGHT*3];

float camera[3] = {0, 0, 0};
float rotation[2] = {0, 0};

void draw_line(float p1[3], float p2[3])
{
    float p[2][3];
    for(int i = 0; i < 3; i++) {
        p[0][i] = p1[i] - camera[i];
        p[1][i] = p2[i] - camera[i];
    }

    glLineWidth(1);
    glBegin(GL_LINES);
    for(int i = 0; i < 2; i++) {
        glVertex3f(p[i][0], p[i][1], -p[i][2]);
    }
    glEnd();
}

float pos[3];
void move(float p[3])
{
    pos[0] = p[0];
    pos[1] = p[1];
    pos[2] = p[2];
}

void move_and_draw(float p[3])
{
    draw_line(pos, p);
    move(p);
}

#define MOVE(x, y, z) do {\
    p[0] = x; p[1] = y; p[2] = z;\
    move(p);\
} while(0)

#define DRAW(x, y, z) do {\
    p[0] = x; p[1] = y; p[2] = z;\
    move_and_draw(p);\
} while(0)

void glut_display()
{
    glClear(GL_COLOR_BUFFER_BIT);
    glLoadIdentity();

    glDrawPixels(SCREEN_WIDTH, SCREEN_HEIGHT, GL_RGB, GL_UNSIGNED_BYTE, buffer);

    gluPerspective(45.0f,SCREEN_WIDTH/SCREEN_HEIGHT, 0.5f, 300000.0f);
    const float s = 10;

    float p[3];

    MOVE(0, 0, 0);
    glColor3f(1.0, 0.0, 0.0);
    DRAW(0, 0, s);
    DRAW(s, 0, s);
    DRAW(s, 0, 0);
    DRAW(0, 0, 0);

    MOVE(0, s, 0);
    glColor3f(0, 1, 0);
    DRAW(0, s, s);
    DRAW(s, s, s);
    DRAW(s, s, 0);
    DRAW(0, s, 0);

    glColor3f(0, 0, 1);
    DRAW(0, 0, 0);
    MOVE(0, 0, s);
    DRAW(0, s, s);
    MOVE(s, 0, s);
    DRAW(s, s, s);
    MOVE(s, 0, 0);
    DRAW(s, s, 0);

    glutSwapBuffers();
}

void glut_click(int button, int state, int x, int y)
{
}

void glut_hover(int x, int y)
{

}

void glut_drag(int x, int y)
{

}

#define DELTA 1

void glut_keyboard(unsigned char key, int x, int y)
{
    switch(key) {
    case 'w':
        camera[2] += DELTA;
    break;
    case 'a':
        camera[0] -= DELTA;
    break;
    case 's':
        camera[2] -= DELTA;
    break;
    case 'd':
        camera[0] += DELTA;
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
    glut_display();
}

#define ROTATION_DELTA 0.2

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
        rotation[0] += ROTATION_DELTA;
    break;
    case GLUT_KEY_RIGHT:
        rotation[0] -= ROTATION_DELTA;
    break;
    default:
    return;
    }
    if(rotation[1] > M_PI) {
        rotation[1] = M_PI;
    } else if(rotation[1] < -M_PI) {
        rotation[1] = -M_PI;
    }
    while(rotation[0] > 2*M_PI) {
        rotation[0] -= 2*M_PI;
    }
    while(rotation[0] < -2*M_PI) {
        rotation[0] += 2*M_PI;
    }
    glut_display();
}

int main(int argc, char *argv[])
{
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

    glutMainLoop();

    return 0;
}
