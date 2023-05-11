# Arma-3-Paradrop

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

flexible AI paradrop script.
might need tweaking.

- drops ai backup units from aircraft
- can handle both, cargo and backpacks (user/ai) controlled parachutes
- highly customizable
- backpacks are reattatched after jumping
- most ramps/doors of dropships are animated
- accepts objects, markers and coordinates as destination, spawn and despawn locations

Have Fun!

## Instructions and parameters


execute with with:
- MINIMUM WORKING:  [destination] execVM "e_paradrop.sqf"; eg. [player] execVM "e_paradrop.sqf";
- MINIMUM RECOMMENDED: [destination, dropshipSpawnlocation, dropshipDESpawnlocation] execVM "e_paradrop.sqf";
- MAXIMUM PARAMETERS: [destination, dropshipSpawnlocation, dropshipDESpawnlocation, side, vehicleType, skillmin, skillmax, variable, nojump, parachutetype, jumpdistancetime, jumpheight, jumpearly,_forceopenParachute] execVM "e_paradrop.sqf";
- MAXIMUM PARAMETERS eg.: [player, [1,1,1], [1,1,1], east,"B_T_VTOL_01_infantry_F",0.1,0.9,[],scriptNull,"O_Parachute_02_F",0.15,150,0,1] execVM "e_paradrop.sqf";

* Parameters:
* to use default value, pass bool false might display a WARNING onscreen!
* 0, destination:				DEFAULT: N/A (MUST BE VALID!)		location where the paratroopers are dropped (marker, position ASL, object)
* 1, dropshipSpawnPosition:		DEFAULT: [1,1,1]					location where dropship and paratroopers are initially spawn (marker, position ASL, object)
* 2, dropshipDESpawnPosition:	DEFAULT: [1,1,1]					location where dropship will despawn (marker, position ASL, object)
* 3, side:						DEFAULT: east						side of dropship crew and cargo[east,west,..]:
* 4, vehicleType:				DEFAULT: "B_T_VTOL_01_infantry_F"	vehicletype that is used as dropship [""]:  *   == V-44X Blackfish (Infantry Transport) *   using a different type of vehicle might need tweaking
* 5, skillmin:					DEFAULT: 0.1						the paratroopers' min skill level [0-1].
* 6, skillmax:					DEFAULT: 0.9						the paratroopers' max skill level [0-1].
* 7, nojump:					DEFAULT: false						can be a script handle (scriptDone == true  => NO JUMP) OR object(alive == false  => NO JUMP) OR [varspace , name] (getVariable == false => NO JUMP) or bool (true => no jump) or taskID (task completed and/or not available => no jump) it will be evaluated before jumping and at despawn of dropship.
* 8, parachutetype.				DEFAULT:"B_Parachute"				Select one parachute of type , it is the fully compatible backpack that does not require any workarounds.    ["B_Parachute", "Steerable_Parachute_F","NonSteerable_Parachute_F", "B_Parachute_02_F","O_Parachute_02_F","I_Parachute_02_F"] or add one to the defines below.
* 9, jumpdistancetime:			DEFAULT: 0.15						the time between the parajumpers when leaving the plane [sec.].
* 10,jumpheight:				DEFAULT: 150						height the dropship is flying when dropping passengers.[m]  *  changing this might need tweaking and is never guaranteed
* 11,jumpearly:					DEFAULT: 0							correction factor to adjust the moment where they start jumping[m]. *   might need adjustment, if jumpheight or jumpdistancetime was modified to make the paratroopers still beeing dropped over the destination.
* 12,_forceopenParachute		DEFAULT: -1							-1: AI decides when to open, 0 <= x <= 20 time to open parachute after leaving dropship, >20 height parachute is forced open. MUST BE SET WHEN USING CARGO PARACHUTE !

Return when paratroopers left the vehicle:

* return:
* [group of paratroopers, dropship, group dropship crew]
* 0, _cargogroup == the group of the parajumpers in the cargospace
* 1, _dropship == the dropship vehicle
* 2, _dropship_group == the group of the non jumping dropship crew : pilots doorgunners,...

Instructions:

NOTE: ePara_fnc_Paradrop must be run on the scheduler, because it requires suspending.

* NOTE : the higher the processing power, the more accurate the drop location.
* MINIMUM WORKING call : [destination] call ePara_fnc_Paradrop; // eg. [player] call ePara_fnc_Paradrop;
* MINIMUM RECOMMENDED call : [destination, dropshipSpawnlocation, dropshipDESpawnlocation] call ePara_fnc_Paradrop;
* MAXIMUM PARAMETERS call : [destination, dropshipSpawnlocation, dropshipDESpawnlocation, side, vehicleType, skillmin, skillmax, nojump, parachutetype, jumpdistancetime, jumpheight, jumpearly, _forceopenParachute] call ePara_fnc_Paradrop;
* MAXIMUM PARAMETERS call : ["marker15", [1, 1, 1], [1, 1, 1], east, "B_T_VTOL_01_infantry_F", 0.1, 0.9, false, "O_Parachute_02_F", 0.15, 150, 0, -1] call ePara_fnc_Paradrop;

