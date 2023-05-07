// Copyright(c) 2022 - 2023 elmo128 (elmo128@protonmail.com)
// force AI to keep angle of engined at 0°
#include "defines.hpp"

if (!isserver) exitwith{};
private _dropship = param[0];
if ((_dropship call ePara_fnc_VTOLGetCapabilities) > 0) then
{
	while {(alive _dropship) && (alive(currentPilot _dropship))} do
	{
		sleep 0.1;
		(currentPilot _dropship) action["VTOLVectoring", _dropship]; // disable
		(currentPilot _dropship) action["VectoringDown", _dropship]; // turn in front 
	};
};