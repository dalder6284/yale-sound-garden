# Yale Sound Garden
 A dynamic garden of sound at Yale created in Supercollider, changed by real-time location fetched via pyicloud.

## Introduction
Hello, I am very proud to present to you my final project for CPSC 432: A real life SynthDef garden. And I mean *real-life*. I was inspired by a web application we had seen in class about a garden of trees where, if a tree entered your radius, the tree would join the symphony of other trees in your vicinity with its own sound, creating a dynamic piece as you moved through-out the garden.

I thought, what if I were to track myself as I walked through out the campus, and whenever I entered the vicinity of some building, an ambient sound would play? And, depending on where you were on campus, a different set of sounds would play, creating a piece as you moved along different paths on campus.

## Setting up and running the program
Python and Supercollider are required. The python script requires [python-osc](https://python-osc.readthedocs.io/en/latest/) and [pyicloud](https://github.com/picklepete/pyicloud). Follow the instructions for `pyicloud` to get the location of your iPhone through the API. OSC communications are a bit tricker, but all you have to do is match the ports that Python sends and OSC receives. I've set up the default port that Supercollider uses in the Python script, so it should work out of the box, but there may be more tinkering you may have to do. Here's the [link](https://doc.sccode.org/Guides/OSC_communication.html) to Supercollider OSC page.

Run the python script and it should start sending the location at whatever interval you set. Then, execute the Supercollider excerpts in order to:
- boot the server and initialize the distance function.
- load the buffers
- load the synths
- load the dictionary
- load the OSC function

It's a Supercollider program, and since you're likely not running it on your iPhone, you'll have to somehow stream the sound of your computer to your iPhone to hear in real-time. There are a few example locations if you're not on campus or you don't feel like walking around at the bottom. To stop the OSC function, you should stop the Python script and free the OSC function along with freeing the synths. When re-running, make sure to reset the dictionary, too. Have fun!

## Yale Locations
Here's a map of the radii of each location on campus I mapped out:

![Yale Sound Garden Locations](/final_project_media/locations.png)

Here's a map of my final runthrough's path (or what the computer interpreted as my path...):

![Yale Sound Garden Locations](/final_project_media/final_path_taken.png)

Here's a [link](https://soundcloud.com/diego-alderete-361579088/yale-sound-garden?si=69f33df079df43faac65d293b2c2a7c5&utm_source=clipboard&utm_medium=text&utm_campaign=social_sharing) to the final product and here's a timeline of when and where I entered certain locations, with the recording starting at around 3:26:03:
<pre>
Entering Morse at 03:29:27
Leaving Stiles at 03:33:28
Leaving Morse at 03:33:28
Entering Sterling at 03:33:28
Entering HQ at 03:33:28
Entering Law at 03:35:29
Leaving Law at 03:37:30
Leaving HQ at 03:37:30
Entering Beinecke at 03:37:30
Entering Cross Campus at 03:37:30
Leaving Beinecke at 03:39:31
Entering Trumbull at 03:39:36
Leaving Sterling at 03:42:15
Leaving Trumbull at 03:42:15
Leaving Cross Campus at 03:42:15
Entering Berkeley at 03:42:25
Entering Cross Campus at 03:42:51
Entering Beinecke at 03:44:21
Leaving Berkeley at 03:44:21
Leaving Cross Campus at 03:44:42
Entering Law at 03:47:45
Leaving Beinecke at 03:47:45
Entering Cemetery at 03:47:45
Entering Sterling at 03:52:03
Leaving Law at 03:52:03
Leaving Cemetery at 03:52:03
Entering Stiles at 03:54:04
Entering Morse at 03:54:04
Leaving Sterling at 03:54:04
Leaving Morse at 03:55:28`
</pre>