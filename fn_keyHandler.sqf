    // Add this in the fn_keyHandler.sqf There should already be code simular to this in there. Just copy and paste over it.
    
    case 38: { // L key
    private _veh = vehicle player;

    if (_shift && (playerSide isEqualTo west || playerSide isEqualTo independent)) then {
        if (_veh != player && (typeOf _veh) in [
            "C_Offroad_01_F",
            "C_Hatchback_01_sport_F",
            "C_SUV_01_F",
            "B_G_Offroad_01_F",
            "B_MRAP_01_F",
            "O_MRAP_02_F",
            "C_Offroad_02_unarmed_F"
        ]) then {
            if (!isNil {_veh getVariable "lights"}) then {
                if (playerSide isEqualTo west) then {
                    [_veh] call life_fnc_sirenLights;
                } else {
                    [_veh] call life_fnc_medicSirenLights;
                };
                _handled = true;
            };
        };
    };

    if (!_alt && !_ctrlKey) then {
        [] call life_fnc_radar;
    };
};
