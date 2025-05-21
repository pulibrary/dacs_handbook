### In-browser Voice Activity Detection

#### Introduction

Voice Activity Detection (VAD) classifies sound into speech and not-speech.
This is helpful in implementing a performant voice search solution, since
non-speech does not need to go through the transcription process, saving
computing resources and (if transcription happens off-device) network calls.

Two popular models are Google's WebRTC VAD, also known as libfvad, and Silero.
Both use machine learning approaches: libfvad uses a Gaussian Mixture Model,
while Silero uses a neural network.
Both can be run in-browser using WASM: libfvad is a C library that can be 
compiled into WASM using Emscripten, while Silero can be run in the onnx runtime using
[the onnxruntime-web package](https://www.npmjs.com/package/onnxruntime-web).

#### Methods

For each VAD:
1. Create an html page that records audio using the MediaRecorder API
1. Use an AudioProcessorWorklet to apply the VAD to a given buffer of samples.
1. If the VAD says the buffer contains voice, append the audio to a file.
1. Using newer hardware, open the HTML page and turn on the browser's profiler.
1. Start recording.  Read a longer passage.
1. Review the resultant file for accuracy using Audacity's Import Raw Data (Signed 16-bit PCM for libfvad / Float32 PCM for silero and non-processed, Default endianness, mono, 44100 Hz).
1. Review the performance profile to see how much of the time was spent in VAD.
1. Repeat steps 4-7 on older hardware.


##### Using the tester locally

1. Clone this repo
1. cd dacs_handbook
1. `research/in-browser_voice_activity_detection/setup-vad-tester.sh`
1. In your browser, go to http://localhost:7878/research/in-browser_voice_activity_detection/vad-tester.html

#### Conclusion

Silero cuts away a _lot_ more non-voice content than libfvad does -- to the
point that silero's output is not particularly intelligible to listen to.  This could be due to differences in this quick-and-dirty implementation, though,
in which we send larger buffers to libfvad than we do to silero (perhaps a 
better silero implementation would concatenate the buffers before speech is
detected and after speech ends to provide more natural spacing).

Both seemed very performant on my work macbook!

Whisper was able to transcribe the libfvad output perfectly, while it got
some words wrong when transcribing the silero output.

TODO:
* profile
* Repeat the test on older/slower hardware
* Figure out the sample rate -- make sure it takes the sample rate from the browser and resamples to a different rate if the model (silero?) requires it

#### Possible next steps

* The current implementations add some noise to the audio -- I don't know if this affects anything or not.
* Investigate proper configuration of Silero and libfvad, tune it for accuracy and performance
* Repeat this study using audio in a variety of languages (from [Common Voice](https://commonvoice.mozilla.org/en/datasets), perhaps)
* Repeat this study using audio with a variety of background/non-speech noise

#### References

* [Digital Audio Concepts](https://developer.mozilla.org/en-US/docs/Web/Media/Guides/Formats/Audio_concepts) - good introduction to web audio concepts
* [One Voice Detector to Rule Them All](https://thegradient.pub/one-voice-detector-to-rule-them-all/) -- an introduction to the Silero VAD
* [Profiling Web Audio Apps in Chrome](https://web.dev/articles/profiling-web-audio-apps-in-chrome)
* [AudioWorklet: What, Why, and How by Hongchan Choi](https://www.youtube.com/watch?v=g1L4O1smMC0)- a good introduction to AudioProcessorWorklet
