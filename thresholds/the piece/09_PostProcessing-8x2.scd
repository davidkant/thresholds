/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8*/


/* stereo each pair */

SynthDef(\PairStereo, {arg inBusA, inBusB, outBus, outPos = 0, vol = 1.0;

    Out.ar(0, vol * [InFeedback.ar(inBusA), InFeedback.ar(inBusB)]);

}).add;

/* sum each pair to mono */

SynthDef(\PairMono, {arg inBusA, inBusB, outBus, outPos = 0, vol = 1.0;

    Out.ar(0, vol * (Pan2.ar((InFeedback.ar(inBusA) + InFeedback.ar(inBusB)), pos:outPos)));

}).add;


/* ringmod each pair to mono */

SynthDef(\PairRinger, {arg inBusA, inBusB, outBus = 0, outPos = 0, vol = 1.0;

    Out.ar(outBus, vol * (Pan2.ar(InFeedback.ar(inBusA) * InFeedback.ar(inBusB), pos:outPos)));

}).add;

SynthDef(\PairRinger1, {arg inBusA, inBusB, outBus = 0, outPos = 0, vol = 1.0;

    Out.ar(outBus, vol * (Pan2.ar(InFeedback.ar(inBusA) ring1: InFeedback.ar(inBusB), pos:outPos)));

}).add;

SynthDef(\PairRinger2, {arg inBusA, inBusB, outBus = 0, outPos = 0, vol = 1.0;

    Out.ar(outBus, vol * (Pan2.ar(InFeedback.ar(inBusA) ring2: InFeedback.ar(inBusB), pos:outPos)));

}).add;

/* ringmod each pair to stereo */

SynthDef(\PairRingerStereo, {arg inBusA, inBusB, outBus = 0, outPos = 0, vol = 1.0;

    var a, b;

    a = vol * InFeedback.ar(inBusA);
    b = vol * InFeedback.ar(inBusB);

    Out.ar(outBus, a);
    Out.ar(outBus+1, b);
    Out.ar(outBus, Pan2.ar(a*b, pos:0));

}).add;

// return
"09: Post-Processing Loaded for 8x2!"