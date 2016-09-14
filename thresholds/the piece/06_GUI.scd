/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 A suite of GUIs for dealin with this unruly beast.

 * do i want all scopes to have same xZoom?
 * some consistent formatting like and padding border?
 * this synth index stuff ...

 TODO
 * faster response have an update param function that gets called directly by
   knob movement and keep track in the responder who called it so don't re-up
   date. currently knob goes through the model and back to make GUI changes.
 * add whoChangedIt to updaters

*/


/* ~quickGui -------------------------------------------------------------------

 A quick and dirty GUI.

 todo
 -> register with model for changes

*/

(
~quickGUI = {|synth, synthDef, winlabelname|

    var win;

    // setup window
    win = Window.new(winlabelname, Rect(500,200,500,700)).front.alwaysOnTop_(true);
    win.view.decorator = FlowLayout(win.view.bounds);

    // loop through all synth params
    synthDef.allControlNames.do({|ctrl|

        var container, label, slider, number, param;

        // only display params that have specs
        if (ctrl.name.asSpec.notNil) {

            // param
            param = ctrl.name;

            // setup container
            container = CompositeView(win, Rect(0,0,500,20));
            container.decorator = FlowLayout(Rect(0,0,500,20));

            // label
            label = StaticText(container, Rect(0,0,100,16)).string_(param).font_(Font.default.size_(12));

            // slider
            slider = Slider(container, Rect(0,0,260,16));

            // number box
            number = NumberBox(container, Rect(0,0, 40, 16)).value_(1.0);
            number.decimals_(2);
            number.font_(Font.default.size_(12));
            number.align_(\center);

            // actions
            slider.action_({|slider|
                if (synth.notNil) {synth.set(param, param.asSpec.map(slider.value))};
                number.value_(param.asSpec.map(slider.value));
            });
            number.action_({|numb|
                if (synth.notNil) {synth.set(param, number.value)};
                slider.value_(param.asSpec.unmap(number.value));
            });

            // initial value
            if (synth.notNil) {
                synth.get(param, {|val| {slider.value_(param.asSpec.unmap(val)); number.value_(val)}.defer});
            };

        }
    });
});

/* ~octoscope ------------------------------------------------------------------

 8-channel scope and primary controls for use with Korg nano

 todo:
 -> if self then can call without value
 -> use .return.return.return syntax
 -> init direct from synth now but should be through model
 ??? ref to self in updater
 -> would be nice otknow it was knob so dont set again but whatevr
 -> scope in scopeview needs -2/+2 left right

*/

(
~octoScope = {|model|

    var myOctoscope = ();

    // settings
    myOctoscope.highlighterColors = [Color.magenta, Color.cyan, Color.yellow];

    // window
    myOctoscope.win = Window.new('Octoscope', Rect(100,500,1225,210)).front.alwaysOnTop_(true);
    myOctoscope.win.background_(Color.black);

    // init channels
    myOctoscope.channels = 8.collect({()});

    // loop through all mixedOutBusses
    model.mixedOutBusses.do({|bus, i|

        // local reference
        var channel = myOctoscope.channels[i];

        // synth and which of pair
        channel.msynth = model.synths[i.div(2)];
        channel.aorb = [\A,\B][i%2];

        // channel container
        channel.container = CompositeView(myOctoscope.win, Rect(i*150+12, 10, 149, 500));

        // oscilloscope
        channel.scopeView = CompositeView(channel.container, Rect(0, 0, channel.container.bounds.width, 85));
        channel.scope = Stethoscope.new(bus.server, 1, bus.index, view: channel.scopeView, zoom: 2);
        channel.scope.view.bounds_(Rect(0, -28, channel.container.bounds.width+19, 85+47));
        channel.scope.scopeView.waveColors_([Color.red]);
        channel.scope.scopeView.background_(Color.white);
        channel.scope.scopeView.fill_(true);

        // kosc r slider
        channel.rSlider = Knob(channel.container, Rect(0, 95, 45, 45));
        channel.rSlider.color_(channel.rSlider.color.put(1, Color.grey));
        channel.rSlider.action_({|slider| if (channel.msynth.notNil) {model.setSynth(channel.msynth, (\koscR ++ channel.aorb).asSymbol, (\koscR ++ channel.aorb).asSymbol.asSpec.map(slider.value))}});

        // kosc r numbox
        channel.rNumber = NumberBox(channel.container, Rect(55, 95+12, 50, 20))
        .value_(1.0)
        .decimals_(3)
        .font_(Font.default.size_(12))
        .normalColor_(Color.white)
        .align_(\right)
        .background_(Color.clear)
        .action_({|number| if (channel.msynth.notNil) {model.setSynth(channel.msynth, (\koscR ++ channel.aorb).asSymbol, number.value)}});

        // preamp slider
        channel.preAmpSlider = Knob(channel.container, Rect(0, 95+50, 45, 45));
        channel.preAmpSlider.color_(channel.preAmpSlider.color.put(1, Color.grey));
        channel.preAmpSlider.action_({|slider| if (channel.msynth.notNil) {model.setSynth(channel.msynth, (\preAmpPot ++ channel.aorb).asSymbol, (\preAmpPot ++ channel.aorb).asSymbol.asSpec.map(slider.value))}});

        // preamp numbox
        channel.preAmpNumber = NumberBox(channel.container, Rect(55, 95+50+12, 50, 20))
        .value_(1.0)
        .decimals_(3)
        .font_(Font.default.size_(12))
        .normalColor_(Color.white)
        .align_(\right)
        .background_(Color.clear)
        .action_({|number| if (channel.msynth.notNil) {model.setSynth(channel.msynth, (\preAmpPot ++ channel.aorb).asSymbol, number.value)}});

        // highlighters
        channel.highlighters = 3.collect({ |j|
            View.new(channel.container, Rect(channel.container.bounds.width-(j+1*6)-1, 2, 5, 5))
                .background_(myOctoscope.highlighterColors[j]
                .alpha_(0.5 * ~model.flags[j][i]))
        });

        // init koscR
        if (channel.msynth.notNil) {
            channel.msynth.get((\koscR ++ channel.aorb).asSymbol, { |value| {
                channel.rSlider.value_((\koscR ++ channel.aorb).asSymbol.asSpec.unmap(value));
                channel.rNumber.value_(value);
            }.defer });
        };

        // init preAmp
        if (channel.msynth.notNil) {
            channel.msynth.get((\preAmpPot ++ channel.aorb).asSymbol, { |value| {
                channel.preAmpSlider.value_((\preAmpPot ++ channel.aorb).asSymbol.asSpec.unmap(value));
                channel.preAmpNumber.value_(value)
            }.defer });
        };

    });

    // updater
    myOctoscope.updater = { arg model, whatChanged ... args;

        if (whatChanged == \setSynth) {

            var synthIndex, param, value, channel;

            // unpack args
            synthIndex = args[0]; param = args[1]; value = args[2];

            // update GUI
            if (param == \koscRA, {
                channel = myOctoscope.channels[synthIndex*2 + 0];
                channel.rSlider.value_(\koscRA.asSpec.unmap(value));
                channel.rNumber.value_(value);
            });
            if (param == \koscRB, {
                channel = myOctoscope.channels[synthIndex*2 + 1];
                channel.rSlider.value_(\koscRA.asSpec.unmap(value));
                channel.rNumber.value_(value);
            });
            if (param == \preAmpPotA, {
                channel = myOctoscope.channels[synthIndex*2 + 0];
                channel.preAmpSlider.value_(\preAmpPotA.asSpec.unmap(value));
                channel.preAmpNumber.value_(value);
            });
            if (param == \preAmpPotB, {
                channel = myOctoscope.channels[synthIndex*2 + 1];
                channel.preAmpSlider.value_(\preAmpPotB.asSpec.unmap(value));
                channel.preAmpNumber.value_(value);
            });
        };

        if (whatChanged == \setFlags) {

            var ringer, channel;

            // unpack args
            ringer = args[0]; channel = args[1];

            // update channel highlighter
            myOctoscope.channels[channel].highlighters[ringer]
                .background_(myOctoscope.highlighterColors[ringer]
                .alpha_(1.0 * ~model.flags[ringer][channel]));
        };

        if (whatChanged == \clearFlags) {

            var ringer;

            // unpack args
            ringer = args[0];

            // clear all channel highlighters
            myOctoscope.channels.do({ |channel| channel.highlighters[ringer]
                .background_(myOctoscope.highlighterColors[ringer]
                .alpha_(0))
            });
        };

    };

    // add octoscope updater function to model dependant list
    model.addDependant(myOctoscope['updater']);

    // remove updater function on window close
    myOctoscope.win.onClose_({model.removeDependant(myOctoscope['updater'])});

    // return osctoscope
    myOctoscope

});

/* ~lowpass --------------------------------------------------------------------

 Lowpass Filters

 todo:
 -> scope in scopeview needs -2/+2 left right

*/
(
~lowPassScope = {|model|

    var self = ();

    // settings
    self.channelWidth = 100;
    self.knobSize = 50;

    // window
    self.win = Window.new('LowPass', Rect(100,500,425,138))
    .front.alwaysOnTop_(true)
    .background_(Color.black);
    self.win.drawFunc_({Pen.strokeColor_(Color.white).width_(2).strokeRect(self.win.bounds.moveTo(0,0).insetBy(2,2))});

    // init channels 1 for each synth
    self.channels = model.synths.collect({()});

    // helpers
    self.numToFreqString = {|val| (1 / (2 * pi * (8e3 * (1 - val) * 100e3 * 0.1e-6 * 0.1e-6).sqrt)).asStringPrec(4) ++ ' Hz'};

    // create channels
    model.synths.do({|synth, i|

        // local reference
        var channel = self.channels[i];

        // synth
        channel.msynth = synth;

        // channel container
        channel.container = CompositeView(self.win, Rect(i*100+12, 10, 99, 200));

        // lowPassPot knob
        channel.lowPassPotKnob = Knob(channel.container, Rect(0, 0, self.knobSize, self.knobSize));
        channel.lowPassPotKnob.color_(channel.lowPassPotKnob.color.put(1, Color.grey));
        channel.lowPassPotKnob.action_({|knob| if (channel.msynth.notNil) {model.setSynth(channel.msynth, \lowPassPot, \lowPassPot.asSpec.map(knob.value))}});

        // lowPassPot numberBox
        channel.lowPassPotNumber = NumberBox(channel.container, Rect(channel.container.bounds.width - 45, 2, 40, 20))
        .value_(1.0)
        .decimals_(3)
        .font_(Font.default.size_(12))
        .normalColor_(Color.white)
        .align_(\right)
        .background_(Color.clear)
        .action_({|number| if (channel.msynth.notNil) {model.setSynth(channel.msynth, \lowPassPot, number.value)}});

        // lowPassPot freq display text
        channel.lowPassPotFreqText = StaticText(channel.container, Rect(channel.container.bounds.width - 64, 33, 58, 20))
        .string_(self['numToFreqString'].value(0))
        .font_(Font.default.size_(9))
        .stringColor_(Color.white)
        .align_(\right)
        .background_(Color.clear)
        .action_({|number| if (channel.msynth.notNil) {model.setSynth(channel.msynth, \lowPassPot, number.value)}});

        // oscilloscope
        channel.scopeView = CompositeView(channel.container, Rect(0, self.knobSize+10, channel.container.bounds.width, 57));
        channel.scope = Stethoscope.new(model.scopeBusses[i].server, 2, model.scopeBusses[i].index, view: channel.scopeView, zoom: 1);
        channel.scope.style_(1);
        channel.scope.view.bounds_(Rect(0, -28, channel.container.bounds.width+19, 57+47));
        channel.scope.scopeView.waveColors_([Color.magenta, Color.cyan]);
        channel.scope.scopeView.fill_(true);

        // init lowPassPot
        if (channel.msynth.notNil) {
            channel.msynth.get(\lowPassPot, { |value| {
                channel.lowPassPotKnob.value_(\lowPassPot.asSpec.unmap(value));
                channel.lowPassPotNumber.value_(value);
                channel.lowPassPotFreqText.string_(self['numToFreqString'].value(value));
            }.defer });
        };

    });

    // updater
    self.updater = { arg model, whatChanged ... args;

        if (whatChanged == \setSynth) {

            var synthIndex, param, value, channel;

            // unpack args
            synthIndex = args[0]; param = args[1]; value = args[2];

            // update GUI
            if (param == \lowPassPot, {

                // which channel
                channel = self.channels[synthIndex];

                // update knob
                channel.lowPassPotKnob.value_(\lowPassPot.asSpec.unmap(value));

                // update numberBox
                channel.lowPassPotNumber.value_(value);

                // update freq text
                channel.lowPassPotFreqText.string_(self['numToFreqString'].value(value));

            });
        };
    };

    // add updater function to model dependant list
    model.addDependant(self['updater']);

    // remove updater function on window close
    self.win.onClose_({model.removeDependant(self['updater'])});

    // return self
    self

});

/* ~attractors -----------------------------------------------------------------

 todo
 -> resize
 -> sliders for x,y zoom
 -> overlay a pair diff colors?
 -> overlay waveforms? or even below X,Y

*/

(
~attractors = {|model, style=2|

    var self = ();

    // formatting
    self.scopeSize = 120;
    self.paddingFromEdge = 10;
    self.paddingCeneterColumn = 8;
    self.paddingWithinPair = 1;

    // window
    self.win = Window.new('Attractors', Rect(
        100,
        500,
        self.scopeSize*4+self.paddingFromEdge+self.paddingFromEdge+self.paddingCeneterColumn,
        self.scopeSize*2+self.paddingFromEdge+self.paddingFromEdge+self.paddingCeneterColumn)
    ).front.alwaysOnTop_(true)
    .background_(Color.black);
    self.win.drawFunc_({Pen.strokeColor_(Color.white).width_(2).strokeRect(self.win.bounds.moveTo(0,0).insetBy(2,2))});

    // self.win.background_(Color.black);

    // init channels 1 for each osc
    self.channels = model.componentOutBusses.collect({()});

    // create channels
    model.componentOutBusses.do({|bus, i|

        // local reference
        var channel = self.channels[i];

        // channel container
        channel.container = CompositeView(self.win, Rect(0,0,100,100));

        // channel container
        channel.container = CompositeView(self.win, Rect(
            (i%2)*(self.scopeSize+self.paddingWithinPair) + ((i/4).asInteger*(self.scopeSize*2+self.paddingCeneterColumn+self.paddingWithinPair)) + self.paddingFromEdge,
            (i/2).asInteger%2*(self.scopeSize+self.paddingCeneterColumn) + self.paddingFromEdge,
            self.scopeSize,
            self.scopeSize));

        // oscilloscope
        channel.scopeView = CompositeView(channel.container, Rect(0,0,channel.container.bounds.width, channel.container.bounds.height));
        channel.scope = Stethoscope.new(bus.server, 2, bus.index, view: channel.scopeView, zoom: 10);
        channel.scope.yZoom_(2);
        channel.scope.style_(style);
        channel.scope.view.bounds_(Rect(-2, -28, channel.scopeView.bounds.width+21, channel.scopeView.bounds.height+47));
        channel.scope.scopeView.waveColors_([Color.magenta, Color.white]);
        channel.scope.scopeView.background_(Color.magenta(0.1, 1));
        channel.scope.scopeView.fill_(true);

    });

    // return self
    self

});

/* ~lfo ------------------------------------------------------------------------

 controls:

   * lfoPotA, lfoPotB
   * lfoCapSwitchA, lfoCapSwitchB
   * lfoLowPassPotA, lfoLowPassPotB
   * lfoCoupling

 and led-like monitor when they are firing

 todo
 -> bug: sometimes blinker misses a flash or flashes twice
    * fixed: monitoring on pre-LP b/c lowpass values caused some trouble
 -> bug: blinker faster than ~ 4hz undersampling blinker rendering... really just want all on it's b/c the impulse duty cycle is too narrow
 -> refactor: un-hardwire from 8 to number of lfo busses and the number of ACTIVE synths when that's rolling, same with [0,2,4,6]
 -> question: gui animation best practice? i'm launching an appclock thread to driver the window drawFun
 -> question: best way to detect control bus triggers via appclock thread?
 -> snag:: computes from formula here, even if used static method of LFO still wouldn't correspond to instance variable changes

*/
(
~lfoscope = {|model|

    var self = ();

    // formatting
    self.lfoPotKnobSize = 60;
    self.lfoLowPassPotSize = 30;
    self.blinkerSize = 10;

    // window
    self.win = Window.new('LFOs', Rect(100, 500, 926, 150))
    .front.alwaysOnTop_(true)
    .background_(Color.black);

    // init channels 1 for each channel
    self.channels = 8.collect({()});

    // helpers
    self.normToLfoFreqString = {|val, c|

        var freq = 1.44 / ( (1e3 + (2 * val * 1e6) ) * (if (c.asBoolean.not, {10.0e-6}, {0.22e-6})));

        if (freq > 1.0, {freq.asStringPrec(2) ++ ' Hz'}, {(1.0/freq).asStringPrec(4) ++ ' s'});

        };

    // helpers
    self.normToLowPassFreqString = {|val| (1 / (2 * pi * (8e3 * (1 - val) * 100e3 * 0.1e-6 * 0.1e-6).sqrt)).asStringPrec(3) ++ ' Hz'};

    // create channels
    8.do({|i|

        // local reference
        var channel = self.channels[i];

        // synth and which of pair
        channel.msynth = model.synths[i.div(2)];
        channel.aorb = [\A,\B][i%2];

        // a few local copies
        channel.lfoCapSwitch = 0;
        channel.blinkerValue = -1;

        // channel container
        channel.container = CompositeView(self.win, Rect(i*115+10,60,115,100));

        // lfoPot knob
        channel.lfoPotKnob = Knob(channel.container, Rect(0, 0, self.lfoPotKnobSize, self.lfoPotKnobSize));
        channel.lfoPotKnob.color_(channel.lfoPotKnob.color.put(1, Color.grey))
        .action_({|knob| if (channel.msynth.notNil) {model.setSynth(channel.msynth, (\lfoPot ++ channel.aorb).asSymbol, (\lfoPot ++ channel.aorb).asSymbol.asSymbol.asSpec.map(knob.value))}});

        // lfoPot text
        channel.lfoPotText = StaticText(channel.container, Rect(self.lfoPotKnobSize/2-25, self.lfoPotKnobSize+4, 50, 20))
        .font_(Font.default.size_(11))
        .stringColor_(Color.grey(0.6))
        .align_(\center)
        .background_(Color.clear);

        // lfoLowPassPot knob
        channel.lfoLowPassPotKnob = Knob(channel.container, Rect(self.lfoPotKnobSize+4, self.lfoPotKnobSize-self.lfoLowPassPotSize, self.lfoLowPassPotSize, self.lfoLowPassPotSize));
        channel.lfoLowPassPotKnob.color_(channel.lfoLowPassPotKnob.color.put(1, Color.grey))
        .action_({|knob| if (channel.msynth.notNil) {model.setSynth(channel.msynth, (\lfoLowPassPot ++ channel.aorb).asSymbol, (\lfoLowPassPot ++ channel.aorb).asSymbol.asSpec.map(knob.value))}});

        // lfoLowPassPot text
        channel.lfoLowPassPotText = StaticText(channel.container, Rect(self.lfoPotKnobSize+4+(self.lfoLowPassPotSize/2)-(50/2)+2, self.lfoPotKnobSize+0, 50, 20))
        .font_(Font.default.size_(8))
        .stringColor_(Color.grey(0.6))
        .align_(\center)
        .background_(Color.clear);

        //lfoCapSwitch checkbox
        channel.lfoCapSwitchCheckBox = CheckBox(self.win, Rect(50*i + (self.win.bounds.width/4)+50, 10, 25, 25))
        .action_({|checkbox| if (channel.msynth.notNil) {model.setSynth(channel.msynth, (\lfoCapSwitch ++ channel.aorb).asSymbol, checkbox.value)}});

        // blinker
        channel.blinker = CompositeView(channel.container, Rect(self.lfoPotKnobSize+4+(self.lfoLowPassPotSize/2)-(self.blinkerSize/2), 10, self.blinkerSize, self.blinkerSize));

        // init lfoCapSwitch (init first b/c lfoPotText depends on it)
        if (channel.msynth.notNil) {
            channel.msynth.get((\lfoCapSwitch ++ channel.aorb).asSymbol, { |value| {
                channel.lfoCapSwitchCheckBox.value_(value);
                channel.lfoCapSwitch = value;
            }.defer });
        };

        // init lfoPot
        if (channel.msynth.notNil) {
            channel.msynth.get((\lfoPot ++ channel.aorb).asSymbol, { |value| {
                channel.lfoPotKnob.value_((\lfoPot ++ channel.aorb).asSymbol.asSpec.unmap(value));
                channel.lfoPotText.string_(self['normToLfoFreqString'].value((\lfoPot ++ channel.aorb).asSymbol.asSpec.unmap(value), channel.lfoCapSwitch));
            }.defer });
        };

        // init lfoLowPassPot
        if (channel.msynth.notNil) {
            channel.msynth.get((\lfoLowPassPot ++ channel.aorb).asSymbol, { |value| {
                channel.lfoLowPassPotKnob.value_((\lfoLowPassPot ++ channel.aorb).asSymbol.asSpec.unmap(value));
                channel.lfoLowPassPotText.string_(self['normToLowPassFreqString'].value((\lfoLowPassPot ++ channel.aorb).asSymbol.asSpec.unmap(value)));
            }.defer });
        };

    });

    // draw brackets
    self.win.drawFunc_({

        // white border
        Pen.strokeColor_(Color.white).width_(2).strokeRect(Rect(0, 0, 926, 150).insetBy(2,2));

        // in pairs
        [0,2,4,6].do({|i|

            var p1, p2;

            // reference points
            p1 = self.channels[i].container.bounds.origin.translate(self.channels[i].lfoPotKnob.bounds.width/4@0);
            p2 = self.channels[i+1].container.bounds.origin.translate(self.channels[i+1].lfoPotKnob.bounds.width*3/4@0);

            // path
            Pen.moveTo(p1.translate(0@(-4)));
            Pen.lineTo(p1.translate(0@(-11)));
            Pen.lineTo(p2.translate(0@(-11)));
            Pen.lineTo(p2.translate(0@(-4)));

            // stroke
            Pen.strokeColor = Color.white;
            Pen.stroke;

        });

    });

    // update blinkers
    self.updateBlinkers = {

        // check current lfo bus val against internal val
        model.lfoScopeBusses.get({|vals| vals.do({|val,i|

            // if different update that channel
            if (val != self.channels[i].blinkerValue, {

                // update color
                {self.channels[i].blinker.background_([Color.red, Color.grey(0.65)][1-val])}.defer;

                // update internal val
                self.channels[i].blinkerValue = val;
            });

        })});
    };

    // updater
    self.updater = { arg model, whatChanged ... args;

        if (whatChanged == \setSynth) {

            var synthIndex, param, value, channel;

            // unpack args
            synthIndex = args[0]; param = args[1]; value = args[2];

            // update GUI
            if (param == \lfoPotA) {
                channel = self.channels[synthIndex*2 + 0];
                channel.lfoPotKnob.value_(\lfoPotA.asSpec.unmap(value));
                channel.lfoPotText.string_(self['normToLfoFreqString'].value(\lfoPotA.asSpec.unmap(value), channel.lfoCapSwitch));
            }{ if (param == \lfoPotB) {
                channel = self.channels[synthIndex*2 + 1];
                channel.lfoPotKnob.value_(\lfoPotB.asSpec.unmap(value));
                channel.lfoPotText.string_(self['normToLfoFreqString'].value(\lfoPotB.asSpec.unmap(value), channel.lfoCapSwitch));
            }{ if (param == \lfoLowPassPotA) {
                channel = self.channels[synthIndex*2 + 0];
                channel.lfoLowPassPotKnob.value_(\lfoLowPassPotA.asSpec.unmap(value));
                channel.lfoLowPassPotText.string_(self['normToLowPassFreqString'].value(\lfoLowPassPotA.asSpec.unmap(value)));
            }{ if (param == \lfoLowPassPotB) {
                channel = self.channels[synthIndex*2 + 1];
                channel.lfoLowPassPotKnob.value_(\lfoLowPassPotB.asSpec.unmap(value));
                channel.lfoLowPassPotText.string_(self['normToLowPassFreqString'].value(\lfoLowPassPotB.asSpec.unmap(value)));
            }{ if (param == \lfoCapSwitchA) {
                channel = self.channels[synthIndex*2 + 0];
                channel.lfoCapSwitchCheckBox.value_(value);
                channel.lfoCapSwitch = value;
                channel.lfoPotText.string_(self['normToLfoFreqString'].value(channel.lfoPotKnob.value, channel.lfoCapSwitch));
            }{ if (param == \lfoCapSwitchB) {
                channel = self.channels[synthIndex*2 + 1];
                channel.lfoCapSwitchCheckBox.value_(value);
                channel.lfoCapSwitch = value;
                channel.lfoPotText.string_(self['normToLfoFreqString'].value(channel.lfoPotKnob.value, channel.lfoCapSwitch));
            }}}}}};
        };
    };

    // add updater function to model dependant list
    model.addDependant(self['updater']);

    // fork drawFunc routine @60Hz on AppClock
    self.drawRoutine = {loop{self['updateBlinkers'].value(); 0.016666666666667.yield;}}.fork(AppClock);

    // remove drawRoutine and updater function on window close
    self.win.onClose_({model.removeDependant(self['updater']); self.drawRoutine.stop});

    // return self
    self

});

/* ~vactrolscope ---------------------------------------------------------------

attack
decay
time
depth
offset

*/

(
~vactrolscope = {|model|

    var self = ();

    // settings
    self.channelWidth = 40;
    self.channelHeight = 180;
    self.paddingBetween = 5;
    self.paddingFromEdge = 10;

    // window
    self.win = Window.new('~vactrolscope', Rect(100, 500, (self.channelWidth*8)+(self.paddingBetween*7)+(self.paddingFromEdge*2), self.channelHeight+self.paddingFromEdge+self.paddingFromEdge))
    .front.alwaysOnTop_(true)
    .background_(Color.black);
    self.win.drawFunc_({Pen.strokeColor_(Color.white).width_(2).strokeRect(self.win.bounds.moveTo(0,0).insetBy(2,2))});

    // init channels
    self.channels = model.vactrolScopeBusses.collect({()});

    // loop through all vactrolScopeBusses
    model.vactrolScopeBusses.do({|bus, i|

        // local referenceKnob
        var channel = self.channels[i];

        // synth and which of pair
        channel.msynth = model.synths[i.div(2)];
        channel.aorb = [\A,\B][i%2];

        // channel container
        channel.container = UserView(self.win, Rect(
            i*(self.channelWidth+self.paddingBetween) + self.paddingFromEdge,
            self.paddingFromEdge,
            self.channelWidth,
            self.channelHeight)).background_(Color.cyan);

        // oscilloscope
        channel.scopeView = CompositeView(channel.container, Rect(0, 0, channel.container.bounds.width, self.channelHeight-self.paddingFromEdge-self.paddingFromEdge+20));
        channel.scope = Stethoscope.new(bus.server, 3, bus.index, view: channel.scopeView, zoom: 8);
        channel.scope.yZoom_(0.8);
        channel.scope.view.bounds_(Rect(-2, -28, channel.scopeView.bounds.width+21, channel.scopeView.bounds.height+47+30));
        channel.scope.scopeView.waveColors_([Color.white, Color.magenta, Color.white]);
        channel.scope.scopeView.background_(Color.black);
        channel.scope.scopeView.fill_(true);
        channel.scope.style_(0);

    });

    /* in progress: plot y axis ticks and labels

    // plot
    self.plot = ();

    // formatting
    self.plot.tickLength = 5;
    self.plot.labelWidth = 24;

    // plot view
    self.plot.view = UserView(self.win, Rect(
        self.paddingFromEdge,
        self.paddingFromEdge,
        self.win.bounds.width-self.paddingFromEdge-self.paddingFromEdge+50,
    self.channelHeight)).background_(Color.clear);

    // y-axis
    self.plot.numTicks = 4;
    self.plot.offset = 0.0;
    self.plot.depth = 2;
    self.plot.skew = {|val| if (val < self.plot.offset, {val.linlin(-1,0,-1,self.plot.offset)}, {val.linlin(0,1,self.plot.offset,1)})};
    self.plot.tickVals = (-1, 2/self.plot.numTicks-1 .. 1);
    self.plot.ticks = self.plot.tickVals.collect(self.plot['skew']);

    // draw
    self.plot.view.drawFunc_({

        // x pos
        var xPos = self.plot.view.bounds.width-self.plot.labelWidth-self.plot.tickLength-self.plot.tickLength;

        // formatting
        Pen.strokeColor_(Color.magenta).color_(Color.magenta);

        // vertical axis
        Pen.moveTo(xPos@10);
        Pen.lineTo(xPos@(self.plot.view.bounds.height-10));
        Pen.width_(1).smoothing_(false).stroke();

        // ticks
        self.plot.ticks.do({|y_norm, i|

            // y pos
            var yPos, maj;

            maj = ([-1.0, 0.0, 1.0].includes(self.plot.tickVals[i]));
            yPos = y_norm.linlin(-1,1,self.plot.view.bounds.height-10,10);

            // draw tick
            Pen.moveTo((xPos-self.plot.tickLength)@yPos);
            Pen.lineTo((xPos+self.plot.tickLength)@yPos);
            Pen.width_(if (maj, {1}, {1})).smoothing_(false).stroke();

            // draw label
            Pen.font_(Font( "Arial", 10 ));
            Pen.stringAtPoint(self.plot.depth.pow(self.plot.tickVals[i]).asStringPrec(3),
            (self.plot.view.bounds.width-self.plot.labelWidth+6)@yPos-6);
        });

        /*        // dashed lines
        self.plot.ticks.do({|y_norm, i|

        // y pos
        var yPos = y_norm.linlin(-1,1,self.plot.view.bounds.height-10,10);

        // draw line
        Pen.moveTo(0@yPos);
        Pen.lineTo((xPos-self.plot.tickLength-10)@yPos);
        Pen.lineDash_(FloatArray.newFrom([2.0,2.0]));
        Pen.width_(1).smoothing_(false).strokeColor_(Color.magenta(alpha:0.75)).stroke();

        });*/

    });
    */

    // return self
    self

});

/* ~patchbay -------------------------------------------------------------------

 controls what you hear... super just sketch so i can get some basic control now.

 these post processin GUIS define and launch their own synths but still would like
 to keep track of them on window close etc. need something to persist in the model
 but don't want to hardcode it in. maybe these guys can add stuff to the model
 dynamicall and on load check for it. that's nice. do this later.

 -> have internal state variable that is separate from button val

*/
(
~patchbay = {|model|

    var self = ();

    // formatting
    self.buttonWidth = 60;
    self.buttonHeight = 40;
    self.paddingBetween = 10;
    self.paddingFromEdge = 10;

    // window
    self.win = Window.new('patchbay', Rect(100, 500, 290, 60))
    .front.alwaysOnTop_(true)
    .background_(Color.black)
    .drawFunc_({Pen.strokeColor_(Color.white).width_(2).strokeRect(Rect(0, 0, 290, 60).insetBy(2,2))});

    // init channels 1 for each synth
    self.channels = model.synths.collect({()});

    // create channels
    model.synths.do({|synth, i|

        // local reference
        var channel = self.channels[i];

        // synth
        channel.msynth = synth;

        // channel container
        channel.container = CompositeView(self.win, Rect(
            i*(self.buttonWidth+self.paddingBetween)+self.paddingFromEdge,
            self.paddingFromEdge,
            self.buttonWidth,
            self.buttonHeight));

        // button
        channel.button = Button(channel.container, Rect(0, 0, self.buttonWidth, self.buttonHeight))
        .states_([["OFF", Color.black, Color.grey], ["ON", Color.black, Color.red]])
        .action_({|butt|
            if (butt.value == 1, {
                // launch synth
                channel.patchSynth = Synth(\StereoPair, [
                    inBusA: ~model.mixedOutBusses[2*i],
                    inBusB: ~model.mixedOutBusses[2*i+1],
                    outBus: 0
                ]);
            }, {
                // free synth
                channel.patchSynth.free;
            });
        });

    });

    // keyboard action
    self.win.view.keyDownAction_({|view, char, mod, unicode, keycode, key|

        var index = char.asString.asInt - 1;

        if ([0,1,2,3].includes(index), {

            if (self.channels[index].button.value != 1, {

                self.channels[index].button.valueAction_(1);

            });
        });
    });

    // keyboard action
    self.win.view.keyUpAction_({|view, char, mod, unicode, keycode, key|

        var index = char.asString.asInt - 1;

        if ([0,1,2,3].includes(index), {

            if (self.channels[index].button.value != 0, {

                self.channels[index].button.valueAction_(0);

            });
        });
    });

    // return self
    self

});

/* ~big knob -------------------------------------------------------------------

how do init for all 8? what updaer? => this needs it's own spot in the model...
shape and offset / level for vatrol
vatrol shape plot
lettering "VACTROL"
asymmetry

*/

(
~bigknob = {|model|

    var self = ();

    // formatting
    self.bigKnobSize = 300;
    self.smallKnobSize = 60;

    // spec
    self.spec = ControlSpec(1, 24*60*60, \exp);

    // log scale
    self.ticks = ((1..10) * 1) ++ ((1..10) * 60) ++ ((1..10) * 60*60);
    // self.ticks = ((1..9) * 1) ++ ((1..9) * 10) ++ ((1..9) * 100) ++ ((1..9) * 1000) ++ ((1..9) * 10000)
    // self.ticks = (1..9)/10 * 60) ++ ((1..9)/10 * 60*60) ++ ((1..10)/10 * 60*60*24)
    // self.ticks = ((1..10) * 1) ++ [20,30,40,50] ++ ((1..10) * 60) ++ [600*2, 600*3, 600*4, 600*5] ++ ((1..10) * 60*60)

    // window
    self.win = Window.new('bigknob', Rect(100, 500, 600, 400))
    .front.alwaysOnTop_(true)
    .background_(Color.black)
    .drawFunc_({Pen.strokeColor_(Color.white).width_(2).strokeRect(self.win.bounds.moveTo(0,0).insetBy(2,2))});

    // helpers
    self.stringFormat = {|val|

        if (val < 60) {
            val.asStringPrec(3) ++ " sec";
        } { if (val < (60*60)) {
            (val/60).asStringPrec(3) ++ " min";
        } {
            (val / (60*60)).asStringPrec(3) ++ " hour"
        }}};

    // helpers
    self.stringFormatColor = {|val|

        if (val < 60) {
            Color.magenta;
        } { if (val < (60*60)) {
            Color.cyan;
        } {
            Color.yellow;
        }}};

    // big knob view
    self.bigKnobView = UserView(self.win, Rect(self.bigKnobSize/2, 90, self.bigKnobSize, self.bigKnobSize))
    .background_(Color.clear);

    // big knob
    self.bigKnob = Knob(self.bigKnobView, Rect(self.bigKnobView.bounds.width*0.10, self.bigKnobView.bounds.height*0.10, self.bigKnobView.bounds.width*0.80, self.bigKnobView.bounds.width*0.80));
    self.bigKnob.color_(self.bigKnob.color.put(1, Color.white));
    self.bigKnob.color_(self.bigKnob.color.put(2, Color.clear));

    // big knob text
    self.bigKnobText = StaticText(self.bigKnobView, Rect(self.bigKnobView.bounds.width/2-35, self.bigKnobView.bounds.height-40, 70, 20))
    .string_("1.00").stringColor_(Color.magenta).align_(\center);

    // big knob action
    self.bigKnob.action_({|knob|

        // set all synths
        model.synths.do({|synth|

            if (synth.notNil) {
                model.setSynth(synth, \vactrolHysteresisA, self.spec.map(knob.value));
                model.setSynth(synth, \vactrolHysteresisB, self.spec.map(knob.value));
            }

        });

        // text
        self.bigKnobText.string_(self['stringFormat'].value(self.spec.map(knob.value)));
        self.bigKnobText.stringColor_(self['stringFormatColor'].value(self.spec.map(knob.value)));

    });

    // draw
    self.bigKnobView.drawFunc_({|view|

        // draw regions
        self.spec.unmap([1, 60, 60*60, 60*60*24]).doAdjacentPairs({|val1, val2, color|

            var theta1, theta2, theta3, theta4;

            theta1 = val1.linlin(0, 1, 0.65pi, 2.35pi);
            theta2 = val2.linlin(0, 1, 0.65pi, 2.35pi);
            theta3 = val1.linlin(0, 1, -0.35pi, 1.35pi);
            theta4 = val2.linlin(0, 1, -0.35pi, 1.35pi);

            Pen.addAnnularWedge(view.bounds.moveToPoint(0@0).center,
                // 0.65*view.bounds.width/2,
                // 0.9*view.bounds.width/2,
                // 0.72*view.bounds.width/2,
                // 0.9*view.bounds.width/2,
                0.85*view.bounds.width/2,
                0.9*view.bounds.width/2,
                // 0.72*view.bounds.width/2,
                // 0.8*view.bounds.width/2,
                theta1,
                theta2-theta1);

            // Pen.rotate((theta3+((theta4-theta3)/2)), v.bounds.moveToPoint(0@0).center.x, v.bounds.moveToPoint(0@0).center.y);
            // Pen.stringAtPoint("seconds", (0.0@1)*v.bounds.moveToPoint(0@7.neg).center, Font( "Helvetica", 14), Color.white);
            // Pen.rotate((theta3+((theta4-theta3)/2)).neg, v.bounds.moveToPoint(0@0).center.x, v.bounds.moveToPoint(0@0).center.y);

            Pen.fillColor_([Color.magenta, Color.cyan, Color.yellow][color].alpha_(0.5)).fill();

        });

        // draw ticks
        self.ticks.do({|val|

            var theta = self.spec.unmap(val).linlin(0, 1, -0.32pi, 1.35pi);

            Pen.rotate(theta, view.bounds.moveToPoint(0@0).center.x, view.bounds.moveToPoint(0@0).center.y);
            Pen.moveTo((0.35@1)*view.bounds.moveToPoint(0@0).center);
            Pen.lineTo((0.17@1)*view.bounds.moveToPoint(0@0).center);
            Pen.color_(Color.white).smoothing_(true).width_(2).stroke();
            // Pen.stringAtPoint(val.asString, (0.0@1)*view.bounds.moveToPoint(0@7.neg).center, Font( "Helvetica", 14), Color.white);
            Pen.rotate(-1*theta, view.bounds.moveToPoint(0@0).center.x, view.bounds.moveToPoint(0@0).center.y);

        });

    });

    // other knobs
    self.smallKnobPaddingFromTop = 30;
    self.smallKnobPadding = 50;

    self.attackKnob = Knob(self.win, Rect(self.smallKnobPadding, self.smallKnobPaddingFromTop, self.smallKnobSize, self.smallKnobSize));
    self.attackKnob.color_(self.attackKnob.color.put(1, Color.grey));

    self.decayKnob = Knob(self.win, Rect(self.win.bounds.width-self.smallKnobPadding-self.smallKnobSize, self.smallKnobPaddingFromTop, self.smallKnobSize, self.smallKnobSize));
    self.decayKnob.color_(self.decayKnob.color.put(1, Color.grey));

    self.depthKnob = Knob(self.win, Rect(self.smallKnobPadding, self.smallKnobPadding+self.smallKnobPaddingFromTop+self.smallKnobSize, self.smallKnobSize, self.smallKnobSize));
    self.depthKnob.color_(self.depthKnob.color.put(1, Color.grey));

    self.offsetKnob = Knob(self.win, Rect(self.win.bounds.width-self.smallKnobPadding-self.smallKnobSize, self.smallKnobPadding+self.smallKnobPaddingFromTop+self.smallKnobSize, self.smallKnobSize, self.smallKnobSize));
    self.offsetKnob.color_(self.offsetKnob.color.put(1, Color.grey));

    // return self
    self

});

/* ~photodesigner --------------------------------------------------------------

 vactrol photresistor innards

 model
 * do inits from model not hardwired (have to store in master)
 * along those lines, spec for vactrolAttack (not A or B) or will that break simple GUI?

 feature
 * add voltage divider?
 * instead of normalize y plot on log scale?

 drawing improvments
 * freq knob draw while
 * draw smooth curve instead of a line

 sc question
 * [..-1] syntax to remove last element?

*/

(
~photodesigner = {|model|

    var self = ();

    // formatting
    self.plotColor = Color.magenta;

    // params
    self.maxMu = 666;
    self.maxCycle = 13;
    self.mu = 200;
    self.attack = 0.03;
    self.decay = 1;
    self.cycle = 12;

    // plots
    self.plot1 = ();
    self.plot2 = ();

    // buffer
    self.dataBuff = Buffer.alloc(s, self.maxMu * self.maxCycle, 1);

    // synthdef
    SynthDef(\makeData, {|mu, attack = 0.1, decay = 1|
        var sig = LFPulse.ar(44100.0/mu);
        RecordBuf.ar(Vactrol.ar(sig, attack: attack, decay: decay, depth: 1), self.dataBuff, doneAction: 2, loop: 0);
    }).add;

    // window
    self.win = Window.new('~photodesigner', Rect(900, 300, 345, 290))
    .front.alwaysOnTop_(true)
    .background_(Color.black)
    .drawFunc_({

        // border
        Pen.strokeColor_(Color.white).width_(2).strokeRect(self.win.bounds.moveTo(0,0).insetBy(2,2));

        // vertical line between knobs and plots
        Pen.moveTo(77@10); Pen.lineTo(77@280); Pen.strokeColor_(Color.grey).width_(1).smoothing_(false).stroke();

    });

    // plots
    self.plot1.view = UserView(self.win, Rect(100,15,250,120)).background_(Color.clear);
    self.plot1.data = [];
    self.plot2.view = UserView(self.win, Rect(100,155,250,120)).background_(Color.clear);
    self.plot2.data = [];

    // update plot data and refresh
    self.updateData = {fork { var cycle, mu;

        cycle = self.cycle;
        mu = self.mu;

        // make data
        Synth(\makeData, [\mu, self.mu, \attack, self.attack, \decay, self.decay]).waitForFree;

        // get data for plot2
        self.dataBuff.getn((cycle - 1.5 * mu).floor, self.mu, {|data|
            self.plot1.data = data;
            {self.plot1.view.refresh()}.defer;
        });

        // get data for plot2
        self.dataBuff.getn(0, self.maxMu * self.maxCycle / 2, {|data|
            // self.dataBuff.getn(0, self.mu * self.cycle / 2, {|data|
            self.plot2.data = data;
            {self.plot2.view.refresh()}.defer;
        });
    }};

    // knob formatting (could clean this up a bit...)
    self.knobSize = 50;
    self.numBoxWidth = 50;
    self.numBoxHeight = 16;
    self.paddingBetweenLabelAndKnob = 4;
    self.paddingBetweenKnobAndText = 0;
    self.paddingBetweenTextAndKnob = 6;
    self.paddingFromEdge = 20;
    self.paddingFromTop = 10;
    self.center = 40;

    // attack label
    self.attackLabel = StaticText(self.win, Rect(self.numBoxWidth.neg/2+self.center,self.paddingFromTop,self.numBoxWidth,self.numBoxHeight))
    .string_('Attack')
    .font_(Font.default.size_(12))
    .stringColor_(Color.black)
    .align_(\center)
    .background_(Color.grey(0.3));

    // attack knob
    self.attackKnob = Knob(self.win, Rect(self.knobSize.neg/2+self.center,self.attackLabel.bounds.bottom+self.paddingBetweenLabelAndKnob,self.knobSize,self.knobSize));
    self.attackKnob.color_(self.attackKnob.color.put(1, Color.white).put(2, Color.black)).value_(\vactrolAttackA.asSpec.unmap(self.attack))
    .action_({|knob| model.setSynthMaster(\vactrolAttack, \vactrolAttackA.asSpec.map(knob.value), knob)});

/*    // attack text
    self.attackText = NumberBox(self.win, Rect(self.numBoxWidth.neg/2+self.center,self.attackKnob.bounds.bottom+self.paddingBetweenKnobAndText,self.numBoxWidth,self.numBoxHeight))
    .value_(self.attack)
    .decimals_(3)
    .font_(Font.default.size_(11))
    .normalColor_(Color.white)
    .align_(\center)
    .background_(Color.clear);*/

    // attack text
    self.attackText = StaticText(self.win, Rect(self.numBoxWidth.neg/2+self.center,self.attackKnob.bounds.bottom+self.paddingBetweenKnobAndText,self.numBoxWidth,self.numBoxHeight))
    .string_('0.003 sec')
    // .decimals_(3)
    .font_(Font.default.size_(10))
    .stringColor_(Color.white)
    .align_(\right)
    .background_(Color.clear);

     // decay label
    self.decayLabel = StaticText(self.win, Rect(self.numBoxWidth.neg/2+self.center,self.attackText.bounds.bottom+self.paddingBetweenTextAndKnob,self.numBoxWidth,self.numBoxHeight))
    .string_('Decay')
    .font_(Font.default.size_(12))
    .stringColor_(Color.black)
    .align_(\center)
    .background_(Color.grey(0.3));

    // decay knob
    self.decayKnob = Knob(self.win, Rect(self.knobSize.neg/2+self.center,self.decayLabel.bounds.bottom+self.paddingBetweenLabelAndKnob,self.knobSize,self.knobSize));
    self.decayKnob.color_(self.decayKnob.color.put(1, Color.white).put(2, Color.black)).value_(\vactrolDecayA.asSpec.unmap(self.decay))
    .action_({|knob| model.setSynthMaster(\vactrolDecay, \vactrolDecayA.asSpec.map(knob.value), knob)});

/*    // decay text
    self.decayText = NumberBox(self.win, Rect(self.numBoxWidth.neg/2+self.center,self.decayKnob.bounds.bottom+self.paddingBetweenKnobAndText,self.numBoxWidth,self.numBoxHeight))
    .value_(self.decay)
    .decimals_(3)
    .font_(Font.default.size_(11))
    .normalColor_(Color.white)
    .align_(\center)
    .background_(Color.clear);*/

    // decay text
    self.decayText = StaticText(self.win, Rect(self.numBoxWidth.neg/2+self.center,self.decayKnob.bounds.bottom+self.paddingBetweenKnobAndText,self.numBoxWidth,self.numBoxHeight))
    .string_('1.542 sec')
    // .decimals_(3)
    .font_(Font.default.size_(10))
    .stringColor_(Color.white)
    .align_(\right)
    .background_(Color.clear);

     // freq label
    self.freqLabel = StaticText(self.win, Rect(self.numBoxWidth.neg/2+self.center,self.decayText.bounds.bottom+self.paddingBetweenTextAndKnob,self.numBoxWidth,self.numBoxHeight))
    .string_('Freq')
    .font_(Font.default.size_(12))
    .stringColor_(Color.black)
    .align_(\center)
    .background_(Color.grey(0.3));

    // freq knob
    self.freqKnob = Knob(self.win, Rect(self.knobSize.neg/2+self.center,self.freqLabel.bounds.bottom+self.paddingBetweenLabelAndKnob,self.knobSize,self.knobSize));
    self.freqKnob.color_(self.freqKnob.color.put(1, Color.white).put(2, Color.black)).value_(0.5)
    .action_({|knob|
        self.mu = (1 - knob.value * self.maxMu).asInteger.max(8);
        // self['updateData'].value(); // continuously update while turning knob
        if (self.updateDataRoutine.isNil.not) {self.updateDataRoutine.stop}; // stops update while turning knob
        self.updateDataRoutine = self['updateData'].value();
        self.freqText.string_((44100.0/self.mu).asStringPrec(4) ++ ' Hz')
    });

/*    // freq text
    self.freqText = NumberBox(self.win, Rect(self.numBoxWidth.neg/2+self.center,self.freqKnob.bounds.bottom+self.paddingBetweenKnobAndText,self.numBoxWidth,self.numBoxHeight))
    .value_(0.5)
    .decimals_(3)
    .font_(Font.default.size_(11))
    .normalColor_(Color.white)
    .align_(\center)
    .background_(Color.clear);*/

    // freq text
    self.freqText = StaticText(self.win, Rect(self.numBoxWidth.neg/2+self.center,self.freqKnob.bounds.bottom+self.paddingBetweenKnobAndText,self.numBoxWidth,self.numBoxHeight))
    .string_('66.66 Hz')
    // .decimals_(3)
    .font_(Font.default.size_(10))
    .stringColor_(Color.white)
    .align_(\right)
    .background_(Color.clear);


    // draw plot1
    self.plot1.view.drawFunc_({|view|

        if (self.plot1.data != []) {

            var toXpix, toYpix, plotBounds;

            plotBounds = Rect(0, 10, view.bounds.width-50, view.bounds.height-20);
            toXpix = {|x| x * plotBounds.width};
            toYpix = {|y| 1 - y * plotBounds.insetBy(1,1).height + 10};

            // plot vactrol curve
            (self.plot1.data - self.plot1.data.minItem).normalize().do({|val, i|

                if (i == 0)
                {
                    Pen.moveTo(toXpix.value(i/(self.plot1.data.size-1))@toYpix.value(val));
                } {
                    Pen.lineTo(toXpix.value(i/(self.plot1.data.size-1))@toYpix.value(val));
                };
            });

            // render
            Pen.strokeColor_(self.plotColor).width_(2).stroke();

            // plot square wave
            [[0,0],[1/2,0],[1/2,1],[1,1]].do({|vals, i|

                if (i == 0)
                {
                    Pen.moveTo(toXpix.value(vals[0])@toYpix.value(vals[1]));
                } {
                    Pen.lineTo(toXpix.value(vals[0])@toYpix.value(vals[1]));
                };
            });

            // render
            Pen.lineDash_(FloatArray.newFrom([3.0,3.0]));
            Pen.strokeColor_(Color.grey).width_(1).smoothing_(false).stroke();

            // bounds
            Pen.stringAtPoint(self.plot1.data.maxItem.asStringPrec(2), toXpix.value(1.05)@toYpix.value(1.065), Font("Arial", 11), self.plotColor);
            Pen.stringAtPoint(self.plot1.data.minItem.asStringPrec(2), toXpix.value(1.05)@toYpix.value(0.065), Font("Arial", 11), self.plotColor);
            Pen.stringAtPoint('kΩ', toXpix.value(1.05)@toYpix.value(0.565), Font("Arial", 11), Color.grey);
        };

    });

    // draw plot 2
    self.plot2.view.drawFunc_({|view|

        if (self.plot2.data != []) {

            var toXpix, toYpix, plotBounds, normed, avg;

            plotBounds = Rect(0, 10, view.bounds.width-50, view.bounds.height-20);
            toXpix = {|x| x * plotBounds.width};
            toYpix = {|y| 1 - y * plotBounds.insetBy(1,1).height + 10};

            // normed = (self.plot2.data - self.plot2.data.minItem).normalize(); // normalize to range
            normed = (self.plot2.data).normalize(); // normalize to 0
            avg = normed.clump(self.mu).collect({|clump| clump.sum / clump.size});
            avg = avg[..avg.size-2];

            // plot vactrol curve
            normed.do({|val, i|

                if (i == 0)
                {
                    Pen.moveTo(toXpix.value(i/(self.plot2.data.size-1))@toYpix.value(val));
                } {
                    Pen.lineTo(toXpix.value(i/(self.plot2.data.size-1))@toYpix.value(val));
                };
            });

            // render
            Pen.strokeColor_(self.plotColor).width_(1).stroke();

            //
            Pen.moveTo(toXpix.value(0.15)@toYpix.value(0));
            Pen.lineTo(toXpix.value(1)@toYpix.value(0));
            Pen.lineTo(toXpix.value(1)@toYpix.value(0.08));
            Pen.lineDash_(FloatArray.newFrom([3,3]));
            Pen.strokeColor_(Color.grey.alpha_(0.75)).width_(1).smoothing_(false).stroke();
            Pen.stringAtPoint(self.plot2.data.size.asString ++ ' samples', toXpix.value(0.68)@toYpix.value(0.12), Font("Arial", 10), Color.grey);

            // plot average curve
            Pen.moveTo(toXpix.value(0)@toYpix.value(0));
            avg.do({|val, i| Pen.lineTo(toXpix.value(i+0.5*self.mu/(self.plot2.data.size-1))@toYpix.value(val))});
            Pen.lineTo(toXpix.value(1)@toYpix.value(avg.last));
            // Pen.lineTo(toXpix.value(self.plot2.data.shape[0]-1)@toYpix.value(0));

            // render
            Pen.lineDash_(FloatArray.newFrom([2,2]));
            Pen.strokeColor_(Color.cyan.alpha_(0.75)).width_(1).smoothing_(false).stroke();

            // bounds
            Pen.stringAtPoint('0.0', toXpix.value(1.05)@toYpix.value(0.065), Font("Arial", 11), self.plotColor);
            Pen.stringAtPoint((avg.last.linlin(0,1,self.plot2.data.minItem, self.plot2.data.maxItem)).asStringPrec(2), toXpix.value(1.05)@toYpix.value(avg.last*1.1), Font("Arial", 11), Color.cyan.alpha_(0.75));
        };

    });

    // updater
    self.updater = { arg model, whatChanged ... args;

        // respond to setSynthMaster
        if (whatChanged == \setSynthMaster) {

            // unpack args
            var param, value, whoChangedIt;
            param = args[0]; value = args[1]; whoChangedIt = args[2];

            // update GUI: vactrolAttack
            if (param == \vactrolAttack) {

                // set knob
                if (whoChangedIt != self.attackKnob) {self.attackKnob.value_(\vactrolAttackA.asSpec.unmap(value))};

                // set text
                // if (whoChangedIt != self.attackText) {self.attackText.value_(value)};
                if (whoChangedIt != self.attackText) {self.attackText.string_(value.round(0.001).asString.padRight(2, ".").padRight(5, "0") ++ ' sec')};

                // set internal values
                self.attack = value;

                // update plots
                self['updateData'].value();

            // update GUI: vactrolDecay
            }{ if (param == \vactrolDecay) {

                // set knob
                if (whoChangedIt != self.decayKnob) {self.decayKnob.value_(\vactrolDecayA.asSpec.unmap(value))};

                // set text
                // if (whoChangedIt != self.decayText) {self.decayText.value_(value)};
                if (whoChangedIt != self.decayText) {self.decayText.string_(value.round(0.001).asString.padRight(2, ".").padRight(5, "0") ++ ' sec')};

                // set internal values
                self.decay = value;

                // update plots
                self['updateData'].value();

            }};
        };
    };

    // add updater function to model dependant list
    model.addDependant(self['updater']);

    // on close free buffer
    self.win.onClose_({model.removeDependant(self['updater']); self.dataBuff.close; self.dataBuff.free});

    // inits
    self['updateData'].value();

    // return self
    self

});