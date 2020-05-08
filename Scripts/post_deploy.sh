mkdir "${BUILT_PRODUCTS_DIR}/${TARGET_NAME}.app/Contents/libs"
cp -rf "Libs/ImageMagick" "${BUILT_PRODUCTS_DIR}/${TARGET_NAME}.app/Contents/libs"

cd "${BUILT_PRODUCTS_DIR}/${TARGET_NAME}.app/Contents"

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
cd ..

dylibbundler -of -b -x ./Frameworks/libmediainfo.0.dylib -d ./libs/
cd MacOS
install_name_tool -change /usr/local/opt/media-info/lib/libmediainfo.0.dylib @executable_path/../Frameworks/libmediainfo.0.dylib ContactSheetz
cd ../Frameworks
install_name_tool -id @executable_path/../Frameworks/libmediainfo.0.dylib libmediainfo.0.dylib
cd ..


install_name_tool -change /usr/local/opt/imagemagick/lib/libMagickWand-7.Q16HDRI.7.dylib @executable_path/../libs/ImageMagick/lib/libMagickWand-7.Q16HDRI.7.dylib MacOS/ContactSheetz
install_name_tool -id @executable_path/../libs/ImageMagick/lib/libMagickWand-7.Q16HDRI.7.dylib libs/ImageMagick/lib/libMagickWand-7.Q16HDRI.dylib
install_name_tool -change /ImageMagick-7.0.10/lib/libMagickCore-7.Q16HDRI.7.dylib @executable_path/../libs/ImageMagick/lib/libMagickCore-7.Q16HDRI.dylib libs/ImageMagick/lib/libMagickWand-7.Q16HDRI.dylib
install_name_tool -id @executable_path/../libs/MagickWand/lib/libMagickCore-7.Q16HDRI.7.dylib libs/ImageMagick/lib/libMagickCore-7.Q16HDRI.dylib