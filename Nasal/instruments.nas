###############################
# Set instruments serviceable #
###############################

setlistener("/controls/electric/battery-switch", func {
	if (getprop("/controls/electric/battery-switch")) {
		setprop("/instrumentation/fuel-gauges/tank[0]/serviceable", 1);
		setprop("/instrumentation/fuel-gauges/tank[1]/serviceable", 1);
	} else {
		setprop("/instrumentation/fuel-gauges/tank[0]/serviceable", 0);
		setprop("/instrumentation/fuel-gauges/tank[1]/serviceable", 0);
	}
});

###################
# US Gal / Liters #
###################

var gal2ltr0 = func {
	if (getprop("/instrumentation/fuel-gauges/tank[0]/serviceable")) {
		var level_gal_us = getprop("/consumables/fuel/tank[0]/level-gal_us");
		level_gal_us != nil or return;
		var level_ltr = 3.785 * level_gal_us;
		interpolate("/instrumentation/fuel-gauges/tank[0]/level-ltr", level_ltr, 0.2);
		settimer(gal2ltr0, 0.2);
	} else {
		interpolate("/instrumentation/fuel-gauges/tank[0]/level-ltr", -10, 1);
		return;
	}
}

var gal2ltr1 = func {
	if (getprop("/instrumentation/fuel-gauges/tank[1]/serviceable")) {
		var level_gal_us = getprop("/consumables/fuel/tank[1]/level-gal_us");
		level_gal_us != nil or return;
		var level_ltr = 3.785 * level_gal_us;
		interpolate("/instrumentation/fuel-gauges/tank[1]/level-ltr", level_ltr, 0.2);
		settimer(gal2ltr1, 0.2);
	} else {
		interpolate("/instrumentation/fuel-gauges/tank[1]/level-ltr", -10, 1);
		return;
	}
}

setlistener("/instrumentation/fuel-gauges/tank[0]/serviceable", gal2ltr0);
setlistener("/instrumentation/fuel-gauges/tank[1]/serviceable", gal2ltr1);

setlistener("/sim/signals/fdm-initialized", func {
	gal2ltr0;
	gal2ltr1;
});
setlistener("/sim/signals/reinit", func {
	gal2ltr0;
	gal2ltr1;
});
