/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 A suite of GUIs for dealin with this unruly beast.

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
~octoscope = {|model|

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
        channel.scope.view.bounds_(Rect(0, -28, channel.container.bounds.width+19, 90+47));
        channel.scope.scopeView.waveColors_([Color.cyan]);
        channel.scope.scopeView.fill_(true);

        // kosc r slider
        channel.rSlider = Knob(channel.container, Rect(0, 95, 45, 45));
        channel.rSlider.color_(channel.rSlider.color.put(1, Color.grey));
        channel.rSlider.action_({|slider| if (channel.msynth.notNil) {model.setSynth(channel.msynth, (\koscR ++ channel.aorb).asSymbol, (\koscR ++ channel.aorb).asSymbol.asSpec.map(slider.value))}});

        // kosc r numbox
        channel.rNumber = NumberBox(channel.container, Rect(55, 95+12, 50, 20)).value_(1.0);
        channel.rNumber.decimals_(3);
        channel.rNumber.font_(Font.default.size_(12));
        channel.rNumber.font_(Font.default.size_(12));
        channel.rNumber.align_(\right);
        channel.rNumber.background_(Color.clear);
        channel.rNumber.action_({|number| if (channel.msynth.notNil) {model.setSynth(channel.msynth, (\koscR ++ channel.aorb).asSymbol, number.value)}});

        // preamp slider
        channel.preAmpSlider = Knob(channel.container, Rect(0, 95+50, 45, 45));
        channel.preAmpSlider.color_(channel.preAmpSlider.color.put(1, Color.grey));
        channel.preAmpSlider.action_({|slider| if (channel.msynth.notNil) {model.setSynth(channel.msynth, (\preAmpPot ++ channel.aorb).asSymbol, (\preAmpPot ++ channel.aorb).asSymbol.asSpec.map(slider.value))}});

        // preamp numbox
        channel.preAmpNumber = NumberBox(channel.container, Rect(55, 95+50+12, 50, 20)).value_(1.0);
        channel.preAmpNumber.decimals_(3);
        channel.preAmpNumber.font_(Font.default.size_(12));
        channel.preAmpNumber.align_(\right);
        channel.preAmpNumber.background_(Color.clear);
        channel.preAmpNumber.action_({|number| if (channel.msynth.notNil) {model.setSynth(channel.msynth, (\preAmpPot ++ channel.aorb).asSymbol, number.value)}});

        // highlighters
        channel.highlighters = 3.collect({ |j|
            View.new(channel.container, Rect(channel.container.bounds.width-(j+1*6)-1, 2, 5, 5))
                .background_(myOctoscope.highlighterColors[j]
                .alpha_(0.5 * ~model.flags[j][i]))
        });

        // init koscR
        if (channel.msynth.notNil) {
            channel.msynth.get((\koscR ++ channel.aorb).asSymbol, { |val| {
                channel.rSlider.value_((\koscR ++ channel.aorb).asSymbol.asSpec.unmap(val));
                channel.rNumber.value_(val);
            }.defer });
        };

        // init preAmp
        if (channel.msynth.notNil) {
            channel.msynth.get((\preAmpPot ++ channel.aorb).asSymbol, { |val| {
                channel.preAmpSlider.value_((\preAmpPot ++ channel.aorb).asSymbol.asSpec.unmap(val));
                channel.preAmpNumber.value_(val)
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