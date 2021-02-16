const { Elm } = require('../src/Worker.elm')

const app = Elm.Worker.init()

app.ports.sendMessage.subscribe(message => {
  console.log(message)
})

app.ports.messageReceiver.send('struct mystruct;\nstring myfunc(int foo, string bar);')
