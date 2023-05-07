// Copyright(c) 2022 - 2023 elmo128 (elmo128@protonmail.com)
#include "defines.hpp"

if (!isserver) exitwith{};
private _unit = param[0];
private _parachuteVehicleType = param[1,""];
private _garbageobj = param[3, objnull,[objnull]];

private _parachute = objnull;
private _garbage = [];
if (_garbageobj != objnull) then
{
	_garbage = _garbageobj getVariable[GARBAGE_BIN_VAR_NAME,[]];
};
if ((!((tolower _parachuteVehicleType) in(PARACHUTTYPE_HUMAN_BACKPACK apply{tolower _x; }))) && (((tolower _parachuteVehicleType) in(PARACHUTTYPE_HUMAN apply{tolower _x; })) || ((tolower _parachuteVehicleType) in(PARACHUTETYPE_CARGO apply{tolower _x; })))) then
{
	private _unitpos = getPosATL _unit;
	_parachute = createVehicle[_parachuteVehicleType, _unitpos];
	if (_garbageobj != objnull) then
	{
		_garbage pushback(_parachute);
		_garbageobj setVariable[GARBAGE_BIN_VAR_NAME, _garbage, true];
	};
	_parachute setDir getDir _unit;
	_parachute setPos _unitpos;

	if ((tolower _parachuteVehicleType) in(PARACHUTTYPE_HUMAN  apply{tolower _x; })) then
	{
		_unit moveInAny _parachute;
	};
	if ((tolower _parachuteVehicleType) in(PARACHUTETYPE_CARGO apply{tolower _x; })) then
	{
		_unit attachTo[_parachute,[0, -0.3, 0]];
		waitUntil{ isTouchingGround _unit };
		detach _unit;
	};
};
_parachute;