/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 Thresholds and Fragile States as usually performed recently ...

   eight oscillators:

     (1 <=> 2)  (5 <=> 6)
      |     |    |     |
      |     |    |     |
     (3 <=> 4)  (7 <=> 8)  and 1 <--> 8

*/

// play ------------------------------------------------------------------------

~dir = "/Users/davidkant/Projects/Thresholds and Fragile States/git/thresholds/the piece/";

(~dir ++ "01_Startup.scd").load;             // Server Options and Startup
(~dir ++ "02_SynthDefs.scd").load;           // SynthDefs
(~dir ++ "03_Networking.scd").load;          // Networking Busses setup
(~dir ++ "04_Synths.scd").load;              // Launch the Synths
(~dir ++ "05_Model.scd").load;               // MVC Model Setup
(~dir ++ "05_Settings.scd").load;            // Apply Settings
(~dir ++ "99_Random.scd").load;              // Random State
(~dir ++ "06_GUI.scd").load;                 // Load GUIs
(~dir ++ "08_Presets.scd").load;             // Load Presetsl
(~dir ++ "09_PostProcessing-8x2.scd").load;  // KOSC -> DAC via RingMods
// (~dir ++ "07_MidiControl.scd").load;         // Some Midi Control
// (~dir ++ "10_Analytics-Master.scd").load;    // What is going on
// (~dir ++ "99_Ringers.scd").load;             // Ring Moddders
// (~dir ++ "99_Walkers.scd").load;             // White Walkers --- oh my!

// guis ------------------------------------------------------------------------

~launch = ~launchpad.value(~model);

~quick1 = ~quickGUI.value(~a1b1,z,"A1B1");
~quick2 = ~quickGUI.value(~c1d1,z,"C1D1");
~quick3 = ~quickGUI.value(~a2b2,z,"A2B2");
~quick4 = ~quickGUI.value(~c2d2,z,"C2D2");

~pairi = ~pairiScope.value(~model);
~octo = ~octoScope.value(~model);
~lp = ~lowPassScope.value(~model);
~atr = ~attractors.value(~model, style:2);
~lfo = ~lfoScope.value(~model);
~hyst = ~hysteresisMonitor.value(~model);
~pd = ~photoDesigner.value(~model);
~bk = ~bigKnob.value(~model);
~hyp = ~hyperspace.value(~model, oscs: \a1b1, scale: 10)
~pb = ~patchbay.value(~model);
~pre = ~presets.value(~model);

// free ------------------------------------------------------------------------

~a1b1.free
~c1d1.free
~a2b2.free
~c2d2.free

~a1b1.run(true)
~c1d1.run(true)
~a2b2.run(true)
~c2d2.run(true)

~a1b1.run(false)
~c1d1.run(false)
~a2b2.run(false)
~c2d2.run(false)

s.scope
s.meter