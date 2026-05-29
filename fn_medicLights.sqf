/*
██████████File: fn_medicLights.sqf██████████
████Author: [GSN] Pager & [GSN] Paronity████
██████████Date Created: 02.24.2015██████████
███████Date Modified: 05.28.2026 v6.1███████
*/
// ============================================================================
// fn_medicLights.sqf
// Attaches and animates emergency medic lights on supported vehicles.
//
// Usage:  [vehicle] call fn_medicLights;
//
// Flash pattern: "WIGWAG" — left and right alternate (classic wig-wag)
// ============================================================================

if (!hasInterface) exitWith {};

private _vehicle = param [0, objNull, [objNull]];
if (isNull _vehicle) exitWith {};

// Hardened nil/false guard
private _lightsVar = _vehicle getVariable "lights";
if (isNil "_lightsVar" || { !_lightsVar }) exitWith {};

if ((player distance _vehicle) > 500) exitWith {};

uiSleep 1;

// ── Tunables ──────────────────────────────────────────────────────────────────

#define FLASH_COUNT   4      // flashes per side per cycle
#define FLASH_ON      0.05   // seconds light stays ON per flash
#define FLASH_OFF     0.075  // seconds between flashes (light OFF)
#define CYCLE_PAUSE   0.0    // optional pause between full L/R cycles

// Light colours (RGB)
#define COL_RED    [1, 0, 0]
#define COL_WHITE  [1, 1, 1]
#define COL_YELLOW [1, 1, 0]

// ── Day / night brightness ─────────────────────────────────────────────────────

private _brightnessHigh = 0;
private _attenuation    = [];
private _intensity      = 0;

if (sunOrMoon < 0.2) then {
    _brightnessHigh = 100;
    _attenuation    = [0.001, 0,    50, 2500000, 0.001, 250];
    _intensity      = 1000;
} else {
    _brightnessHigh = 20;
    _attenuation    = [0.001, 3000, 50,  500000, 0.001, 250];
    _intensity      = 100;
};

// ── Light factory ──────────────────────────────────────────────────────────────
// Creates and attaches a single light point.
// Returns the light object.
//
// _colorArr  : RGB array (use COL_* macros)
// _position  : model-space offset [x, y, z]
//              +x = driver's right | -x = driver's left
//              +y = forward        | -y = rearward

private _fnCreateLight = {
    params ["_colorArr", "_position"];

    private _light = "#lightpoint" createVehicleLocal (getPos _vehicle);
    _light setLightAmbient    [0, 0, 0];
    _light setLightBrightness 0;
    _light setLightAttenuation _attenuation;
    _light setLightIntensity   _intensity;
    _light setLightColor       _colorArr;
    _light lightAttachObject  [_vehicle, _position];

    _light  // return
};

// ── Vehicle light definitions ──────────────────────────────────────────────────
// Format per entry: [side, colorMacro, [x, y, z]]
//   side : "L" = driver's left (x < 0) | "R" = driver's right (x > 0)

private _leftLights  = [];
private _rightLights = [];
private _pattern     = "WIGWAG";   // default; overridden per vehicle

private _buildLights = {
    params ["_defs"];
    {
        _x params ["_side", "_color", "_pos"];
        private _light = [_color, _pos] call _fnCreateLight;
        if (_side == "L") then { _leftLights  pushBack _light; }
                          else { _rightLights pushBack _light; };
    } forEach _defs;
};

switch (typeOf _vehicle) do
{
    // ── Civilian Offroad ───────────────────────────────────────────────────────
    case "C_Offroad_01_F":
    {
        _pattern = "WIGWAG";
        [
            // Roof bar
            ["L", COL_RED,    [-0.440,  0.000,  0.5125]],
            ["R", COL_YELLOW, [ 0.345,  0.000,  0.5125]],
            // Rear low
            ["R", COL_RED,    [ 0.575, -2.950, -0.7700]],
            ["L", COL_YELLOW, [-0.645, -2.950, -0.7700]],
            // Rear mid
            ["L", COL_RED,    [-0.905, -2.875, -0.2250]],
            ["R", COL_RED,    [ 0.825, -2.875, -0.2250]],
            // Front bumper
            ["R", COL_WHITE,  [ 0.610,  2.2825,-0.3550]],
            ["L", COL_WHITE,  [-0.695,  2.2825,-0.3550]]
        ] call _buildLights;
    };

    // ── BG Repair / Repair Offroad (shared layout) ─────────────────────────────
    case "B_G_Offroad_01_repair_F";
    case "O_Offroad_01_repair_F":
    {
        _pattern = "SIMULTANEOUS";
        [
            // Roof bar — both sides yellow for repair/utility
            ["L", COL_YELLOW, [-0.440, 0, 0.5125]],
            ["R", COL_YELLOW, [ 0.345, 0, 0.5125]]
        ] call _buildLights;
    };

    // ── SUV ────────────────────────────────────────────────────────────────────
    case "C_SUV_01_F":
    {
        _pattern = "WIGWAG";
        [
            // Front
            ["L", COL_RED,    [-0.390,  2.280, -0.520]],
            ["R", COL_YELLOW, [ 0.380,  2.280, -0.520]],
            // Rear
            ["L", COL_RED,    [-0.860, -2.750, -0.180]],
            ["R", COL_RED,    [ 0.860, -2.750, -0.180]],
            ["L", COL_YELLOW, [-0.600, -2.925, -0.240]],
            ["R", COL_YELLOW, [ 0.590, -2.925, -0.240]],
            // Side whites
            ["R", COL_WHITE,  [ 0.800,  1.950, -0.480]],
            ["L", COL_WHITE,  [-0.800,  1.950, -0.480]]
        ] call _buildLights;
    };

    // ── Hatchback ──────────────────────────────────────────────────────────────
    case "C_Hatchback_01_F":
    {
        _pattern = "ALTERNATE";
        [
            ["L", COL_RED,    [-0.030,  0.000,  0.200]],
            ["R", COL_YELLOW, [-0.030,  0.000,  0.200]],
            ["L", COL_RED,    [-0.800, -2.250, -0.300]],
            ["R", COL_YELLOW, [ 0.780, -2.250, -0.300]],
            ["R", COL_WHITE,  [ 0.750,  1.615, -0.520]],
            ["L", COL_WHITE,  [-0.800,  1.615, -0.525]]
        ] call _buildLights;
    };

    // ── Sport Hatchback ────────────────────────────────────────────────────────
    case "C_Hatchback_01_sport_F":
    {
        _pattern = "ALTERNATE";
        [
            ["L", COL_RED,    [-0.030,  0.000,  0.200]],
            ["R", COL_YELLOW, [-0.030,  0.000,  0.200]],
            ["L", COL_RED,    [-0.800, -2.250, -0.300]],
            ["R", COL_YELLOW, [ 0.780, -2.250, -0.300]],
            ["R", COL_WHITE,  [ 0.750,  1.615, -0.520]],
            ["L", COL_WHITE,  [-0.800,  1.615, -0.525]]
        ] call _buildLights;
    };

    // ── Box Truck ──────────────────────────────────────────────────────────────
    case "C_Truck_02_box_F":
    {
        _pattern = "WIGWAG";
        [
            // Cab roof
            ["L", COL_RED,    [-0.790, -0.17275,  1.325]],
            ["R", COL_YELLOW, [ 0.750, -0.17275,  1.325]],
            // Cab front
            ["L", COL_RED,    [-0.710,  2.12750, -0.750]],
            ["R", COL_YELLOW, [ 0.675,  2.12750, -0.750]],
            // Front whites
            ["R", COL_WHITE,  [ 0.620,  1.93000, -0.400]],
            ["L", COL_WHITE,  [-0.665,  1.93000, -0.400]],
            // Centre roof
            ["L", COL_WHITE,  [-0.025, -0.17275,  1.325]],
            // Rear bar
            ["L", COL_RED,    [-0.735, -3.47250,  1.260]],
            ["R", COL_RED,    [ 0.7125,-3.47250,  1.260]],
            ["L", COL_YELLOW, [-0.225, -3.47250,  1.260]],
            ["R", COL_YELLOW, [ 0.210, -3.47250,  1.260]]
        ] call _buildLights;
    };

    // ── Strider (MRAP) ─────────────────────────────────────────────────────────
    case "I_MRAP_03_F":
    {
        _pattern = "WIGWAG";
        [
            // Front
            ["R", COL_YELLOW, [ 0.900,  2.200, -0.800]],
            ["L", COL_RED,    [-0.900,  2.200, -0.800]],
            // Rear
            ["R", COL_YELLOW, [ 0.000, -3.000,  0.025]],
            ["L", COL_RED,    [-0.725, -3.100,  0.025]],
            // Side whites
            ["L", COL_WHITE,  [ 1.050,  2.250, -0.300]],
            ["R", COL_WHITE,  [-1.050,  2.250, -0.300]]
        ] call _buildLights;
    };

    // ── Ifrit (MRAP) ───────────────────────────────────────────────────────────
    case "O_MRAP_02_F":
    {
        _pattern = "ALTERNATE";
        [
            // Side mid
            ["R", COL_YELLOW, [ 1.175, -1.500,  0.3650]],
            ["L", COL_RED,    [-1.175, -1.500,  0.3650]],
            // Roof rear
            ["L", COL_RED,    [-0.4325,-1.500,  0.6275]],
            ["R", COL_YELLOW, [ 0.4325,-1.500,  0.6275]],
            // Front low
            ["L", COL_RED,    [-0.200,  1.575, -1.1250]],
            ["R", COL_YELLOW, [ 0.200,  1.575, -1.1250]],
            // Front whites
            ["L", COL_WHITE,  [-0.775,  1.475, -1.0000]],
            ["R", COL_WHITE,  [ 0.775,  1.475, -1.0000]],
            // Rear upper
            ["R", COL_RED,    [ 0.525, -4.500, -1.3000]],
            ["L", COL_YELLOW, [-0.525, -4.500, -1.3000]],
            // Rear lower
            ["L", COL_RED,    [-0.400, -4.950,  0.1550]],
            ["R", COL_YELLOW, [ 0.400, -4.950,  0.1550]]
        ] call _buildLights;
    };

    default {
        diag_log format ["[MedicLights] Unsupported vehicle type: %1", typeOf _vehicle];
    };
};

// ── Guard: nothing attached → bail ────────────────────────────────────────────
if (_leftLights isEqualTo [] && { _rightLights isEqualTo [] }) exitWith {
    diag_log "[MedicLights] No lights attached — aborting.";
};

// ── Flash helpers ──────────────────────────────────────────────────────────────
// Burst: flash one set of lights N times.
private _fnBurst = {
    params ["_lights"];
    for "_i" from 1 to FLASH_COUNT do {
        { _x setLightBrightness _brightnessHigh; } forEach _lights;
        uiSleep FLASH_ON;
        { _x setLightBrightness 0; } forEach _lights;
        uiSleep FLASH_OFF;
    };
};

// Wig-wag step: L on while R off, then swap — one interleaved pair per call.
private _fnWigwagStep = {
    // Phase A: left ON, right OFF
    { _x setLightBrightness _brightnessHigh; } forEach _leftLights;
    { _x setLightBrightness 0;               } forEach _rightLights;
    uiSleep FLASH_ON;
    { _x setLightBrightness 0;               } forEach _leftLights;
    uiSleep FLASH_OFF;

    // Phase B: right ON, left OFF
    { _x setLightBrightness _brightnessHigh; } forEach _rightLights;
    { _x setLightBrightness 0;               } forEach _leftLights;
    uiSleep FLASH_ON;
    { _x setLightBrightness 0;               } forEach _rightLights;
    uiSleep FLASH_OFF;
};

// ── Active-check closure ───────────────────────────────────────────────────────
private _fnIsActive = {
    if (!alive _vehicle) exitWith { false };
    private _v = _vehicle getVariable ["lights", false];
    !isNil "_v" && { _v }
};

// ── Main flash loop ────────────────────────────────────────────────────────────
while { call _fnIsActive } do {
    switch (_pattern) do {

        case "ALTERNATE": {
            [_leftLights]  call _fnBurst;
            [_rightLights] call _fnBurst;
        };

        case "WIGWAG": {
            for "_i" from 1 to FLASH_COUNT do {
                call _fnWigwagStep;
            };
        };

        case "SIMULTANEOUS": {
            [_leftLights + _rightLights] call _fnBurst;
            // brief pause so SIMULTANEOUS doesn't look identical to rapid ALTERNATE
            uiSleep 0.15;
        };
    };

    if (CYCLE_PAUSE > 0) then { uiSleep CYCLE_PAUSE; };
};

// ── Cleanup ────────────────────────────────────────────────────────────────────
{ deleteVehicle _x; } forEach (_leftLights + _rightLights);
_leftLights  = [];
_rightLights = [];
