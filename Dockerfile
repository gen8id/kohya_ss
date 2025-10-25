# CUDA 12.1 + PyTorch 2.3.0
FROM pytorch/pytorch:2.3.0-cuda12.1-cudnn8-devel

# 기본 작업 경로 설정
WORKDIR /app

# 필수 패키지 설치
RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget curl libgl1 libglib2.0-0 libcudnn9-cuda-12 libcudnn9-dev-cuda-12 \
    && rm -rf /var/lib/apt/lists/*

# Python 패키지 캐싱 방지
ENV PIP_NO_CACHE_DIR=1

# pip 업그레이드 및 공통 유틸 설치
RUN pip install --upgrade pip setuptools wheel

# kohya_ss 전체 복사 (모델 포함)
COPY . /app/sdxl_train_captioner
# 두 requirements.txt 모두 설치
WORKDIR /app/sdxl_train_captioner
RUN pip install -r requirements.txt

# 모델 파일 복사 (미리 포함시킬 가중치)
COPY ./models /app/sdxl_train_captioner/models

# 모델 디렉토리 확인 로그
RUN echo "✅ Copied models:" && ls -R /app/sdxl_train_captioner/models || echo "⚠️ No models found"

RUN chmod +x entrypoint.sh
ENTRYPOINT ["bash", "entrypoint.sh"]

# 엔트리포인트 복사 및 실행 권한
#COPY entrypoint.sh /entrypoint.sh

# 환경 변수 기본값
#ENV TRAIN_DIR=/app/sdxl_train_captioner/dataset
#ENV OUTPUT_DIR=/app/sdxl_train_captioner/output_model

# 볼륨 마운트 포인트
#VOLUME ["/app/sdxl_train_captioner/dataset", "/app/sdxl_train_captioner/output_model"]
