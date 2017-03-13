FROM node:argon
EXPOSE 80

WORKDIR /app
COPY package.json .
RUN npm install
COPY . .

DDD

CMD ["node", "server.js"]
