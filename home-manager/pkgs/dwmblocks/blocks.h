//Modify this file to change what commands output to your statusbar, and recompile using the make command.
static const Block blocks[] = {
	    /*Icon*/    /*Command*/         /*Update Interval*/    /*Update Signal*/



	    //{" [ ", "~/.config/suckless/statusbar/pacupdate",        36000,                 1},
	    
	    {"^c#ff79c9^^b#44475a^ ", "~/home/ohsean/.config/home-manager/pkgs/statusbar/internet",             5,                    3},

	    {"^c#8be9fd^^b#44475a^  ", "~/home/ohsean/.config/home-manager/pkgs/statusbar/volume2",             0,                    10},

	    {"^c#f1fa8c^^b#44475a^   ", "~/home/ohsean/.config/home-manager/pkgs/statusbar/brightness",       0,                    1},

	    {"^c#50fa7b^^b#44475a^", "~/home/ohsean/.config/home-manager/pkgs/statusbar/battery",              5,                    12},

	    {"^c#8be9fd^^b#44475a^   ", "~/home/ohsean/.config/home-manager/pkgs/statusbar/clock",              60,                   6},

 	    //{"",                   "~/Programs/suckless/statusbar/update_loop",              0,                   4},
	                        
};
//sets delimeter between status commands. NULL character ('\0') means no delimeter.
static char delim[] = "\0";
static unsigned int delimLen = 5;
