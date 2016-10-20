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

/* ~markovMaker ----------------------------------------------------------------

 simple first order markov for entropy computations

 NOTES
 * it's actually two separate transition tables, one for same-to-same
   transitions and the other for transitions btwn diff elements to combact the
   effect of first order markov not having a memory

 CONTROLS
 * ~mark.setNumBins(20)
 * ~mark.setInitValue(0.1)
 * ~mark.setForgettingThresh(0.01)
 * ~mark.setForgettingDur(10)
 * ~mark.zero

 TODO
 ? how override getters / setters with object prototyping ...
 -> i guess that means this should be a proper object
 -> need to decide convention for setting input range
 ? a way to inline ttable = ttable * beta

*/

(
~markovMaker = {

    var self = ();

    // inits
    self.numBins = 10 + 1;
    self.binWidth = 1 / (self.numBins - 1);
    self.initValue = 1;
    self.forgettingThresh = 0.01;  // value at which we consider an entry forgetten
    self.forgettingDur = inf;      // time it take to reach forgottenThresh
    self.beta = 1;                 // scale table by this value each update. this is computed internally.
    self.fps = 30;                 // assume time passes at 30 updates per second
    self.prevIndex = -1;

    // update numBins and binWidth
    self.setNumBins = {|self, num| self.numBins = num + 1; self.binWidth = 1 / (self.numBins - 1); };

    // update initValue but don't zero the table
    self.setInitValue = {|self, val| self.initValue = val; };

    // update forgottenThresh and beta
    self.setForgettingThresh = {|self, val| self.forgettingThresh = val; self.updateBeta; };

    // update forgetting and beta
    self.setForgettingDur = {|self, val| self.forgettingDur = val; self.updateBeta; };

    // calc beta from forgetting thresh and dur @ 30fps THIS IS INTERNAL DO NOT CALL DIRECTLY
    self.updateBeta = {self.beta = self.forgettingThresh.pow(1/(self.fps*self.forgettingDur))};

    // reset entire table to initial value
    self.zero = {|self| self.ttable = (self.numBins*self.numBins).collect({self.initValue})};

    // surprise
    self.surprise = {|self, val|

        // if it's not the first sample
        if (self.prevIndex != -1) {

            // decimate sample to find ttable bin index
            // self.currIndex = ((val.clip(-1, 1) + 1) / self.binWidth).round;  // bipolar input range
            self.currIndex = (val.clip(0, 1) / self.binWidth).round;   // unipolar input range

            // --- surprise --- //

            // normalize ~currIndex row as weighted probabilites and grab ~currIndex
            // self.prob = self.numBins.collect({|i| self.ttable[self.prevIndex * self.numBins + i]}).normalizeSum[self.currIndex];

            // ONLY UPDATE IF prev != curr
            if (self.prevIndex != self.currIndex) {

                self.prob = self.numBins.collect({|i|

                    if (self.prevIndex != i) {self.ttable[self.prevIndex * self.numBins + i]} {0}

                }).normalizeSum[self.currIndex];

            } {

                self.prob = self.numBins.collect({|i| self.ttable[self.prevIndex * self.numBins + i]}).normalizeSum[self.currIndex];

            };

            // entropy
            self.entropy = log(self.prob).neg;

            // --- update --- //

            // first decay
            self.ttable =  self.ttable * self.beta;

            // increment index in transition table
            self.ttable[self.prevIndex * self.numBins + self.currIndex] = self.ttable[self.prevIndex * self.numBins + self.currIndex] + 1;

            // curr -> prev
            self.prevIndex = self.currIndex;

            // return etnropy
            self.entropy

        // if it is the first sample
        } {

            // decimate sample to find ttable bin index and store
            self.prevIndex = (val.clip(0, 1) / self.binWidth).round;

            // return nil
            nil
        }

    };

    // initialize table
    self.zero;

    // return self
    self
});

/* ~entropyEngine --------------------------------------------------------------

 TODO
 -> needs a head!

 requires: anglegrider, markovMAker

 * set input bus / engine
 * adjust frame rate
 * define or instantiate markov in here
 * make peak variable not hardwird and have a text number peak display
 * scaling

 markov controls
 * ~mark.setNumBins(20)
 * ~mark.setInitValue(0.1)
 * ~mark.setForgettingThresh(0.01)
 * ~mark.setForgettingDur(10)
 * ~mark.zero

*/

(
~entropyEngine = {|model|

    var self = ();

    // init channels
    self.channels = 8.collect({()});

    // create channels
    8.do({|i|

        // local reference
        var channel = self.channels[i];

        // inits
        channel.state = 0;
        channel.entropy = 0;

        // markov
        channel.mark = ~markovMaker.value();

    });

    // calculate
    self.updateData = {

        // update channels
        ~grinder.channels.do({|channel, i|

            // calculate entropy
            var entropy = self.channels[i].mark.surprise(2*channel.angle/(pi));  // <-- scaling

            // update val
            self.channels[i].entropy = entropy;
            self.channels[i].state = self.channels[i].mark.currIndex;

        });

        // notify dependants
        self.changed();

    };

    // register with ~angleGrinder
    ~grinder.addDependant(self['updateData']);

    // on close remove self from ~angleGrinder dependant list
    self.onClose = {|self|
        ~grinder.removeDependant(self['updateData']);
    };

    // fork animation routine @60Hz on AppClock
    // self.animationRoutine = {loop{self['updatePlots'].value(); 0.016666666666667.yield;}}.fork(AppClock);
    // self.animationRoutine = {loop{self['updateData'].value(); 0.033333333333333.yield;}}.fork(AppClock);

    // on close
    // self.win.onClose_({
        // remove animation routine
       // self.animationRoutine.stop;
    // });

    // return self
    self

});

/* ~entropyPlot ----------------------------------------------------------------

 requires: anglegrider, markov

 * set input bus / engine
 * adjust frame rate
 * define or instantiate markov in here
 * make peak variable not hardwird and have a text number peak display

*/

(
~entropyPlot = {|model|

    var self = ();

    // formatting
    self.channelWidth = 40;
    self.channelHeight = 100;
    self.paddingFromEdge = 10;
    self.paddingBetween = 10;

    // window
    self.win = Window.new('~entropyPlot', Rect(900, 700, 410, 120))
    .front.alwaysOnTop_(true)
    .background_(Color.black)
    .drawFunc_({ Pen.strokeColor_(Color.white).width_(2).strokeRect(self.win.bounds.moveTo(0,0).insetBy(2,2));});

    // init channels
    self.channels = 8.collect({()});

    // create channels
    8.do({|i|

        // local reference
        var channel = self.channels[i];

        // channel container
        channel.container = CompositeView(self.win, Rect(
            i*(self.channelWidth+self.paddingBetween)+self.paddingFromEdge,
            self.paddingFromEdge,
            self.channelWidth,
            self.channelHeight)).background_(Color.cyan);

        // plot
        channel.plot = ();
        channel.plot.view = UserView(self.win, channel.container.bounds.insetBy(2,2)).background_(Color.black);
        channel.plot.diff = 0.5;
        channel.plot.entropy = 0.5;

        // drawFunc
        channel.plot.view.drawFunc_({|view|

            var yPix, yPix2, yPix3;

            yPix = 1 - (channel.plot.entropy / 7) * view.bounds.height;
            yPix2 = 1 - (channel.plot.diff / (~eEngine.channels[i].mark.numBins-1)) * view.bounds.height;

            // rect 1
            Pen.fillColor_(if (channel.plot.entropy < 7) {Color.cyan(alpha: 0.5)} {Color.red(alpha: 0.5)});
            Pen.fillRect(Rect(0, yPix, view.bounds.width/2, view.bounds.height - yPix));

            // rect 2
            Pen.fillColor_(Color.magenta(alpha: 0.5));
            Pen.fillRect(Rect(view.bounds.width/2, yPix2, view.bounds.width/2, (1/(~eEngine.channels[i].mark.numBins-1))*view.bounds.height));

            // line 1
            Pen.moveTo(0@yPix);
            Pen.lineTo((view.bounds.width/2)@yPix);
            Pen.strokeColor_(Color.cyan).width_(1).smoothing_(false).stroke();

            // line 2
            Pen.moveTo((view.bounds.width/2)@yPix2);
            Pen.lineTo(view.bounds.width@yPix2);
            Pen.strokeColor_(Color.magenta).width_(1).smoothing_(false).stroke();

            // peak
/*            if (channel.plot.entropy > 7) {
                Pen.fillColor_(Color.red(alpha:0.70));
                Pen.fillRect(Rect(0, 0, view.bounds.width/2, 6));
            };*/

        });

    });

/*    // calculate
    self.updatePlots = {

        ~aa.outBus.get({|vals|

            vals[0..0].do({|val, i|

                var entropy;

                // calculate
                entropy = ~mark.surprise(2*val/(pi));

                // peak
                if (entropy > 7) {'PEAK'.postln; entropy.postln;};

                // if different than current val update plot
                // if (val != self.channels[i].plot.val, {

                // update val
                self.channels[i].plot.entropy = entropy;
                self.channels[i].plot.diff = ~mark.currIndex;

                // refresh
                {self.channels[i].plot.view.refresh()}.defer;

            });
        });
    };*/

        // calculate
    self.updatePlots = {

        ~eEngine.channels.do({|channel, i|

                // peak
            // if (entropy > 7) {'PEAK'.postln; entropy.postln;};

                // if different than current val update plot
                // if (val != self.channels[i].plot.val, {

            // update val
            self.channels[i].plot.entropy = channel.entropy;
            self.channels[i].plot.diff = channel.state;

            // refresh
            {self.channels[i].plot.view.refresh()}.defer;

        });
    };

    // fork animation routine @60Hz on AppClock
    // self.animationRoutine = {loop{self['updatePlots'].value(); 0.016666666666667.yield;}}.fork(AppClock);
    // self.animationRoutine = {loop{self['updatePlots'].value(); 0.033333333333333.yield;}}.fork(AppClock);

    // register with entropy engine
    ~eEngine.addDependant(self['updatePlots']);

    // on close
    self.win.onClose_({
        // remove listener
        // model.removeDependant(self['updater']);
        // remove animation routine
        // self.animationRoutine.stop;
        ~eEngine.removeDependant(self['updatePlots']);
    });

    // return self
    self

});

/* ~entropySequencer -----------------------------------------------------------

 a state sequencer.

 TODO
 -> select which channels to see
 -> figure out scaling convention what comes out what goes in
 -> scaling is a hack
 -> turn onoff min max for efficienct

*/

(
~entropySequencer = {|model, numChannels=2|

    var self = ();

    // params
    self.buffSize = 200;

    // formatting
    self.colors = [Color.red, Color(1,0.5,0), Color.yellow, Color.green, Color.cyan, Color(0, 0.5, 1), Color.magenta, Color(0.5,0,1)];

    // window
    self.win = Window.new('~entropySequencer', Rect(900, 400, 760, numChannels*200+10))
    .front.alwaysOnTop_(true)
    .background_(Color.black)
    .drawFunc_({ Pen.strokeColor_(Color.white).width_(2).strokeRect(self.win.bounds.moveTo(0,0).insetBy(2,2));});

    // init channels
    self.channels = numChannels.collect({()});

    // create channels
    self.channels.do({|channel, i|

        // local reference
        // var channel = self.channels[i];

        // angle
        channel.state = self.buffSize.collect({0.5});
        channel.entropy = self.buffSize.collect({0.5});

        // plot
        channel.plot = ();
        channel.plot.view = UserView(self.win, Rect(
            6,
            i*200+6,
            750,
            200-2)).background_(Color.grey(0.1));

        // drawFunc
        channel.plot.view.drawFunc_({|view|

            // first
            Pen.moveTo(0 @ (0.5 * view.bounds.height));

            // subsequent
            channel.state.do({|val, index|
                Pen.lineTo( (index/self.buffSize * view.bounds.width)@(1- val * view.bounds.height));
            });

            // stroke
            Pen.strokeColor_(Color.magenta).width_(2).smoothing_(true).stroke();

            // first
            Pen.moveTo(0 @ (0.5 * view.bounds.height));

            // subsequent
            channel.entropy.do({|val, index|
                Pen.lineTo( (index/self.buffSize * view.bounds.width)@(1 - val * view.bounds.height));
            });

            // stroke
            Pen.strokeColor_(Color.cyan).width_(2).smoothing_(true).stroke();

        });

    });

    // update plot
    self.updatePlots = {

        ~eEngine.channels[0..(numChannels-1)].do({|channel, i|

            var hi, lo, val, entropy;

            val = channel.state / (channel.mark.numBins-1);
            entropy = channel.entropy / 7;

            // update val: append to list
            self.channels[i].state = self.channels[i].state.rotate(-1).put(self.buffSize-1, val);
            self.channels[i].entropy = self.channels[i].entropy.rotate(-1).put(self.buffSize-1, entropy);

            // refresh plot
            {self.channels[i].plot.view.refresh()}.defer;

        })
    };

    // fork animation routine @60Hz on AppClock
    // self.animationRoutine = {loop{self['updatePlot'].value(); 0.016666666666667.yield;}}.fork(AppClock);
    // self.animationRoutine = {loop{self['updatePlots'].value(); 0.033333333333333.yield;}}.fork(AppClock);

    // register with entropy engine
    ~eEngine.addDependant(self['updatePlots']);

    // on close
    self.win.onClose_({
        // remove animation routine
        // self.animationRoutine.stop;
        // free each channel
        self.channels.do({|channel|
            // free channel mfcc machine synths
            // channel.mfccAngleSynth.free;
        });
        // free outBus nope cuz it belongs to ~aa
        // self.outBus.free;
        ~eEngine.removeDependant(self['updatePlots']);
    });

    // return self
    self

});

// return
"10: Analytics Loaded!"