// LOAD RAIN AND FOOTSTEPS INTO BUFFERS
~rain = Buffer.read(s,"C:/Users/Christine/Desktop/SOUND FX/zoom/white noise rain mono-1.wav");
~footsteps = Buffer.read(s,"C:/Users/Christine/Desktop/SOUND FX/zoom/steps on gravel sc edit.wav");

~rain.numChannels
~footsteps.numChannels

// Playback:
{PlayBuf.ar(~rain.numChannels, ~rain)}.play;
{PlayBuf.ar(~footsteps.numChannels, ~footsteps)}.play;

// (
// SynthDef(\help_Buffer,{arg out=0, amp=2, bufnum;
// Out.ar (out,
// PlayBuf.ar(~footsteps.numChannels,bufnum, BufRateScale.kr(bufnum))
// )
// }).add;
// )


//HELP_BUFFER SYNTH DEF
(
SynthDef(\help_Buffer,{arg bufnum, speed=0.1, width=2;
    var snd;
    snd = PlayBuf.ar(2,bufnum, BufRateScale.kr(bufnum));
    snd = Mix.ar(snd);
	snd = PanAz.ar(
		numChans: 8,
		width: width,
		in: snd,
		pos: LFSaw.kr(speed));
    Out.ar(0, snd);
}).add;
)

//  HELP_BUFFER SOUND TEST
s
b = Synth(\help_Buffer, [\bufnum, ~footsteps]);

b.set(\speed, 1)


c = Synth(\help_Buffer, [\bufnum, ~rain, \width,4]);

c.set(\speed, 4)


x = { arg pos=0; PanAz.ar(8, SinOsc.ar(freq: 60, mul: 0.3), LFSaw.ar(1/4).range(0, 2)) }.play;

x.set(\pos, 0.)



// MYPLAYER SYNTHDEF

(
SynthDef(\myPlayer,{arg bufnum, pan=0, amp=1, rate=1, att=10, sus=0.5, rel=2, gate=1;
	var env, snd;
	env = Env.asr(attackTime: att, sustainLevel: sus, releaseTime: rel).kr(gate: gate, doneAction: 2);
	snd = PlayBuf.ar(bufnum.numChannels, bufnum, BufRateScale.kr(bufnum)*rate);
	snd = Mix.ar(snd);  //automate mix down from stereo to mono
	snd = snd * env;
	Out.ar(0, Pan2.ar(snd, pan, amp))

}).add;
)

// MYPLAYER SOUND TEST
(
Synth(\myPlayer, [\bufnum, ~footsteps, \pan, \rate, \env, \amp, 0.5]);
)


// SINOSC SYNTH

// 1 OF 3

(
SynthDef("Sin", {arg out = 0, freq=200, pan = 0, rate=5, amp=0.2, gate=1;
	var acco, snd;
	acco = Env.adsr(
		attackTime:0.4,
		decayTime:0.8,
		sustainLevel:0.8,
		releaseTime:1.5,
		peakLevel:2,
		curve:-4.0,
		bias:0).kr(gate: gate, doneAction:2);
	snd = LPF.ar(
		in: SinOsc.ar(freq: [freq,280,100]));
	snd = snd*acco;
	snd = Mix.ar(snd);
		Out.ar(0,Pan2.ar (snd, pan, amp));
}).add;
)

//  SIN SOUND TEST 2 OF 3
(
x = Synth(\Sin);
)
x.set(\gate, 1);


// 3 OF 3 SOUNDS LIKE A NORMAL SINOSC, HOW DO I MAKE MORE EFFECTS?

Pbind(
			\instrument, \Sin,
			\scale, Scale.dorian,
		    \midinote, Prand([15,30,50,53],inf),
			\dur, 3.3,
			\amp, 0.2,
			\ctranspose, 2,
		    \legato,0.8
	).trace.play;
	4.wait;
	a.free;


// FOOTSTEPS, RAIN, SIN FORK

(
{
	a =     Pbind(
			\instrument, \Sin,
			\scale, Scale.dorian,
		    \midinote, Prand([15,30,50,53],inf),
			\dur, 3.3,
			\amp, 0.2,
			\ctranspose, 2,
		    \legato,0.8
	).trace.play;
	4.wait;

	b = Synth(\help_Buffer, [
		\bufnum, ~footsteps,
		\pan,0,
		\amp,1,
		\rate,1,
		\att,10,
		\sus,0.8,
		\rel,0.1,
	]);

	8.wait;
	c = Synth(\help_Buffer, [\bufnum, ~rain,]);
	10.wait;

	d = Synth(\help_Buffer, [
		\bufnum, ~footsteps,
		\pan,0,
		\amp,1,
		\rate,1,
		\att,10,
		\sus,0.8,
		\rel,0.1,
	]);
	6.wait;

	d = Synth(\help_Buffer, [
		\bufnum, ~footsteps,
		\pan,0,
		\amp,1,
		\rate,1,
		\att,10,
		\sus,0.8,
		\rel,0.1,
	]);
	8.wait;
	a.stop;
	4.wait;
	b.stop;
	1.wait;
	c.stop;
	1.wait;
	d.stop;

}.fork;
)




// loads into o which is the server options, set the number of buses to 8
// the last line boots the server

o = Server.default.options;
o.numOutputBusChannels = 8;
s = Server.default.boot;
s.quit;
Server.local.options.device = "ASIO : ASIO4ALL";
(
Routine({
	(0..7).do ({| spkr |
		var noisy = {Out.ar(spkr, PinkNoise.ar (0.1))}.play;
		1.wait;
		noisy.free;
		0.2.wait;
	});
}).play(SystemClock);
)



///////////////
o = Server.local.options;


o.numOutputBusChannels = 8;

s.boot;
s.meter;
{ SinOsc.ar([1, 2, 3, 4, 5, 6, 7, 8]*100, 0.05) }.play


















