# Contact Sheetz
## Your Mac OS X video thumbnailer

This is a Mac app developed to generate contact sheets from videos. It uses the FFMpeg and ImageMagick C APIs to perform most of its operations, and is built on top of the Cocoa framework.

For bundling...

Go to Contents folder
mkdir libs

<!-- First fix MagickWand -->
dylibbundler -of -b -x ./Frameworks/libMagickWand-7.Q16HDRI.7.dylib -d ./libs/
cd MacOS
install_name_tool -change /usr/local/opt/imagemagick/lib/libMagickWand-7.Q16HDRI.7.dylib @executable_path/../Frameworks/libMagickWand-7.Q16HDRI.7.dylib ContactSheetz
cd ../Frameworks
install_name_tool -id @executable_path/../Frameworks/libMagickWand-7.Q16HDRI.7.dylib libMagickWand-7.Q16HDRI.7.dylib

<!-- Now fix ffmpeg libs -->
dylibbundler -of -b -x ./Frameworks/libavcodec.58.54.100.dylib -d ./libs/
dylibbundler -of -b -x ./Frameworks/libavformat.58.29.100.dylib -d ./libs/
dylibbundler -of -b -x ./Frameworks/libavutil.56.31.100.dylib -d ./libs/
dylibbundler -of -b -x ./Frameworks/libswscale.5.5.100.dylib -d ./libs/
cd MacOS
install_name_tool -change /usr/local/opt/ffmpeg/lib/libavcodec.58.dylib @executable_path/../Frameworks/libavcodec.58.54.100.dylib ContactSheetz
install_name_tool -change /usr/local/opt/ffmpeg/lib/libavformat.58.dylib @executable_path/../Frameworks/libavformat.58.29.100.dylib ContactSheetz
install_name_tool -change /usr/local/opt/ffmpeg/lib/libavutil.56.dylib @executable_path/../Frameworks/libavutil.56.31.100.dylib ContactSheetz
install_name_tool -change /usr/local/opt/ffmpeg/lib/libswscale.5.dylib @executable_path/../Frameworks/libswscale.5.5.100.dylib ContactSheetz
cd ../Frameworks
install_name_tool -id @executable_path/../Frameworks/libavcodec.58.54.100.dylib libavcodec.58.54.100.dylib
install_name_tool -id @executable_path/../Frameworks/libavformat.58.29.100.dylib libavformat.58.29.100.dylib
install_name_tool -id @executable_path/../Frameworks/libavutil.56.31.100.dylib libavutil.56.31.100.dylib
install_name_tool -id @executable_path/../Frameworks/libswscale.5.5.100.dylib libswscale.5.5.100.dylib

<!-- Finally fix MediaInfo lib -->
dylibbundler -of -b -x ./Frameworks/libmediainfo.0.dylib -d ./libs/
cd MacOS
install_name_tool -change /usr/local/opt/media-info/lib/libmediainfo.0.dylib @executable_path/../Frameworks/libmediainfo.0.dylib ContactSheetz
cd ../Frameworks
install_name_tool -id @executable_path/../Frameworks/libmediainfo.0.dylib libmediainfo.0.dylib

<!-- dylibbundler -od -b -x ./ContactSheetz.app/Contents/MacOS/ContactSheetz -d ./ContactSheetz.app/Contents/libs/ -i /usr/lib/swift
install_name_tool -add_rpath /usr/lib/swift/ ./ContactSheetz.app/Contents/MacOS/ContactSheetz -->

<!-- rm ./ContactSheetz.app/Contents/libs/libavcodec*
rm ./ContactSheetz.app/Contents/libs/libavformat*
rm ./ContactSheetz.app/Contents/libs/libavutil*
rm ./ContactSheetz.app/Contents/libs/libswscale*
rm ./ContactSheetz.app/Contents/libs/libMagick* -->


#### Get more information [here](http://contactsheetz.ca/)
#### Report any issues [here](https://github.com/hicklin-james/contact-sheetz/issues)
