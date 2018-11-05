/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 Server Options and Hardware I/O Setup.

*/

// "01: Starting Server...".postln;

(
o = Server.local.options;
// o.numOutputBusChannels = 10; // need this for multichannel output
o.numAudioBusChannels_(200);
o.sampleRate = 44100;
o.blockSize = 2;
s.waitForBoot({"-> 01: Server Started!".postln});
s.meter;
);

// return
"01: Starting Server..."