/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 LM741 Pre-Amplifier from David Dunn's "Thresholds and Fragile States" (2010)

 Dunn's circuit topology is a basic inverting amplifier with component values
 rin = 1k and rf = 100k variable potentiometer. Gain is calculated according
 to the formula:

   :: gain = rf / rin

 features:

   * gain
   * saturation
   * inverts signal

 The pre-amplifier is a point of signal coupling between oscillator pairs
 through a emphasis::resistance network::. The resistance network makes contact
 to the op-amp inverting input allowing pre-amplifiers to be coupled. In Dunn's
 network,  pre-amplifiers from separate oscillator pairs are coupled.

 This is implemented as teletype::rNetSigIn:: and teletype::rNetResIn::. It is
 necessary to know both the voltage and resistance of coupled signals in order
 to calculate the gain across pre-amplifiers.

 from "Thresholds" library  -dkant, 2016


 NOTE:
 - val is downsampled to control rate
 - pot is through nose so pot position affects rin as well as rf

 TUNING:
 - set potRMin to match the analog circuit

 TOOD
 -> is there any dc block?
 -> is this the rNet or is it a different coupling stage? (note above)
 -> uhhh you're not inverting david...
 -> i may have observed a small DC offset
 -> schematic is not clear: is the pot hooked up through the nose?
 -> add schematic image to help page

*/

PreAmp741 {

    *ar { |in, val = 0.5, rNetSigIn, rNetResIn, potRmin = 1, potRmax = 100e3,
        r2 = 1e3, saturation = 0.85, mul = 1, add = 0|

        var rf, rin, gain, rNetGain, out;

        // rf from pot value [0,1]
        rf = LinLin.kr(val, 0, 1, potRmin, potRmax);

        // rin from pot value [0,1] (1k + through pot nose)
        rin = r2 + LinLin.kr(1-val, 0, 1, potRmin, potRmax);

        // gain
        gain = rf / rin;

        // rNet (normalized pot position in assumes same pot strength)
        rNetGain = rf / r2 + LinLin.kr(1-rNetResIn, 0, 1, potRmin, potRmax);

        // apply gain and saturation
        out = Clip.ar((in * gain) + (rNetSigIn * rNetGain), -1*saturation, saturation);

        // out
        ^out
    }
}