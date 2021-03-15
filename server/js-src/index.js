const url = require('url');
const uuid = require('uuid').v4;

const app = require('../elm-output/server').Elm.Server.init({
    flags: null,
});

function Location(nodeUrl = 'https://google.com') {
    parsedUrl = url.parse(nodeUrl);
    return {
        protocol: parsedUrl.protocol,
        hash: parsedUrl.hash || '',
        search: parsedUrl.search || '',
        pathname: parsedUrl.pathname,
        port_: parsedUrl.port || '',
        hostname: parsedUrl.hostname,
        host: parsedUrl.host,
        origin: parsedUrl.protocol + '//' + parsedUrl.host,
        href: parsedUrl.href,
        username: '', // temp
        password: '' // temp
    };
}



function Connection(id, location) {
    return {
        type: 'Connection',
        id: id,
        location: location
    };
};



function Disconnection(id, location) {
    return {
        type: 'Disconnection',
        id: id,
        location: location
    };
};



function Message(id, location, message) {
    return {
        type: 'Message',
        id: id,
        location: location,
        message: message
    };
};

const inputPort = app.ports.inputPort;
const outputPort = app.ports.outputPort;

outputPort.subscribe((cmd) => {
    console.log(cmd);
});

// app.ports.inputPort.send(Connection(uuid(), Location()));
const obj = ["req","sent",{"sent": "abc"}];
const msg = Message(uuid(), Location(), JSON.stringify(obj));
inputPort.send(msg);
