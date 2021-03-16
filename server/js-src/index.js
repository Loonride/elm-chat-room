const url = require('url');
const uuid = require('uuid').v4;

const app = require('../elm-output/server').Elm.Server.init({
    flags: null,
});

const inputPort = app.ports.inputPort;
const outputPort = app.ports.outputPort;

outputPort.subscribe((cmd) => {
    console.log(cmd);
});

const obj = {
    dataType: 'connection',
    uuid: uuid(),
    data: '',
};

// const obj = {
//     type: 'disconnection',
//     id: 'abcd',
// };

inputPort.send(JSON.stringify(obj));
