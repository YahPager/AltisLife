    // Add this in the fn_keyHandler.sqf There should already be code simular to this in there. Just copy and paste over it.
    
    case 38: { // L key
    private _veh = vehicle player;

    // Whitelisted emergency vehicles
    private _emergencyVehicles = [
        "C_Offroad_01_F",
        "C_Hatchback_01_sport_F",
        "C_SUV_01_F",
        "B_G_Offroad_01_F",
        "B_MRAP_01_F",
        "O_MRAP_02_F",
        "C_Offroad_02_unarmed_F"
    ];

    private _isEmergencySide = playerSide isEqualTo west || playerSide isEqualTo independent;
    private _isInVehicle     = _veh != player;
    private _isValidVehicle  = (typeOf _veh) in _emergencyVehicles;
    private _hasLights       = !isNil { _veh getVariable "lights" };

    // Shift+L — Toggle siren lights (emergency sides only)
    if (_shift && _isEmergencySide && _isInVehicle && _isValidVehicle && _hasLights) then {
        switch (true) do {
            case (playerSide isEqualTo west):        { [_veh] call life_fnc_sirenLights;       };
            case (playerSide isEqualTo independent): { [_veh] call life_fnc_medicSirenLights;  };
        };
        _handled = true;
    };

    // L alone — Open radar (no modifier keys)
    if (!_handled && !_alt && !_ctrlKey && !_shift) then {
        [] call life_fnc_radar;
    };
};
