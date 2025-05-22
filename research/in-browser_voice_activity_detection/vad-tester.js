import {SileroInference} from './silero-inference.js';

if (!window.showSaveFilePicker) {
    document.getElementById('controls').innerHTML = 'Your browser does not support saving files, try a different browser'
}
const selectVadConfig = (allOptions) => {
    return () => {
        const selected = document.querySelector('input[name=vad]:checked').value;
        return allOptions[selected];    
    }
}
const module = selectVadConfig({
    libfvad: './libfvad-worklet.js',
    silero: './silero-worklet.js',
    none: './no-processing-worklet.js'
});
const processor = selectVadConfig({
    libfvad: 'libfvad-processor',
    silero: 'silero-processor',
    none: 'no-processing-processor'
});
const filename = selectVadConfig({
    libfvad: 'libfvad.pcm',
    silero: 'silero.pcm',
    none: 'no-processing.pcm'
});

const pcmFrameCallback = (writeableStream) => {
    return selectVadConfig({
        libfvad: async (e) => {
            await writeableStream.write(e.data)
        },
        silero: async (e) => {
            if (await sileroInference.isVoice(e.data)) { await writeableStream.write(e.data) };
        },
        none: async (e) => {
            await writeableStream.write(e.data)
        },
    });
}

const sileroInference = new SileroInference();
let stream;
let recorder;
let writeableStream;

document.getElementById('start').addEventListener('click', async () => {
    stream = await navigator.mediaDevices.getUserMedia({ audio: true });
    const audioContext = new AudioContext();
    await audioContext.audioWorklet.addModule(module());

    const handle = await window.showSaveFilePicker({suggestedName: filename()});
    writeableStream = await handle.createWritable();

    const source = audioContext.createMediaStreamSource(stream);
    const workletNode = new AudioWorkletNode(audioContext, processor());
    workletNode.port.onmessage = pcmFrameCallback(writeableStream)();

    // Connect the source to the worklet and the worklet to the destination
    source.connect(workletNode);
    workletNode.connect(audioContext.destination);
    recorder = new MediaRecorder(stream);
    recorder.start();
    recorder.addEventListener('stop', (event) => {
        writeableStream.close();
        stream.getTracks().forEach(track => track.stop());
    });
});
document.getElementById('stop').addEventListener('click', () => {
    recorder.stop();
})
