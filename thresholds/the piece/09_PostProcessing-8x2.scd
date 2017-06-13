
/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 Main Output Synths Stereo --- these patch stereoMix through to the to DAC~

*/

/* none */

SynthDef(\MainChannelNone, {

    Out.ar(0, InFeedback.ar(~stereoMix, 2));

}).add;

/* DC block */

SynthDef(\MainChannelDCBlock, {

    Out.ar(0, LeakDC.ar(InFeedback.ar(~stereoMix, 2)));

}).add;

/* hard clip */

SynthDef(\MainChannelClip, {

    Out.ar(0, Clip.ar(InFeedback.ar(~stereoMix, 2), -1, 1));

}).add;

/* tanh compression */

// allocate buffer
~tanhBuff = Buffer.alloc(s, 1024, 1);

// computer tanh buffer
~tanhSig = Signal.fill(513, {|i| i.linlin(0.0, 512.0, -2.0, 2.0).tanh});

// send to server as wavetable
~tanhBuff.sendCollection(~tanhSig.asWavetableNoWrap);

// shaper synth
SynthDef(\MainChannelTanh, {

    Out.ar(0, Shaper.ar(~tanhBuff, InFeedback.ar(~stereoMix, 2)));

}).add;

/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 launch mainChannelSynth to stereo DAC~ so we have sound!

*/

~model.mainChannelSynth = Synth(\MainChannelDCBlock);

/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 Patchbay Synths --- these patch from oscillators through to stereoMix

*/

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