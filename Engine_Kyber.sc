Engine_Kyber : CroneEngine {
  var <synth;
  
  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    SynthDef(\Convulution2L, {
      arg in, out, kernel, trigger=0.0, framesize=2048, crossfade=1.0;
      
      var sig = {
        Convolution2L.ar(SoundIn.ar([0, 1]),
          kernel,
          trigger,
          framesize,
          crossfade
        ); 
      };

      Out.ar(out, sig);
    }).add;

    context.server.sync;

    synth = Synth.new(\Convolution2L, [
      \out, context.out_b.index],
    context.xg);

    this.addCommand("kernel", "f", {|msg|
      synth.set(\freq, msg[1]);
    });
    
    this.addCommand("trigger", "f", {|msg|
      synth.set(\res, msg[1]);
    }); 

    this.addCommand("framesize", "f", {|msg|
      synth.set(\inputGain, msg[1]);
    });

    this.addCommand("crossfade", "f", {|msg|
      synth.set(\fType, msg[1]);
    });

  free {
    synth.free;
  }
}
