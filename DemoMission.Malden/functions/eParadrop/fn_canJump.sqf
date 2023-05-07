// Copyright(c) 2022 - 2023 elmo128 (elmo128@protonmail.com)
// check if the jump condition is met. access to objects, script handlers, variables in namespaces
#include "defines.hpp"

if (!isserver) exitwith{false};
#ifdef DEBUG
	diag_log["ePara_fnc_canJump",_this];
#endif // DEBUG

private _condcode = param[0];
private _jump = true;

if (_condcode isEqualType scriptnull) then
{
	if (!scriptDone _condcode) then // no jump if script NOT running
	{
		_jump = false;
	};
}
else
{
	if (_condcode isEqualType objnull) then
	{
			_jump = alive _condcode; // no jump if dead
	}
	else
	{
		if (_condcode isEqualType []) then
		{
			if (count _condcode  isEqualTo 2) then
			{
				_jump = (_condcode # 0) getVariable[(_condcode # 1), true]; // no jump if variable set to false
			};
		}
		else
		{
			if (_condcode isEqualType false) then
			{
				_jump = !_condcode;// no jump if true
			}
			else
			{
				if (_condcode isEqualType "taskID") then
				{
					if ([_condcode] call BIS_fnc_taskExists)then
					{
						_jump = !(_condcode call BIS_fnc_taskCompleted);
					}
					else
					{
						_jump = [_condcode] call BIS_fnc_taskExists;
					};
				};
			};
		};
	};
};
_jump;