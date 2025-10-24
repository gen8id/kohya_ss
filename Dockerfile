# CUDA 12.1 + PyTorch 2.3.0
FROM pytorch/pytorch:2.3.0-cuda12.1-cudnn8-devel

# 기본 작업 경로 설정
WORKDIR /app

# 필수 패키지 설치
RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget curl vim \
    && rm -rf /var/lib/apt/lists/*

# Python 패키지 캐싱 방지
ENV PIP_NO_CACHE_DIR=1

# kohya_ss 전체 복사 (모델 포함)
COPY kohya_ss /app/kohya_ss

# pip 업그레이드 및 공통 유틸 설치
RUN pip install --upgrade pip setuptools wheel \
 && pip install --no-cache-dir accelerate bitsandbytes xformers

# 두 requirements.txt 모두 설치
RUN pip install --no-cache-dir -r /app/kohya_ss/requirements.txt --use-pep517 \
 && if [ -f /app/kohya_ss/sd-scripts/requirements.txt ]; then \
        pip install --no-cache-dir -r /app/kohya_ss/sd-scripts/requirements.txt --use-pep517; \
    fi

# 모델 파일 복사 (미리 포함시킬 가중치)
COPY kohya_ss/sd-scripts/models /app/kohya_ss/sd-scripts/models

# (선택) BLIP/WD14 등 관련 종속 추가
RUN pip install transformers==4.44.2 accelerate==0.33.0 \
    torch torchvision torchaudio

# 모델 디렉토리 확인 로그
RUN echo "✅ Copied models:" && ls -R /app/kohya_ss/models || echo "⚠️ No models found"

# 엔트리포인트 복사 및 실행 권한
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 환경 변수 기본값
ENV TRAIN_DIR=/workspace/dataset
ENV OUTPUT_DIR=/workspace/output_model

# 볼륨 마운트 포인트
VOLUME ["/workspace/dataset", "/workspace/output_model"]
