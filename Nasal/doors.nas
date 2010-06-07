# =====
# Doors
# =====

var Doors = {};

Doors.new = func {
   obj = { parents : [Doors],
           door1L : aircraft.door.new("surface-positions/doors/door1L", 6.0),
           door1R : aircraft.door.new("surface-positions/doors/door1R", 6.0),
         };
   return obj;
};

Doors.door1Lexport = func {
   me.door1L.toggle();
}

Doors.door1Rexport = func {
   me.door1R.toggle();
}

# ==============
# Initialization
# ==============

# objects must be here, otherwise local to init()
var doorsystem = Doors.new();
