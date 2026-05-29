/*
███████File: fn_medicSirenLights.sqf████████
███████████████Author: Pager████████████████
██████████Date Created: 05.28.2026██████████
███████Date Modified: 05.28.2026 v1.1███████
*/
// ============================================================================
// fn_medicSirenLights.sqf
// Attaches and animates siren lights on supported medic vehicles.
// Runs ALONGSIDE fn_medicLights — both scripts active at the same time.
//
// Usage:  [vehicle] call fn_medicSirenLights;
//
// Trigger condition: BOTH "lights" AND "siren" vehicle variables must be true.
//
// Flash pattern: "WIGWAG_HOLD"
//   — left side bursts, right side bursts, then both sides hold ON briefly.
//   Covers two light groups per vehicle:
//     • Primary  — same positions as fn_medicLights (brighter, faster)
//     • Grille   — extra low-mount grille / dash lights
// ============================================================================

if (!hasInterface) exitWith {};

private _vehicle = param [0, objNull, [objNull]];
if (isNull _vehicle) exitWith {};

// Both "lights" AND "siren" must be true
private _lightsVar = _vehicle getVariable "lights";
private _sirenVar  = _vehicle getVariable "siren";
if (isNil "_lightsVar" || { !_lightsVar })  exitWith {};
if (isNil "_sirenVar"  || { !_sirenVar  })  exitWith {};

if ((player distance _vehicle) > 500) exitWith {};

uiSleep 1;

// ── Tunables ──────────────────────────────────────────────────────────────────

#define FLASH_COUNT   3      // flashes per side before the hold
#define FLASH_ON      0.03   // seconds light stays ON per flash  (faster than medicLights)
#define FLASH_OFF     0.05   // seconds between flashes (light OFF)
#define HOLD_DURATION 0.15   // seconds both sides stay ON together after the wig-wag burst
#define CYCLE_PAUSE   0.05   // pause between full wig-wag+hold cycles

// Light colours (RGB)
#define COL_RED    [1, 0, 0]
#define COL_WHITE  [1, 1, 1]
#define COL_YELLOW [1, 1, 0]

// ── Day / night brightness ─────────────────────────────────────────────────────
// Siren lights run slightly brighter than regular medic lights to stand out.

private _brightnessHigh = 0;
private _brightnessHold = 0;   // brightness for the "both ON" hold phase
private _attenuation    = [];
private _intensity      = 0;

if (sunOrMoon < 0.2) then {
    _brightnessHigh = 100;
    _brightnessHold = 75;
    _attenuation    = [0.001, 0,    50, 2500000, 0.001, 250];
    _intensity      = 1200;
} else {
    _brightnessHigh = 25;
    _brightnessHold = 15;
    _attenuation    = [0.001, 3000, 50,  500000, 0.001, 250];
    _intensity      = 120;
};

// ── Light factory ──────────────────────────────────────────────────────────────
// Creates and attaches a single light point. Returns the light object.
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
// Two groups per vehicle:
//   Primary — mirrors fn_medicLights positions (driven harder during siren)
//   Grille  — extra forward-facing grille / dash lights unique to siren mode
//
// Format per entry: [side, colorMacro, [x, y, z]]
//   side: "L" = driver's left | "R" = driver's right

private _leftLights  = [];
private _rightLights = [];

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
        [
            ["L", COL_RED,    [-0.440,  0.000,  0.5125]],
            ["R", COL_YELLOW, [ 0.345,  0.000,  0.5125]],
            ["R", COL_RED,    [ 0.575, -2.950, -0.7700]],
            ["L", COL_YELLOW, [-0.645, -2.950, -0.7700]],
            ["L", COL_RED,    [-0.905, -2.875, -0.2250]],
            ["R", COL_RED,    [ 0.825, -2.875, -0.2250]],
            // Grille — low centre-mount flashers
            ["L", COL_RED,    [-0.300,  2.500, -0.500]],
            ["R", COL_YELLOW, [ 0.300,  2.500, -0.500]]
        ] call _buildLights;
    };

    // ── BG Repair / Repair Offroad ─────────────────────────────────────────────
    case "B_G_Offroad_01_repair_F";
    case "O_Offroad_01_repair_F":
    {
        [
            // Primary
            ["L", COL_YELLOW, [-0.440, 0, 0.5125]],
            ["R", COL_YELLOW, [ 0.345, 0, 0.5125]],
            // Grille
            ["L", COL_YELLOW, [-0.300, 2.500, -0.500]],
            ["R", COL_YELLOW, [ 0.300, 2.500, -0.500]]
        ] call _buildLights;
    };

    // ── SUV ────────────────────────────────────────────────────────────────────
    case "C_SUV_01_F":
    {
        [
            // Primary
            ["L", COL_RED,    [-0.390,  2.280, -0.520]],
            ["R", COL_YELLOW, [ 0.380,  2.280, -0.520]],
            ["L", COL_RED,    [-0.860, -2.750, -0.180]],
            ["R", COL_RED,    [ 0.860, -2.750, -0.180]],
            ["L", COL_YELLOW, [-0.600, -2.925, -0.240]],
            ["R", COL_YELLOW, [ 0.590, -2.925, -0.240]],
            // Grille — bumper-level flashers
            ["L", COL_RED,    [-0.350,  2.700, -0.600]],
            ["R", COL_YELLOW, [ 0.350,  2.700, -0.600]],
            // Dash — interior windscreen flashers
            ["L", COL_RED,    [-0.200,  1.200,  0.100]],
            ["R", COL_YELLOW, [ 0.200,  1.200,  0.100]]
        ] call _buildLights;
    };

    // ── Hatchback ──────────────────────────────────────────────────────────────
    case "C_Hatchback_01_F":
    {
        [
            // Primary
            ["L", COL_RED,    [-0.030,  0.000,  0.200]],
            ["R", COL_YELLOW, [-0.030,  0.000,  0.200]],
            ["L", COL_RED,    [-0.800, -2.250, -0.300]],
            ["R", COL_YELLOW, [ 0.780, -2.250, -0.300]],
            // Grille
            ["L", COL_RED,    [-0.280,  2.100, -0.450]],
            ["R", COL_YELLOW, [ 0.280,  2.100, -0.450]]
        ] call _buildLights;
    };

    // ── Sport Hatchback ────────────────────────────────────────────────────────
    case "C_Hatchback_01_sport_F":
    {
        [
            // Primary
            ["L", COL_RED,    [-0.030,  0.000,  0.200]],
            ["R", COL_YELLOW, [-0.030,  0.000,  0.200]],
            ["L", COL_RED,    [-0.800, -2.250, -0.300]],
            ["R", COL_YELLOW, [ 0.780, -2.250, -0.300]],
            // Grille
            ["L", COL_RED,    [-0.280,  2.200, -0.480]],
            ["R", COL_YELLOW, [ 0.280,  2.200, -0.480]]
        ] call _buildLights;
    };

    // ── Box Truck ──────────────────────────────────────────────────────────────
    case "C_Truck_02_box_F":
    {
        [
            // Primary
            ["L", COL_RED,    [-0.790, -0.17275,  1.325]],
            ["R", COL_YELLOW, [ 0.750, -0.17275,  1.325]],
            ["L", COL_RED,    [-0.710,  2.12750, -0.750]],
            ["R", COL_YELLOW, [ 0.675,  2.12750, -0.750]],
            ["L", COL_RED,    [-0.735, -3.47250,  1.260]],
            ["R", COL_RED,    [ 0.7125,-3.47250,  1.260]],
            ["L", COL_YELLOW, [-0.225, -3.47250,  1.260]],
            ["R", COL_YELLOW, [ 0.210, -3.47250,  1.260]],
            // Grille — bumper corners
            ["L", COL_RED,    [-0.650,  3.200, -0.700]],
            ["R", COL_YELLOW, [ 0.650,  3.200, -0.700]]
        ] call _buildLights;
    };

    // ── Strider (MRAP) ─────────────────────────────────────────────────────────
    case "I_MRAP_03_F":
    {
        [
            // Primary
            ["R", COL_YELLOW, [ 0.900,  2.200, -0.800]],
            ["L", COL_RED,    [-0.900,  2.200, -0.800]],
            ["R", COL_YELLOW, [ 0.000, -3.000,  0.025]],
            ["L", COL_RED,    [-0.725, -3.100,  0.025]],
            // Grille — front lower corners
            ["L", COL_RED,    [-0.800,  2.600, -0.900]],
            ["R", COL_YELLOW, [ 0.800,  2.600, -0.900]]
        ] call _buildLights;
    };

    // ── Ifrit (MRAP) ───────────────────────────────────────────────────────────
    case "O_MRAP_02_F":
    {
        [
            // Primary
            ["R", COL_YELLOW, [ 1.175, -1.500,  0.3650]],
            ["L", COL_RED,    [-1.175, -1.500,  0.3650]],
            ["L", COL_RED,    [-0.4325,-1.500,  0.6275]],
            ["R", COL_YELLOW, [ 0.4325,-1.500,  0.6275]],
            ["L", COL_RED,    [-0.200,  1.575, -1.1250]],
            ["R", COL_YELLOW, [ 0.200,  1.575, -1.1250]],
            ["R", COL_RED,    [ 0.525, -4.500, -1.3000]],
            ["L", COL_YELLOW, [-0.525, -4.500, -1.3000]],
            ["L", COL_RED,    [-0.400, -4.950,  0.1550]],
            ["R", COL_YELLOW, [ 0.400, -4.950,  0.1550]],
            // Grille — front lower armour flashers
            ["L", COL_RED,    [-0.900,  2.000, -1.200]],
            ["R", COL_YELLOW, [ 0.900,  2.000, -1.200]]
        ] call _buildLights;
    };

    default {
        diag_log format ["[MedicSirenLights] Unsupported vehicle type: %1", typeOf _vehicle];
    };
};

// ── Guard: nothing attached → bail ────────────────────────────────────────────
if (_leftLights isEqualTo [] && { _rightLights isEqualTo [] }) exitWith {
    diag_log "[MedicSirenLights] No lights attached — aborting.";
};

// ── Flash helpers ──────────────────────────────────────────────────────────────

// Burst: flash one bank N times.
private _fnBurst = {
    params ["_lights"];
    for "_i" from 1 to FLASH_COUNT do {
        { _x setLightBrightness _brightnessHigh; } forEach _lights;
        uiSleep FLASH_ON;
        { _x setLightBrightness 0;               } forEach _lights;
        uiSleep FLASH_OFF;
    };
};

// Wig-wag + hold:
//   1. Left bank bursts
//   2. Right bank bursts
//   3. Both banks hold ON together briefly
private _fnWigwagHold = {
    // Left burst
    [_leftLights]  call _fnBurst;
    // Right burst
    [_rightLights] call _fnBurst;
    // Hold — both ON simultaneously
    { _x setLightBrightness _brightnessHold; } forEach (_leftLights + _rightLights);
    uiSleep HOLD_DURATION;
    { _x setLightBrightness 0;               } forEach (_leftLights + _rightLights);
};

// ── Active-check closure ───────────────────────────────────────────────────────
// Loop continues only while the vehicle is alive and BOTH variables are true.
private _fnIsActive = {
    if (!alive _vehicle) exitWith { false };
    private _lv = _vehicle getVariable ["lights", false];
    private _sv = _vehicle getVariable ["siren",  false];
    (!isNil "_lv" && { _lv }) && (!isNil "_sv" && { _sv })
};

// ── Main flash loop ────────────────────────────────────────────────────────────
while { call _fnIsActive } do {
    call _fnWigwagHold;
    if (CYCLE_PAUSE > 0) then { uiSleep CYCLE_PAUSE; };
};

// ── Cleanup ────────────────────────────────────────────────────────────────────
{ deleteVehicle _x; } forEach (_leftLights + _rightLights);
_leftLights  = [];
_rightLights = [];
