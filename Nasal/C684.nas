
###################
# Propeller pitch #
###################

var pitch = 0;
var change_pitch = 0;
var adjustPitch = func {
    settimer(adjustPitch, 1);
    var rpm = getprop("/engines/engine[0]/thruster/rpm");
    rpm != nil or return;
    if (change_pitch == -1) {
        pitch = 0;
        change_pitch = 0;
        print ("Switching to low pitch...");
    }
    if (change_pitch == 1) {
        print ("Switching to high pitch...");
        pitch = 1;
        change_pitch = 0;
    }
    interpolate("/controls/engines/engine[0]/propeller-pitch", pitch, 4.0);
}
adjustPitch();

var setPitch = func (value) {
    if (value == -1) {
        if (getprop("/gear/gear[2]/wow") and getprop("/engines/engine[0]/rpm") == 0) {
            change_pitch = -1;
        } else {
            print("You must be on ground and engine stopped!");
        }
    }
    if (value == 1) {
        change_pitch = 1;
    }
}

# just turn at launch
var prop_offset = rand();
setprop("/controls/engines/engine[0]/propeller-offset", prop_offset);

###################
# US Gal / Liters #
###################

var ltr_av = 0;
var ltr_ar = 0;
var gal_av = 0;
var gal_ar = 0;
var gal2ltr = func {
    settimer(gal2ltr, 0.1);
    gal_av = getprop("/consumables/fuel/tank[0]/level-gal_us");
    gal_ar = getprop("/consumables/fuel/tank[1]/level-gal_us");
    battery = getprop("/controls/electric/battery-switch");
    ltr_av = gal_av * 3.785;
    ltr_ar = gal_ar * 3.785;
    setprop("/consumables/fuel/tank[0]/level-ltr", ltr_av);
    setprop("/consumables/fuel/tank[1]/level-ltr", ltr_ar);
}
gal2ltr();

###########
# Starter #
###########

var starter = func(value) {
    if (value == 1) {
        setprop("/controls/switches/starter", 1);
        if (getprop("/controls/electric/battery-switch")) {
            setprop("/controls/engines/engine[0]/starter", 1);
        }
    } else {
        setprop("/controls/engines/engine[0]/starter", 0);
        setprop("/controls/switches/starter", 0);
    }
}
