grunt-polymer-nodewebkit-example
================================

Demo project using grunt to build polymer + node-webkit apps


building a release
------------------
Various builds targets (browser, desktop, standalone or integration) are available ,
but it is advised to only build the specific version you require as some of these can
take a bit of time to generate.

Once a build is complete, you will find the resulting files in the build/target-subtarget 
folder : for example: **build/browser-integration** or **build/desktop-standalone** etc

To build the example component for **integration** into a website:

    $ grunt build:browser:integration

To build it **standalone** for usage in the browser using the provided demo index.html

    $ grunt build:browser:standalone

Some optional build flags are also available
 - --minify


Notes:
------
- there seem to be some issues in the custom lifecycle callbacks when using polymer with some of the latests versions of node-webkit 
