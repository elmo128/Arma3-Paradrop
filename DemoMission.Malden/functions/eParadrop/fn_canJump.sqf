// Copyright(c) 2022 - 2023 elmo128 (elmo128@protonmail.com)
// check if the jump condition is met. access to objects, script handles, variables in namespaces
#include "defines.hpp"

if (!isserver) exitwith{false};
#ifdef DEBUG
	diag_log["ePara_fnc_canJump",_this];
#endif // DEBUG

private _condcode = param[0];
private _jump = true;

if (_condcode isEqualType scriptnull) then
{
	if (scriptDone _condcode) then // jump if other script is running
	{
		_jump = false;
	};
}
else
{
	if (_condcode isEqualType objnull) then
	{
		// no jump if dead
		_jump = alive _condcode; 
	}
	else
	{
		if (_condcode isEqualType []) then
		{
			if (count _condcode  isEqualTo 2) then
			{	
				// no jump if variable set to false
				_jump = (_condcode # 0) getVariable[(_condcode # 1), true]; 
			};
		}
		else
		{
			if (_condcode isEqualType false) then
			{
				// no jump if true
				_jump = !_condcode;
			}
			else
			{
				if (_condcode isEqualType "taskID") then
				{
					// jump if task exists and is running
					if ([_condcode] call BIS_fnc_taskExists)then
					{
						_jump = !(_condcode call BIS_fnc_taskCompleted);
					}
					else
					{
						_jump = false;
					};
				};
			};
		};
	};
};
_jump;