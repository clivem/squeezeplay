/*
** Copyright 2007 Logitech. All Rights Reserved.
**
** This file is subject to the Logitech Public Source License Version 1.0. Please see the LICENCE file for details.
*/


#include "common.h"
#include "jive.h"


void jive_print_stack(lua_State *L, char *str) {
	int i, n;

	printf("%s:\n", str);

	n = lua_gettop(L);
	for (i=1; i<=n; i++) {
		switch(lua_type(L, i)) {
		case LUA_TNIL:
			printf("\t%i: nil\n", i);
			break;

		case LUA_TNUMBER:
			printf("\t%i: number %f\n", i, lua_tonumber(L, i));
			break;

		case LUA_TBOOLEAN:
			printf("\t%i: boolean %i\n", i, lua_toboolean(L, i));
			break;

		case LUA_TSTRING:
			printf("\t%i: string %s\n", i, lua_tostring(L, i));
			break;

		case LUA_TTABLE:
		case LUA_TFUNCTION:
		case LUA_TUSERDATA:
		case LUA_TTHREAD:
		case LUA_TLIGHTUSERDATA:
			printf("\t%i: %s %p\n", i, lua_typename(L, lua_type(L, i)), lua_topointer(L, i));
			break;
		}
	}
}


int jiveL_getframework(lua_State *L) {
	lua_getglobal(L, "jive");
	lua_getfield(L, -1, "ui");
	lua_getfield(L, -1, "Framework");

	lua_replace(L, -3);
	lua_pop(L, 1);

	return 1;
}


int jive_getmethod(lua_State *L, int index, char *method)  {

	if (lua_isnil(L, index)) {
		return 0;
	}

	lua_getfield(L, index, method);
	if (!lua_isnil(L, -1)) {
		return 1;
	}
	else {
		lua_pop(L, 1);
		return 0;
	}
}


void *jive_getpeer(lua_State *L, int index, JivePeerMeta *peerMeta) {
	void *peer;

	JIVEL_STACK_CHECK_BEGIN(L);

	lua_getfield(L, index, "peer");
	if (lua_isnil(L, -1)) {
		lua_pop(L, 1);

		peer = lua_newuserdata(L, peerMeta->size);
		memset(peer, 0, peerMeta->size);
		
		luaL_newmetatable(L, peerMeta->magic);
		lua_pushcfunction(L, peerMeta->gc);
		lua_setfield(L, -2, "__gc");

		lua_setmetatable(L, -2);
		lua_setfield(L, index, "peer");
	}
	else {
		luaL_checkudata(L, -1, peerMeta->magic);

		peer = lua_touserdata(L, -1);
		lua_pop(L, 1);
	}

	JIVEL_STACK_CHECK_END(L);

	return peer;
}


void jive_torect(lua_State *L, int index, SDL_Rect *rect) {

	JIVEL_STACK_CHECK_BEGIN(L);

	luaL_checktype(L, index, LUA_TTABLE);

	lua_rawgeti(L, index, 1);
	rect->x = luaL_checkinteger(L, -1);
	lua_pop(L, 1);

	lua_rawgeti(L, index, 2);
	rect->y = luaL_checkinteger(L, -1);
	lua_pop(L, 1);

	lua_rawgeti(L, index, 3);
	rect->w = luaL_checkinteger(L, -1);
	lua_pop(L, 1);

	lua_rawgeti(L, index, 4);
	rect->h = luaL_checkinteger(L, -1);
	lua_pop(L, 1);

	JIVEL_STACK_CHECK_END(L);
}


void jive_rect_union(SDL_Rect *a, SDL_Rect *b, SDL_Rect *c) {
	int x0 = MIN(a->x, b->x);
	int y0 = MIN(a->y, b->y);
	int x1 = MAX(a->x + a->w, b->x + b->w);
	int y1 = MAX(a->y + a->h, b->y + b->h);

	c->x = x0;
	c->y = y0;
	c->w = x1-x0;
	c->h = y1-y0;
}


void jive_rect_intersection(SDL_Rect *a, SDL_Rect *b, SDL_Rect *c) {
	int cx0 = a->x;
	int cy0 = a->y;
	int cx1 = a->x + a->w;
	int cy1 = a->y + a->h;

	int bx1 = b->x + b->w;
	int by1 = b->y + b->h;

	if (cx0 < b->x) cx0 = b->x;
	if (cy0 < b->y) cy0 = b->y;
	if (cx1 > bx1) cx1 = bx1;
	if (cy1 > by1) cy1 = by1;

	if (cx1 < cx0 || cy1 < cy0) {
		c->x = 0;
		c->y = 0;
		c->w = 0;
		c->h = 0;
	}
	else {
		c->x = cx0;
		c->y = cy0;
		c->w = cx1 - cx0;
		c->h = cy1 - cy0;
	}
}
