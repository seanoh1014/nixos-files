/* See LICENSE file for copyright and license details. */
#include <X11/XF86keysym.h>

/* appearance */
static const unsigned int borderpx  = 2;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const unsigned int gappih    = 10;       /* horiz inner gap between windows */
static const unsigned int gappiv    = 10;       /* vert inner gap between windows */
static const unsigned int gappoh    = 10;       /* horiz outer gap between windows and screen edge */
static const unsigned int gappov    = 10;       /* vert outer gap between windows and screen edge */
static       int smartgaps          = 1;        /* 1 means no outer gap when there is only one window */
static const int swallowfloating    = 0;        /* 1 means swallow floating windows by default */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const char *fonts[]          = { "FiraCode Nerd Font:size=10:weight=bold:antialias=true", "Symbols Nerd Font:pixelsize=30:autohint:true" };
static const char dmenufont[]       = {"Fira Code:size=10:antialias=true:autohint=true"};
//static const char *upvol[] = { "/usr/bin/amixer","-c0", "set", "Master", "5%+", NULL };
//static const char *downvol[] = { "/usr/bin/amixer","-c0", "set", "Master", "5%-", NULL };
//static const char *mutevol[] = { "/usr/bin/amixer","-c0", "set", "Master", "toggle", NULL };
static const char col_gray1[]       = "#222222";
static const char col_gray2[]       = "#444444";
static const char col_gray3[]       = "#bbbbbb";
static const char col_gray4[]       = "#8BE9FD";
static const char col_gray5[]       = "#44475a";
static const char col_white1[]      = "#eeeeee";
static const char col_cyan[]        = "#6986db";
static const char col_green[]       = "#51ad69"; /*5dc978*/
static const char *colors[][3]      = {
	/*               fg         bg         border   */
	//[SchemeNorm] = { col_gray3, col_gray1, col_gray2 },
	//[SchemeSel]  = { col_white1, col_cyan,  col_gray4 },
	[SchemeNorm] = { col_gray3, col_gray5, col_gray2 },
	[SchemeSel]  = { col_cyan, col_gray5, col_gray4  },
	[SchemeTitle]= { col_gray3, col_gray5,  col_gray2  },
	[SchemeUnderline] = { col_green, col_gray5, col_gray4},
};


/* tagging */
static const char *tags[] = { "   ", "   ", "   ", "  " };
static const char *tagsel[][2] = {
		{ "#7db6e0", "#4e5061" }, //#478061 for void linux, #67b58b
		{ "#a6a6a6", "#4e5061" }, //#a6a6a6 #4078f2
		{ "#bbbbbb", "#4e5061" }, //#f66244 #f73451 #ff6a0f #8261f7
		{ "#f8e9d4", "#4e5061" },
};
static const unsigned int ulinepad	= 5;	/* horizontal padding between the underline and tag */
static const unsigned int ulinestroke	= 2;	/* thickness / height of the underline */
static const unsigned int ulinevoffset	= 0;	/* how far above the bottom of the bar the line should appear */
static const int ulineall 		= 0;	/* 1 to show underline on all tags, 0 for just the active ones */

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
    /* class     instance  title           tags mask  isfloating  isterminal  noswallow  monitor */
	{ "Gimp",    NULL,     NULL,           0,         1,          0,           0,        -1 },
	{ "Firefox", NULL,     NULL,           1 << 8,    0,          0,          -1,        -1 },
	{ "St",      NULL,     NULL,           0,         0,          1,           0,        -1 },
	{ NULL,      NULL,     "Event Tester", 0,         0,          0,           1,        -1 }, /* xev */
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 0;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

#include "fibonacci.c"
static const Layout layouts[] = {
	/* symbol     arrange function */
    { "",      spiral },
	{ "",      NULL },    /* no layout function means floating behavior */
    { "󰟾",      tile }, /* first entry is default */
	{ "[M]",      monocle },
 	{ "[\\]",      dwindle },
};

/* key definitions */
#define MODKEY Mod1Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }
#define STATUSBAR "dwmblocks"
/* commands */
//static const char *dmenucmd[] = { "dmenu_run", "-fn", dmenufont, "-nb", col_gray1, "-nf", col_gray3, "-sb", col_cyan, "-sf", col_gray4, NULL };
static const char *dmenucmd[] = {"dmenu_run", NULL};
static const char *termcmd[]  = { "st", NULL };

#include "exitdwm.c"
static const Key keys[] = {
	/* modifier                     key        function        argument */
	{ MODKEY,                       XK_p,      spawn,          {.v = dmenucmd } },
	{ MODKEY|ShiftMask,             XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_b,      togglebar,      {0} },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_q,      incnmaster,     {.i = +1 } },
	{ MODKEY,                       XK_w,      incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY,                       XK_Return, zoom,           {0} },
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY|ShiftMask,             XK_c,      killclient,     {0} },
	{ MODKEY,                       XK_r,      setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_f,      setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[2]} },
    { MODKEY,                       XK_m,      setlayout,      {.v = &layouts[3]} },
	{ MODKEY|ShiftMask,             XK_r,      setlayout,      {.v = &layouts[4]} },
	{ MODKEY,                       XK_space,  setlayout,      {0} },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period, focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
	{ MODKEY,                       XK_minus,  incrgaps,        {.i = -1 } },
	{ MODKEY,                       XK_equal,  incrgaps,        {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_equal,  togglegaps,        {.i = 0  } },
	{ MODKEY|ShiftMask,  		    XK_s,      spawn,          SHCMD("flameshot gui") },
	{ MODKEY,              		    XK_i,      shiftview,      { .i = -1 } },
	{ MODKEY,             	     	XK_o,      shiftview,      { .i = +1 } },
	{ MODKEY|ShiftMask, 		    XK_w,      spawn,	       SHCMD("sxiv -t -b ~/wallpaper")}, 
	{ MODKEY, 		                XK_x,      spawn,	       SHCMD("betterlockscreen -l & sleep .5; xset dpms force off")}, 
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
    { MODKEY|ShiftMask,             XK_e,      exitdwm,       {0} },
    { MODKEY,                       XK_g,      scratchpad_show, {.i = 1} },
    { MODKEY,                       XK_y,      scratchpad_show, {.i = 2} },
    { MODKEY,                       XK_u,      scratchpad_show, {.i = 3} },
    { MODKEY|ShiftMask,             XK_g,      scratchpad_hide, {.i = 1} },
    { MODKEY|ShiftMask,             XK_y,      scratchpad_hide, {.i = 2} },
    { MODKEY|ShiftMask,             XK_u,      scratchpad_hide, {.i = 3} },
	{ MODKEY|ShiftMask,             XK_r,      scratchpad_remove,           {0} },
	/*specific keys*/
	{ MODKEY,                       XK_F11, spawn, 		SHCMD("amixer -c0 set Master 5%- ; kill -44 $(pidof dwmblocks)") /*{.v = downvol  }*/ },
	{ MODKEY,                       XK_F10, spawn, 		SHCMD("amixer -c0 set Master toggle ; kill -44 $(pidof dwmblocks)") /*{.v = mutevol  }*/ },
	{ MODKEY,                       XK_F12, spawn, 		SHCMD("amixer -c0 set Master 5%+ ; kill -44 $(pidof dwmblocks)") /*{.v = upvol  }*/ },
	{ 0, 				XK_F3,	spawn,		SHCMD("xbacklight -inc 1 ; pkill -RTMIN+1 dwmblocks") },
        { 0, 				XK_F2,	spawn,		SHCMD("xbacklight -dec 1 ; pkill -RTMIN+1 dwmblocks") },
	/*{ MODKEY,			XK_r,		spawn,          SHCMD("rofi -show drun") },*/
	
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	//{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkStatusText,        0,              Button1,        sigstatusbar,   {.i = 1} },
	{ ClkStatusText,        0,              Button2,        sigstatusbar,   {.i = 2} },
	{ ClkStatusText,        0,              Button3,        sigstatusbar,   {.i = 3} },
	{ ClkStatusText,        0,              Button1,        sigstatusbar,   {.i = 4} },
	{ ClkStatusText,        0,              Button1,        sigstatusbar,   {.i = 5} },
	{ ClkStatusText,        0,              Button1,        sigstatusbar,   {.i = 6} },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};

