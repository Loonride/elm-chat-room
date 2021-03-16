const app = Elm.Client.Client.init({
    node: document.getElementById('elm'),
});

app.ports.sendMessage.subscribe(function (str) {
    console.log(str);
});

app.ports.receiveMessage.send('wassup');
