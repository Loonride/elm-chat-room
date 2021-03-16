const app = Elm.Client.Client.init({
    node: document.getElementById('elm'),
});

app.ports.outputPort.subscribe(function (str) {
    console.log(str);
});

// app.ports.inputPort.send();
