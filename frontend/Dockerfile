# Placeholder Dockerfile for Frontend
# Full implementation coming in PR #3

FROM node:20-alpine

WORKDIR /app

# Create a minimal placeholder server
RUN echo 'console.log("Frontend placeholder - waiting for PR #3 implementation");' > index.js
RUN echo 'setTimeout(() => {}, 999999999);' >> index.js

CMD ["node", "index.js"]

