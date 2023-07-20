// Copyright(c) 2022 - 2023 elmo128 (elmo128@protonmail.com)
//force open parachutes at altitude, time after jump or make ai decide
#include "defines.hpp"

if (!isserver) exitwith{};
#ifdef DEBUG
	diag_log["ePara_fnc_ParachuteForceOpen",_this];
#endif // DEBUG

private _unit = param[0, objNull];
private _setting = param[1, NACK];
private _paratype = param[2, DEFAULT_PARACHUTE];

if (_setting isEqualTo NACK) exitWith{};

if ((_setting >= 0) && (_setting <= 20)) then
{
	sleep _setting;
}
else
{
	if (_setting > 20) then
	{
		waituntil
		{
			sleep 1;
			((getPosATL _unit) select 2) <= _setting;
		};
	};
};
if (alive _unit) then
{
	if ((tolower _paratype) in(PARACHUTTYPE_HUMAN_BACKPACK apply {tolower _x; })) then
	{
		_unit action["OpenParachute", _unit];
	}
	else
	{
		[_unit, _paratype] call ePara_fnc_ParachuteNoBackpack;
	};
};
