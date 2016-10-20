/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 A suite of analytic GUIs for figuring out what is happening.

*/

/* ~angleGrinder ---------------------------------------------------------------

 projects a feature vector to 1-d by multi angle measured to normal vector.

 ~angleGrinder just computes. separate plot GUI to see and analyze.

 features should be made variable but we'll use mfccs for now.

*/

/* ----- SynthDefs ----- */

(
// synthdef to measure mfcc vector angle
SynthDef(\mfccAngle, { |inBus, outBus|

    var in, mfcc, norm, theta;

    // input
    in = InFeedback.ar(inBus);

    // features
    mfcc = MFCC.kr(FFT(LocalBuf(2048), in, hop: 0.5));

    // norm
    // norm = [1,2,3,4,5,6,7,8,9,10,11,12,13]/13;
    norm = [1,1,1,1,1,1,1,1,1,1,1,1,1];

    // theta
    theta = acos((mfcc * norm).sum / (mfcc.pow(2).abs.sum.sqrt * norm.pow(2).abs.sum.sqrt));

    // out
     Out.kr(outBus, theta);

}).add
);

/* ----- GUI ----- */
(
~angleGrinder = {|model|

    var self = ();

    // init channels
    self.channels = 8.collect({()});

    // init outBus's (all at once)
    self.outBus = Bus.control(s, 8);

    // create channels
    model.mixedOutBusses.do({|bus, i|

        // local reference
        var channel = self.channels[i];

        // bus
        channel.outBus = self.outBus.subBus(i);
        channel.inBus = bus;

        // angle
        channel.angle = -1;

        // launch mfcc machine synth
        channel.mfccAngleSynth = Synth(\mfccAngle, [\inBus, channel.inBus, \outBus, channel.outBus]);

    });

    // update Data
    self.updateData = {

        self.outBus.get({|vals|

            // update vals
            vals.do({|val, i| self.channels[i].angle = val});

            // notify dependants
            self.changed();
        })
    };

    // fork animation routine @60Hz on AppClock
    // self.animationRoutine = {loop{self['updatePlot'].value(); 0.016666666666667.yield;}}.fork(AppClock);
    self.animationRoutine = {loop{self['updateData'].value(); 0.033333333333333.yield;}}.fork(AppClock);

    // there's no window to close to call this to stop animation and free resources
    self.onClose = {|self|

        // remove animation routine
        self.animationRoutine.stop;
        // free each channel
        self.channels.do({|channel|
            // free channel mfcc machine synths
            channel.mfccAngleSynth.free;
        });
        // free outBus
        self.outBus.free;
    };

    // return self
    self

});

// return
"10: Analytics Loaded!"