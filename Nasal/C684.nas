var pitch = 0;
var reset_pitch = 0;
var adjustPitch = func {
    settimer(adjustPitch, 2);
    var rpm = getprop("/engines/engine[0]/thruster/rpm");
    rpm != nil or return;
    if (reset_pitch == 1) {
        pitch = 0;
        reset_pitch = 0;
    }
    if (rpm > 2750) {
        print ("Switching to high pitch...");
        pitch = 1;
        reset_pitch = 0;
    }
    interpolate("/controls/engines/engine[0]/propeller-pitch", pitch, 4.0);
}
adjustPitch();

var resetPitch = func {
    if (getprop("/gear/gear[2]/wow") and getprop("/engines/engine[0]/rpm") == 0) {
        reset_pitch = 1;
        print ("Switching to low pitch...");
    } else {
        print("You must be on ground and engine stopped!");
    }
}

#reset_listener = setlistener("
