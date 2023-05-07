// Copyright(c) 2022 - 2023 elmo128 (elmo128@protonmail.com)
#include "defines.hpp"

if (!isserver) exitwith{};
#ifdef DEBUG
	diag_log["eparadrop begin:",_this];
#endif // DEBUG
if (!canSuspend) exitWith {diag_log "eparadrop: noParadrop possible, can't suspend code"; };

// input parameters
private _iDpos = [_this, 0,[],[objNull,[], ""]] call BIS_fnc_param;
private _iSpos = [_this, 1, DEFAULT_LOC,[objNull,[], ""]] call BIS_fnc_param;
private _iDSpos = [_this, 2, DEFAULT_LOC,[objNull,[], ""]] call BIS_fnc_param;
private _dsSide = [_this, 3, DEFAULT_SIDE,[DEFAULT_SIDE]] call BIS_fnc_param;
private _vehicletype = [_this, 4, DEFAULT_DROPSHIP,[DEFAULT_DROPSHIP]] call BIS_fnc_param;
private _skillmin = [_this, 5, DEFAULT_SKILLMIN,[0]] call BIS_fnc_param;
private _skillmax = [_this, 6, DEFAULT_SKILLMAX,[0]] call BIS_fnc_param;
private _nojump = [_this, 7, DEFAULT_NOJUMP,[scriptnull, objNull,[],false,""]] call BIS_fnc_param; // string is used for taskid
private _parachutetype = [_this, 8, DEFAULT_PARACHUTE] call BIS_fnc_param;
private _jumpdistancetime = [_this, 9, DEFAULT_JUMPDISTANCE,[0]] call BIS_fnc_param;
private _jumpheight = [_this, 10, DEFAULT_HEIGHT,[0]] call BIS_fnc_param;
private _jumpearly = [_this, 11, DEFAULT_JEARLY,[0]] call BIS_fnc_param;
private _forceParachute = [_this, 12, DEFAULT_PARACHUTEFORCEOPEN,[0]] call BIS_fnc_param;

//parse input locations
private _destinationpos = ([_iDpos] call ePara_fnc_getInputLocation) select 0;
private _finaldestination = ([_iDSpos] call ePara_fnc_getInputLocation) select 0;
private _vehiclespawncoordinates = ([_iSpos] call ePara_fnc_getInputLocation) select 0;
private _vehiclespawnbearing = ([_iSpos] call ePara_fnc_getInputLocation) select 1;

if ((_destinationpos isequaltype false) || {(_finaldestination isequaltype false) || {(_vehiclespawncoordinates isequaltype false)}})exitWith
{
	diag_log "eparadrop: noParadrop possible, invalid input loaction";
};

private _garbage = [];
private _isVTOL = 0;

if (!isNull _thisScript) then { _garbage pushback _thisScript };
// let's go

// create garbage bin
private _bin = objnull;
if (!((tolower _parachutetype) in(PARACHUTTYPE_HUMAN_BACKPACK apply{ tolower _x }))) then
{
	_bin = createVehicle[GARBAGE_BIN, DEFAULT_LOC];
	_bin allowdamage false;
	if (isServer isequalto true) then
	{
		_bin hideObjectGlobal true;
		_bin enableSimulationGlobal false;
	}
	else
	{
		_bin hideObject true;
		_bin enableSimulation false;
	};
	_garbage pushback _bin;
};

//create dropship
private _vehicle = [_vehiclespawncoordinates, _vehiclespawnbearing, _vehicletype, _dsSide] call BIS_fnc_spawnVehicle;
private _dropship = _vehicle select 0;
private _dropship_crew = _vehicle select 1;
private _dropship_group = _vehicle select 2;
_dropship limitSpeed 999;
_dropship forceSpeed 998;
_isVTOL = _dropship call ePara_fnc_VTOLGetCapabilities;
_dropship_group deleteGroupWhenEmpty true;
_garbage pushback([_dropship, _dropship_group] spawn ePara_fnc_despawnPilots);

_garbage pushback _dropship;
{
	_garbage pushback _x;
}foreach units _dropship_group;

_destinationpos set[2, ((getTerrainHeightASL _destinationpos) + _jumpheight)];

//create waypoint at destination
private _WP_destination = _dropship_group addWaypoint[_destinationpos, -1];
_WP_destination setWaypointType "MOVE";
_WP_destination setWaypointCompletionRadius 50;
_dropship_group setCurrentWaypoint _WP_destination;
_dropship_group setBehaviour "CARELESS";
_dropship flyInHeight _jumpheight;
_garbage pushback _WP_destination;
private _WP3D = getWPPos _WP_destination;
private _WP2D = _WP3D;
_WP2D set[2, 0];

//create cargo
private _cargoseatcnt = count(fullCrew[_dropship, "cargo", true]) + 2;
private _cargogroup = [_vehiclespawncoordinates, _dsSide, _cargoseatcnt,[],[],[_skillmin, _skillmax]] call BIS_fnc_spawnGroup;
private _onboard = true;

private _despawnCrewhandle = [_dropship] spawn ePara_fnc_despawnCrew;
_garbage pushback _despawnCrewhandle;
//debug handle to cargo

{
	_x assignAsCargo _dropship;
	[_x] allowgetin true;
	[_x] orderGetIn true;
	_x moveInCargo _dropship;
	_garbage pushback _x;
}foreach units _cargogroup;

_cargogroup deleteGroupWhenEmpty true;

private _forceVTOLdown = _dropship spawn ePara_fnc_VTOLforceDown;
_garbage pushback(_forceVTOLdown);

while {_onboard} do
{
	sleep 0.05;
	if (!alive _dropship) exitWith{};
	private _DS2D = getPos _dropship;
	_DS2D set[2, 0];

	if (((_WP2D distance _DS2D) < ENABLEDISTANCE_VTOL) && (!scriptdone _forceVTOLdown) && (_onboard == true)) then
	{
		terminate _forceVTOLdown;
	};

	// DROPSPEEDBREAKLENGTH distance to destination
	if ((_WP2D distance _DS2D) < DROPSPEEDBREAKLENGTH) then
	{
		_dropship_group setSpeedMode "LIMITED";
		_dropship forceSpeed - 1;
		_dropship limitSpeed DROPSPEED;
		_dropship flyInHeight _jumpheight;

		// next step before reaching destination
		if ((_WP2D distance _DS2D) < ((speed _dropship) + (_jumpheight / 2 + _jumpheight / 10) + _jumpearly + 100)) then //open door 100m before jumping
		{
			_garbage pushback(_dropship spawn ePara_fnc_DoorsOpen);

			// destination spawnpoint almost reached, initiate drop
			if ((_WP2D distance _DS2D) < ((speed _dropship) + (_jumpheight / 2 + _jumpheight / 10) + _jumpearly)) then //jumpJumpJump
			{
				terminate _despawnCrewhandle;
				private _high = (getPosASL _dropship) select 2;
				private _highASL = [_high, _high, _high];
				_dropship flyInHeightASL _highASL;
				//calculate next Waypoint probably broken but works somehow! 
				private _xc = (_WP2D select 0);
				if (_xc < 0) then { _x - DROPLENGTH; }
				else { _xc + DROPLENGTH; };
				private _mc = (((_WP2D select 1) - (_DS2D select 1))) / (((_WP2D select 0) - (_DS2D select 0)));
				private _cc = (_WP2D select 1) - _mc * (_WP2D select 0);
				_yc = _mc * _xc + _cc;

				private _nwp = _dropship_group addWaypoint [[_xc,_yc, _high], -1];
				_dropship flyInHeightASL _highASL;
				_nwp setWaypointType "MOVE";
				_dropship_group setSpeedMode "FULL";
				_nwp setWaypointCompletionRadius 50;
				_dropship_group setCurrentWaypoint _nwp;
				// is paradrop still needed?
				if (_nojump call ePara_fnc_canJump) then
				{
					{
						_dropship flyInHeightASL _highASL;
						//jump jump jump
						if (((assignedVehicleRole _x)select 0)  isEqualTo "cargo") then
						{
							private _backpack = backpack _x;
							private _contents = backpackItems _x;
							if ((tolower _parachutetype) in(PARACHUTTYPE_HUMAN_BACKPACK apply {tolower _x; })) then
							{
								removebackpack _x;
								_x addbackpack _parachutetype;
							};
							_x disableCollisionWith _dropship;
							_dropship disableCollisionWith _x;
							[_x] ordergetin false;
							[_x] allowgetin false;
							unassignvehicle _x;
							moveout _x;
							_garbage pushback(_x spawn{ _this allowdamage false; sleep INVINCIBILITY_AFTER_JUMP; _this allowdamage true; });
							_garbage pushback([_x, _forceParachute, _parachutetype, _bin] spawn ePara_fnc_ParachuteForceOpen);
							if (_backpack isnotequalto "") then
							{
								_garbage pushback([_x, _backpack, _contents] spawn ePara_fnc_reattachBackpack);
							};
							sleep _jumpdistancetime;
						};
					}foreach(units _cargogroup);
				};
				// final settings for fast departure
				_onboard = false;
				_dropship flyInHeight _jumpheight;
				_garbage pushback(_dropship spawn ePara_fnc_DoorsClose);
				_garbage pushback _nwp;
				_dropship limitSpeed 999;
				_dropship forceSpeed 998;
				_dropship flyInHeight 105;
				_cargogroup enableAttack true;
				deleteWaypoint _WP_destination;
				_dropship_group setSpeedMode "FULL";
				if (scriptdone _forceVTOLdown) then
				{
					_garbage pushback(_dropship spawn ePara_fnc_VTOLforceDown);
				};
				if (true) exitWith{};
			};
		};
	};
};
// set final waypoint
private _fwp = _dropship_group addWaypoint[_finaldestination,0];
_garbage pushback _fwp;
_fwp setWaypointType "MOVE";
_fwp setWaypointCompletionRadius 200;
_fwp setWaypointStatements["true", "{ if ((objectParent _x) isnotequalto objNull) then{{deleteVehicle _x;}foreach crew objectParent _x;deleteVehicle(objectParent _x);};deleteVehicle _x;}foreach thislist;"];

//handle return and garbage

[_cargogroup, _dropship, _garbage,(_nojump call ePara_fnc_canJump)] spawn ePara_fnc_garbagecollectorCaller;

[_cargogroup, _dropship, _dropship_group];