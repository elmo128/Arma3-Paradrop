// Copyright(c) 2022 - 2023 elmo128 (elmo128@protonmail.com)
// despawn all units in the dropship
#include "defines.hpp"

if (!isserver) exitwith{};
#ifdef DEBUG
	diag_log["ePara_fnc_despawnCrew",_this];
#endif // DEBUG

private _dropship = param[0, objNull];
waitUntil 
{
	sleep 1; 
	!alive _dropship
};
sleep 10;
if ((count(crew _dropship))  isEqualTo 0) exitWith{};
{
	if (alive _x) then
	{
		deleteVehicle _x;	// _x setdamage 1;
	};
}foreach(crew _dropship);
