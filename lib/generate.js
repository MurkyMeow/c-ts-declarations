const fs = require('fs')

const { Elm } = require('../src/Worker.elm')

/**
 * 
 * @param {{ input: string[]; out: string }} param0
 */
function generate({ input, out }) {
  const app = Elm.Worker.init()

  // clear the output file
  fs.writeFileSync(out, '')

  app.ports.sendMessage.subscribe(msg => {
    fs.appendFileSync(out, `${msg}\n`)
  })

  for (const path of input) {
    const content = fs.readFileSync(path).toString()
    app.ports.messageReceiver.send(content)
  }
}

module.exports = generate
