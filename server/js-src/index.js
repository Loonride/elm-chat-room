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

// app.ports.inputPort.send(Connection(uuid(), Location()));
const obj = ["req","add",{"x":1,"y":2}];
const msg = Message(uuid(), Location(), JSON.stringify(obj));
console.log(msg);
app.ports.inputPort.send(msg);
