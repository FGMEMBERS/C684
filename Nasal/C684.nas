###################
# Propeller pitch #
###################

var ApplyPitch = func (selected_pitch) {
	pitch = getprop("/controls/engines/engine[0]/propeller-pitch");
	var time_factor = 1 - pitch;	# used only if selected_pitch != 0, else we use directly pitch
	if (selected_pitch == 0) {
		var lamp_time = abs(3 * pitch - 0.2);
		var propeller_time = 3 * pitch;
		interpolate("/controls/engines/engine[0]/propeller-pitch", 0, propeller_time);			# low pitch
		interpolate("/controls/electric/pitch-transit", 1, 0.2, 1, lamp_time, 0, 0.2);	# just for the red light
	} elsif (selected_pitch == 1) {
		var lamp_time = abs(5 * time_factor - 0.2);
		var propeller_time = 5 * time_factor;
		interpolate("/controls/engines/engine[0]/propeller-pitch", 1, propeller_time);			# slow high pitch
		interpolate("/controls/electric/pitch-transit", 1, 0.2, 1, lamp_time, 0, 0.2);
	} elsif (selected_pitch == 2) {
		var lamp_time = abs(2 * time_factor - 0.2);
		var propeller_time = 2 * time_factor;
		interpolate("/controls/engines/engine[0]/propeller-pitch", 1, propeller_time);			# high pitch
		interpolate("/controls/electric/pitch-transit", 1, 0.2, 1, lamp_time, 0, 0.2);
	}
}

var PitchTest = func {
	var battery = getprop("/controls/electric/battery-switch");
	var apply_pitch = getprop("/controls/switches/apply_pitch");
	var selected_pitch = getprop("/controls/switches/selected_pitch");
	var pitch = getprop("/controls/engines/engine[0]/propeller-pitch");
	if (selected_pitch == 2) {
		var new_pitch = 1
	} else {
		var new_pitch = selected_pitch
	}
	if (pitch == new_pitch) {
		var change_pitch = 0	# verify that selected pitch is different than actual pitch
	} else {
		var change_pitch = 1
	}
	if (battery and apply_pitch and change_pitch) {
		ApplyPitch(selected_pitch);
	}
}

var set_pitch_listener = setlistener("/controls/switches/selected_pitch", PitchTest);
var apply_pitch_listener = setlistener("/controls/switches/apply_pitch", func {
	if (getprop("/controls/switches/apply_pitch") == 1) {
		PitchTest();
	} elsif(getprop("/controls/engines/engine[0]/propeller-pitch") != 0 and getprop("/controls/engines/engine[0]/propeller-pitch") !=1) {
		interpolate("/controls/engines/engine[0]/propeller-pitch", 1, 2.0);		# if we cut apply pitch switch while the pitch is between low and high, it becomes high ?
		interpolate("/controls/electric/pitch-transit", 0, 0.2);
	}
});
var battery_listener = setlistener("/controls/electric/battery-switch", func {
	if (getprop("/controls/electric/battery-switch") == 1) {
		PitchTest();
	} elsif(getprop("/controls/engines/engine[0]/propeller-pitch") != 0 and getprop("/controls/engines/engine[0]/propeller-pitch") !=1) {
		interpolate("/controls/engines/engine[0]/propeller-pitch", 1, 2.0);		# same question with battery switch
		interpolate("/controls/electric/pitch-transit", 0, 0.2);
	}
});

# just turn propeller at launch
var prop_offset = rand();
setprop("/controls/engines/engine[0]/propeller-offset", prop_offset);

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

#############
# Autostart #
#############

var autostart = func{
	setprop("/controls/electric/battery-switch", 1);
	setprop("/controls/engines/engine[0]/magnetos", 3);
	controls.applyBrakes(1);
	starter(1);
	if (getprop("/engines/engine[0]/running")) {
		starter(0);
		controls.applyBrakes(0);
		return;
	}
	settimer(autostart, 1);
}

#########
# Flaps #
#########

controls.flapsDown = func(n) {
	if (n == 1) setprop("/fdm/jsbsim/fcs/flap-cmd-in", 1);
	if (n == 0) setprop("/fdm/jsbsim/fcs/flap-cmd-in", 0);
	if (n == -1) setprop("/fdm/jsbsim/fcs/flap-cmd-in", -1);
}
