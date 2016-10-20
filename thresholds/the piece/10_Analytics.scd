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

/* ~angleGrinderPlot -----------------------------------------------------------

 plot angleGrinder in 2-D polar coordinates.

 doesn't launch own draw routine rather registers dependant of ~angleGrinder
 to consolidate bus.get calls to ~angleGrinder data.

 REQUIRES
 * ~angleGrinder

 NOTES
 * ~angleGrinder env var is hardcoded

*/

(
~angleGrinderPlot = {|model|

    var self = ();

    // formatting
    self.colors = [Color.red, Color(1,0.5,0), Color.yellow, Color.green, Color.cyan, Color(0, 0.5, 1), Color.magenta, Color(0.5,0,1)];
    self.decayRate = 0.01;
    self.wedgeWidth = 40;

    // window
    self.win = Window.new('~angleGrinderPlot', Rect(900, 400, 800, 450))
    .front.alwaysOnTop_(true)
    .background_(Color.black)
    .drawFunc_({ Pen.strokeColor_(Color.white).width_(2).strokeRect(self.win.bounds.moveTo(0,0).insetBy(2,2));});

    // init channels
    self.channels = 8.collect({()});

    // create channels
    model.mixedOutBusses.do({|bus, i|

        // local reference
        var channel = self.channels[i];

        // values
        channel.angle = -1;
        channel.lo = -1;
        channel.hi = -1;

    });

    // polar plot
    self.plot = ();
    self.plot.view = UserView(self.win, self.win.bounds.moveTo(0,0).insetBy(2,2)).background_(Color.grey(0.0));

    // drawFunc
    self.plot.view.drawFunc_({|view|

        // for each channel
        self.channels.do({|channel, i|

            if (channel.angle.isNil.not) {

                // line from origin to angle
                Pen.moveTo((view.bounds.width/2)@(view.bounds.height-20));
                Pen.moveTo((view.bounds.width/2+(1+i*self.wedgeWidth))@(view.bounds.height-20));
                // Pen.lineTo(Polar(50, channel.angle).asPoint);
                Pen.lineTo((view.bounds.width/2+(2+i*self.wedgeWidth))@(view.bounds.height-20));
                Pen.rotate(-1*channel.angle*2, view.bounds.width/2, view.bounds.height-20); // hey i am multiply by 2 here!!!

                // stroke

                // Pen.strokeColor_(Gradient(Color.cyan, Color.magenta).at(i/7))
                Pen.strokeColor_(self.colors[i])
                .width_(2).smoothing_(true).stroke();
                Pen.rotate(channel.angle*2, view.bounds.width/2, view.bounds.height-20);

                Pen.addAnnularWedge((view.bounds.width/2)@(view.bounds.height-20), 1+i*self.wedgeWidth, 1+i*self.wedgeWidth+self.wedgeWidth, channel.lo.neg*2, (channel.hi-channel.lo*2).neg);
                Pen.fillColor_(self.colors[i].alpha_(0.5));
                Pen.fill();

            }
        });
    });

    // update plot
    self.updatePlot = {

        // update channels
        ~grinder.channels.do({|channel, i|

            // update val from ~angleGrinder
            self.channels[i].angle = channel.angle;

            // init lo and hi
            if (self.channels[i].hi == -1) {self.channels[i].hi = channel.angle*1.05};
            if (self.channels[i].lo == -1) {self.channels[i].lo = channel.angle*0.95};

            // decay hi and lo
            self.channels[i].hi = self.channels[i].hi - ((self.channels[i].hi - self.channels[i].lo)*self.decayRate);  // update relative to width
            self.channels[i].lo = self.channels[i].lo + ((self.channels[i].hi - self.channels[i].lo)*self.decayRate);  // update relative to width
            self.channels[i].hi = max(channel.angle, self.channels[i].hi);
            self.channels[i].lo = min(channel.angle, self.channels[i].lo);

        });

        // refresh plot
        {self.plot.view.refresh()}.defer;

    };

    // register with ~angleGrinder
    ~grinder.addDependant(self['updatePlot']);

    // on close remove self from ~angleGrinder dependant list
    self.win.onClose_({~grinder.removeDependant(self['updatePlot'])});

    // return self
    self

});

// return
"10: Analytics Loaded!"