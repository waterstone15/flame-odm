class FlameError extends Error
  constructor: (message) ->
    (super message)
    @.name = "FlameError"
    return

module.exports = FlameError
