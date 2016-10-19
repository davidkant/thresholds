/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 Store and recall presets.

 -> turn this into an object so can preset.store / preset.load / preset.write
 -> needs time to get from server

 * this can now all be accessed via the ~preset GUI

 USE:

 |  ~store.value(0, ~synths)
 |  ~store.value(1, ~synths)
 |
 |  ~recall.value(0, ~synths)
 |  ~recall.value(1, ~synths)
 |
 |  Archive.write();

*/

/* init */
(

/* where to read archive from disk */
Archive.archiveDir_(~model.dir);

/* read the archive */
Archive.read();

/* write the archive to disk */
// Archive.write();
);

/* get current synth arg values as dict for preset storage */
(
~getParamsDict = { |synth|

    var sdl, preset;

    preset = Dictionary.new;
    sdl = SynthDescLib.global[synth.defName.asSymbol];

    sdl.notNil.if {

        synth.getn(0, sdl.controls.size, {|vals|

            vals.do { |val, i|

                preset.put(sdl.controls[i].name.asSymbol, val);

            };
        });
    };

    // {preset.postln}.defer();

    // return
    preset
}
);

/* set synth arg values from dict for preset recall */
(
~setParamsDict =  { |synth, preset|

    preset.keysValuesDo { |key,value| ~model.setSynth(synth, key, value) };
}
);

/* test store and recall */
(
~store = { |index, synths|

    /* put all synths in a list */
    var preset = synths.collect{ |synth, i| ~getParamsDict.value(synth) };

    /* tell me you're starting */
    'storing...'.postln;

    {
        /* where to write archive to disk */
        // Archive.archiveDir_(~model.dir);

        /* add preset list to archive */
        synths.do{ |synth| Archive.global.put(index, preset) };

        /* write archive to disk */
        /*Archive.write();*/

        /* tell me you're done */
        ('stored: preset ' ++ index).postln;

    }.defer(2);  // needs time to get from server
}
);

/* test store and recall */
(
~recall = { |index, synths|

    var preset;

    /* tell me you're working */
    ('preset '++index.asString).postln;

    /* where to read archive from disk */
    // Archive.archiveDir_(~model.dir);

    /* read the archive */
    // Archive.read();

    /* get the preset */
    preset = Archive.global.at(index);

    /* set synths */
    preset.do { |p, i|

        /* set synth with preset */
        ~setParamsDict.value(synths[i], p);

    }
}
);

// return
"08: Presets Initialized!"