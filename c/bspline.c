#include "global.h"

int l_bspline_setup(lua_State *L)
{
    int n_pts = lua_tonumber(L, 1);
    int n_knots = lua_tonumber(L, 2);
    int dim = lua_tonumber(L, 3);

    float *points = malloc(n_pts*dim*sizeof(float));
    float *knots = malloc(n_knots*sizeof(float));

    lua_pushvalue(L, 4); //points table
    for(int i = 0; i < n_pts; i++)
    {
        lua_pushnumber(L, i + 1);
        lua_gettable(L, -2);
        for(int j = 0; j < dim; j++) {
            lua_pushnumber(L, j + 1);
            lua_gettable(L, -2);
            points[i*dim + j] = lua_tonumber(L, -1);
            lua_pop(L, 1);
        }
        lua_pop(L, 1);
    }
    lua_pop(L, 1);

    lua_pushvalue(L, 5); //knots table
    for(int i = 0; i < n_knots; i++) {
        lua_pushnumber(L, i + 1);
        lua_gettable(L, -2);
        knots[i] = lua_tonumber(L, -1);
        lua_pop(L, 1);
    }
    lua_pop(L, 1);

    lua_pushlightuserdata(L, points);
    lua_pushlightuserdata(L, knots);
    return 2;
}

int l_bspline_eval(lua_State *L)
{
    float *points = (float *)lua_touserdata(L, 1);
    float *knots = (float *)lua_touserdata(L, 2);
    int n_pts = lua_tonumber(L, 3);
    int n_knots = lua_tonumber(L, 4);
    int dim = lua_tonumber(L, 5);

    float u = lua_tonumber(L, 6);
    int degree = lua_tonumber(L, 7);

    int k;
    int s = 0;

    for(k = 0; k < n_knots; k++) {
        float uk = knots[k];
        if(u == uk) {
            s++;
        } else if(u < uk) {
            break;
        }
    }
    k--;

    if(s != degree + 1) {
        int first = k - degree;
        int last = k - s;
        int N = last - first + 1;

        int n_result = N * (N + 1)/2;
        float result[n_result * dim];
        memcpy(result, &points[first*dim], N*dim*sizeof(float));

        int lidx = 0;
        int ridx = dim;
        int tidx = N*dim;
        for(int r = 1; r <= degree - s; r++) {
            for(int i = first + r; i <= last; i++) {
                float a = (u - knots[i]);
                a = a/(knots[i + degree - r + 1] - knots[i]);
                for(int j = 0; j < dim; j++) {
                    result[tidx] = (1 - a)*result[lidx] + a*result[ridx];
                    tidx++; lidx++; ridx++;
                }
            }
            lidx = lidx + dim;
            ridx = ridx + dim;
        }

        for(int i = 0; i < dim; i++) {
            lua_pushnumber(L, result[(n_result - 1)*dim + i]);
        }
    } else { // edge case
        int idx;
        if(k != degree && k != n_knots - 1) {
            idx = (k - s)*dim + 1;
        } else {
            idx = 0;
            if(k != degree) {
                idx = (k - s)*dim;
            }
        }

        for(int i = 0; i < dim; i++) {
            lua_pushnumber(L, points[idx*dim + i]);
        }
    }
    return dim;
}

int l_bspline_free(lua_State *L) {
    float *points = lua_touserdata(L, 1);
    float *knots = lua_touserdata(L, 2);

    free(points);
    free(knots);

    return 0;
}

void bspline_bootstrap()
{
    lua_pushcfunction(L, l_bspline_setup);
    lua_setglobal(L, "BSPLINE_SETUP");
    lua_pushcfunction(L, l_bspline_eval);
    lua_setglobal(L, "BSPLINE_EVAL");
    lua_pushcfunction(L, l_bspline_free);
    lua_setglobal(L, "BSPLINE_FREE");
}
