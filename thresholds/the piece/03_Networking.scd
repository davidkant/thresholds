/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 These are the networking busses. The feedback network is hardwired by the bus
 topology. We are going to change this in the future to dynamically patch oscs
 all managed via a OscPair Object that will keep track of these busses. But
 standing in for now...

*/

(

// mixed output busses
~mixedOutA1 = Bus.audio(s, 1);
~mixedOutB1 = Bus.audio(s, 1);
~mixedOutC1 = Bus.audio(s, 1);
~mixedOutD1 = Bus.audio(s, 1);
~mixedOutA2 = Bus.audio(s, 1);
~mixedOutB2 = Bus.audio(s, 1);
~mixedOutC2 = Bus.audio(s, 1);
~mixedOutD2 = Bus.audio(s, 1);
~mixedOutBusses = [~mixedOutA1, ~mixedOutB1, ~mixedOutC1, ~mixedOutD1, ~mixedOutA2, ~mixedOutB2, ~mixedOutC2, ~mixedOutD2];

// otherIn busses
~otherInA1 = Bus.audio(s,1);
~otherInC1 = Bus.audio(s,1);
~otherInA2 = Bus.audio(s,1);
~otherInC2 = Bus.audio(s,1);

// component output busses
~componentOutA1 = Bus.audio(s, 3);
~componentOutB1 = Bus.audio(s, 3);
~componentOutC1 = Bus.audio(s, 3);
~componentOutD1 = Bus.audio(s, 3);
~componentOutA2 = Bus.audio(s, 3);
~componentOutB2 = Bus.audio(s, 3);
~componentOutC2 = Bus.audio(s, 3);
~componentOutD2 = Bus.audio(s, 3);
~componentOutBusses = [~componentOutA1, ~componentOutB1, ~componentOutC1, ~componentOutD1, ~componentOutA2, ~componentOutB2, ~componentOutC2, ~componentOutD2];

// scope busses
~scopeBusA1B1 = Bus.audio(s, 2);
~scopeBusC1D1 = Bus.audio(s, 2);
~scopeBusA2B2 = Bus.audio(s, 2);
~scopeBusC2D2 = Bus.audio(s, 2);
~scopeBusses = [~scopeBusA1B1, ~scopeBusC1D1, ~scopeBusA2B2, ~scopeBusC2D2];

~lfoScopeBusses = Bus.control(s, 8);

~vactrolScopeBusA1 = Bus.audio(s, 3);
~vactrolScopeBusB1 = Bus.audio(s, 3);
~vactrolScopeBusC1 = Bus.audio(s, 3);
~vactrolScopeBusD1 = Bus.audio(s, 3);
~vactrolScopeBusA2 = Bus.audio(s, 3);
~vactrolScopeBusB2 = Bus.audio(s, 3);
~vactrolScopeBusC2 = Bus.audio(s, 3);
~vactrolScopeBusD2 = Bus.audio(s, 3);
~vactrolScopeBusses = [~vactrolScopeBusA1, ~vactrolScopeBusB1, ~vactrolScopeBusC1, ~vactrolScopeBusD1, ~vactrolScopeBusA2, ~vactrolScopeBusB2, ~vactrolScopeBusC2, ~vactrolScopeBusD2];

// patching bussses [signal, resistance]
~patchrNetA1toC1 = Bus.audio(s, 2);
~patchrNetC1toA1 = Bus.audio(s, 2);
~patchrNetB1toD1 = Bus.audio(s, 2);
~patchrNetD1toB1 = Bus.audio(s, 2);
~patchrNetA2toC2 = Bus.audio(s, 2);
~patchrNetC2toA2 = Bus.audio(s, 2);
~patchrNetB2toD2 = Bus.audio(s, 2);
~patchrNetD2toB2 = Bus.audio(s, 2);

// assign patching busses
~rNetInA1 = ~patchrNetC1toA1;
~rNetOutA1 = ~patchrNetA1toC1;
~rNetInB1 = ~patchrNetD1toB1;
~rNetOutB1 = ~patchrNetB1toD1;
~rNetInC1 = ~patchrNetA1toC1;
~rNetOutC1 = ~patchrNetC1toA1;
~rNetInD1 = ~patchrNetB1toD1;
~rNetOutD1 = ~patchrNetD1toB1;
~rNetInA2 = ~patchrNetC2toA2;
~rNetOutA2 = ~patchrNetA2toC2;
~rNetInB2 = ~patchrNetD2toB2;
~rNetOutB2 = ~patchrNetB2toD2;
~rNetInC2 = ~patchrNetA2toC2;
~rNetOutC2 = ~patchrNetC2toA2;
~rNetInD2 = ~patchrNetB2toD2;
~rNetOutD2 = ~patchrNetD2toB2;
)