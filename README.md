# thresholds

#### a digital model of David Dunn's _Thresholds and Fragile States_ (2010)

---

`thresholds` is a digital model of composer David Dunn's 2010 piece _Thresholds and Fragile States_, an analog feedback network of coupled chaotic oscillators.

### Included here:
* chaotic oscillator UGen w/ basic examples (see .schelp)
* sclang psedu-UGens for network nodes (amp, pre-amp, vactrol, filters, LFO, etc)
* harcoded 8-osc version of the piece as David usually configues it (initial draft)
* a bunch of GUIs

### Running the piece
  0. Open the file `/the piece/**_Thresholds-8x.scd`
  1. set `~dir` to local folder containing the piece files
  2. load each file, waiting for previous to complete before loading the next
  3. turn on oscillator pairs (`SynthDefs` are added using `.newPaused`)
  4. launch GUIs and open `~patchbay`. click one of the 4 pairs to hear anything.
  5. fire off a random state or turn some knobs to hear something

Note: you probably won't hear anything until you launch a random sate, because
the default parameter values produce silence.

### GUIs:
A collection of GUIs for interacting with and visualziang the results of the digital model in ways not possible through analog circuitry:

* ~vectorView: plots the state of each osc as a vector
* ~pairiScope: scopes signal flow through a coupled pair ~a1b1 by default
* ~octoScope: scopes each oscillator output, knobs for koscR and preAmpPot
* ~lowPassScope: set and scope low pass filters
* ~lfoScope: set LFO frqeuencies, red square indicates hi/low
* ~hysterMon: visualizes the hysteresis states of the vactrols
* ~photoDesigner: edit vactrol response curves, attack and decay times
* ~bigKnob: sets hysteresis time for all 8 oscs, from 1 sec to 24 hours
* ~timeWarp: scale hysteresis values, rather than set all to the same value
* ~attractors: phase space plots for all 8 oscs
* ~hypersapce: phase space plots for all 8 oscs and mixed pairs
* ~tone: set X, Y, Z output levels
* ~patchbay: patch coupled pairs through to main output
* ~presets: store and recall states, shift-clik to store, click to recall
  

### About the piece

Composer David Dunn’s 2010 piece _Thresholds and Fragile States_ is an analog feedback network of chaotic oscillators designed to generate an endless and constantly evolving variety of musical sound. Motivated by his experience listening to the patterns of insects on a swamp in the Atchafalaya Basin of Louisiana in addition to his study of cybernetics, Dunn’s piece is an attempt to mimic, through electronic circuitry, the kinds of self-organizing patterns he observes in living systems, drawing togther ideas from chaos theory and Varela and Maturana's theory of autopoiesis. 

Like many electronic works in the American experimental tradition, the music is difficult to analyze because compositional decisions are embedded within layers of circuit design and musical features are explained at the level of individual electrical components. My approach to understanding the piece has been to create a digital model, integrating tools from circuit analysis, digital modeling, and dynamical systems theory into music analysis. See references for more info.

### References
Dunn, David. “Thresholds and Fragile States.” Moebius 1 (2012), Web.

Kant, David. "Measuring Infinity: Digitizing David Dunn's Thresholds and Fragile States.” Paper Presentation at American Musicological Society Annual Meeting (2018).

Heying, Madions and David Kant. “The Emergent Magician: Metaphors of Mind in the Work of David Dunn.” Sound American 18: The David Dunn Issue (2018), Web.


