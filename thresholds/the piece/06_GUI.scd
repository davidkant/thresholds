/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 A suite of GUIs for dealin with this unruly beast.

 * do i want all scopes to have same xZoom?
 * some consistent formatting like and padding border?
 * this synth index stuff ...

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
    self.win = Window.new('LowPass', Rect(100,500,425,138)).front.alwaysOnTop_(true);

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
        .align_(\right)
        .background_(Color.clear)
        .action_({|number| if (channel.msynth.notNil) {model.setSynth(channel.msynth, \lowPassPot, number.value)}});

        // lowPassPot freq display text
        channel.lowPassPotFreqText = StaticText(channel.container, Rect(channel.container.bounds.width - 64, 33, 58, 20))
        .string_(self['numToFreqString'].value(0))
        .font_(Font.default.size_(9))
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
    ).front.alwaysOnTop_(true);

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