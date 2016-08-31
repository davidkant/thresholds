/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 Vactrol from David Dunn's "Thresholds and Fragile States" (2010)

 A vactrol, or optoisolator, converts voltage to resistance. It is used to allow
 signal feedback to modualate the variable resistance of the chaotic oscillator.

 Dunn's optoisolator is made of an LED RadioShack #276-0085 glued to a
 photoresistor. Incoming voltage signal drives the LED and the photoresistor
 responds by changing resistance.

 features

   * half-wave rectify (diode)
   * voltage to resistance response measured from actual optoisolator
   * asymmetric attack / release lag times
   * hysteresis
   - freq dependent lag [NOT YET IMPLEMENTED]

 * voltage-to-resistance curve is measured from physical components

 Photoresistors exhibit a poperty of hysteresis, which means that the resistance
 of the photoresistor is determined not only by its current state but by past
 states as well. For instance, a photoresistor will have a greater resistance
 when coming from a light environment than when coming from a dark environment
 in response to the same illumination.

 Hysteresis is implemented by scaling the current internal state by a hysteresis
 state. The hysteresis state is determined using a long lag to track and smooth
 the internal state of the photoresistor. The hysteresis state is converted to a
 bipolar range [-1,1] and scaled by an exponential function. This value is used
 to scale the current photoresistor state.

 from "Thresholds" library  -dkant, 2016


 NOTE
 - attack / decay in seconds
 - signal is essentially inverted b/c hi voltage -> hi illum -> low resistance

 TODO
 -> ambientLight should be normalized as percent of light range
 -> removed madd for now b/c should it apply to everything? not sure.
 -> TUNING: measure hysteresis depth
 -> FEATURE: implement frequency dependent lag
 -> TUNING: measure the lag
 -> TUNING: measure some other vactrol responses
 ** would be nice to scope the intermediate signals
 ** still want to maintain photoR bounds
 ** still want to maintain ledV bounds
 -> make envelope editable, a gui would be great

*/

Vactrol {

    *ar { |in = 0, attack = 0.030, decay = 2.0, hysteresis = 10, depth = 2,
        ambientLight = 110.0, mul = 1, add = 0|

        var out;

        // [1] voltage to resistance
        out = this.v2r(in, ambientLight);

        // [2] lag
        out = this.lag(out, attack, decay);

        // [3] hysteresis
        out = this.hysteresis(out, time: hysteresis, base: depth);

        // [4] out
        ^out;
	}


    *monitor { |in = 0, attack = 0.030, decay = 2.0, hysteresis = 10, depth = 2,
        ambientLight = 110.0, mul = 1, add = 0|

        var out, hyst;

        // [1] voltage to resistance
        out = this.v2r(in, ambientLight);

        // [2] lag
        out = this.lag(out, attack, decay);

        // [3] hysteresis
        hyst = this.hysteresisMonitor(out, time: hysteresis, base: depth);

        // [4] out: pre-hysteresis, post-hysteresis, internal state
        ^[out, hyst[0], hyst[1]]
	}


    *ledMonitor { |in = 0, attack = 0.030, decay = 2.0, hysteresis = 10, depth = 2,
        ambientLight = 110.0, mul = 1, add = 0|

        var out, led, hyst;

        // [1] voltage to resistance
        led = this.v2r(in, ambientLight);

        // [2] lag
        hyst = this.lag(led, attack, decay);

        // [3] hysteresis
        hyst = this.hysteresisMonitor(hyst, time: hysteresis, base: depth);

        // [4] out: post-hysteresis, internal state, led
        ^[hyst[0], hyst[1], LinLin.ar(led/109, 0,1,1,0)];
        // ^[hyst[0], hyst[1], in];
	}


    *v2r { |in = 0, ambientLight = 50.0|

         var out, pairs, curves;

        // pairs [voltage, resistance] response
        /* pairs = [[0.0, 109.0], [1.0, 109.0], [1.9, 96.2], [2.0, 88.2],
            [3.0, 18.75], [4.0, 9.40], [5.0, 5.99], [6.0, 4.43], [7.0, 3.53],
            [8.0, 2.94], [9.0, 2.56]];*/

        // vactrol #1
        pairs = [[0.0, 110.0], [1.0, 110.0], [1.9, 91.0], [2.0, 64.0],
            [3.0, 8.24], [4.0, 4.00], [5.0, 2.79], [6.0, 2.18], [7.0, 1.83],
            [8.0, 1.59], [9.0, 1.42], [10.0, 1.29], [11.0, 1.20], [12.0, 1.12],
            [13.0, 1.05], [14.0, 0.99], [15.0, 0.94]];

        // interpolation curves
        curves = [1 ,1, 1, -2, -1, -1, -1, -1, -1, -1, -1];

        // half-wave rectify
        out = Clip.ar(in, lo: 0, hi: 1);

        // scale input to 9v and impose response curve and clip to ambient light
        ^Clip.ar(IEnvGen.ar(Env.pairs(pairs, curves), out * 9.0), 0, ambientLight)
    }


    *lag { |resistance, attack, decay|

        // asymmetric lag (time in seconds)
        ^LagUD.ar(resistance, decay, attack);
    }


    *hysteresis { |in = 0, time = 1, base = 2|

        var hysteresis, hysteresis_coef, exp_x;

        // lag hysteresis
        hysteresis = LagUD.ar(in, time, time);

        // scale hysteresis value and invert to [-1,1]
        exp_x = LinLin.ar(hysteresis, 2.56, 109.0, 1, -1);

        // scale by exp function, base B
        hysteresis_coef = base.pow(exp_x);

        // apply to resistanc
        ^in * hysteresis_coef
    }

    *hysteresisMonitor { |in = 0, time = 1, base = 2|

        var hysteresis, hysteresis_coef, exp_x;

        // lag hysteresis
        hysteresis = LagUD.ar(in, time, time);

        // scale hysteresis value and invert to [-1,1]
        exp_x = LinLin.ar(hysteresis, 2.56, 109.0, 1, -1);

        // scale by exp function, base B
        hysteresis_coef = base.pow(exp_x);

        // apply to resistance (return exp_x for monitor)
        ^[in * hysteresis_coef, exp_x]
    }
}