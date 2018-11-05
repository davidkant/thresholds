/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

A digital model of david Dunn's _Thresholds and Fragile States_ (2010).

Thresholds and Fragile States is a feedback network of eight chaotic oscillators
arranged hierarchically in coupled pairs of two oscs each. Pairs are represented
in SC by the \feedbackPair SynthDef and networked together thru audio busses.
See refences in README for more information about the piece. Running the piece:

  1. set ~dir to local folder containing the piece files
  2. load each file, waiting for previous to complete before loading the next
  3. turn on oscillator pairs (SynthDefs are added using .newPaused)
  4. launch GUIs and open ~patchbay. click one of the 4 pairs to hear anything.
  5. fire off a random state or turn some knobs to hear something

Note: you probably won't hear anything until you launch a random sate, because
the default parameters values produce silence.

GUIs:
  ~vectorView: plots the state of each osc as a vector
  ~pairiScope: scopes signal flow through a coupled pair ~a1b1 by default
  ~octoScope: scopes each oscillator output, knobs for koscR and preAmpPot
  ~lowPassScope: set and scope low pass filters
  ~lfoScope: set LFO frqeuencies, red square indicates hi/low
  ~hysterMon: visualizes the hysteresis states of the vactrols
  ~photoDesigner: edit vactrol response curves, attack and decay times
  ~bigKnob: sets hysteresis time for all 8 oscs, from 1 sec to 24 hours
  ~timeWarp: scale hysteresis values, rather than set all to the same value
  ~attractors: phase space plots for all 8 oscs
  ~hypersapce: phase space plots for all 8 oscs and mixed pairs
  ~tone: set X, Y, Z output levels
  ~patchbay: patch coupled pairs through to main output
  ~presets: store and recall states, shift-clik to store, click to recall

*/

// 1. set directory to local folder.
~dir = "/Users/davidkant/Projects/Thresholds and Fragile States/git/thresholds/the piece/"

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

// 3. turn on oscillator pairs. i often run only 2 pairs b/c 4 pairs wrecks my CPU load.
~a1b1.run(true);
~c1d1.run(true);
~a2b2.run(true);
~c2d2.run(true);

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

// adjust error if needed, lower error requires more CPU: 1 is low; 2 is medium; 4 and above is large
~model.setSynthMaster(\koscError, 4);