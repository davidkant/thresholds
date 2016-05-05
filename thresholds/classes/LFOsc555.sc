/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 LM555 LFO from David Dunn's "Thresholds and Fragile States" (2010)

 Dunn's circuit topology is a basic astable 555 oscillator circuit with value
 r1 = 1k, r2 = 1M variable potentiometer, c = 10 uF or 0.22 uF (switch).

 This software implementation uses SC's LFPulse pulse oscillator to model.
 Freq is calculated from potentiometer value (r2) according to the formula:

   :: freq = 1.44 / ( (r1 + 2 * r2) * c )

   :: , with R in ohms and C in farads [1 uf = e-6 farad]

 from "Thresholds" library  -dkant, 2016

 NOTE:
 - val and switch are downsampled to control rate

 TUNING:
 - set potRMin to match the analog circuit

 TOOD
 -> LFOs are actually coupled...
 -> explain why this topology is identical to basic astable inverted
 ?? invert?
 ?? which c1/c2 is which switch position?
 ?? can we be more precise than 1.44?
 ?? dc leak?
 -> add schematic image to help page

*/

LFOsc555 {

    *ar { |val = 0.5, cswitch = 0, potRmin = 1, potRmax = 1e6,
        r1 = 1e3, c1 = 10.0e-6, c2 = 0.22e-6, mul = 1, add = 0|

        var r2, c, freq;

        // r2 from pot value [0,1]
        r2 = LinLin.kr(val, 0, 1, potRmin, potRmax);

        // c from cswitch position
        c = Select.kr(cswitch, [c1, c2]);

        // osc freq in Hertz
        freq = 1.44 / ( (r1 + (2 * r2) ) * c);

        // lfo
        ^LFPulse.ar(freq);
    }
}