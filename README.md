# Arma-3-Paradrop

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

flexible AI paradrop script.
might need tweaking.

- Drops ai units from aircraft
- Can handle both, cargo and backpacks (user/ai) controlled parachutes.
- Highly customizable.
- Backpacks are reattatched after jumping.
- Most ramps/doors of dropships are animated.
- Accepts objects, markers and coordinates as destination, spawn and despawn locations.

Have Fun!

## Instructions and parameters

* Parameters:
* 0, destination:				DEFAULT: N/A (MUST BE VALID!)		Location where the paratroopers are dropped (marker, position ASL, object).
* 1, dropshipSpawnLocation:		DEFAULT: [1,1,1]					Location where dropship and paratroopers are initially spawn (marker, position ASL, object).
* 2, dropshipDESpawnLocation:	DEFAULT: [1,1,1]					Location where dropship will despawn (marker, position ASL, object).
* 3, side:						DEFAULT: east						Side of dropship crew and cargo.
* 4, vehicleType:				DEFAULT: "B_T_VTOL_01_infantry_F"	Vehicletype that is used as dropship "":  *   == V-44X Blackfish (Infantry Transport) *   using a different type of vehicle might need tweaking
* 5, skillmin:					DEFAULT: 0.1						The paratroopers' min skill level 0-1.
* 6, skillmax:					DEFAULT: 0.9						The paratroopers' max skill level 0-1.
* 7, nojump:					DEFAULT: false						Can be a script handle (scriptDone == true  => NO JUMP), object(alive == false  => NO JUMP), [varspace , name] (getVariable == false => NO JUMP), bool (true => no jump) or taskID (task completed and/or not available => no jump) it will be evaluated before jumping and at despawn of dropship.
* 8, parachutetype.				DEFAULT: "B_Parachute"				Select parachute type tobe used. eg. "B_Parachute" it is the fully compatible backpack that does not require any workarounds.    ["B_Parachute", "Steerable_Parachute_F","NonSteerable_Parachute_F", "B_Parachute_02_F","O_Parachute_02_F","I_Parachute_02_F"] or add one to the defines below.
* 9, jumpdistancetime:			DEFAULT: 0.15						Delay between Paratroopers leaving the plane in seconds.
* 10,jumpheight:				DEFAULT: 150						Target height the dropship is flying when dropping cargo.[m]  *  changing this might need tweaking and is never guaranteed
* 11,jumpearly:					DEFAULT: 0							Correction factor to adjust the moment where they start jumping[m]. *   might need adjustment, if jumpheight or jumpdistancetime was modified to make the paratroopers still beeing dropped over the destination.
* 12,forceopenParachute		    DEFAULT: -1							-1: AI decides when to open, 0 <= x <= 20 time in sec. to open parachute after leaving dropship, >20 height in m, parachute is forced open. MUST BE SET WHEN USING CARGO PARACHUTE !

* Function returns, when paratroopers left the vehicle.
* [group of paratroopers, dropship, group dropship crew]

Instructions:

NOTE: ePara_fnc_Paradrop requires suspending.
NOTE: spawn it, if you don't need the return values.

* MINIMUM WORKING: [destination] spawn ePara_fnc_Paradrop;
* MINIMUM RECOMMENDED: [destination, dropshipSpawnlocation, dropshipDESpawnlocation] spawn ePara_fnc_Paradrop;
* MAXIMUM PARAMETERS: [destination, dropshipSpawnlocation, dropshipDESpawnlocation, side, vehicleType, skillmin, skillmax, nojump, parachutetype, jumpdistancetime, jumpheight, jumpearly, _forceopenParachute] spawn ePara_fnc_Paradrop;
* MAXIMUM PARAMETERS: ["marker15", [1, 1, 1], [1, 1, 1], east, "B_T_VTOL_01_infantry_F", 0.1, 0.9, false, "O_Parachute_02_F", 0.15, 150, 0, -1] spawn ePara_fnc_Paradrop;

