# build: dockebuild -t conftest:latest .
# run: docker run -it --rm -e API_URL=http://www.google.com -p 8800:80 conftest

### STAGE 1: Build ###

# We label our stage as 'builder'
FROM node:10-alpine as builder
ARG NODE_ENV
ARG API_BASE_URL
ENV NODE_ENV "$NODE_ENV"
ENV API_BASE_URL "$API_BASE_URL"

COPY package.json package-lock.json ./
#RUN npm set progress=false && npm config set depth 0 && npm cache clean --force
#RUN npm install -g ts-node yargs dotenv typescript@2.4.2

## Storing node modules on a separate layer will prevent unnecessary npm installs at each build
RUN npm i && mkdir /js-app && cp -R ./node_modules ./js-app
WORKDIR /js-app
COPY . .
## Build the angular app in production mode and store the artifacts in dist folder
RUN npm run build

### STAGE 2: Setup ###

FROM nginx:1.13.3-alpine

## Copy our default nginx config
COPY nginx/default.conf /etc/nginx/conf.d/

## Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

## From 'builder' stage copy over the artifacts in dist folder to default nginx public folder
COPY startup.sh /startup.sh
COPY --from=builder /js-app/dist /usr/share/nginx/html

RUN chmod +x /startup.sh

CMD ["/startup.sh"]
