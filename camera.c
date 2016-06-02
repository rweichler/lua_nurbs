#include <stdio.h>
void exit(int);

float pos[3] = {0, 0, 0};

float V_UP[3] = {0, 1, 0};
float V_FORWARD[3] = {0, 0, -1};

static void cross_product(float *result, float *u, float *v)
{
	result[0] = u[1]*v[2] - v[1]*u[2];
	result[1] = -u[0]*v[2] + v[0]*u[2];
	result[2] = u[0]*v[1] - v[0]*u[1];
}

static void set_scale(float *v, float d)
{
    for(int i = 0; i < 3; i++) {
        pos[i] += v[i]*d;
    }
}

void camera_move(char dir, float d)
{
    if(dir == 'x') {
        float cross[3];
        cross_product(cross, V_UP, V_FORWARD);
        set_scale(cross, d);
    } else if(dir == 'y') {
        set_scale(V_UP, d);
    } else if(dir == 'z') {
        set_scale(V_FORWARD, d);
    } else {
        printf("wtf???");
        exit(1);
    }
}
