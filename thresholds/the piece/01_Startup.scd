/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 Server Options and Hardware I/O Setup.

*/

// "01: Starting Server...".postln;

(
o = Server.local.options;
// o.outDevice_("Soundflower (64ch)");
// o.outDevice_("Builtin+Soundflower64");
// o.numOutputBusChannels = 10; // need this for multichannel output
o.numAudioBusChannels_(200);
o.sampleRate = 44100;
o.blockSize = 2;
s.waitForBoot({"-> 01: Server Started!".postln});
// o.numAudioBusChannels_(128);
s.meter;
// o.blockSize.postln;
);

// return
"01: Starting Server..."