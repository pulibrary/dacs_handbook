import * as ort from "https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/esm/ort.min.js";

export class SileroInference {
    #ort = undefined;
    #ortSession = undefined;
    constructor() {
        this.#ort = ort;
        this.#ort.env.wasm.wasmPaths = 'https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/';
    }

    // frame parameter should be an array of 512 Float32 audio samples, rather than the 128 samples provided by the browser
    async isVoice(frame) {
        const inputTensor = new this.#ort.Tensor("float32", frame, [
            1,
            frame.length,
        ]);

        const state = new this.#ort.Tensor("float32", Array(128*2).fill(0), [2, 1, 128]);

        // Sample rate is 16000 Hz
        const sampleRate = new this.#ort.Tensor("int64", [BigInt(16000)]);

        const inputs = {
            input: inputTensor,
            state: state,
            sr: sampleRate,
        };
        const session = await this.#session();
        const outputs = await session.run(inputs)
        const speechProbability = outputs["output"]?.data;
        return (speechProbability && speechProbability > 0.125);
    }

    #session() {
        if (this.#ortSession) { return Promise.resolve(this.#ortSession) }

        return this.#ort.InferenceSession.create("./silero_vad_v5.onnx", {
            executionProviders: ["wasm"],
        }).then(session => {
            this.#ortSession = session;
            return session;
        });
    }
}
