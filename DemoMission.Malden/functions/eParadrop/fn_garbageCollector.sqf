// Copyright(c) 2022 - 2023 elmo128 (elmo128@protonmail.com)
// terminates all scripts, removes all units and waypoints ever created
#include "defines.hpp"

if (!isserver) exitwith{};
#ifdef DEBUG
	diag_log["ePara_fnc_garbageCollector",_this];
#endif // DEBUG

private _Lgarbage = param[0,[]];

if ((count _Lgarbage) != 0) then
{
	{
		if (typename _x isEqualto "SCRIPT") then
		{
			if (!isNull _x) then
			{
				terminate _x;
			};
		};
		if (typename _x isEqualto "OBJECT") then
		{
			if (_x isKindOf GARBAGE_BIN) then
			{
				private _bin = _x getVariable[GARBAGE_BIN_VAR_NAME,[]];
				_Lgarbage append _bin;
				uisleep 0.01;
			};
			deleteVehicle _x;
		};
		if (typename _x isEqualto "ARRAY") then // waypoint
		{
			if ((count _x  isEqualTo 2) && (typename (_x select 0) isEqualto "GROUP") && (typename (_x select 1) isEqualto "SCALAR")) then
			{
				deleteWaypoint _x;
			};
		};
	}foreach _Lgarbage;
};