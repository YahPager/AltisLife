#include "..\..\script_macros.hpp"
/*
█████████File: fn_vehicleSiren.sqf██████████
███████████████Author: Pager████████████████
██████████Date Created: 05.28.2026██████████
███████Date Modified: 05.28.2026 v1.1███████
*/

_this params [
	["_vehicle", objNull, [objNull]],
	["_sirens", [], [[]]],
	["_on", true, [false]]
];

if (isNull _vehicle) exitWith {};

// Clean up any existing siren safely
private _oldSiren = _vehicle getVariable ["siren", objNull];
if (!isNull _oldSiren) then {
	deleteVehicle _oldSiren;
};

// Always clear stored reference to avoid dangling vars
_vehicle setVariable ["siren", objNull, true];

// Turn OFF logic
if (!_on) exitWith {
	// Reset selection safely (keep type consistent)
	_vehicle setVariable ["selected_siren", 0, true];
};

// Validate siren list
if (_sirens isEqualTo []) exitWith {};

// Select siren safely
private _index = _vehicle getVariable ["selected_siren", 0];

// clamp index to valid range
_index = _index max 0 min ((count _sirens) - 1);

private _siren = _sirens select _index;

if (_siren isEqualTo "") exitWith {};

// Create and attach sound source
private _source = createSoundSource [_siren, position _vehicle, [], 0];

if (isNull _source) exitWith {};

_source attachTo [_vehicle, [0, 0, 0]];

// store globally for cleanup / JIP sync
_vehicle setVariable ["siren", _source, true];
