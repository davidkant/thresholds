/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 LM741 Low-Pass Filter from David Dunn's "Thresholds and Fragile States" (2010)

 Dunn's circuit topology is a Sallen-Key low-pass filter with component values
 r1 = 8k, r2 = 100k variable potentiometer, c1 = 0.1 uF, and c2 = 0.1 uF.

 This software implementation uses SC's LPF (second order Butterworth) to model.
 Center freq is calculated from potentiometer value according to the formula:

   :: freq = 1 / ( 2 * pi * sqrt(r1 * r2 * c1 * c2) )

   :: , with R in ohms and C in farads [1 uf = e-6 farad]

 from "Thresholds" library  -dkant, 2016


 NOTE:
 - val is downsampled to control rate

 TUNING:
 - set potRMin to match the analog circuit

 TOOD
 -> solder up and check where exactly the ends and half fit, BUT THIS LOOKS GOOD
 -> add schematic image to help page

*/

LowPass741 {

    *ar { |in, val = 0.5, potRmin = 2e3, potRmax = 100e3, r1 = 8e3,
        c1 = 0.1e-6, c2 = 0.1e-6, mul = 1, add = 0|

        var r2, freq;

        // r2 from pot value [0,1]
        r2 = LinLin.kr(val, 0, 1, potRmin, potRmax);

        // cutoff frequency in Hertz
        freq = 1 / ( 2 * pi * (r1 * r2 * c1 * c2).sqrt );

        // lowpass filter
        ^LPF.ar(in, freq, mul, add);
    }
}