/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 Server Options and Hardware I/O Setup.

*/

"01: Starting Server...".postln;

(
o = Server.local.options;
// o.numOutputBusChannels = 12; // need this for multichannel output
o.sampleRate = 44100;
o.blockSize = 64;
s.waitForBoot({"-> BOOT SUCCESS!!!".postln});
// o.numAudioBusChannels_(128);
// s.meter;
// o.blockSize.postln;
);

// return
"+"