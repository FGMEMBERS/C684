###################
# Oil temperature #
###################

var oilTemp = func {
	var oil_f = getprop("/engines/engine[0]/oil-temperature-degf");
	var rpm = getprop("/engines/engine[0]/rpm");
	var fuel_flow_gph = getprop("/engines/engine[0]/fuel-flow-gph");
	var oil_c = (oil_f - 32) * 0.555556;
	#oil_c = oil_c + (rpm - 2300) * 0.03;
	setprop("/engines/engine[0]/oil-temperature-degc", oil_c);
	settimer(oilTemp, 0.05);
}

####################
# Engine  control #
####################

var max_oil_temp = 145;
var rpm_limit = 2700;
var max_normal_rpm = 2450;
var max_overrpm = 500;
var overrpm = 0;
var neg_g_fuel_factor = 0;
var max_neg_g_fuel_factor = 250;
var engine_broken = 0;

var engineFailure = func {
	engine_broken = 1;
	setprop("/fdm/jsbsim/propulsion/engine[0]/failure", 1);
	interpolate("/fdm/jsbsim/fcs/mixture-failure-cmd-norm", 0, 30);
	interpolate("/controls/engines/engine[0]/faults/smoke", 1, 20);
	#print("Engine failure!");
};

var engineControl = func {
	engine_broken != 1 or return;
	var oil_temp = getprop("/engines/engine[0]/oil-temperature-degc");
	var rpm = getprop("/engines/engine[0]/rpm");
	if (getprop("/fdm/jsbsim/accelerations/Nz") >= 0) var g_sign = 1;
	else var g_sign = -1;
	settimer(engineControl, 1);
	setprop("/fdm/jsbsim/fcs/mixture-failure-cmd-norm", getprop("/controls/engines/engine[0]/mixture"));
	oil_temp != nil or return;
	if (oil_temp > max_oil_temp) {
		var throttle_factor = 1 - (oil_temp - max_oil_temp) * 0.1;
		if (throttle_factor < 0) throttle_factor = 0;
		setprop("/fdm/jsbsim/propulsion/engine/throttle-factor-pos-norm", throttle_factor);
		setprop("/controls/engines/engine[0]/faults/smoke", 1 - throttle_factor);
	} elsif (getprop("/fdm/jsbsim/propulsion/engine/throttle-factor-pos-norm") != 1 or getprop("/controls/engines/engine[0]/faults/smoke") != 0) {
		var throttle_factor = 1;
		setprop("/fdm/jsbsim/propulsion/engine/throttle-factor-pos-norm", throttle_factor);
		setprop("/controls/engines/engine[0]/faults/smoke", 0);
	}
	if (g_sign < 0) {
		fuel_flow = getprop("/engines/engine[0]/fuel-flow-gph");
		neg_g_fuel_factor += fuel_flow;
		#print(neg_g_fuel_factor);
	} elsif (neg_g_fuel_factor > 0) {
		neg_g_fuel_factor += -50;
		if (neg_g_fuel_factor < 0) neg_g_fuel_factor = 0;
		setprop("/fdm/jsbsim/propulsion/engine/throttle-factor-pos-norm", 1);
	}
	if (neg_g_fuel_factor > max_neg_g_fuel_factor) {
		setprop("/fdm/jsbsim/propulsion/engine/throttle-factor-pos-norm", 0);
	}
	elsif (rpm > rpm_limit) engineFailure();
	elsif (overrpm > 0) overrpm = overrpm + (rpm - max_normal_rpm) * 0.08;
	if (overrpm > max_overrpm) engineFailure();
	#print(overrpm);
};

var initFunctions = func {
	var overrpm = 0;
	var rpmmod = 1;
	setprop("/controls/engines/engine[0]/faults/smoke", 0);
	setprop("/fdm/jsbsim/propulsion/engine[0]/failure", 0);
	setprop("/fdm/jsbsim/fcs/mixture-failure-cmd-norm", 1);
	setprop("/fdm/jsbsim/propulsion/engine/throttle-factor-pos-norm", 1);
	oilTemp();
	engineControl();
};

setlistener("/sim/signals/fdm-initialized", initFunctions);
setlistener("/sim/signals/reinit", initFunctions);
