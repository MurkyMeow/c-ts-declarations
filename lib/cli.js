const meow = require('meow')

const generate = require('./generate')

const ARG_OUT = 'out'
const ARG_IN = 'input'

const cli = meow(`
  Usage
    $ c-ts-declarations --${ARG_IN} <input1> --${ARG_IN} <input2> --${ARG_OUT} <output>

  Options
    ${ARG_IN}, -i  List of .h files
    ${ARG_OUT}, -o  Output file
`, {
  flags: {
    [ARG_IN]: {
      alias: 'i',
      type: 'string',
      isRequired: true,
      isMultiple: true,
    },
    [ARG_OUT]: {
      alias: 'o',
      type: 'string',
      isRequired: true,
    },
  },
})

generate(cli.flags)
