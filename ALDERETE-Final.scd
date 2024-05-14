s.boot;

// ----- UTILITY -----
(

~within_bounds = {|start_coords, end_coords, radius|
	// Haversine Distance. If the distance is less than the radius, then BOOM, you're in the location!
	var a, c, d;
	var lat_1, lon_1, lat_2, lon_2;
	var dlat, dlon;
	var r = 6357000;

	lat_1 = start_coords[0];
	lon_1 = start_coords[1];
	lat_2 = end_coords[0];
	lon_2 = end_coords[1];

	dlat = (lat_2 - lat_1).degrad;
	dlon = (lon_2 - lon_1).degrad;

	a = ((sin(dlat/2))** 2) + (cos(lat_1.degrad) * cos(lat_2.degrad) * sin(dlon / 2)**2);
	c = 2 * atan(sqrt(a), sqrt(1 - a));
	d = r * c;

	if (d < radius, {1}, {0});
};
)


(
// ----- SAMPLES -----
~nostalgia = Buffer.readChannel(s, "sf/nostalgia.mp3".resolveRelative, channels:[0]);
~infinite  = Buffer.readChannel(s, "sf/infinite_love.mp3".resolveRelative, channels:[0]);
~prayer = Buffer.read(s, "sf/prayer.wav".resolveRelative);
~kaneko = Buffer.readChannel(s, "sf/kaneko.mp3".resolveRelative, channels:[0]);
~kaneko_part = Buffer.readChannel(s, "sf/kaneko.mp3".resolveRelative, channels:[0], numFrames:1000000);

// ----- ENVELOPES -----
~fade_env = Env.asr(5, 1, 5, 'linear');
)


(
// ----- SYNTH DEFS -----
var fftsize=4096;
var a_bufsize = PartConv.calcBufSize(fftsize, ~prayer);
var a_irspectrum = Buffer.alloc(s, a_bufsize, 1);

var b_bufsize = PartConv.calcBufSize(fftsize, ~kaneko_part);
var b_irspectrum = Buffer.alloc(s, b_bufsize, 1);

var split_freq = 600;
a_irspectrum.preparePartConv(~prayer, fftsize);
b_irspectrum.preparePartConv(~kaneko_part, fftsize);

// Nostalgia Granular Synthesis
SynthDef(\nost_high, { |out, gate=1|
	var sig, env;
	// sig = GrainBuf.ar(2, Dust.ar(ExpRand(60, 60, 5)), LFNoise1.kr(0.3!2).exprange(0.0002, 0.2), ~nostalgia, 1, 0.244495, 2, 0, -1, 512);
	sig = GrainBuf.ar(2, Impulse.ar(4), 2, ~nostalgia, 1, LFNoise0.kr(0.5).range(0, 1), 2, 0, -1, 512);
	env = EnvGen.kr(~fade_env, gate, doneAction: Done.freeSelf);
	Out.ar(out, HPF.ar(sig * env, split_freq) * -25.dbamp);
}).add;

SynthDef(\nost_low, { |out, gate=1|
	var sig, env;
	// sig = GrainBuf.ar(2, Dust.ar(ExpRand(60, 60, 5)), LFNoise1.kr(0.3!2).exprange(0.0002, 0.2), ~nostalgia, 1, 0.244495, 2, 0, -1, 512);
	sig = GrainBuf.ar(2, Impulse.ar(4), 2, ~nostalgia, 1, LFNoise0.kr(0.5).range(0, 1), 2, 0, -1, 512);
	env = EnvGen.kr(~fade_env, gate, doneAction: Done.freeSelf);
	Out.ar(out, LPF.ar(sig * env, split_freq) * -25.dbamp);
}).add;

// Infinity Granular Synthesis
SynthDef(\infi_high, { |out, gate=1|

	var sig, env;
	sig = GrainBuf.ar(2, Dust.ar(8), 2, ~infinite, 1, LFNoise1.ar(0.5).range(0, 1), 2, 0, -1, 512);
	env = EnvGen.kr(~fade_env, gate, doneAction: Done.freeSelf);
	Out.ar(out, HPF.ar(sig * env, split_freq) * -30.dbamp);
}).add;

SynthDef(\infi_low, { |out, gate=1|

	var sig, env;
	sig = GrainBuf.ar(2, Dust.ar(8), 2, ~infinite, 1, LFNoise1.ar(0.5).range(0, 1), 2, 0, -1, 512);
	env = EnvGen.kr(~fade_env, gate, doneAction: Done.freeSelf);
	Out.ar(out, LPF.ar(sig * env, split_freq) * -30.dbamp);
}).add;


// Kaneko Granular Synthesis
SynthDef(\kaneko_high, { |out, gate=1|
	var sig, env;
	sig = GrainBuf.ar(2, Impulse.ar(3), 2, ~kaneko, 1, SinOsc.ar(0.5, add:0.7), 2, 0, -1, 512);
	env = EnvGen.kr(~fade_env, gate, doneAction: Done.freeSelf);
	Out.ar(out, HPF.ar(sig * env, split_freq) * -30.dbamp);
}).add;

SynthDef(\kaneko_low, { |out, gate=1|
	var sig, env;
	sig = GrainBuf.ar(2, Impulse.ar(3), 2, ~kaneko, 1, SinOsc.ar(0.5, add:0.7), 2, 0, -1, 512);
	env = EnvGen.kr(~fade_env, gate, doneAction: Done.freeSelf);
	Out.ar(out, LPF.ar(sig * env, split_freq) * -30.dbamp);
}).add;

// Prayer Partial Convolution
SynthDef(\prayer, { |out, gate=1|
	// If the Buffer UGen channel mismatch: expected 1, yet buffer has 2 channels, is showing up, that's okay.
	// It sounds too obviously like the prayer sound file if I convert it to one channel. I'm not sure exactly what makes the difference, but there is one. And I like it. Sue me!!!
	var sig, env;
	sig = PartConv.ar(PlayBuf.ar(1, ~prayer, 1, loop:1)*0.0125, fftsize, a_irspectrum, 0.125);
	env = EnvGen.kr(~fade_env, gate, doneAction: Done.freeSelf);
	Out.ar(0, sig * env * -25.dbamp ! 2);
}).add;

// Boopy thing I did with Splay
SynthDef(\boopy, {|out, gate=1|
	var sig, env, freq, trig, seq;
	trig = Impulse.kr(SinOsc.kr(0.5, 0, 20, 20));
	seq = Drand([1, 2, 3, 4, 5], inf);
	freq = Demand.kr(trig, 0, seq);
	sig = SinOsc.ar(freq * 100);
	env = EnvGen.kr(~fade_env, gate, doneAction: Done.freeSelf);
	Out.ar(0, Splay.ar(sig * env, SinOsc.kr(0.5), center: SinOsc.kr(0.2)) * -43.dbamp);
}).add;

// FM Synths
SynthDef(\fm_seq, {|out=0, gate=1|
    var ctls = [
        // freq, phase, amp
        [Saw.kr(0.5).range(200, 310), 0, 1],
        [LFNoise1.kr(0.5).exprange(3, 310), 0, 1],
        [SinOsc.kr(20).exprange(0, 400), 0, 1],
        [LFNoise1.kr(20).exprange(3, 100), 0, 1],
        [LFNoise1.kr(0.5).exprange(3, 100), 0, 1],
        [LFNoise1.kr(0.5).exprange(3, 100), 0, 1]
    ];
	var algo = Demand.ar(Impulse.ar(8), 0, Dseq([1, 2, 3, 4, 5, 6, 7, 8, 9], inf));
	var env = EnvGen.kr(~fade_env, gate, doneAction: Done.freeSelf);
	Out.ar(0, Mix(FM7.arAlgo(8, ctls, SinOsc.ar(algo * 100))) * env ! 2 * -30.dbamp;)
}).add;

// FM with Convolution?
SynthDef(\fm_exp, {|out=0, gate=1|
    var ctls = [
        // freq, phase, amp
		[Saw.kr(300).exprange(50, 310), 0, 1],
        [LFNoise1.kr(0.5).exprange(50, 100), 0, 0.2],
		[Saw.kr(200).exprange(2, 400), 0, 0.2],
        [SinOsc.kr(400, add:200).exprange(3, 400), 0, 0.2],
        [SinOsc.kr(200, add:200).exprange(3, 400), 0, 0.2],
        [LFNoise1.kr(0.5).exprange(3, 400), 0, 0.2]
    ];
	var algo = Demand.kr(Impulse.kr(3), 0, Dseq([1, 2, 3, 4, 5, 6, 7, 8, 9], inf));
	var sig, env;
	sig = PartConv.ar(PlayBuf.ar(1, ~kaneko_part, 1, loop:1)*0.125, fftsize, b_irspectrum, 0.125);
	env = EnvGen.kr(~fade_env, gate, doneAction: Done.freeSelf);
	Out.ar(0, LPF.ar(sig * env * Mix(FM7.arAlgo(1, ctls, SinOsc.kr(100/algo))), 440) * -25.dbamp ! 2;)
}).add;
)



// ----- LOCATION DEFINITIONS -----
(
~locations = [];

~locations = ~locations.add(Dictionary.with(*["name"->"Stiles", "latlon"->[41.312375,-72.930963], "radius"->56, "active"->false, "synth"->\nost_high, "playing"->nil]));
~locations = ~locations.add(Dictionary.with(*["name"->"Morse", "latlon"->[41.312524,-72.930043], "radius"->56, "active"->false, "synth"->\nost_low, "playing"->nil]));
~locations = ~locations.add(Dictionary.with(*["name"->"Sterling", "latlon"->[41.311380,-72.928660], "radius"->103, "active"->false, "synth"->\infi_high, "playing"->nil]));
~locations = ~locations.add(Dictionary.with(*["name"->"Law", "latlon"->[ 41.312023,-72.928057], "radius"->68, "active"->false, "synth"->\infi_low, "playing"->nil]));
~locations = ~locations.add(Dictionary.with(*["name"->"HQ", "latlon"->[41.312309,-72.929278], "radius"->58, "active"->false, "synth"->\fm_seq, "playing"->nil]));
~locations = ~locations.add(Dictionary.with(*["name"->"Beinecke", "latlon"->[41.311452,-72.926828], "radius"->86, "active"->false, "synth"->\fm_exp, "playing"->nil]));
~locations = ~locations.add(Dictionary.with(*["name"->"Trumbull", "latlon"->[41.310643,-72.928859], "radius"->49, "active"->false, "synth"->\kaneko_high, "playing"->nil]));
~locations = ~locations.add(Dictionary.with(*["name"->"Berkeley", "latlon"->[41.310335,-72.928126], "radius"->47, "active"->false, "synth"->\kaneko_low, "playing"->nil]));
~locations = ~locations.add(Dictionary.with(*["name"->"Cross Campus", "latlon"->[41.310804,-72.927713], "radius"->65, "active"->false, "synth"->\boopy, "playing"->nil]));
~locations = ~locations.add(Dictionary.with(*["name"->"Cemetery", "latlon"->[41.313294,-72.926779], "radius"->166, "active"->false, "synth"->\prayer, "playing"->nil]));
)

// ----- MAIN -----
(
var activator;
activator = {
	arg msg, time, addr, recvPort;
	var latlon = [msg[1], msg[2]];

	~locations.do({arg loc; if(~within_bounds.value(latlon, loc["latlon"], loc["radius"]) == 1,{

		if( loc.at("active") == false,{
			x = Synth(loc.at("synth"));
			postf("Entering % at %\n", loc.at("name"), msg[3]);
			loc.put("playing", x);
			loc.put("active", true);
		},{/* do nothing if active and still in bounds*/});
	},{
		if( loc.at("active") == true,{
			loc.at("playing").release;
			postf("Leaving % at %\n", loc.at("name"), msg[3]);
			loc.put("active", false);
		},{/* do nothing if not active and not in bounds */});
	}
	)});
};

~o = OSCFunc(activator, '/coords');
)


(
~o.free;
~locations.do({arg loc; if(loc.at("active") == true, {loc.at("playing").release; loc.put("active", false);}, {})});
)


// ----- EXAMPLE COORDINATES -----

// You can do a.release, b.release, etc. to fade out each sound to see what each one composes of.

// Rose Walk
(
a = Synth(\infi_low);
b = Synth(\kaneko_high);
c = Synth(\kaneko_low);
d = Synth(\boopy);
)


s.makeWindow;
// Area between Morse and Stiles
(
a = Synth(\nost_high);
b = Synth(\nost_low);
)

// Alexander Walk
(
a = Synth(\infi_low);
b = Synth(\fm_exp);
c = Synth(\boopy);
)

// Cemetery
(
a = Synth(\prayer);
)

(
a = Synth(\fm_seq);
)

