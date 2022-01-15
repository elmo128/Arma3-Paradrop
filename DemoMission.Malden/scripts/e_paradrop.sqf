/*
* 
*	available at https://github.com/elmo128/Arma-3-Paradrop.
* 
*	MIT License
*
*	Copyright(c) 2022 elmo128(60213508 + elmo128@users.noreply.github.com)
*
*	Permission is hereby granted, free of charge, to any person obtaining a copy
*	of this softwareand associated documentation files(the "Software"), to deal
*	in the Software without restriction, including without limitation the rights
*	to use, copy, modify, merge, publish, distribute, sublicense, and /or sell
*	copies of the Software, and to permit persons to whom the Software is
*	furnished to do so, subject to the following conditions :
*
*	The above copyright noticeand this permission notice shall be included in all
*	copies or substantial portions of the Software.
*
*	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
*	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*	SOFTWARE.
*
*   parameters:
*   to use default value, pass bool false might display a WARNING onscreen!
*   0, destination:				DEFAULT: N/A (MUST BE VALID!)		location where the paratroopers are dropped (marker, position ASL, object) 
*   1, dropshipSpawnPosition:	DEFAULT: [1,1,1]					location where dropship and paratroopers are initially spawn (marker, position ASL, object) 
*   2, dropshipDESpawnPosition:	DEFAULT: [1,1,1]					location where dropship will despawn (marker, position ASL, object) 
*   3, side:					DEFAULT: east						side of dropship crew and cargo[east,west,..]: 
*   4, vehicleType:				DEFAULT: "B_T_VTOL_01_infantry_F"	vehicletype that is used as dropship [""]:  *   == V-44X Blackfish (Infantry Transport) *   using a different type of vehicle might need tweaking
*   5, skillmin:				DEFAULT: 0.1						the paratroopers' min skill level [0-1]. 
*   6, skillmax:				DEFAULT: 0.9						the paratroopers' max skill level [0-1]. 
*   7, variable ARRAY:			DEFAULT: [].						of type [varspace , name, public(optional)] (https:*  community.bistudio.com/wiki/setVariable) if you need the return values saved to something 
*   8, nojump:					DEFAULT: scriptNull					can be a script handle (scriptDone == true  => NO JUMP) OR object(alive == false  => NO JUMP) OR [varspace , name] (getVariable == false => NO JUMP) will be evaluated before jumping.
*   9, parachutetype.			DEFAULT:"B_Parachute"				Select one parachute of type , it is the fully compatible backpack that does not require any workarounds.    ["B_Parachute", "Steerable_Parachute_F","NonSteerable_Parachute_F", "B_Parachute_02_F","O_Parachute_02_F","I_Parachute_02_F"] or add one to the defines below.
*   10,jumpdistancetime:		DEFAULT: 0.15						the time between the parajumpers when leaving the plane [sec.].  
*   11,jumpheight:				DEFAULT: 150						height the dropship is flying when dropping passengers.[m]  *  changing this might need tweaking and is never guaranteed
*   12,jumpearly:				DEFAULT: 0							correction factor to adjust the moment where they start jumping[m]. *   might need adjustment, if jumpheight or jumpdistancetime was modified to make the paratroopers still beeing dropped over the destination.
*   13,_forceopenParachute		DEFAULT: -1							-1: AI decides when to open, 0 <= x <= 20 time to open parachute after leaving dropship, >20 height parachute is forced open. MUST BE SET WHEN USING CARGO PARACHUTE !
*   
*   return:
*   [_cargogroup, _dropship, _dropship_group, _garbage];
*  	0, _cargogroup == the group of the parajumpers in the cargospace
*  	1, _dropship == the dropship vehicle
*  	2, _dropship_group == the group of the non jumping dropship crew: pilots doorgunners,...
*  	3, _garbage == script handles, units and waypoints created by this script. 
*  
*   NOTE: the higher the processing power, the more accurate the drop location.
*   MINIMUM WORKING call:  [destination] execVM "e_paradrop.sqf"; // eg. [player] execVM "e_paradrop.sqf";
*   MINIMUM RECOMMENDED call: [destination, dropshipSpawnlocation, dropshipDESpawnlocation] execVM "e_paradrop.sqf";
*   MAXIMUM PARAMETERS call: [destination, dropshipSpawnlocation, dropshipDESpawnlocation, side,vehicleType,skillmin,skillmax,variable,nojump,parachutetype,jumpdistancetime,jumpheight,jumpearly] execVM "e_paradrop.sqf";
*   MAXIMUM PARAMETERS call: ["mrk15", [1,1,1], [1,1,1], east,"B_T_VTOL_01_infantry_F",0.1,0.9,[],scriptNull,"O_Parachute_02_F",0.15,150,0] execVM "e_paradrop.sqf";
*/

// default defines can be changed using parameters, no need to change them here!
#define DEFAULT_LOC [1,1,1]
#define DEFAULT_SIDE east
#define DEFAULT_DROPSHIP "B_T_VTOL_01_infantry_F"
#define DEFAULT_SKILLMIN 0.1
#define DEFAULT_SKILLMAX 0.9
#define DEFAULT_JUMPDISTANCE 0.15
#define DEFAULT_HEIGHT 150
#define DEFAULT_JEARLY 0
#define DEFAULT_VARIABLE []
#define DEFAULT_SCRIPT scriptNull
#define DEFAULT_PARACHUTE "B_Parachute"
#define DEFAULT_PARACHUTEFORCEOPEN -1

// internal use
#define DROPSPEED 220
#define DROPSPEEDBREAKLENGTH 2500
#define DROPLENGTH 3000
#define PARACHUTETYPE "O_Parachute_02_F"			// Parachutetype to use

#define PARACHUTTYPE_HUMAN_BACKPACK ["B_Parachute"]										// (list) parachute backpacks, fully animated, maximum compatibility
#define PARACHUTTYPE_HUMAN ["Steerable_Parachute_F","NonSteerable_Parachute_F"]			// (list) no backpack, spawn as vehicle when outside, but animations for humans available
#define PARACHUTETYPE_CARGO ["B_Parachute_02_F","O_Parachute_02_F","I_Parachute_02_F"]	// (list) no backpack, spawn as vehicle when outside, no animations for humans available

#define NACK -1
#define INVINCIBILITY_AFTER_JUMP 3;			// time in [s]
#define GARBAGE_BIN "Land_PencilBlue_F"		// object for internal use. will be despawned with garbage
#define GARBAGE_BIN_VAR_NAME "Junk11"			
#define ENABLEDISTANCE_VTOL 1500			//enable VTOL before reaching drop locataion, helps AI to reduce speed [m] will be enabled again, after paradrop is completed


// opens most doors and ramps of a vehicle
openDoors =
{
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
};

// close most doors and ramps of a vehicle
closeDoors =
{
	private _vehicle = param[0];
	private _actionlist = ((configOf _vehicle) >> "UserActions") call bis_fnc_returnchildren;
	sleep 2;
	{
		private _pth = [_x, ""] call BIS_fnc_configPath;
		private _pthL = toLower _pth;
		if (("door" in _pthL) || ("ramp"  in _pthL)) then
		{
			if ("close" in _pthL) then
			{
				private _statement = (_x >> "statement") call BIS_fnc_getCfgData;
				private _thispos = _statement find "this";
				_statement = _statement insert[_thispos, "_"];
				_vehicle call compile _statement;
			};
		};
	}foreach _actionlist;
	//orca
	_vehicle animate["dvere1_posunZ", 0];
	_vehicle animate["dvere2_posunZ", 0];
};

// writes the return to a object, namespace,... if asked by parameters
writeReturnVaraible =
{
//	diag_log["writeReturnVaraible",_this];
	private _varData = param[0,[]];
	private _return = param[1,[]];

	if (count _varData  isEqualTo 2) then
	{
		(_varData select 0) setVariable[(_varData select 1), _return];
	};
	if (count _varData  isEqualTo 3) then
	{
		(_varData select 0) setVariable[(_varData select 1), _return, (_varData select 2)];
	};
};

// check if the jump condition is met. access to objects, script handlers, variables in namespaces
checkjumpcondition =
{
//	diag_log["checkjumpcondition",_this];
	private _condcode = param[0];
	private _jump = true;
	if (typename _condcode isEqualto "SCRIPT") then
	{
		if (!scriptDone _condcode) then // no jump if script NOT running
		{
			_jump = false; 
		};
	};
	if (typename _condcode isEqualto "OBJECT") then
	{
			_jump = alive _condcode; // no jump if dead
	};
	if (typename _condcode isEqualto "ARRAY") then
	{
		if (count _condcode  isEqualTo 2) then
		{
			_jump = (_condcode select 0) getVariable[(_condcode select 1), true]; // no jump if variable set to false
		};
	};
	_jump;
};

// teminates all possible remains when dropship not alive and cargo (paratroopers) are killed
garbagecollectorCaller =
{
//	diag_log["garbagecollectorCaller",_this];
	private _cargogroup = param[0];
	private _dropship = param[1];
	private _Lgarbage = param[2,[]];
	private _jumped = param[3, false]; // optional. if there should have never been a jump, don't wait for cargo group beeing killed, remove possible dropped paratroopers with vehicle!
	waitUntil
	{
		sleep 30;
		(!alive _dropship) && (((count units _cargogroup)  isEqualTo 0) || !_jumped);
	};
	sleep 60;
	[_Lgarbage] call garbagecollector;
};

// terminates all scripts, removes all units and waypoints ever created
garbagecollector =	
{
//	diag_log["garbagecollector",_this];
	private _Lgarbage = param[0,[]];

	if ((count _Lgarbage) != 0) then
	{
		{
			if (typename _x isEqualto "SCRIPT") then
			{
				if (!isNull _x) then
				{
					terminate _x;
				};
			};
			if (typename _x isEqualto "OBJECT") then
			{
				if (_x isKindOf GARBAGE_BIN) then
				{
					private _bin = _x getVariable[GARBAGE_BIN_VAR_NAME,[]];
					_Lgarbage append _bin;
					uisleep 0.01;
				};
				deleteVehicle _x;
			};
			if (typename _x isEqualto "ARRAY") then // waypoint
			{
				if ((count _x  isEqualTo 2) && (typename (_x select 0) isEqualto "GROUP") && (typename (_x select 1) isEqualto "SCALAR")) then
				{
					deleteWaypoint _x;
				};
			};
		}foreach _Lgarbage;
	};
};

// despawn all units belonging to the initial crew group
despawnPilots =
{
//	diag_log["despawnPilots",_this];
	private _dropship = param[0, objNull];
	private _dropship_group = param[1];
	waitUntil {!alive _dropship};
	sleep 10;
	if ((count (units _dropship_group))  isEqualTo 0) exitWith{};
	{
		if (alive _x) then
		{
			deleteVehicle _x;	// _x setdamage 1;
		};
	}foreach (units _dropship_group);
};

// despawn all units in the dropship
despawnCrew =
{
//	diag_log["despawnCrew",_this];
	private _dropship = param[0, objNull];
	waitUntil {!alive _dropship};
	sleep 10;
	if ((count (crew _dropship))  isEqualTo 0) exitWith{};
	{
		if (alive _x) then
		{
			deleteVehicle _x;	// _x setdamage 1;
		};
	}foreach (crew _dropship);
};

// reattatch backpacks after parachutes are not in their slot anylonger
reattatchBackpack =
{
//	diag_log["reattatchBackpack",_this];
	private _unit = param[0, objNull];
	private _backpack = param[1,""];
	private _backpack_items = param[2,[]];
	waituntil
	{
		(!alive _unit) || (isTouchingGround _unit) || (""  isEqualTo backpack _unit); //unit died, paracchoote opened or touching ground
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
};

noBackpackparachute =
{
	private _unit = param[0];
	private _parachuteVehicleType = param[1];
	private _garbageobj = param[3, objnull, [objnull]];

	private _parachute = objnull;
	private _garbage = [];
	if (_garbageobj != objnull) then
	{
		_garbage = _garbageobj getVariable[GARBAGE_BIN_VAR_NAME,[]];
	};
	if ( (!((tolower _parachuteVehicleType) in (PARACHUTTYPE_HUMAN_BACKPACK apply{tolower _x;}))) && (((tolower _parachuteVehicleType) in (PARACHUTTYPE_HUMAN apply{tolower _x;})) || ((tolower _parachuteVehicleType) in (PARACHUTETYPE_CARGO apply{tolower _x; })))) then
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

		if ((tolower _parachuteVehicleType) in (PARACHUTTYPE_HUMAN  apply{tolower _x;})) then
		{
			_unit moveInAny _parachute;
		};
		if ((tolower _parachuteVehicleType) in (PARACHUTETYPE_CARGO apply{tolower _x;})) then
		{
			_unit attachTo[_parachute,[0, -0.3, 0]];
			waitUntil{ isTouchingGround _unit };
			detach _unit;
		};
	};
	_parachute;
};

//force open parachutes at altitude, time after jump or make ai decide
parachuteForceOpen =
{
//	diag_log["parachuteForceOpen",_this];
	private _unit = param[0, objNull];
	private _setting = param[1, NACK]; 
	private _paratype = param[2, DEFAULT_PARACHUTE];
	private _garbageobj = param[3, objnull, [objnull]];

	if (_setting  isEqualTo NACK) exitWith{};
	if ((_setting >= 0) && (_setting <= 20)) then
	{
		uisleep _setting;
	}
	else
	{
		if (_setting > 20) then
		{
			waituntil
			{
				((getPosATL _unit) select 2) <= _setting;
			};
		};
	};
	if (alive _unit) then
	{
		if ((tolower _paratype) in (PARACHUTTYPE_HUMAN_BACKPACK apply {tolower _x; })) then
		{
			_unit action["OpenParachute", _unit];
		}
		else
		{
			[_unit, _paratype, _garbageobj] call noBackpackparachute;
		};
	};
};

//is dropship a vtol?
getVtolcapabilities =
{
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
};

// force AI to keep angle of engined at 0°
forceVTOLdown =
{
	private _dropship = param[0];
	if ((_dropship call getVtolcapabilities) > 0) then
	{
		while {(alive _dropship) && (alive(currentPilot _dropship))} do
		{
			sleep 0.1;
			(currentPilot _dropship) action["VTOLVectoring", _dropship]; // disable
			(currentPilot _dropship) action["VectoringDown", _dropship]; // turn in front 
		};
	};
};

// calculate cordinates and bearings from different input types
scanInputLocation =
{
	private _anything = param[0];

	private _location = DEFAULT_LOC;
	private _bearing = 0;

	if (typename _anything isEqualto "STRING") then
	{
		_location = markerpos _anything;
		_bearing = markerDir _anything;
	}
	else
	{
		if (typename _anything isEqualto "OBJECT") then
		{
			_location = getPosASL _anything;
			_bearing = getDir _anything;
		};
		if (typename _anything isEqualto "ARRAY") then
		{
			if (count _anything  isEqualTo 3) then
			{
				_location = _anything;
				_bearing = random 360;
			};
		}
		else { if (true) exitWith{ diag_log["paradrop_script: invalid can't handle input type:",_anything]; }; };
	};
	[_location, _bearing];
};

// main
paradrop = 
{
//	diag_log["paradrop begin",_this];
	if (!canSuspend) exitWith {diag_log "paradrop_script: noParadrop possible, can't suspend code"; };
	disableserialization;

	// input parameters
	private _iDpos = [_this, 0, [], [objNull, [], ""]] call BIS_fnc_param;
	private _iSpos = [_this, 1, DEFAULT_LOC, [objNull, [], ""]] call BIS_fnc_param;
	private _iDSpos = [_this, 2, DEFAULT_LOC, [objNull, [], ""]] call BIS_fnc_param;
	private _dsSide = [_this, 3, DEFAULT_SIDE, [DEFAULT_SIDE]] call BIS_fnc_param;
	private _vehicletype = [_this, 4, DEFAULT_DROPSHIP, [DEFAULT_DROPSHIP]] call BIS_fnc_param;
	private _skillmin = [_this, 5, DEFAULT_SKILLMIN, [0]] call BIS_fnc_param; 
	private _skillmax = [_this, 6, DEFAULT_SKILLMAX, [0]] call BIS_fnc_param; 
	private _retvariable = [_this, 7, [],[]] call BIS_fnc_param;
	private _nojump = [_this, 8, NACK, [DEFAULT_SCRIPT, objNull, []]] call BIS_fnc_param;
	private _parachutetype = [_this, 9, DEFAULT_PARACHUTE] call BIS_fnc_param;
	private _jumpdistancetime = [_this, 10, DEFAULT_JUMPDISTANCE, [0]] call BIS_fnc_param;
	private _jumpheight = [_this, 11, DEFAULT_HEIGHT, [0]] call BIS_fnc_param;
	private _jumpearly = [_this, 12, DEFAULT_JEARLY, [0]] call BIS_fnc_param;
	private _forceParachute = [_this, 13, DEFAULT_PARACHUTEFORCEOPEN, [0]] call BIS_fnc_param;
		
	//parse input locations
	private _destinationpos = (_iDpos call scanInputLocation) select 0;
	private _finaldestination = (_iDSpos call scanInputLocation) select 0;
	private _vehiclespawncoordinates = (_iSpos call scanInputLocation) select 0;
	private _vehiclespawnbearing = (_iSpos call scanInputLocation) select 1;

	private _garbage = [];
	private _isVTOL = 0;

	if (!isNull _thisScript) then { _garbage pushback _thisScript };
	// let's go

	// create garbage bin
	private _bin = objnull;
	if (!((tolower _parachutetype) in (PARACHUTTYPE_HUMAN_BACKPACK apply{ tolower _x; }))) then
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
	_isVTOL = _dropship call getVtolcapabilities;
	_dropship_group deleteGroupWhenEmpty true;
	_garbage pushback([_dropship, _dropship_group] spawn despawnPilots);

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

	private _despawncrewhandle = [_dropship] spawn despawnCrew;
	_garbage pushback _despawncrewhandle;
	//debug handle to cargo
	ds1c = _cargogroup;

	{
		_x assignAsCargo _dropship;
		[_x] allowgetin true;
		[_x] orderGetIn true;
		_x moveInCargo _dropship;
		_garbage pushback _x;
	}foreach units _cargogroup;

	_cargogroup deleteGroupWhenEmpty true;

	private _forceVTOLdown = _dropship spawn forceVTOLdown;
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
				_garbage pushback(_dropship spawn openDoors);

				// destination spawnpoint almost reached, initiate drop
				if ((_WP2D distance _DS2D) < ((speed _dropship) + (_jumpheight / 2 + _jumpheight / 10) + _jumpearly)) then //jumpJumpJump
				{
					terminate _despawncrewhandle;
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
					if (_nojump call checkjumpcondition) then
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
						_garbage pushback(_x spawn{ _this allowdamage false; uisleep INVINCIBILITY_AFTER_JUMP; _this allowdamage true; });
						_garbage pushback([_x, _forceParachute, _parachutetype, _bin] spawn parachuteForceOpen);
						if (_backpack isnotequalto "") then
						{
							_garbage pushback([_x, _backpack, _contents] spawn reattatchBackpack);
						};
						uisleep _jumpdistancetime;
					};
				}foreach(units _cargogroup);
			};
					// final settings for fast departure
					_onboard = false;
					_dropship flyInHeight _jumpheight;
					_garbage pushback(_dropship spawn closeDoors);
					_garbage pushback _nwp;
					_dropship limitSpeed 999;
					_dropship forceSpeed 998;
					_dropship flyInHeight 105;
					_cargogroup enableAttack true;
					deleteWaypoint _WP_destination;
					_dropship_group setSpeedMode "FULL";
					if (scriptdone _forceVTOLdown) then
					{
						_garbage pushback(_dropship spawn forceVTOLdown);
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
	private _return = [_cargogroup, _dropship, _dropship_group, _garbage];
	[_retvariable, [_cargogroup, _dropship, _dropship_group, _garbage]] call writeReturnVaraible;
	[_cargogroup, _dropship, _garbage,(_nojump call checkjumpcondition)] spawn garbagecollectorCaller;

	_return; // returns [group paratroopers, dropship, group dropship, _garbage] (_garbage == script handles, units and waypoints created by this script. call the garbagecollector with this to remove possible remains. groups will be removed when empty by default. flying parachutes will remain).
};

// call main
_this call paradrop;