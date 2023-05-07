// Copyright(c) 2022 - 2023 elmo128 (elmo128@protonmail.com)
// calculate cordinates and bearings from different input types
// always call with array: [datatype] call ePara_fnc_getInputLocation;

if (!isserver) exitwith{};
#include "defines.hpp"

// positionASL
private _anything = param[0];

private _location = false;
private _bearing = 0;

if (_anything isEqualType "STR") then
{
	_location = AGLToASL getMarkerPos[_anything, true];
	_bearing = markerDir _anything;
}
else
{
	if (_anything isEqualType objnull) then
	{
		_location = getPosASL _anything;
		_bearing = getDir _anything;
	}
	else
	{
		if (_anything isEqualType[0, 0, 0]) then
		{
			_location = _anything;
			if (count _location isequalto 2)then
			{
				_location append[getTerrainHeightASL _location];
			};
			_bearing = random 360;
		}
		else
		{
			if (true) exitWith
			{
				diag_log["eParadrop: input invalid, can't handle input type of:", _anything];
			};
		};
	};
};
[_location, _bearing];