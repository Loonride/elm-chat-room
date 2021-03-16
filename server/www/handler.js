const app = Elm.Client.Client.init({
    node: document.getElementById('elm'),
});

const ws = new WebSocket('ws://localhost:8000');

ws.onmessage = (msg) => {
    app.ports.inputPort.send(msg.data);
};

app.ports.outputPort.subscribe((s) => {
    ws.send(s);
});
