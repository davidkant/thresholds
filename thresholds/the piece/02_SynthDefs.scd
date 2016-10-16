/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 This is the synthdef & control spec for a chaotic oscillator feedback pair.

 note: QuickGui only populates params that have control specs

 hacks
  * Y SCALE FIX
  * SCOPE RATIO SCALE and toggle AC plot

  ? are all the reassigments inefficient?
  ? should scopes happen as they go?

*/

"02_SynthDefs!".postln;

// control spec
(
/* --- GLOBAL --- */
Spec.add(\koscFreq, [0, 1, \linear]);
Spec.add(\koscError, [0.5, 15, \linear]);
Spec.add(\lowPassPot, [0, 1, \linear]);
/* --- OSC1 --- */
Spec.add(\koscRA, [0.1, 40, \linear]);
Spec.add(\preAmpPotA, [0, 1, \linear]);
Spec.add(\powAmpPotA, [0, 1, \linear]);
Spec.add(\lfoPotA, [0, 1, \linear]);
Spec.add(\lfoCapSwitchA, [0, 1, \linear, 1]);
Spec.add(\lfoLowPassPotA, [0, 1, \linear]);
Spec.add(\vactrolScalarA, [0.1, 2.0, \linear]);
Spec.add(\vactrolAttackA, [0.001, 0.3, \exp]);
Spec.add(\vactrolDecayA, [0.01, 3.0, \exp]);
Spec.add(\vactrolHysteresisA, [0.0, 100.0, \linear]);
Spec.add(\vactrolDepthA, [1.0, 6.0, \linear]);
Spec.add(\koscGateA, [0, 1, \linear, 1]);
Spec.add(\vactrolGateA, [0, 1, \linear, 1]);
Spec.add(\lfoGateA, [0, 1, \linear, 1]);
// Spec.add(\fbackXA, [0, 1, \linear]);
// Spec.add(\fbackYA, [0, 1, \linear]);
// Spec.add(\fbackZA, [0, 1, \linear]);
// Spec.add(\outXA, [0, 1, \linear]);
// Spec.add(\outYA, [0, 1, \linear]);
// Spec.add(\outZA, [0, 1, \linear]);
/* --- OSC2 --- 2 */
Spec.add(\koscRB, [0.1, 40, \linear]);
Spec.add(\preAmpPotB, [0, 1, \linear]);
Spec.add(\powAmpPotB, [0, 1, \linear]);
Spec.add(\lfoPotB, [0, 1, \linear]);
Spec.add(\lfoCapSwitchB, [0, 1, \linear, 1]);
Spec.add(\lfoLowPassPotB, [0, 1, \linear]);
Spec.add(\vactrolScalarB, [0.1, 2.0, \linear]);
// Spec.add(\vactrolAttackB, [0.0, 0.1, \linear]);
// Spec.add(\vactrolDecayB, [0.0, 4.0, \linear]);
// Spec.add(\vactrolHysteresisB, [0.0, 100.0, \linear]);
// Spec.add(\vactrolDepthB, [1.0, 6.0, \linear]);
Spec.add(\koscGateB, [0, 1, \linear, 1]);
Spec.add(\vactrolGateB, [0, 1, \linear, 1]);
Spec.add(\lfoGateB, [0, 1, \linear, 1]);
// Spec.add(\fbackXB, [0, 1, \linear]);
// Spec.add(\fbackYB, [0, 1, \linear]);
// Spec.add(\fbackZB, [0, 1, \linear]);
// Spec.add(\outXB, [0, 1, \linear]);
// Spec.add(\outYB, [0, 1, \linear]);
// Spec.add(\outZB, [0, 1, \linear]);
);

// synthdef
(
z = SynthDef(\feedbackPair, {

    // busses
    arg mainOutBusA, mainOutBusB, componentOutBusA, componentOutBusB,
    rNetInBusA, rNetOutBusA, rNetInBusB, rNetOutBusB,

    // scope busses
    scopeBus, lfoScopeBusA, lfoScopeBusB, vactrolScopeBusA, vactrolScopeBusB,
    gainStageBusA, gainStageBusB, lfoLPScopeBusA, lfoLPScopeBusB,

    otherIn,

    // kosc
    koscRA = 18.6, koscRB = 18.6, koscFreq = 0.85, koscError = 10.0,
    lowPassPot = 0.85,

    // feedback path
    preAmpPotA = 0.75, preAmpPotB = 0.75, powAmpPotA = 0.9,
    powAmpPotB = 0.9, lfoPotA = 0.33, lfoPotB = 0.22, lfoCapSwitchA = 0,
    lfoCapSwitchB = 0, lfoLowPassPotA = 0.85, lfoLowPassPotB = 0.85,

    vactrolScalarA = 1, vactrolAttackA = 0.027, vactrolDecayA = 2.000,
    vactrolHysteresisA = 60, vactrolDepthA = 2,

    vactrolScalarB = 1, vactrolAttackB = 0.023, vactrolDecayB = 1.000,
    vactrolHysteresisB = 60, vactrolDepthB = 2,

    // gates
    koscGateA = 1, koscGateB = 1,
    vactrolGateA = 1, vactrolGateB = 1,
    lfoGateA = 1, lfoGateB = 1,

    // outs
    fbackXA = 0, fbackYA = 1, fbackZA = 0, outXA = 1, outYA = 1, outZA = 0,
    fbackXB = 0, fbackYB = 1, fbackZB = 0, outXB = 1, outYB = 1, outZB = 0;

    // vars
    var sigMixedIn, sigLP, lfoSigA, lfoSigLPA, sigMix2A, sigPreAmpA, rNetInA,
    sigPowAmpA, sigTformA, sigVtrolA, koscA, sigMixedOut, lfoSigB, lfoSigLPB,
    sigMix2B, sigPreAmpB, rNetInB, sigPowAmpB, sigTformB, sigVtrolB, koscB;

    /*----------------------------------------------------------------*/

    // smooth input
    koscRA = Lag.kr(koscRA, lagTime: 0.3);
    koscRB = Lag.kr(koscRB, lagTime: 0.3);
    preAmpPotA = Lag.kr(preAmpPotA, lagTime: 0.3);
    preAmpPotB = Lag.kr(preAmpPotB, lagTime: 0.3);
    powAmpPotA = Lag.kr(powAmpPotA, lagTime: 0.3);
    powAmpPotB = Lag.kr(powAmpPotB, lagTime: 0.3);

    // [0] mixed input
    sigMixedIn = LocalIn.ar(1);
    // external input
    otherIn = InFeedback.ar(otherIn);
    // mix external and feedback input
    sigMixedIn = otherIn + sigMixedIn;

    // [1] lowpass
    sigLP = LowPass741.ar(sigMixedIn, (1-lowPassPot)); //.scope(name:"lowpass");

    // [2] lfo
    lfoSigA = LFOsc555.ar(lfoPotA, cswitch: lfoCapSwitchA);
    lfoSigLPA = LowPass741.ar(lfoSigA, (1-lfoLowPassPotA));

    lfoSigB = LFOsc555.ar(lfoPotB, cswitch: lfoCapSwitchB);
    lfoSigLPB = LowPass741.ar(lfoSigB, (1-lfoLowPassPotB));

    // [3] mixer
    sigMix2A = Mixer741.ar([sigLP * lfoGateA, lfoSigA]); //.scope(name:"mixer");
    sigMix2B = Mixer741.ar([sigLP * lfoGateB, lfoSigB]); //.scope(name:"mixer");

    // [4] preamp
    Out.ar(rNetOutBusA, [sigMix2A, K2A.ar(preAmpPotA)]);
    rNetInA = InFeedback.ar(rNetInBusA, 2);
    sigPreAmpA = PreAmp741.ar(sigMix2A, preAmpPotA, rNetInA[0], rNetInA[1]);

    Out.ar(rNetOutBusB, [sigMix2B, K2A.ar(preAmpPotB)]);
    rNetInB = InFeedback.ar(rNetInBusB, 2);
    sigPreAmpB = PreAmp741.ar(sigMix2B, preAmpPotB, rNetInB[0], rNetInB[1]);

    // [5] amp
    sigPowAmpA = PowerAmp386.ar(sigPreAmpA, powAmpPotA, gain: 50);
    sigPowAmpB = PowerAmp386.ar(sigPreAmpB, powAmpPotB, gain: 50);

    // [6] transformer
    sigTformA = Transformer1380.ar(sigPowAmpA); //.scope(name:"transformer");
    sigTformB = Transformer1380.ar(sigPowAmpB); //.scope(name:"transformer");

    // [7] vactrol
    sigVtrolA = vactrolScalarA * Vactrol.ledMonitor(sigTformA, attack: vactrolAttackA, decay: vactrolDecayA, hysteresis: vactrolHysteresisA, depth: vactrolDepthA); //.poll();
    sigVtrolB = vactrolScalarB * Vactrol.ledMonitor(sigTformB, attack: vactrolAttackB, decay: vactrolDecayB, hysteresis: vactrolHysteresisB, depth: vactrolDepthB); //.poll();

    // sigVtrolA[0].poll(label: \VtrolA);
    // sigVtrolB[0].poll(label: \VtrolB);

    // [8] feedback R in parallel
    koscA = DunnOsc.ar(r: min((sigVtrolA[0] + (2147483647 * (1-vactrolGateA))), koscRA), freq: koscFreq, error: koscError) * [1,3,1] * koscGateA; // Y SCALE FIX;
    koscB = DunnOsc.ar(r: min((sigVtrolB[0] + (2147483647 * (1-vactrolGateB))), koscRB), freq: koscFreq, error: koscError) * [1,3,1] * koscGateB; // Y SCALE FIX;;

    koscA = LeakDC.ar(koscA);
    koscB = LeakDC.ar(koscB);

    // [9] mixed out
    sigMixedOut = Mixer741.ar([(koscA*[fbackXA,fbackYA,fbackZA]).sum, (koscB*[fbackXB,fbackYB,fbackZB]).sum]);

    /*----------------------------------------------------------------*/

    // [*] feedback out
    LocalOut.ar(sigMixedOut);

    // [*] mains out
    Out.ar(mainOutBusA, (koscA*[outXA,outYA,outZA]).sum);
    Out.ar(mainOutBusB, (koscB*[outXB,outYB,outZB]).sum);

    // [*] component out
    Out.ar(componentOutBusA, LeakDC.ar(koscA * [1, 0.8, 1]));  // SCOPE RATIO SCALE and toggle AC plot
    Out.ar(componentOutBusB, LeakDC.ar(koscB * [1, 0.8, 1]));  // SCOPE RATIO SCALE and toggle AC plot

    // [*] mixedIn scope
    Out.ar(scopeBus, [sigMixedIn, sigLP]);

    // [*] lfo scope
    Out.kr(lfoScopeBusA, [lfoSigA]);
    Out.kr(lfoScopeBusB, [lfoSigB]);
    Out.kr(lfoLPScopeBusA, [lfoSigLPA]);
    Out.kr(lfoLPScopeBusB, [lfoSigLPB]);

    // [*] vactrol scope: [post-hysteresis, internal state, led]
    Out.ar(vactrolScopeBusA, [sigVtrolA[0]/220, sigVtrolA[1], sigVtrolA[2]]);
    Out.ar(vactrolScopeBusB, [sigVtrolB[0]/220, sigVtrolB[1], sigVtrolB[2]]);

    // [*] remaining node outputs
    Out.ar(gainStageBusA, [sigMix2A, sigPreAmpA, sigPowAmpA]);
    Out.ar(gainStageBusB, [sigMix2B, sigPreAmpB, sigPowAmpB]);

    // [*] all outputs in one
    // Out.ar(scopeBusA, [lfoSigA, sigMixedIn, sigLP, sigMix2A, sigPreAmpA, sigPowAmpA, sigTformA/10, sigVtrolA[0]/109, sigVtrolA[1], sigVtrolA[2], koscA[0], koscA[1], koscA[2]]);
    // Out.ar(scopeBusB, [lfoSigB, sigMixedIn, sigLP, sigMix2B, sigPreAmpB, sigPowAmpB, sigTformB/10, sigVtrolB[0]/109, sigVtrolB[1], sigVtrolB[2], koscB[0], koscB[1], koscB[2]]);

}).add
);