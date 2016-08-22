/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 Launch Synths

 todo:
 -> inits should be read from "settings" file not hardwired here

*/

(
~a1b1 = Synth(\feedbackPair, [otherIn: ~otherInA1, mainOutBusA: ~mixedOutA1, mainOutBusB: ~mixedOutB1,
    componentOutBusA: ~componentOutA1, componentOutBusB: ~componentOutB1,
    rNetInBusA: ~rNetInA1, rNetOutBusA: ~rNetOutA1, rNetInBusB: ~rNetInB1,
    rNetOutBusB: ~rNetOutB1, koscRA: 0, koscRB: 0, lowPassPot:
    1.0.rand, preAmpPotA: 0, preAmpPotB: 0, powAmpPotA:
    exprand(0.5, 1.0), powAmpPotB: exprand(0.5, 1.0), lfoPotA: 1.0.rand,
    lofPotB: 1.0.rand]);
~c1d1 = Synth(\feedbackPair, [otherIn: ~otherInC1, mainOutBusA: ~mixedOutC1, mainOutBusB: ~mixedOutD1,
    componentOutBusA: ~componentOutC1, componentOutBusB: ~componentOutD1,
    rNetInBusA: ~rNetInC1, rNetOutBusA: ~rNetOutC1, rNetInBusB: ~rNetInD1,
    rNetOutBusB: ~rNetOutD1, koscRA: 0, koscRB: 0, lowPassPot:
    1.0.rand, preAmpPotA: 0, preAmpPotB: 0, powAmpPotA:
    exprand(0.5, 1.0), powAmpPotB: exprand(0.5, 1.0), lfoPotA: 1.0.rand,
    lofPotB: 1.0.rand]);
~a2b2 = Synth(\feedbackPair, [otherIn: ~otherInA2, mainOutBusA: ~mixedOutA2, mainOutBusB: ~mixedOutB2,
    componentOutBusA: ~componentOutA2, componentOutBusB: ~componentOutB2,
    rNetInBusA: ~rNetInA2, rNetOutBusA: ~rNetOutA2, rNetInBusB: ~rNetInB2,
    rNetOutBusB: ~rNetOutB2, koscRA: 0, koscRB: 0, lowPassPot:
    1.0.rand, preAmpPotA: 0, preAmpPotB: 0, powAmpPotA:
    exprand(0.5, 1.0), powAmpPotB: exprand(0.5, 1.0), lfoPotA: 1.0.rand,
    lofPotB: 1.0.rand]);
~c2d2 = Synth(\feedbackPair, [otherIn: ~otherInC2, mainOutBusA: ~mixedOutC2, mainOutBusB: ~mixedOutD2,
    componentOutBusA: ~componentOutC2, componentOutBusB: ~componentOutD2,
    rNetInBusA: ~rNetInC2, rNetOutBusA: ~rNetOutC2, rNetInBusB: ~rNetInD2,
    rNetOutBusB: ~rNetOutD2, koscRA: 0, koscRB: 0, lowPassPot:
    1.0.rand, preAmpPotA: 0, preAmpPotB: 0, powAmpPotA:
    exprand(0.5, 1.0), powAmpPotB: exprand(0.5, 1.0), lfoPotA: 1.0.rand,
    lofPotB: 1.0.rand]);
);

~synths =  [~a1b1, ~c1d1, ~a2b2, ~c2d2];