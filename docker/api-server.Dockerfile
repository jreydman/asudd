FROM oven/bun:latest AS base
WORKDIR /usr/src/app

FROM base AS install

RUN mkdir -p /temp/dev
COPY package.json /temp/dev/
RUN cd /temp/dev && bun install

FROM base AS dev

COPY --from=install /temp/dev/node_modules node_modules

ENTRYPOINT ["bun", "run", "dev"]
