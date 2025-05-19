/*
TODO
    * Add a switcher between libfvad and silero
    * Add silero support
    * encode pcm samples as opus after processing (maybe compile libopus with emscripten) -- maybe?
*/
if (!window.showSaveFilePicker) {
    document.getElementById('controls').innerHTML = 'Your browser does not support saving files, try a different browser'
}
const noProcessing = document.getElementById('no-processing');
const processed = document.getElementById('processed');
let stream;
let recorder;
let writeableStream;

document.getElementById('start').addEventListener('click', async () => {
    stream = await navigator.mediaDevices.getUserMedia({ audio: true });
    const audioContext = new AudioContext();
    await audioContext.audioWorklet.addModule('./libfvad-worklet.js');

    const handle = await window.showSaveFilePicker({suggestedName: 'libfvad.pcm'});
    writeableStream = await handle.createWritable();

    const source = audioContext.createMediaStreamSource(stream);
    const workletNode = new AudioWorkletNode(audioContext, 'libfvad-processor');
    workletNode.port.onmessage = async (e) => {
        await writeableStream.write(e.data);
    };

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
