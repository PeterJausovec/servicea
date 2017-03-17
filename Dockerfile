FROM node:argon
EXPOSE 5000

WORKDIR /app
COPY package.json .
RUN npm install
COPY . .

CMD ["node", "server.js"]
