// Copyright(c) 2022 - 2023 elmo128 (elmo128@protonmail.com)
// reattatch backpacks after parachutes are not in their slot any longer
#include "defines.hpp"

if (!isserver) exitwith{};
#ifdef DEBUG
	diag_log["ePara_fnc_ParachuteNoBackpack",_this];
#endif // DEBUG

private _unit = param[0, objNull];
private _backpack = param[1,""];
private _backpack_items = param[2,[]];
waituntil
{
	sleep 0.5;
	(!alive _unit) || (isTouchingGround _unit) || (""  isEqualTo backpack _unit); //unit died, choote opened or touching ground
};

if ((alive _unit) && (count _backpack > 0)) then
{
	_unit addBackpack _backpack;
	if (count _backpack_items > 0) then
	{
		{
			_unit addItemToBackpack _x;
		} foreach _backpack_items;
	};
};
