

Thank you for your interest in quince!


If you are interested in developing plug-ins for quince or if you even want to help make quince better, 
the following text will give you a quick overview about what is in this package.

If you just want to check out what quince is and what it does,  you may want to download the latest binary 
release from the quince website at http://quince.maximilianmarcoll.de .

In any case, if you have any questions, please write to quince@maximilianmarcoll.de

Please note that quince is released under the GPL.
You should have received a copy of the GPL along with this package.
If not, go to http://www.gnu.org/licenses/gpl.html

THANK YOU VERY MUCH!!

max



DEVELOPING NEW PLUG-INS FOR QUINCE

If you want to develop your own custom plug-ins for quince, 
please read the chapter "Developing Plug-Ins for quince" in the quince UserGuide.

You don't actually need this source package to develop your own plug-ins. 
However, the sources of the plug-ins contained in this package may be of some help.
You can find the sources for the Plug-Ins in the folder called "bundles".
There are subdirectories for ChildView-, ContainerView, Function- and Player-Plug-Ins.



DEVELOPING QUINCE

From a developer's perspective, quince consists of three parts: the core, the api and plug-ins .
Correspondingly you will find three directories in this package, called "QuinceCore", QuinceApi" and "bundles" (containing the sources for the plug-ins).

The QuinceCore-directory contains all sources that build the basic application, no functionality apart from very fundamental behaviour is implemented in these files. The QuinceApi-directory contains the sources necessary to build the QuinceApi.framework. The QuinceApi.framework is what one needs to link against to build plug-ins. The QuinceApi contains all the classes one has to communicate with when developing plug-ins, as well as abstract superclasses to build plug-ins of different types. Finally, the bundles directory contains the sources of all the plug-ins that come with quince.

There is only one Xcode project for quince. It has multiple targets for quince itself, the api and all the plug-ins.
The build settings are set up in a way that everything that is built  is put into place automatically (bundles into /Library/Application Support/quince, the QuinceApi into /Library/Frameworks) except for the quince application itself. It remains in the build directory until you move it. You do not however have to move it to the Applications folder or any other place for the app to work. 

