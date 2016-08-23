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

*/

(
~octoScope = {|model|

    var myOctoscope = ();

    // settings
    myOctoscope.highlighterColors = [Color.magenta, Color.cyan, Color.yellow];

    // window
    myOctoscope.win = Window.new('Octoscope', Rect(100,500,1225,210)).front.alwaysOnTop_(true);

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
        channel.scope.scopeView.waveColors_([Color.cyan]);
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

    // add octoscope updater function to model dependant list
    model.addDependant(self['updater']);

    // remove updater function on window close
    self.win.onClose_({model.removeDependant(self['updater'])});

    // return self
    self

});