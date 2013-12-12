ImageConvert
============

Extremely simple image conversion CLI tool for OS X.

Example usage
```
imageconvert 1.0 image.tiff image.jpg
imageconvert 0.5 image.psd image.png
```

Why?
=

This was a tool made to scratch an itch that I had for the past couple years. Namely, to convert .psd files into .png files while rescaling them. This is terribly useful as a build rule in Xcode for iOS projects, so I also included the companion 'retinaconvert' Ruby script to go along with it.

![xcode-build-rule](http://files.slembcke.net/upshot/upshot_lOAjEJw0.png)

The build rule will convert any .psd files added to the target into an `image.png` and `image-hd.png` file automagically. ('-hd' is a Cocos2D suffix similar to UIKit's '@2x' suffix)

Since it's so basic, you don't get the option to pass compression settings to lossy formats (such as JPEG). It simply uses the ImageIO defaults.
