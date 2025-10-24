#!/bin/bash
# 모델 다운로드
if [ ! -f /app/models/sd_xl_base_1.0.safetensors ]; then
    wget -O /app/models/sd_xl_base_1.0.safetensors https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors
fi

# 캡셔너 실행
#cd sd-scripts
#python cap-watcher.py
