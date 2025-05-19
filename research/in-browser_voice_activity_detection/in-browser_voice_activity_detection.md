### In-browser Voice Activity Detection

#### Introduction

Voice Activity Detection (VAD) classifies sound into speech and not-speech.
This is helpful in implementing a performant voice search solution, since
non-speech does not need to go through the transcription process, saving
computing resources and (if transcription happens off-device) network calls.

Two popular models are Google's WebRTC VAD, also known as libfvad, and Silero.
Both can be run in-browser using WASM: libfvad is a C library that can be 
compiled into WASM using Emscripten, while Silero is a machine learning model
that can be run in the onnx runtime using
[the onnxruntime-web package](https://www.npmjs.com/package/onnxruntime-web).

#### Methods

For each VAD:
1. Create an html page that records audio using the MediaRecorder API
1. Use an AudioProcessorWorklet to apply the VAD to a given buffer of samples.
1. If the VAD says the buffer contains voice, append the audio to a file.
1. Using newer hardware, open the HTML page and turn on the browser's profiler.
1. Start recording.  Read a longer passage.
1. Review the resultant file for accuracy using Audacity's Import Raw Data (Signed 16-bit PCM, Default endianness, mono, 44100 Hz).
1. Review the performance profile to see how much of the time was spent in VAD.
1. Repeat steps 4-7 on older hardware.


##### Using the tester locally

1. Clone this repo
1. ruby -run -e httpd . -p 7878
1. In your browser, go to http://localhost:7878/research/in-browser_voice_activity_detection/vad-tester.html

#### Conclusion


#### Next steps

* Repeat this study using librivox audio in a variety of languages
* Repeat this study using audio with a variety of background/non-speech noise

#### References

* https://web.dev/articles/profiling-web-audio-apps-in-chrome
