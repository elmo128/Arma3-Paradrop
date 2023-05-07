// Copyright(c) 2022 - 2023 elmo128 (elmo128@protonmail.com)

// default defines can be changed using parameters, no need to change them here!
#define DEFAULT_LOC [1,1,1]
#define DEFAULT_SIDE east
#define DEFAULT_DROPSHIP "B_T_VTOL_01_infantry_F"
#define DEFAULT_SKILLMIN 0.4
#define DEFAULT_SKILLMAX 0.8
#define DEFAULT_JUMPDISTANCE 0.15
#define DEFAULT_HEIGHT 150
#define DEFAULT_JEARLY 0
#define DEFAULT_NOJUMP false
#define DEFAULT_PARACHUTE "B_Parachute"
#define DEFAULT_PARACHUTEFORCEOPEN -1
#define DEFAULT_NOJUMP false

// internal use
#define DROPSPEED 220
#define DROPSPEEDBREAKLENGTH 2500
#define DROPLENGTH 3000
#define PARACHUTETYPE "B_Parachute"			// Parachutetype to use

#define PARACHUTTYPE_HUMAN_BACKPACK ["B_Parachute","B_B_Parachute_02_F","B_I_Parachute_02_F","B_O_Parachute_02_F"]	// (list) steerable parachutes
#define PARACHUTTYPE_HUMAN ["Steerable_Parachute_F","NonSteerable_Parachute_F"]										// (list) no backpack, spawn as vehicle when outside, but animations for humans available
#define PARACHUTETYPE_CARGO ["B_Parachute_02_F","O_Parachute_02_F","I_Parachute_02_F"]								// (list) no backpack, spawn as vehicle when outside, no animations for humans available

#define NACK -1
#define INVINCIBILITY_AFTER_JUMP 6;			// time in [s]
#define GARBAGE_BIN "Land_PencilBlue_F"		// object for internal use. will be despawned with garbage
#define GARBAGE_BIN_VAR_NAME "Junk11"			
#define ENABLEDISTANCE_VTOL 1500			//enable VTOL before reaching drop locataion, helps AI to reduce speed [m] will be enabled again, after paradrop is completed

// #define DEBUG