// This class is responsible for posting raw PCM samples to the main thread
// as messageport messages without any processing.

class NoProcessingVADProcessor extends AudioWorkletProcessor {
    // inputs and outputs are PCM samples as 32-bit floats
    // see https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Using_AudioWorklet#the_input_and_output_lists
    process(inputs, outputs, params) {
        this.port.postMessage(inputs[0][0]);
        return true;
    }
}
registerProcessor("no-processing-processor", NoProcessingVADProcessor);
