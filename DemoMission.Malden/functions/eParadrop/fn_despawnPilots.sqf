// Copyright(c) 2022 - 2023 elmo128 (elmo128@protonmail.com)
// despawn all units belonging to the initial crew group
#include "defines.hpp"

if (!isserver) exitwith{};
#ifdef DEBUG
	diag_log["ePara_fnc_despawnPilots",_this];
#endif // DEBUG

private _dropship = param[0, objNull];
private _dropship_group = param[1, grpnull];
waitUntil 
{
	sleep 1;
	!alive _dropship
};
sleep 10;
if ((count(units _dropship_group))  isEqualTo 0) exitWith{};
{
	if (alive _x) then
	{
		deleteVehicle _x;	// _x setdamage 1;
	};
}foreach(units _dropship_group);
