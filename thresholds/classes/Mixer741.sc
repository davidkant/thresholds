/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 LM741 Mixer from David Dunn's "Thresholds and Fragile States" (2010)

 Mixes an array of input signals. Input is an array of any length.

 features:

   * mix input signals
   * op-amp saturation
   * invert
   * DC leak (b/c capacitor at amp output)

 from "Thresholds" library  -dkant, 2016


 TUNING:
 - saturation is actual measured
 - dcblock is a guess

 TOOD
 -> confirm measure the saturation
 ?? is saturation absolute or relative to supply?
 -> add schematic image to help page

*/

Mixer741 {

    *ar { |in, saturation = 0.85, dcblock = 0.995, mul = 1, add = 0|

        var mix, out;

        // sum inputs
        mix = in.sum();

        // saturation
        out = Clip.ar(mix, -1*saturation, saturation);

        // invert
        out = out.neg;

        // DC leak from output capacitor
        out = LeakDC.ar(out, coef: dcblock)

        // out
        ^out
    }
}