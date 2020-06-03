Engine_Kyber : CroneEngine {
  var <synth, <buffer;

  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    SynthDef(\Convolution2L, {
      arg in1, in2, out, kernel, trigger=0.0, framesize=2048, crossfade=1.0;

      var sig = {
        Convolution2L.ar(SoundIn.ar([in1, in2]),
          kernel,
          trigger,
          framesize,
          crossfade
        );
      };

      Out.ar(out, sig);
    }).add;

    context.server.sync;
    
    buffer = Buffer.alloc(context.server, 2048, 1);
    buffer.sine1(1.0/[1, 2, 3, 4, 5, 6], true, true, true);

    synth = Synth.new(\Convolution2L, [
      \in1, context.in_b[0].index,
      \in2, context.in_b[1].index,
      \out, context.out_b.index,
      \kernel, buffer,
      \trigger, 0.0,
      \framesize, 2048,
      \crossfade, 1],
    context.xg
    );

    this.addCommand("kernel", "f", {|msg|
      synth.set(\kernel, msg[1]);
    });

    this.addCommand("trigger", "f", {|msg|
      synth.set(\trigger, msg[1]);
    });

    this.addCommand("framesize", "f", {|msg|
      synth.set(\framesize, msg[1]);
    });

    this.addCommand("crossfade", "i", {|msg|
      synth.set(\crossfade, msg[1]);
    });

  free {
    synth.free;
  }
}
}
