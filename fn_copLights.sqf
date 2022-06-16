/*
███████████File: fn_copLights.sqf███████████
████Author: [GSN] Pager & [GSN] Paronity████
██████████Date Created: 02.24.2015██████████
███████Date Modified: 06.16.2022 v4.0███████
*/

if (!hasInterface) exitWith {}; // Doesn't have interface, no lights.

private _vehicle = param[0, objNull, [objNull]];
if (isNil "_vehicle" || {isNull _vehicle || {!(_vehicle getVariable "lights")}}) exitWith {};
uisleep 1; // Sleep a second to allow syncing, if remoteexec was faster than the variable.

private _redLights = [255, 0.1, 0.1];
private _whiteLights = [255, 255, 255];
private _blueLights = [0.1, 0.1, 255];

if (sunOrMoon isEqualTo 1) then
{ // Night
	private _brightnessLow = 0;
	private _brightnessHigh = 20;
	private _attenuation = [0.001, 3000, 50, 500000, 0.001, 250];
	private _intensity = 100;
} else { // Day
	private _brightnessLow = 0;
	private _brightnessHigh = 100;
	private _attenuation = [0.001, 0, 50, 2500000, 0.001, 250];
	private _intensity = 1000;
};

private _flashes = 3;
private _flashOn = 0.05;
private _flashOff = 0.075;

private _leftLights = [];
private _rightLights = [];

private _attach =
{
	private _isLight = _this select 0;
	private _color = _this select 1;
	private _position = _this select 2;
	private _lights = "#lightpoint" createVehicleLocal getPos _vehicle;
	uisleep 0.2;
	_lights setLightAmbient [0,0,0];
	_lights setLightBrightness 0;
	_lights setLightAttenuation _attenuation;
	_lights setLightIntensity _intensity;
	_lights setLightFlareSize 1;
	_lights setLightFlareMaxDistance 150;
	_lights setLightUseFlare true;

	switch (_color) do
	{
		case "RED": { _lights setLightColor _redLights; };
		case "WHITE": { _lights setLightColor _whiteLights; }; // Always headlights except on Pub Cops & Pub Medics White isn't used.
		case "BLUE": { _lights setLightColor _blueLights; };
	};

	if (_isLight) then
	{
		_leftLights pushBack [_lights, _position];
	} else {
		_rightLights pushBack [_lights, _position];
	};

	_lights lightAttachObject [_vehicle, _position];
};

switch (typeOf _vehicle) do
{
	case "C_Offroad_01_F": // Offroad
	{
		[false, "RED", [-0.44, 0, 0.525]] call _attach;
		[true, "BLUE", [0.345, 0, 0.525]] call _attach;
		[false, "RED", [0.575, -2.95, -0.77]] call _attach;
		[true, "BLUE", [-0.645, -2.95, -0.77]] call _attach;
		[false, "RED", [-0.905, -2.875, -0.225]] call _attach;
		[true, "RED", [0.825, -2.875, -0.225]] call _attach;
		[false, "WHITE", [0.61, 2.2825, -0.355]] call _attach;
		[true, "WHITE", [-0.695, 2.2825, -0.355]] call _attach;
	};

	case "B_G_Offroad_01_F": // BG_Offroad
	{
		[false, "RED", [0.575, -2.95, -0.77]] call _attach;
		[true, "BLUE", [-0.645, -2.95, -0.77]] call _attach;
		[false, "RED", [-0.905, -2.875, -0.225]] call _attach;
		[true, "RED", [0.825, -2.875, -0.225]] call _attach;
		[true, "BLUE", [0.61, 2.2825, -0.355]] call _attach;
		[false, "RED", [-0.695, 2.2825, -0.355]] call _attach;
	};

	case "C_SUV_01_F": // SUV
	{
		[true, "RED", [-0.39, 2.28, -0.52]] call _attach;
		[false, "BLUE", [0.38, 2.28, -0.52]] call _attach;
		[true, "RED", [-0.86, -2.75, -0.18]] call _attach;
		[true, "RED", [0.86, -2.75, -0.18]] call _attach;
		[false, "BLUE", [-0.6, -2.925, -0.24]] call _attach;
		[false, "BLUE", [0.59, -2.925, -0.24]] call _attach;
		[true, "WHITE", [0.8, 1.95, -0.48]] call _attach;
		[false, "WHITE", [-0.8, 1.95, -0.48]] call _attach;
	};

	case "C_Hatchback_01_F": // Hatch
	{
		[false, "BLUE", [-0.03, 0, 0.2]] call _attach;
		[true, "BLUE", [-0.03, 0, 0.2]] call _attach;
		[false, "BLUE", [-0.8, -2.25, -0.3]] call _attach;
		[true, "BLUE", [0.78, -2.25, -0.3]] call _attach;
		[false, "WHITE", [0.75, 1.615, -0.52]] call _attach;
		[true, "WHITE", [-0.8, 1.615, -0.525]] call _attach;
	};

	case "C_Hatchback_01_sport_F": // Sport
	{
		[false, "RED", [-0.03, 0, 0.2]] call _attach;
		[true, "BLUE", [-0.03, 0, 0.2]] call _attach;
		[false, "RED", [-0.8, -2.25, -0.3]] call _attach;
		[true, "BLUE", [0.78, -2.25, -0.3]] call _attach;
		[false, "WHITE", [0.75, 1.615, -0.52]] call _attach;
		[true, "WHITE", [-0.8, 1.615, -0.525]] call _attach;
	};

	case "B_MRAP_01_F": // Hunter
	{
		[false, "RED", [-0.85, -0.9, 0.6]] call _attach;
		[true, "BLUE", [0.85, -0.9, 0.6]] call _attach;
		[true, "RED", [-0.93, -2.8, 0.6]] call _attach;
		[false, "BLUE", [0.93, -2.8, 0.6]] call _attach;
		[true, "WHITE", [-0.85, 1.475, -0.75]] call _attach;
		[false, "WHITE", [0.85, 1.475, -0.75]] call _attach;
	};

	case "O_MRAP_02_F": // Ifrit
	{
		[false, "BLUE", [1.175, -1.5, 0.365]] call _attach;
		[true, "RED", [-1.175, -1.5, 0.365]] call _attach;
		[false, "RED", [0.4325, -1.5, 0.6275]] call _attach;
		[true, "BLUE", [0.4325, -1.5, 0.6275]] call _attach;
		[true, "RED", [-0.2, 1.575, -1.125]] call _attach;
		[false, "BLUE", [0.2, 1.575, -1.125]] call _attach;
		[false, "WHITE", [-0.775, 1.475, -1]] call _attach;
		[true, "WHITE", [0.775, 1.475, -1]] call _attach;
		[true, "RED", [0.525, -4.5, -1.3]] call _attach;
		[false, "BLUE", [-0.525, -4.5, -1.3]] call _attach;
		[true, "RED", [-0.4, -4.95, 0.155]] call _attach;
		[false, "BLUE", [0.4, -4.95, 0.155]] call _attach;
	};

	case "C_Offroad_02_unarmed_F": // Jeep
	{
		[false, "RED", [0.5, 1.25, -0.16]] call _attach;
		[true, "BLUE", [-0.5, 1.25, -0.16]] call _attach;
	};   
};

private _lightsOn = true;
while {(alive _vehicle)} do
{
	if (!(_vehicle getVariable "lights")) exitWith {};
	if (_lightsOn) then
	{
		for [{_i=0}, {_i<_flashes}, {_i=_i+1}] do
		{
			{ (_x select 0) setLightBrightness _brightnessHigh; } forEach _leftLights;
			uiSleep _flashOn;
			{ (_x select 0) setLightBrightness _brightnessLow; } forEach _leftLights;
			uiSleep _flashOff;
		};
		{ (_x select 0) setLightBrightness 0; } forEach _leftLights;

		for [{_i=0}, {_i<_flashes}, {_i=_i+1}] do
		{
			{ (_x select 0) setLightBrightness _brightnessHigh; } forEach _rightLights;
			uiSleep _flashOn;
			{ (_x select 0) setLightBrightness _brightnessLow; } forEach _rightLights;
			uiSleep _flashOff;
		};
		{ (_x select 0) setLightBrightness 0; } forEach _rightLights;
	};
};

{ deleteVehicle (_x select 0) } foreach _leftLights;
{ deleteVehicle (_x select 0) } foreach _rightLights;

private _leftLights = [];
private _rightLights = [];
 
