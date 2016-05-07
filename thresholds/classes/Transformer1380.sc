/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 Audio Transformer from David Dunn's "Thresholds and Fragile States" (2010)

 Transformer is RadioShack Audio Output Tranformer #273-1380 with specs:

   * input: 1K
   * output: center-tapped to 8ohms
   * frequency response: 300 - 10k

 features:

   * step-up
   * frequency response: high-pass filter
   * frequency response: low-pass filter
   * blocks dc signal

 from "Thresholds" library  -dkant, 2016


 TUNING:
 - step-up is measured
 - high-pass and low-pass are from spec sheet
 - dcblock is a guess

 TOOD
 -> confirm center tap is the output used
 -> confirm step-up by measure and calc
 ?? does it invert ??
 ?? this one doesn't do the curve b-h ??
 ?? better model / other features to odel ??

*/

Transformer1380 {

    *ar { |in, stepUp = 10, minFreq = 300, maxFreq = 1e4, dcblock = 0.995,
        mul = 1, add = 0|

        var out;

        // step up
        out = in * stepUp;

        // frequency response: low-pass and high-pass
        out = HPF.ar(LPF.ar(out, maxFreq), minFreq);

        // DC leak
        out = LeakDC.ar(out, coef: dcblock);

        // out
        ^out;
    }
}