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
(~dir ++ "06_GUI.scd").load;                 // Load GUIs
(~dir ++ "07_MidiControl.scd").load;         // Some Midi Control
(~dir ++ "09_PostProcessing-8x2.scd").load;  // KOSC -> DAC via RingMods
(~dir ++ "99_Ringers.scd").load;             // White Walkers --- oh my!
(~dir ++ "99_Walkers.scd").load;             // White Walkers --- oh my!

// guis ------------------------------------------------------------------------

~quick1 = ~quickGUI.value(~a1b1,z,"A1B1");
~quick2 = ~quickGUI.value(~c1d1,z,"C1D1");
~quick3 = ~quickGUI.value(~a2b2,z,"A2B2");
~quick4 = ~quickGUI.value(~c2d2,z,"C2D2");

~pairo = ~pairiScope.value(~model);
~octo = ~octoScope.value(~model);
~lp = ~lowPassScope.value(~model);
~atr2 = ~attractors.value(~model, style:2);
~lf = ~lfoscope.value(~model);
~vtrol = ~vactrolscope.value(~model);
~bg = ~bigknob.value(~model);
~pb = ~patchbay.value(~model);
~pd = ~photodesigner.value(~model)

// free ------------------------------------------------------------------------

~a1b1.free
~c1d1.free
~a2b2.free
~c2d2.free