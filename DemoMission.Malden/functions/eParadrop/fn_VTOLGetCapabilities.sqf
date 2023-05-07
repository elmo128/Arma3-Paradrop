// Copyright(c) 2022 - 2023 elmo128 (elmo128@protonmail.com)
//is dropship a vtol?
#include "defines.hpp"

if (!isserver) exitwith{};
private _vehicle = param[0];
private["_statement"];

if (!isNil{ ((configOf(_vehicle)) >> "vtol") call BIS_fnc_getCfgData }) then
{
	_statement = ((configOf(_vehicle)) >> "vtol") call BIS_fnc_getCfgData;
}
else
{
	_statement = 0;
};
_statement;
