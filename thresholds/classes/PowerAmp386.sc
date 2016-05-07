/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 LM386 Power Amplifier from David Dunn's "Thresholds and Fragile States" (2010)

 features:

   * voltage divider
   * gain
   * amp saturation
   * DC leak

 from "Thresholds" library  -dkant, 2016


 NOTE:
 - val is downsampled to control rate

 TUNING:
 - set potRMin to match the analog circuit
 - gain is theoretical calculated from circuit topology
 - saturation is actual measured
 - dcblock is a guess

 TOOD
 ?? gain is linear w/ amplitude not db scale?
 -> audio taper pot use log / exp curve
 -> confirm measure the saturation
 -> measure dcblock
 ?? is saturation absolute or relative to supply?
 -> potRmin/max is redundant...
 -> add schematic image to help page

*/

PowerAmp386 {

    *ar { |in, val = 0.5, gain = 20, potRmin = 0, potRmax = 10e3,
        saturation = 0.44444444444444, dcblock = 0.995, mul = 1, add = 0|

        var r1, r2, vdivider, out;

        // r1 and r2 from pot value [0,1]
        r1 = LinLin.kr(1-val, 0, 1, potRmin, potRmax);
        r2 = LinLin.kr(val, 0, 1, potRmin, potRmax);

        // voltage divider attenuation
        vdivider = r2 / (r1 + r2);

        // apply voltage divider and gain
        out = in * vdivider * gain;

        // saturation
        out = Clip.ar(out, -1*saturation, saturation);

        // DC leak
        out = LeakDC.ar(out, coef: dcblock);

        // out
        ^out
    }
}