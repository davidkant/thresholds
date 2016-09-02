/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 Super sketchy quick implementation of some post-processing. Just filling in
 for now -- this is going to change.

 todo
 -> should be length of out busses . rand not hardcoded to 8.rand

*/

(
SynthDef(\ringer, {arg inBusA, inBusB, outPos, atk=0.0, rel=0.0, amp=0.05,
    pan=1, dur=1, mute=1;

    var sig, env;

    sig = InFeedback.ar(inBusA) * InFeedback.ar(inBusB);
    env = EnvGen.kr(Env.new([0,1,1,0], [atk,dur,rel],[1,-1]), doneAction: 2);
    sig = sig * env;

    Out.ar(0, Pan2.ar(sig * 0.5 * mute, pos:outPos));

}).add
);

/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 stereo each pair

*/

(
SynthDef(\StereoPair, {arg inBusA, inBusB, outBus;
1
    Out.ar(0, [InFeedback.ar(inBusA), InFeedback.ar(inBusB)]);

}).add
);

/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 ringmod each pair to mono

*/

(
SynthDef(\PairRinger, {arg inBusA, inBusB, outBus = 0, outPos = 0;

    Out.ar(0, Pan2.ar(InFeedback.ar(inBusA) * InFeedback.ar(inBusB), pos:outPos));

}).add
);

/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 launch ringers

*/
/*
(
p = Pbind(
    \instrument, \ringer,
    \inBusA, Pfunc({var i=8.rand;
        {~model.clearFlags(0)}.defer;
        {~model.setFlags(0, i, 1)}.defer;
        ~model.mixedOutBusses[i]}),
    \inBusB, Pfunc({var i=8.rand;
        {~model.setFlags(0, i, 1)}.defer;
        ~model.mixedOutBusses[i]}),
    \outPos, Prand([-1, -0.666, -0.333, 0 , 0.333, 0.666, 1], inf),
    \dur, Pwhite(0.15, 1.8, inf),
    \mute, Prand([0,1,1], inf),
).play
);

(
q = Pbind(
    \instrument, \ringer,
    \inBusA, Pfunc({var i=8.rand;
        {~model.clearFlags(1)}.defer;
        {~model.setFlags(1, i, 1)}.defer;
        ~model.mixedOutBusses[i]}),
    \inBusB, Pfunc({var i=8.rand;
        {~model.setFlags(1, i, 1)}.defer;
        ~model.mixedOutBusses[i]}),
    \outPos, Prand([-1, -0.666, -0.333, 0 , 0.333, 0.666, 1], inf),
    \dur, Pwhite(0.15, 1.8, inf),
    \mute, Prand([0,1,1], inf),
).play
);

(
r = Pbind(
    \instrument, \ringer,
    \inBusA, Pfunc({var i=8.rand;
        {~model.clearFlags(2)}.defer;
        {~model.setFlags(2, i, 1)}.defer;
        ~model.mixedOutBusses[i]}),
    \inBusB, Pfunc({var i=8.rand;
        {~model.setFlags(2, i, 1)}.defer;
        ~model.mixedOutBusses[i]}),
    \outPos, Prand([-1, -0.666, -0.333, 0 , 0.333, 0.666, 1], inf),
    \dur, Pwhite(0.15, 1.8, inf),
    \mute, Prand([0,1,1], inf),
).play
);

p.stop; ~model.clearFlags(0);
q.stop; ~model.clearFlags(1);
r.stop; ~model.clearFlags(2);
*/