const http = require('http');
const path = require('path');
const uuid = require('uuid').v4;
const express = require('express');
const WebSocket = require('ws');

const elmApp = require('../elm-output/server').Elm.Server.init({
    flags: null,
});

const app = express();
const port = process.env.PORT || 8000;
app.use(express.static(path.resolve(__dirname, '../www')));
const server = http.createServer(app);

const wss = new WebSocket.Server({
    server,
});

const inputPort = elmApp.ports.inputPort;
const outputPort = elmApp.ports.outputPort;

const sendConnection = (id) => {
    const obj = {
        dataType: 'connection',
        uuid: id,
        data: '',
    };
    inputPort.send(JSON.stringify(obj));
};

const sendDisconnection = (id) => {
    const obj = {
        dataType: 'disconnection',
        uuid: id,
        data: '',
    };
    inputPort.send(JSON.stringify(obj));
};

const users = {};

wss.on('connection', (ws) => {
    const id = uuid();
    users[id] = ws;
    sendConnection(id);

    ws.on('message', (msg) => {
        try {
            const data = JSON.parse(msg);
            // this is a simple security measure to make sure a user
            // doesn't try to maliciously send false connect/disconnect messages
            if (data.dataType === 'connection' || data.dataType === 'disconnection') {
                return;
            }

            // set the uuid to the user's id
            data.uuid = id;
            inputPort.send(JSON.stringify(data));
        } catch (e) {

        }
    });

    ws.on('close', () => {
        delete users[id];
        sendDisconnection(id);
    });
});

outputPort.subscribe((s) => {
    Object.keys(users).forEach(key => {
        const ws = users[key];
        ws.send(s);
    });
});

server.listen(port, () => {
    console.log(`App listening at http://localhost:${port}`);
});
