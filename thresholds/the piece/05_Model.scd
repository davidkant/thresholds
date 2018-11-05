/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 A very sketchy implementation of Model-View-Controller (MVC) architecture.

 ALL COMMUNICATION GOES THROUGH THE MODEL. DO NOT SET THE SYNTHS DIRECTLY.
 ... i mean, worst that happens is you don't update a GUI, so not terrrrible.

 Note: the model currently is NOT holding much data, we should change that!

 Example: setting a synth param looks like this...

   ~model.setSynth(~a1b1, \preAmpPotB, 0.4)
   ~model.setSynth(~a1b1, \koscRB, 23.98)

 Todo:
 -> ... args syntax for lists of parameters
 -> populate upon instatiation with current synth values
 -> don't forget to set internal data! want to get from model not query synth
 -> synth should probs be the first arg

 -> is this the best way to reset all vals of an array to 0?

*/

// "05: Creating Model...".postln;

// init model
(
~model = ();
~model.synths = ~synths;
~model.stereoMix = ~stereoMix;
~model.quadMix = ~quadMix;
~model.mainOut = ~mainOut;
~model.mixedOutBusses = ~mixedOutBusses;
~model.scopeBusses = ~scopeBusses;
~model.lfoScopeBusses = ~lfoScopeBusses;
~model.lfoLPScopeBusses = ~lfoLPScopeBusses;
~model.vactrolScopeBusses = ~vactrolScopeBusses;
~model.gainStageBusses = ~gainStageBusses;
~model.componentOutBusses = ~componentOutBusses;
~model.synthsIndex = Dictionary.newFrom([~model.synths, ~model.synths.collect({|e,i| i})].lace);
~model.flags = 3.collect({8.collect({0})});  // [ringer][channel]
~model.masterParams = Dictionary.new;
~model.dir = ~dir;
~model.archive_dir = ~dir;
~model.patchSynths = ~model.synths.collect({nil});
);

// guis
(
~model.guiList = [
    ["~vecView", "~vectorView.value(~model)",          "~vectorView",     \master],
    ["~pairi",   "~pairiScope.value(~model)",          "~pairiScope",     \pair],
    ["~octo",    "~octoScope.value(~model)",           "~octoScope",      \master],
    ["~lp",      "~lowPassScope.value(~model)",        "~lowPassScope",   \master],
    ["~lfo",     "~lfoScope.value(~model)",            "~lfoScope",       \master],
    ["~hyst",    "~hysteresisMonitor.value(~model)",   "~hysterMon",      \master],
    ["~pd",      "~photoDesigner.value(~model)",       "~photoDesigner",  \master],
    ["~bk",      "~bigKnob.value(~model)",             "~bigKnob",        \master],
    ["~tm",      "~timeWarp.value(~model)",            "~timeWarp",       \master],
    ["~atr",     "~attractors.value(~model, style:2)", "~attractors",     \master],
    ["~hyp",     "~hyperspace.value(~model)",          "~hypersapce",     \master],
    ["~tn",      "~tone.value(~model)",                "~tone",           \master],
    ["~pb",      "~patchbay.value(~model)",            "~patchbay",       \post],
    ["~pre",     "~presets.value(~model)",             "~presets",        \preset],
]);

(
~model.pairedParams = [\koscFreq, \koscError, \lowPassPot];
~model.synthFromIndex = {|self, index| self.synths[index.div(2)]};
~model.aorb = {|self, index| [\A,\B][index % 2]};
);


// converters
(
~model.pairedParamToSingleParam = {arg self, param;
    if (param.asString.endsWith("A") || param.asString.endsWith("B"),
        {param.asString[0..param.asString.size-2].asSymbol},
        {param}
    );
});

(
~model.singleParamToPairedParam = {arg self, param, index;
    if (self.pairedParams.includes(param), {param}, {(param ++ self.aorb(index)).asSymbol});
});

// this does same thing as singleParamToPairedParam but better name -> remove other
(
~model.rawParamToIndividualParam = {arg self, param, index;
    if (self.pairedParams.includes(param), {param}, {(param ++ self.aorb(index)).asSymbol});
});

(
~model.rawParamToMasterParam = {arg self, param, index;
    if (self.pairedParams.includes(param), {param}, {(param ++ \AB).asSymbol});
});



// set synths param with a function
(
~model.setSynthsWithFunc = {arg self, synthsIndex, param, func;

    // synthsIndex.postln;
    param.postln;

    // loop through synthsIndex
    synthsIndex.do({|index|

        var synth, aorb;

        // synth and aorb
        synth = self.synthFromIndex(index);
        aorb = if (self.pairedParams.includes(param)) {''} {self.aorb(index)};

        // set synth
        if (synth.notNil) {
            self.setSynth(synth, (param ++ aorb).asSymbol, func.value());
        }

    });
});


// set synth param Controller function
(
~model.setSynth = { arg self, synth, param, value, whoChangedIt;

    // set synth
    if (synth.notNil) {synth.set(param, value)};

    // notify dependants
    self.changed(\setSynth, ~model.synthsIndex[synth], param, value, synth, whoChangedIt); // synth should really be the first arg

});


// used for inits
(
~model.setSynthJustDependants = { arg self, synth, param, value;

    // notify dependants
    self.changed(\setSynth, ~model.synthsIndex[synth], param, value, synth);  // synth should really be the first arg

});

// used for inits
(
~model.initGUIsforParam = { arg self, synth, param;

    synth.get(param, { |value| {

        self.changed(\setSynth, ~model.synthsIndex[synth], param, value, synth);  // synth should really be the first arg

    }.defer});

});


// set master synth param Controller function
// this notifies individual dependants as well
// via ~model.setSynth
/*
(
~model. = { arg self, param, value, whoChangedIt;

    // set ALL synths both A and B
    self.synths.do({|synth|

        if (synth.notNil) {
            self.setSynth(synth, (param ++ \A).asSymbol, value, whoChangedIt);
            self.setSynth(synth, (param ++ \B).asSymbol, value, whoChangedIt);
        }

    });

    // this too
    self.synths.do({|synth|

        if (synth.notNil) {
            self.setSynth(synth, param, value, whoChangedIt);
        }

    });

    // store internal copy
    self.masterParams.add((param ++ \Master).asSymbol -> value);

    // notify dependants MASTER
    self.changed(\setSynthMaster, param, value, whoChangedIt);

});
*/

(
~model.setSynthMaster = { arg self, param, value, whoChangedIt;

    if (param.asString.endsWith("AB"), {
        self.synths.do({|synth|
            if (synth.notNil) {
                self.setSynth(synth, (param.asString.rotate(2)[2..] ++ \A).asSymbol, value, whoChangedIt);
                self.setSynth(synth, (param.asString.rotate(2)[2..] ++ \B).asSymbol, value, whoChangedIt);
            };
        });
    },{
        self.synths.do({|synth|
            if (synth.notNil) {
                self.setSynth(synth, param, value, whoChangedIt);
            };
        });
    });

    // store internal copy
    self.masterParams.add((param ++ \Master).asSymbol -> value);

    // notify dependants MASTER
    self.changed(\setSynthMaster, param, value, whoChangedIt);

});


// used for inits
(
~model.setSynthMasterJustDependants = { arg self, param, value, whoChangedIt;

    // store internal copy
    self.masterParams.add((param ++ \Master).asSymbol -> value);

    // notify dependants MASTER
    self.changed(\setSynthMaster, param, value, whoChangedIt);

});


(
~model.clearFlags = { arg self, ringer;

    // clear all flags this ringer
    ~model.flags[ringer] = 8.collect({0});

    // notify dependants
    self.changed(\clearFlags, ringer);
});

(
~model.setFlags = { arg self, ringer, channel, value;

    // update model.flags
    ~model.flags[ringer][channel] = value;

    // notify dependants
    self.changed(\setFlags, ringer, channel);

});

// ~model.dependants;

// return
"05: Model Created!"