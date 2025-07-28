# Single stage since the build happens on the server at runtime
FROM node:22-alpine

WORKDIR /app

COPY package*.json ./

# --- CHANGE IS HERE ---
# Install dependencies and immediately clean the npm cache in the same layer.
# This is the most effective way to reduce size in a single-stage build.
RUN npm install && npm cache clean --force

# Copy the rest of the application source code
COPY . .

# Environment variables to prevent file watcher errors with 'npm start'
ENV WATCHPACK_POLLING=true
ENV CHOKIDAR_USEPOLLING=true

# Expose the port the server will run on
EXPOSE 3000

# The CMD remains the same for your workflow
CMD ["npm", "start"]