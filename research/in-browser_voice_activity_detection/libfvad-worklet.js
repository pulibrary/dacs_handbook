import VADBuilder, { VADMode, VADEvent } from 'https://ozymandiasthegreat.github.io/libfvad-wasm/embedded.js';
const FRAME_SIZE = 128;

// This class is responsible for filtering audio frames that contain speech from those that do not
// using libfvad.  It does this by:
//   1. collecting frames into buffers
//   2. sending those buffers to libfvad to determine whether or not it contains speech
//   3. broadcasting buffers with speech via a MessagePort
class LibFVADProcessor extends AudioWorkletProcessor {
    #vad = undefined;
    #bufferSize = undefined;
    #floatTo16BitPCM = undefined;
    #buffer = new Int16Array(128);
    #offset = 0;
    constructor() {
        super();
        VADBuilder().then((builder) => {
            // sample rate is 48_000 Hz
            // We do not want VADMode.VERY_AGGRESSIVE, it cuts the first part of each word off!
            this.#vad = new builder(VADMode.AGGRESSIVE, 48_000);
            this.#bufferSize = this.#vad.getMinBufferSize(FRAME_SIZE);
            this.#floatTo16BitPCM = builder.floatTo16BitPCM;
        })
    }

    // inputs and outputs are PCM samples as 32-bit floats
    // see https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Using_AudioWorklet#the_input_and_output_lists
    process(inputs, outputs, params) {
        if (this.#vad && this.#bufferSize && this.#floatTo16BitPCM) {
            const frame = this.#floatTo16BitPCM(inputs[0][0]);
            this.#addFrame(frame)
        }
        return true;
    }

    #addFrame(frame) {
        for (let i = 0; i < frame.length; i++) {
            if (this.#offset < this.#bufferSize) { // should this be the size of the buffer, rather than the size of the frame (128)
                this.#buffer[this.#offset] = frame[i];
                this.#offset++;
            } else {
                const result = this.#vad.processBuffer(this.#buffer);
                if (result == VADEvent.VOICE) {
                    this.port.postMessage(this.#buffer);
                }
                this.#offset = 1;
                this.#buffer = new Int16Array(this.#bufferSize);
                this.#buffer[this.#offset] = frame[i];
            }
        }
    }
}
registerProcessor("libfvad-processor", LibFVADProcessor);
