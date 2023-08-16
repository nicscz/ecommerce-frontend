# Use uma imagem Node.js
FROM node:16

# Defina o diretório de trabalho dentro do contêiner
WORKDIR /app

# Copie os arquivos de configuração
COPY package.json .
COPY package-lock.json .

# Instale as dependências
RUN npm install

# Copie o restante do código
COPY . .

# Compile o TypeScript
RUN npm run build

# Exponha a porta que a API usará
EXPOSE 3000

# Comando para iniciar a API
CMD ["node", "dist/main/server.js"]
# Use uma imagem Node.js para o backend
FROM node:16 AS backend

# Defina o diretório de trabalho para o backend
WORKDIR /app/backend

# Copie os arquivos de configuração do backend
COPY ecommerce-backend/package.json .
COPY ecommerce-backend/package-lock.json .

# Instale as dependências do backend
RUN npm install

# Copie o código fonte do backend
COPY ecommerce-backend .

# Compile o TypeScript do backend
RUN npm run build

# Use uma imagem Node.js para o frontend
FROM node:16 AS frontend

# Defina o diretório de trabalho para o frontend
WORKDIR /app/frontend

# Copie os arquivos de configuração do frontend
COPY ecommerce-frontend/package.json .
COPY ecommerce-frontend/package-lock.json .

# Instale as dependências do frontend
RUN npm install

# Copie o código fonte do frontend
COPY ecommerce-frontend .

# Compile e construa o frontend (ajuste conforme necessário)
RUN npm run build

# Use uma imagem menor para o contêiner final
FROM node:16-alpine

# Crie um diretório para o projeto completo
WORKDIR /app

# Copie o build do backend do estágio "backend"
COPY --from=backend /app/backend/dist ./backend

# Copie o build do frontend do estágio "frontend"
COPY --from=frontend /app/frontend/build ./frontend

# Exponha a porta do backend (ajuste conforme necessário)
EXPOSE 3000

# Comando para iniciar o frontend e o backend juntos
CMD ["sh", "-c", "node backend/dist/main/server.js & npx serve -s frontend"]
