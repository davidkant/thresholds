// patch ~stereoMix thru to Outs 0,1
~model.mainChannelSynth = Synth(\MainChannelDCBlock);

(
// main out mix settings
~model.setSynthMaster(\outXAB, 0.33, nil);
~model.setSynthMaster(\outYAB, 1.0, nil);
~model.setSynthMaster(\outZAB, 0.13, nil);
);

(
// feedback max settings
~synths.do({|synth| ~model.setSynth(synth, \fbackXA, 0); }); // fback X A
~synths.do({|synth| ~model.setSynth(synth, \fbackXB, 0); }); // fback X B
~synths.do({|synth| ~model.setSynth(synth, \fbackYA, 1); }); // fback Y A
~synths.do({|synth| ~model.setSynth(synth, \fbackYB, 1); }); // fback Y B
~synths.do({|synth| ~model.setSynth(synth, \fbackZA, 0); }); // fback X A
~synths.do({|synth| ~model.setSynth(synth, \fbackZB, 0); }); // fback X B
);

// return
"05: Init Settings!"