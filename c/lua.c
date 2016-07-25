#include "global.h"

bool lua_bootstrap(const char *path)
{
    L = luaL_newstate();
    luaL_openlibs(L);

    lua_pushnumber(L, SCREEN_WIDTH);
    lua_setglobal(L, "SCREEN_WIDTH");

    lua_pushnumber(L, SCREEN_HEIGHT);
    lua_setglobal(L, "SCREEN_HEIGHT");

    bspline_bootstrap();

    luaL_loadfile(L, path);
    if(lua_isstring(L, -1)) {
        printf("%s\n", lua_tostring(L, -1));
        return false;
    }
    luacall(0);

    lua_getglobal(L, "display");
    lf_display = luaL_ref(L, LUA_REGISTRYINDEX);

    lua_getglobal(L, "drag");
    lf_drag = luaL_ref(L, LUA_REGISTRYINDEX);

    lua_getglobal(L, "click");
    lf_click = luaL_ref(L, LUA_REGISTRYINDEX);

    lua_getglobal(L, "keypress");
    lf_keypress = luaL_ref(L, LUA_REGISTRYINDEX);

    return true;
}

void luacall(int args)
{
    if(lua_pcall(L, args, 0, 0) != 0) {
        printf("%s\n", lua_tostring(L, -1));
        exit(1);
    }
}
