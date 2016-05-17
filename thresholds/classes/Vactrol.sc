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
   - hysteresis [NOT YET IMPLEMENTED]
   - freq dependent lag [NOT YET IMPLEMENTED]

 * voltage-to-resistance curve is measured from physical components

 from "Thresholds" library  -dkant, 2016


 NOTE
 - attack / decay in seconds
 - signal is essentially inverted b/c hi voltage -> hi illum -> low resistance

 TODO
 -> FEATURE implement hysteresis
 -> FEATURE: implement frequency dependent lag
 -> TUNING: measure the lag
 -> TUNING: measure some other vactrol responses
 ** would be nice to scope the intermediate signals
 ** still want to maintain photoR bounds
 ** still want to maintain ledV bounds
 -> explain hysteresis in comments
 -> make envelope editalbe, a gui would be great

*/

Vactrol {

    *ar { |in = 0, attack = 0.030, decay = 2.0, mul = 1, add = 0|

        var out;

        // [1] voltage to resistance
        out = this.v2r(in);

        // [2] lag
        out = this.lag(out, attack, decay);

        // [3] hysteresis
        out = this.hysteresis(out);

        // [4] out
        ^out.madd(mul: mul, add: add);
	}


    *v2r { |in = 0|

         var out, pairs, curves;

        // pairs [voltage, resistance] response
        pairs = [[0.0, 109.0], [1.0, 109.0], [1.9, 96.2], [2.0, 88.2],
            [3.0, 18.75], [4.0, 9.40], [5.0, 5.99], [6.0, 4.43], [7.0, 3.53],
            [8.0, 2.94], [9.0, 2.56]];

        // interpolation curves
        curves = [1 ,1, 1, -2, -1, -1, -1, -1, -1, -1, -1];

        // half-wave rectify
        out = Clip.ar(in, lo: 0, hi: 1);

        // scale input to 9v and impose response curve
        ^IEnvGen.ar(Env.pairs(pairs, curves), out * 9.0)
    }


    *lag { |resistance, attack, decay|

        // asymmetric lag (time in seconds)
        ^LagUD.ar(resistance, decay, attack);
    }


    *hysteresis { |in = 0, time = 1, base = 2|

        // just pass through for now...
        // ^in

        var hysteresis, hysteresis_coef, exp_x;

        // lag hysteresis
        hysteresis = LagUD.ar(in, time, time);

        // scale hysteresis value and invert to [-1,1]
        exp_x = LinLin.ar(hysteresis, 2.56, 109.0, 1, -1);

        // scale by exp function, base B
        hysteresis_coef = base.pow(exp_x);

        // apply to resistance (return hyst coef for monitor)
        ^[in * hysteresis_coef, hysteresis_coef]
    }
}