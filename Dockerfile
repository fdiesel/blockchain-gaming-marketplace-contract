FROM node:18 as baseimage

RUN npm install --global truffle ganache


FROM baseimage as build

WORKDIR /contract
COPY . .
RUN npm ci
RUN chmod +x entrypoint.sh

EXPOSE 8545
ENTRYPOINT [ "./entrypoint.sh" ]
