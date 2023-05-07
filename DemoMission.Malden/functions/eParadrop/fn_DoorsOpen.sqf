// Copyright(c) 2022 - 2023 elmo128 (elmo128@protonmail.com)
// opens most doors and ramps of a vehicle
#include "defines.hpp"

if (!isserver) exitwith{};
private _vehicle = param[0];
private _actionlist = ((configOf _vehicle) >> "UserActions") call bis_fnc_returnchildren;

{
private _pth = [_x, ""] call BIS_fnc_configPath;
_pth = toLower _pth;
private _pthL = toLower _pth;
if (("door" in _pthL) || ("ramp"  in _pthL)) then
{
	if ("open" in _pthL) then
	{
		private _statement = (_x >> "statement") call BIS_fnc_getCfgData;
		private _thispos = _statement find "this";
		_statement = _statement insert[_thispos, "_"];
		_vehicle call compile _statement;
	};
};
}foreach _actionlist;
//orca
_vehicle animate["dvere1_posunZ",1];
_vehicle animate["dvere2_posunZ",1];
