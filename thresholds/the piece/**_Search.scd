/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

  A digital model of david Dunn's _Thresholds and Fragile States_.

  This is a sketch of a search algorithm that looks for "auditory neotaxis"
  or novel sound behaviors by making small adjustments one knob at a time.

  Uses dynamic entropy to measure novelty. See Entropy params below.

  It's pretty not intelligent in the sense that it doesn't learn from the past.

  dk, 2018.

*/

// ---------------------------------------------

// difference
~dEngine = ~differenceEngine.value(~model);

// ---LAUNCHERS---------------------------------

// launch ~angleGrinder
~grinder = ~angleGrinder.value(~model);

// launch ~entropyEngine
~eEngine = ~entropyEngine.value(~model);

// ---PLOTTERS----------------------------------

// plot ~angleGrinder
~grinderPlot = ~angleGrinderPlot.value(~model);

// entropy plot
// ~ePlot = ~entropyPlot.value(~model);

// entropy sequencer
~eSeq = ~entropySequencer.value(~model);


// ---ENTROPY-----------------------------------

// adjust markov params (defaults are fine...)
~eEngine.channels[0].mark.numBins
~eEngine.channels[0].mark.setNumBins(10)
~eEngine.channels[0].mark.setInitValue(0.1)
~eEngine.channels[0].mark.setForgettingThresh(0.01)
~eEngine.channels[0].mark.setForgettingDur(10)
~eEngine.channels[0].mark.zero

// ---SEARCH------------------------------------

~obejectVal = 0;
~direction = -1;
~thresh = 2;

// launch search routine
~alpha = {loop{~noveltyKnobs.value(~model, ~a1b1, ~randorams, 4.70, 0).yield;}}.fork(AppClock);
~beta = {loop{~noveltyKnobs.value(~model, ~c1d1, ~randorams, 4.70, 0).yield;}}.fork(AppClock);
~alpha = {loop{~noveltyKnobs.value(~model, ~a1b1, [\lowPassPot], 4.70, 0).yield;}}.fork(AppClock);
~beta = {loop{~noveltyKnobs.value(~model, ~c1d1, [\lowPassPot], 4.70, 2).yield;}}.fork(AppClock);

// stop routine
~alpha.stop
~beta.stop

// ---STOP--------------------------------------

// stop ~grinder
~grinder.onClose()
// stop ~entropy
~eEngine.onClose()