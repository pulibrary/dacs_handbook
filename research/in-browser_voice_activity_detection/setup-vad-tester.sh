#!/bin/bash

if [ ! -f "research/in-browser_voice_activity_detection/silero_vad_v5.onnx" ]; then
    wget 'https://github.com/ricky0123/vad/raw/refs/heads/master/silero_vad_v5.onnx'
    mv 'silero_vad_v5.onnx' 'research/in-browser_voice_activity_detection/'
fi
ruby -run -e httpd . -p 7878
