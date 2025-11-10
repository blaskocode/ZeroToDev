# Placeholder Dockerfile for API
# Full implementation coming in PR #2

FROM node:20-alpine

WORKDIR /app

# Create a minimal placeholder server
RUN echo 'console.log("API placeholder - waiting for PR #2 implementation");' > index.js
RUN echo 'setTimeout(() => {}, 999999999);' >> index.js

CMD ["node", "index.js"]

