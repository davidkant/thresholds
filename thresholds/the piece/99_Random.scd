/* rando --
would be nice to have a sep spec for this

*/

(
~randorams = [
    \lowPassPot,
    \lfoIPhaseA, \lfoIPhaseB,
    \koscRA, \koscRB,
    \preAmpPotA, \preAmpPotB,
    \powAmpPotA, \powAmpPotB,
    \lfoPotA, \lfoPotB,
    \vactrolAttackA, \vactrolAttackB,
    \vactrolDecayA, \vactrolDecayB,
    \vactrolHysteresisA, \vactrolHysteresisB,
    \vactrolDepthA, \vactrolDepthB
]
);

(
~randomize = {|randorams, synths|

    randorams.do({|randoram|

        synths.do({|synth|

            var val = 1.0.rand;

            ("setting: " ++ randoram ++ " = " ++ randoram.asSpec.map(val).asString).postln;

            ~model.setSynth(synth, randoram, randoram.asSpec.map(val));

        });
    });
}
);

(
~randomizeUnison = {|randorams, synths|

    randorams.do({|randoram|

        synths.do({|synth|

            var val = 1.0.rand;

            ("setting: " ++ randoram ++ " = " ++ randoram.asSpec.map(val).asString).postln;

            ~synths.do({|synth| ~model.setSynth(synth, randoram, randoram.asSpec.map(val))});

        });
    });
}
);

// ~randomize.value(~randorams, ~model.synths);

// return
"99: Random State!"