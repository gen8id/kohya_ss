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
COPY . /app/sxdl_train_captioner

# pip 업그레이드 및 공통 유틸 설치
RUN pip install --upgrade pip setuptools wheel \
 && pip install --no-cache-dir accelerate bitsandbytes xformers

# 두 requirements.txt 모두 설치
RUN pip install --no-cache-dir -r /app/sxdl_train_captioner/requirements.txt --use-pep517 \
  && pip install --no-cache-dir -r /app/sxdl_train_captioner/sd-scripts/requirements.txt --use-pep517
 
# 모델 파일 복사 (미리 포함시킬 가중치)
#COPY ./models /app/sxdl_train_captioner/models

# (선택) BLIP/WD14 등 관련 종속 추가
RUN pip install transformers==4.44.2 accelerate==0.33.0 \
    torch torchvision torchaudio

# 모델 디렉토리 확인 로그
RUN echo "✅ Copied models:" && ls -R /app/kohya_ss/models || echo "⚠️ No models found"

WORKDIR /app/sxdl_train_captioner/sd-scripts

# 엔트리포인트 복사 및 실행 권한
#COPY entrypoint.sh /entrypoint.sh
#RUN chmod +x /entrypoint.sh

# 환경 변수 기본값
ENV TRAIN_DIR=/app/sxdl_train_captioner/dataset
ENV OUTPUT_DIR=/app/sxdl_train_captioner/output_model

# 볼륨 마운트 포인트
VOLUME ["/app/sxdl_train_captioner/dataset", "/app/sxdl_train_captioner/output_model"]
