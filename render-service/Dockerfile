FROM node:20-bookworm

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    libreoffice \
    libreoffice-calc \
    fonts-dejavu \
    fonts-liberation \
    fontconfig \
    ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package.json ./
RUN npm install --omit=dev

COPY server.js ./

ENV PORT=8080
ENV MAX_FILE_SIZE_MB=35
ENV RENDER_TIMEOUT_MS=180000
ENV ALLOWED_ORIGINS=https://zakriii.github.io

EXPOSE 8080

CMD ["npm", "start"]
