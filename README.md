# Yale Sound Garden
 A dynamic garden of sound at Yale created in Supercollider, changed by real-time location fetched via pyicloud.

## Introduction
Hello, I am very proud to present to you my final project for CPSC 432: A real life SynthDef garden. And I mean *real-life*. I was inspired by a web application we had seen in class about a garden of trees where, if a tree entered your radius, the tree would join the symphony of other trees in your vicinity with its own sound, creating a dynamic piece as you moved through-out the garden.

I thought, what if I were to track myself as I walked through out the campus, and whenever I entered the vicinity of some building, an ambient sound would play? And, depending on where you were on campus, a different set of sounds would play, creating a piece as you moved along different paths on campus.

## Setting up and running the program
Python and Supercollider are required. The python script requires [python-osc](https://python-osc.readthedocs.io/en/latest/) and [pyicloud](https://github.com/picklepete/pyicloud). Follow the instructions for *pyicloud* to get the location of your iPhone through the API. OSC communications are a bit tricker, but all you have to do is match the ports that Python sends and OSC receives. I've set up the default port that Supercollider uses in the Python script, so it should work out of the box, but there may be more tinkering you may have to do. Here's the [link](https://doc.sccode.org/Guides/OSC_communication.html) to Supercollider OSC page.

Run the python script and it should start sending the location at whatever interval you set. Then, execute the Supercollider excerpts in order to:
- boot the server and initialize the distance function.
- load the buffers
- load the synths
- load the dictionary
- load the OSC function

There are a few example locations if you're not on campus or you don't feel like walking around at the bottom. To stop the OSC function, you should stop the Python script and free the OSC function along with freeing the synths. When re-running, make sure to reset the dictionary, too. Have fun!