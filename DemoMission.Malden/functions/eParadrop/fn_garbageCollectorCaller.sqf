// Copyright(c) 2022 - 2023 elmo128 (elmo128@protonmail.com)
// teminates all possible remains when dropship not alive and cargo (paratroopers) are killed
#include "defines.hpp"

if (!isserver) exitwith{};
#ifdef DEBUG
	diag_log["ePara_fnc_garbagecollectorCaller",_this];
#endif // DEBUG

private _cargogroup = param[0];
private _dropship = param[1];
private _Lgarbage = param[2,[]];
private _jumped = param[3, false]; // optional. if there should have never been a jump, don't wait for cargo group beeing killed, remove possible dropped paratroopers with vehicle!
waitUntil
{
	sleep 10;
	(!alive _dropship) && (((count units _cargogroup)  isEqualTo 0) || !_jumped);
};
sleep 60;
[_Lgarbage] call ePara_fnc_garbagecollector;
