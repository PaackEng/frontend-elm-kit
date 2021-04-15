# build environment
FROM node:lts as build-stage

ARG PROJ_ENV=development
ARG PROJ_AUTH0_CLIENT_ID
ARG PROJ_AUTH0_DOMAIN
ARG PROJ_AUTH0_AUDIENCE
ARG PROJ_AUTOLOGIN
ARG PROJ_ROLLBAR_TOKEN
ARG PROJ_GOOGLE_MAPS_KEY


# Elm by default uses ~/.elm to store the dependencies, but we can't cache folders
# outside the project in Codefresh, so there we set to /codefresh/volume/elm_cache_dir
ARG ELM_HOME=~/.elm

WORKDIR /app
COPY package.json yarn.lock /app/

RUN echo $PROJ_ENV \
  && yarn install --check-files \
  && yarn cache clean --force

COPY . /app/
RUN yarn run build

# production environment
FROM nginx:1.19.8
COPY --from=build-stage /app/dist /usr/share/nginx/html
COPY --from=build-stage /app/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
