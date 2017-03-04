/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 A few MIDI control inputs.

*/

// "07: Setting up MIDI...".postln;

MIDIIn.connectAll;

(
/* koscR */
MIDIFunc.cc({|val, num, chan, uid| {~model.setSynth(~a1b1, \koscRA, (val/127)*25)}.defer}, 16, 0);
MIDIFunc.cc({|val, num, chan, uid| {~model.setSynth(~a1b1, \koscRB, (val/127)*25)}.defer}, 17, 0);
MIDIFunc.cc({|val, num, chan, uid| {~model.setSynth(~c1d1, \koscRA, (val/127)*25)}.defer}, 18, 0);
MIDIFunc.cc({|val, num, chan, uid| {~model.setSynth(~c1d1, \koscRB, (val/127)*25)}.defer}, 19, 0);
MIDIFunc.cc({|val, num, chan, uid| {~model.setSynth(~a2b2, \koscRA, (val/127)*25)}.defer}, 20, 0);
MIDIFunc.cc({|val, num, chan, uid| {~model.setSynth(~a2b2, \koscRB, (val/127)*25)}.defer}, 21, 0);
MIDIFunc.cc({|val, num, chan, uid| {~model.setSynth(~c2d2, \koscRA, (val/127)*25)}.defer}, 22, 0);
MIDIFunc.cc({|val, num, chan, uid| {~model.setSynth(~c2d2, \koscRB, (val/127)*25)}.defer}, 23, 0);

/* preAmpPot */
MIDIFunc.cc({|val, num, chan, uid| {~model.setSynth(~a1b1, \preAmpPotA, (val/127))}.defer}, 0, 0);
MIDIFunc.cc({|val, num, chan, uid| {~model.setSynth(~a1b1, \preAmpPotB, (val/127))}.defer}, 1, 0);
MIDIFunc.cc({|val, num, chan, uid| {~model.setSynth(~c1d1, \preAmpPotA, (val/127))}.defer}, 2, 0);
MIDIFunc.cc({|val, num, chan, uid| {~model.setSynth(~c1d1, \preAmpPotB, (val/127))}.defer}, 3, 0);
MIDIFunc.cc({|val, num, chan, uid| {~model.setSynth(~a2b2, \preAmpPotA, (val/127))}.defer}, 4, 0);
MIDIFunc.cc({|val, num, chan, uid| {~model.setSynth(~a2b2, \preAmpPotB, (val/127))}.defer}, 5, 0);
MIDIFunc.cc({|val, num, chan, uid| {~model.setSynth(~c2d2, \preAmpPotA, (val/127))}.defer}, 6, 0);
MIDIFunc.cc({|val, num, chan, uid| {~model.setSynth(~c2d2, \preAmpPotB, (val/127))}.defer}, 7, 0);
);

// return
"07: Setting up MIDI..."