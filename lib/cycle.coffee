randInt = (min, max) ->
  Math.floor(Math.random() * (max - min)) + min

module.exports = (cycleArray) ->
  current = randInt(0, cycleArray.length - 1)
  return ->
    retIndex = current
    current = (current + 1) % cycleArray.length
    return cycleArray[retIndex]