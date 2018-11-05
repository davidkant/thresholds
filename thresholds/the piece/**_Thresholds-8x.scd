/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

  A digital model of david Dunn's _Thresholds and Fragile States_. dk, 2018.

*/

// 1. set directory to local folder.
~dir = "/Users/davidkant/Library/Application Support/SuperCollider/Extensions/ThresholdsV3/the piece/"

// 2. load each file one after another.
(~dir ++ "01_Startup.scd").load;             // Server Options and Startup
(~dir ++ "02_SynthDefs.scd").load;           // SynthDefs
(~dir ++ "03_Networking.scd").load;          // Networking Busses setup
(~dir ++ "04_Synths.scd").load;              // Launch the Synths
(~dir ++ "05_Model.scd").load;               // MVC Model Setup
(~dir ++ "06_GUI.scd").load;                 // Load GUIs
(~dir ++ "08_Presets.scd").load;             // Load Presets
(~dir ++ "09_PostProcessing-8x2.scd").load;  // Mixdown 8 oscs for stereo playback
(~dir ++ "99_Settings.scd").load;            // Apply Settings
(~dir ++ "99_Random.scd").load;              // Random states
(~dir ++ "10_Analytics-Master.scd").load;    // Analysis features for serach

// 3. turn on oscillator pairs. i often run 2 pairs b/c 4 pairs wrecks my CPU load.
~a1b1.run(true);
~c1d1.run(true);
~a2b2.run(false);
// ~c2d2.run(true);

// 4. launch GUIs. open ~patchbay and turn on one or more pairs to hear anything.
~launch = ~launchpad.value(~model);

// list of parameters to be randomized
(
~randorams = [
    \koscFreq,
    \lowPassPot,
    \koscRA, \koscRB,
    \preAmpPotA, \preAmpPotB,
    \powAmpPotA, \powAmpPotB,
    \lfoPotA, \lfoPotB,
    \lfoIPhaseA, \lfoIPhaseB,
    \vactrolAttackA, \vactrolAttackB,
    \vactrolDecayA, \vactrolDecayB,
    \vactrolHysteresisA, \vactrolHysteresisB,
    \vactrolDepthA, \vactrolDepthB
]
);

// 5. fire off a random state (uses the spec set in 02_SynthDefs.scd for ranges)
~randomize.value(~randorams, ~model.synths);
~randomizeUnison.value(~randorams, ~model.synths)

// adjust error if needed, lower error requires more CPU: 1 is low; 2 is medium; 4 is high
~model.setSynthMaster(\koscError, 4);