# Rain

*Rain* is a little game about a little guy that is running around his little planet trying to dodge rain and also meteoroids. Every time a drop hits the planet or a meteoroid leaves the screen, the player is awarded a point. The game is over if the little guy gets hit even once.

The little guy is controlled using [paddle controls](https://en.wikipedia.org/wiki/Paddle_(game_controller)). By default, the [Stella emulator](https://stella-emu.github.io/) uses mouse movements to emulate that input. This can be a bit imprecise, but it gets the job done!

Unfortunately, a limitation of the paddle controller is that it cannot be spun around indefinitely. This means the little guy cannot go 'round and 'round his planet. He can move clockwise from the top-left corner of his planet until he reaches that corner again. From there, he must move counter-clockwise to get back to the top side.

To play, simply download the binary from Releases, and run it in your preferred emulator.