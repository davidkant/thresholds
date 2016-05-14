/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 Signal flow of a single feedback path with scopes at each node.

 TODO
 -> GUI or ndef GUI
 -> colormap for scope colors
 -> voltage divider for vactrol
 -> scale for Tform as well

*/

(
// scope busses
var b = Bus.audio(s, 10);

// synth
y = { arg freq = 258.7, bus,

    lowPassPot = 0.85, preAmpPot = 0.75, powAmpPot = 0.9,
    lfoPot = 0.90, lfoCapSwitch = 0, lfoLowPassPot = 0.85, lfoGate = 0,

    vactrolAttack, vactrolDecay;

    var sig, sigMix1, sigLP, sigMix2, sigPreAmp, sigPowAmp, sigTform,
    sigVtrol, lfoSig, lfoSigLP;

    // [-1] test signal
    sig = SinOsc.ar(freq, mul: 1.0);

    // [0] mixed input
    sigMix1 = Mixer741.ar([sig]);

    // [1] lowpass
    sigLP = LowPass741.ar(sigMix1, (1-lowPassPot));

    // [2] lfo
    lfoSig = LFOsc555.ar(lfoPot, cswitch: lfoCapSwitch) * lfoGate;
    lfoSigLP = LowPass741.ar(lfoSig, (1-lfoLowPassPot));

    // [3] mixer
    sigMix2 = Mixer741.ar([sigLP, lfoSigLP]);

    // [4] preamp
    sigPreAmp = PreAmp741.ar(sigMix2, preAmpPot);

    // [5] poweramp
    sigPowAmp = PowerAmp386.ar(sigPreAmp, powAmpPot);

    // [6] transformer
    sigTform = Transformer1380.ar(sigPowAmp);

    // [7] vactrol
    sigVtrol = Vactrol.ar(sigTform, vactrolAttack, vactrolDecay);

    // scope outputs
    [sig, sigMix1, sigLP, lfoSig, lfoSigLP, sigMix2, sigPreAmp, sigPowAmp, sigTform/10, sigVtrol/150]

}.play(outbus: b);

// scope
d = Stethoscope.new(s, numChannels: 10, index: b.index);
d.size_(450);
d.style_(0);
d.yZoom_(1.0);
d.xZoom_(1.0);
d.scopeView.background_(Color.new(0.15, 0.15, 0.15));
d.scopeView.waveColors_(10.collect({|i| Color.magenta.hueBlend(Color.cyan, i/8.0)}));
d.scopeView.fill_(true);
d.view.alwaysOnTop_(true);
d.view.onClose = {y.free; b.free;}.addFunc(d.view.onClose);
)