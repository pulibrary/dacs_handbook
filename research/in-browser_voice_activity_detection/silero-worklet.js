// This class is responsible for concatenating raw PCM audio frames into frames of 512 samples,
// then posting them to the main thread as messageport messages.
// ONNX runtime does not seem to work within an AudioWorkletProcessor.

const DESIRED_FRAME_SIZE=512;
class SileroVADProcessor extends AudioWorkletProcessor {
    #outputFrame = new Float32Array(DESIRED_FRAME_SIZE);
    #offset = 0;

    // inputs and outputs are PCM samples as 32-bit floats
    // see https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Using_AudioWorklet#the_input_and_output_lists
    process(inputs, outputs, params) {
        const inputFrame = inputs[0][0];
        for (let i=0; i < inputFrame.length; i++) {
            if (this.#offset == DESIRED_FRAME_SIZE) {
                this.port.postMessage(this.#outputFrame);
                this.#outputFrame = new Float32Array(DESIRED_FRAME_SIZE);
                this.#offset = 0;
            }
            this.#outputFrame[this.#offset] = inputFrame[i];
            this.#offset += 1;
        }
        return true;
    }
}
registerProcessor("silero-processor", SileroVADProcessor);
