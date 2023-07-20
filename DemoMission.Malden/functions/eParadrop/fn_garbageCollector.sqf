// Copyright(c) 2022 - 2023 elmo128 (elmo128@protonmail.com)
// terminates all scripts, removes all units and waypoints ever created
#include "defines.hpp"

if (!isserver) exitwith{};
#ifdef DEBUG
	diag_log["ePara_fnc_garbageCollector",_this];
#endif // DEBUG

private _Lgarbage = param[0,[]];
private _hasJumped = param[1, false];

if ((count _Lgarbage) > 0) then
{
	{
		if (_x isequaltype scriptnull) then // script handle
		{
			if (!isNull _x) then
			{
				terminate _x;
			};
		};
		if (_x isequaltype objnull) then // vehicle, soldier
		{
			if (_x isnotequalto vehicle _x)then
			{
				moveOut _x;
			};
			deleteVehicle _x;
		};
		if (_x isequaltype []) then // waypoint
		{
			if ((count _x  isEqualTo 2) && (typename (_x select 0) isEqualto "GROUP") && (typename (_x select 1) isEqualto "SCALAR")) then
			{
				deleteWaypoint _x;
			};
		};
		if ((_hasJumped isequalto false)&& { (_x isequaltype grpNull) })then // group
		{
			{
				if (_x isnotequalto vehicle _x)then
				{
					moveOut _x;
				};
				deleteVehicle _x;
			}foreach units _x;
			if (isMultiplayer)then
			{
				_x setGroupOwner 2;
			};
			deleteGroup _x;
		};
	}foreach _Lgarbage;
};