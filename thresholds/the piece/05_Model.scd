/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 A very sketchy implementation of Model-View-Controller (MVC) architecture.

 ALL COMMUNICATION GOES THROUGH THE MODEL. DO NOT SET THE SYNTHS DIRECTLY.
 ... i mean, worst that happens is you don't update a GUI, so not terrrrible.

 Note: the model currently is NOT holding much data, we should change that!

 Example: setting a synth param looks like this...

   ~model.setSynth(~a1b1, \preAmpPotB, 0.4)
   ~model.setSynth(~a1b1, \koscRB, 23.98)

 Todo:
 -> ... args syntax for lists of parameters
 -> populate upon instatiation with current synth values
 -> don't forget to set internal data! want to get from model not query synth

 -> is this the best way to reset all vals of an array to 0?

*/

// init model
(
~model = ();
~model.synths = ~synths;
~model.mixedOutBusses = ~mixedOutBusses;
~model.scopeBusses = ~scopeBusses;
~model.lfoScopeBusses = ~lfoScopeBusses;
~model.componentOutBusses = ~componentOutBusses;
~model.synthsIndex = Dictionary.newFrom([~model.synths, ~model.synths.collect({|e,i| i})].lace);
~model.flags = 3.collect({8.collect({0})});  // [ringer][channel]
);

// set synth param Controller function
(
~model.setSynth = { arg self, synth, param, value;

    // set synth
    if (synth.notNil) {synth.set(param, value)};

    // notify dependants
    self.changed(\setSynth, ~model.synthsIndex[synth], param, value);

});

(
~model.clearFlags = { arg self, ringer;

    // clear all flags this ringer
    ~model.flags[ringer] = 8.collect({0});

    // notify dependants
    self.changed(\clearFlags, ringer);
});

(
~model.setFlags = { arg self, ringer, channel, value;

    // update model.flags
    ~model.flags[ringer][channel] = value;

    // notify dependants
    self.changed(\setFlags, ringer, channel);

});

// ~model.dependants;