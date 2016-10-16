/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 Super sketchy quick implementation of some post-processing. Just filling in
 for now -- this is going to change.

 todo
 -> should be length of out busses . rand not hardcoded to 8.rand

*/

"09_PostProcessing-8x2!".postln;

(
SynthDef(\ringer, {arg inBusA, inBusB, outPos, atk=0.0, rel=0.0, amp=0.05,
    pan=1, dur=1, mute=1;

    var sig, env;

    sig = InFeedback.ar(inBusA) * InFeedback.ar(inBusB);
    env = EnvGen.kr(Env.new([0,1,1,0], [atk,dur,rel],[1,-1]), doneAction: 2);
    sig = sig * env;

    Out.ar(0, Pan2.ar(sig * 0.5 * mute, pos:outPos));

}).add;
);

/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 stereo each pair

*/

(
SynthDef(\StereoPair, {arg inBusA, inBusB, outBus;

    Out.ar(0, [InFeedback.ar(inBusA), InFeedback.ar(inBusB)]);

}).add;
);

/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 ringmod each pair to mono

*/

(
SynthDef(\PairRinger, {arg inBusA, inBusB, outBus = 0, outPos = 0;

    Out.ar(0, Pan2.ar(InFeedback.ar(inBusA) * InFeedback.ar(inBusB), pos:outPos));

}).add;
);