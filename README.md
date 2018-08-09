## User Guide

The final app allows a user to interact with their current world via augmented reality.
It is implemented using Apple’s ARKit library for iOS devices. The app functions
best outside because it uses GPS services. To use the app, start it and wait for
the first screen to disappear once heading accuracy has improved or bypass via
the button. The augmented reality screen starts next. Wait for the status bar
in the bottom left to turn all green. Waypoints can be placed via a double tap
in the world. A 45 second timer can be started via the start button to challenge
a user to collected as many waypoints as possible in the time limit. This
functionality can be reset via the reset button. Default waypoint types are
shown and editable in the default settings screen accessed via a left swipe. All
waypoints in the scene can be seen in the list view accessed via a right swipe.
Waypoints in this list can be edited with different options shown if you swipe left
on them individually. Waypoints can be saved and loaded via the screen
accessible by an up swipe. They are saved according to their current latitude and
longitude. Precision is affected by current heading accuracy and location
accuracy. Using the set thresholds, the error radius is approximately 18 meters.


## Screens

### Heading accuracy screen
- Displays current true north heading accuracy and allowable threshold
- Allows user to tap button to bypass to app if threshold is not reached

<table><tr><td>
<img src="https://raw.githubusercontent.com/rayweiss/ARKit/master/images/image001.png" width="300">
</td></tr></table>


### Main screen
- Displays main AR functionality
- Allows placement of waypoints via double tap
- Allows collection timer to be started and reset via bottom buttons
- Displays 3D arrow pointing to next waypoint in AR scene
- Displays distance from current waypoint in top left label
- Displays time left and number of waypoints collected in top right label
- Displays AR settings in bottom bar
- Allows navigation to all other screens via swipes

<table><tr><td>
<img src="https://raw.githubusercontent.com/rayweiss/ARKit/master/images/image003.png" width="300">
</td></tr></table>


### Default settings screen
- Accessed via left swipe from main screen
- Allows choice of waypoint object type to be placed via picker
- Allows choice of waypoint color to be placed via picker
- Allows choice of size of waypoint to be placed via slider
- Allows toggling of gravity feature via switch

<table><tr><td>
<img src="https://raw.githubusercontent.com/rayweiss/ARKit/master/images/image005.png" width="300">
</td></tr></table>


### Save / Load screen
- Accessed via up swipe from main screen
- Displays current location accuracy
- Displays location accuracy threshold required for saving and loading
- Save button saves waypoints currently placed in scene
- Load button loads waypoints saved on device

<table><tr><td>
<img src="https://raw.githubusercontent.com/rayweiss/ARKit/master/images/image007.png" width="300">
</td></tr></table>


### Waypoints list screen
- Accessed via right swipe from main screen
- Displays all waypoints placed in scene and order
- Waypoints can be selected by tap from this screen
- Swiping left on individual waypoint in list displays editing options
- Edit options are delete, edit, and rename

<table><tr>
<td><img src="https://raw.githubusercontent.com/rayweiss/ARKit/master/images/image009.png" width="300"></td>
<td><img src="https://raw.githubusercontent.com/rayweiss/ARKit/master/images/image011.png" width="300"></td>
</tr></table>


### Edit waypoint screen
- Accessed via edit option button from individual waypoint in list
- Displays name of current waypoint to be edited
- Allows changing of object type via picker
- Allows changing of object color via picker
- Allows changing of object size via slider

<table><tr><td>
<img src="https://raw.githubusercontent.com/rayweiss/ARKit/master/images/image013.png" width="300">
</td></tr></table>
