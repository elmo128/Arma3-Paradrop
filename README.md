# Arma-3-Paradrop

flexible AI paradrop script.
might need tweaking.

- drops ai backup units from aircraft
- can handle both, cargo and backpacks (user/ai) controlled parachutes
- highly customizable
- backpacks are reattatched after jumping
- most ramps/doors of dropships are animated
- accepts objects, markers and coordinates as destination, spawn and despawn locations

execute with with:
MINIMUM WORKING:  [destination] execVM "e_paradrop.sqf"; eg. [player] execVM "e_paradrop.sqf";
MINIMUM RECOMMENDED: [destination, dropshipSpawnlocation, dropshipDESpawnlocation] execVM "e_paradrop.sqf";
MAXIMUM PARAMETERS: [destination, dropshipSpawnlocation, dropshipDESpawnlocation, side,vehicleType,skillmin,skillmax,variable,nojump,parachutetype,jumpdistancetime,jumpheight,jumpearly] execVM "e_paradrop.sqf";
MAXIMUM PARAMETERS eg.: ["mrk15", [1,1,1], [1,1,1], east,"B_T_VTOL_01_infantry_F",0.1,0.9,[],scriptNull,"O_Parachute_02_F",0.15,150,0] execVM "e_paradrop.sqf";

parameters:

0, destination:				DEFAULT: N/A (MUST BE VALID!)		location where the paratroopers are delivered to (marker, position ASL, object) 
1, dropshipSpawnPosition:	DEFAULT: [1,1,1]					location where dropship and paratroopers initially spawn (marker, position ASL, object) 
2, dropshipDESpawnPosition:	DEFAULT: [1,1,1]					location where dropship will despawn (marker, position ASL, object) 
3, side:					DEFAULT: east						side of dropship crew and cargo [east,west,..]: 
4, vehicleType:				DEFAULT: "B_T_VTOL_01_infantry_F"	vehicletype that is used as a dropship [""]: default: V-44X Blackfish (Infantry Transport) using a different type of vehicle might need tweaking
5, skillmin:				DEFAULT: 0.1						the paratroopers' min skill level [0-1]. 
6, skillmax:				DEFAULT: 0.9						the paratroopers' max skill level [0-1]. 
7, variable ARRAY:			DEFAULT: [].						if you need the return values saved somewhere. array of type [varspace , name, public(optional)] (https://community.bistudio.com/wiki/setVariable) 
8, nojump:					DEFAULT: scriptNull					can be a script handle (scriptDone == true  => NO JUMP) OR object(alive == false  => NO JUMP) OR [varspace , name] (getVariable == false => NO JUMP) will be evaluated before jumping.
9, parachutetype.			DEFAULT:"B_Parachute"				parachute type to be used, default it is the fully compatible backpack that does not require any workarounds and looks best.    ["B_Parachute", "Steerable_Parachute_F","NonSteerable_Parachute_F", "B_Parachute_02_F","O_Parachute_02_F","I_Parachute_02_F"] or add one to the defines
10,jumpdistancetime:		DEFAULT: 0.15						the time between the parajumpers when leaving the plane [sec.].  
11,jumpheight:				DEFAULT: 150						height the dropship will fly when dropping passengers.[m]
12,jumpearly:				DEFAULT: 0							correction factor to adjust the location where cargo is dropped[m]. might need adjustment, if jumpheight or jumpdistancetime was modified to make the paratroopers still beeing dropped over the destination.
13,_forceopenParachute	DEFAULT: -1								-1: AI decides when to open (only works with backpack paracutes), 0 <= x <= 20 time to open parachute after leaving dropship, >20 height parachute is forced open. MUST BE SET WHEN USING CARGO PARACHUTE !

return of main. will be saved to a namespace on request
[_cargogroup, _dropship, _dropship_group, _garbage];
0, _cargogroup == the group of the parajumpers in the cargospace
1, _dropship == the dropship vehicle
2, _dropship_group == the group of the non jumping dropship crew: pilots doorgunners,...
3, _garbage == script handles, units and waypoints created by this script.  

NOTE: repeatability and precision also depends on processing power


Have Fun!!!