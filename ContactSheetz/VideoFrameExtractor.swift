//
//  VideoFrameExtractor.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-10-01.
//  Copyright (c) 2016 James Hicklin. All rights reserved.
//


import Cocoa

class VideoFrameExtractor: NSObject {
    
    let duration: Double
    let numFrames: Int
    var pFormatCtx:UnsafeMutablePointer<AVFormatContext>?
    let videoStreamIndex:Int
    let filePath: String
    var decoder:UnsafeMutablePointer<AVCodec>?
    
    init?(filePath: String, _numFrames: Int) {
        self.filePath = filePath
        av_register_all()
        
        numFrames = _numFrames
        
        //av_register_all()
        
        // set input path to ascii encoded string C string for ffmpeg
        guard let address = filePath.cString(using: String.Encoding(rawValue: String.Encoding.ascii.rawValue)) else {
            NSLog("Unable to initialize file path - check that file exists")
            return nil
        }
        
        // open the path
        guard(avformat_open_input(&pFormatCtx, address, nil, nil) >= 0) else {
            NSLog("Error opening input")
            return nil
        }
        
        // populate pFormatCtx->streams
        guard avformat_find_stream_info(pFormatCtx, nil) >= 0 else {
            NSLog("Unable to populate streams")
            return nil
        }
        
        // find the video stream and set the decoder
        // we could do this manually but this probably works better
        videoStreamIndex = Int(av_find_best_stream(pFormatCtx, AVMEDIA_TYPE_VIDEO, Int32(-1), Int32(-1), &decoder, 0))
        
        // set the video duration in seconds
        let vidDuration = Double(pFormatCtx!.pointee.duration)
        //let timeBase = params.
        duration = vidDuration / Double(AV_TIME_BASE)
    }
    
    deinit {
        avformat_close_input(&pFormatCtx)
    }
    
    static func checkVideoFile(filePath: String) -> Bool {
        av_register_all()
        var formatCtx:UnsafeMutablePointer<AVFormatContext>?
        var decoderTemp:UnsafeMutablePointer<AVCodec>?
        
        guard avformat_open_input(&formatCtx, filePath, nil, nil) >= 0 else {
            NSLog("Couldn't open file - probably not a media file")
            return false
        }
        /**
        let streams = formatCtx!.pointee.streams
        NSLog("Number of streams: ")
        NSLog(String(describing: formatCtx!.pointee.nb_streams))
        for i in 0..<formatCtx!.pointee.nb_streams {
            let stream = streams?[Int(i)]
            NSLog("Stream type: ")
            NSLog(String(describing: stream!.pointee.stream_identifier))
        }
        **/
        
        let videoStream = av_find_best_stream(formatCtx, AVMEDIA_TYPE_VIDEO, Int32(-1), Int32(-1), &decoderTemp, 0)
        //NSLog(String(describing: videoStream))
        guard videoStream >= 0 else {
            NSLog("File has no video track")
            return false
        }
        // Now we have whiddled the options down to image and video files - we still need some way
        // to determine whether the file is a video file or not!
        avformat_close_input(&formatCtx)
        return true
    }
    
    
    func generateFrames() -> [FrameWrapper]? {
        // lets start by declaring all the variables that need to be freed
        var usablePFormatCtx: UnsafeMutablePointer<AVFormatContext>?
        //var srcParams: UnsafeMutablePointer<AVCodecParameters>?
        var dstParams: UnsafeMutablePointer<AVCodecParameters>?
        var usableCtx: UnsafeMutablePointer<AVCodecContext>?
        var swsContext: OpaquePointer?
        var pFrame: UnsafeMutablePointer<AVFrame>?
        var pFrameRgb: UnsafeMutablePointer<AVFrame>?
        var packet: UnsafeMutablePointer<AVPacket>?
        
        defer {
            // do any cleanup code here
            // IMPORTANT - this will be called if something goes wrong, so
            // it is not safe to assume that everything is already allocatedx
            if let _pFrame = pFrame {
                //av_free(pFrame!.pointee.data.0)
                av_frame_unref(pFrame)
                av_frame_free(&pFrame)
            }
            if let _pFrameRgb = pFrameRgb {
                av_freep(&pFrameRgb!.pointee.data.0)
                av_frame_unref(pFrameRgb)
                av_frame_free(&pFrameRgb)
            }
            if let _packet = packet {
                av_packet_free(&packet)
            }
            if let _dstParams = dstParams {
                avcodec_parameters_free(&dstParams)
            }
            if let _swsContext = swsContext {
                sws_freeContext(swsContext)
            }
            if let _usableCtx = usableCtx {
                avcodec_close(usableCtx)
                avcodec_free_context(&usableCtx)
            }
        }
        // We first initialize everything we need - these are protected by guards so that if 
        // anything fails we can log it, dealloc anything that was allocated, and return nil
        usablePFormatCtx = pFormatCtx
        guard usablePFormatCtx != nil, let streams = usablePFormatCtx!.pointee.streams else {
            NSLog("Unable to get codec context from streams")
            return nil
        }
        
        guard let origAvStream = streams[videoStreamIndex] else {
            NSLog("Couldnt get original stream")
            return nil
        }
        
        usableCtx = avcodec_alloc_context3(decoder)
        guard usableCtx != nil else {
            //cleanup(srcFrame: nil, dstFrame: nil, swsContext: nil, ctx: nil, origCtx: nil)
            NSLog("No usable context")
            return nil
        }
        
        //srcParams = avcodec_parameters_alloc()
        dstParams = avcodec_parameters_alloc()
        
        guard dstParams != nil else {
            NSLog("AVCodecParameters failed to initialize")
            return nil
        }
        
        guard avcodec_parameters_copy(dstParams, origAvStream.pointee.codecpar) >= 0 else {
            NSLog("Failed to copy orig parameters to new parameters")
            return nil
        }
        
        guard avcodec_parameters_to_context(usableCtx, dstParams) >= 0 else {
            NSLog("Failed to copy parameters to usable ctx")
            return nil
        }
        
        usableCtx!.pointee.time_base = av_stream_get_codec_timebase(origAvStream)
        usableCtx!.pointee.refcounted_frames = 1
        
        guard avcodec_open2(usableCtx!, decoder, nil) >= 0 else {
            //cleanup(srcFrame: nil, dstFrame: nil, swsContext: nil, ctx: usableCtx, origCtx: nil)
            NSLog("Unable to open codec context")
            return nil
        }
        
        swsContext = sws_getContext(usableCtx!.pointee.width, usableCtx!.pointee.height, usableCtx!.pointee.pix_fmt, usableCtx!.pointee.width, usableCtx!.pointee.height, AV_PIX_FMT_RGB24, SWS_BILINEAR, nil, nil, nil)
        guard swsContext != nil else {
            //cleanup(srcFrame: nil, dstFrame: nil, swsContext: nil, ctx: usableCtx, origCtx: nil)
            NSLog("swsContext not initialized properly. Quitting.")
            return nil
        }
        
        // initialize AVFrames to use
        pFrame = av_frame_alloc()
        pFrameRgb = av_frame_alloc()
        
        guard pFrameRgb != nil else {
            NSLog("Frames not initialized properly")
            return nil
        }
        
        initFrame(pFrame: &pFrameRgb!, width: usableCtx!.pointee.width, height: usableCtx!.pointee.height)
        
        // init a few variables to use within the loop
        var ind = 0
        packet = av_packet_alloc() //AVPacket()
        guard packet != nil else {
            NSLog("Packet not initialized properly")
            return nil
        }

        let tp = Double(AV_TIME_BASE) * 10.0 // 10.0
        
        let timeBetweenFrames = (Int64(Double(AV_TIME_BASE) * duration) - pFormatCtx!.pointee.start_time - Int64(tp)) / Int64(numFrames)
        
        var seekPos = Int64(tp)
        var tempSeekPos = Int64(tp)
        // seek to first frame we want to grab
        let flag = AVSEEK_FLAG_FRAME
        avformat_seek_file(pFormatCtx, -1, 0, Int64(seekPos), Int64.max, flag)
        avcodec_flush_buffers(usableCtx)
        var last_ts: String? = nil
        var images:[FrameWrapper] = []
        
        // while we haven't reached max frames
        while ind < numFrames {
            // read the current frame
            packet = av_packet_alloc()
            let rfe = av_read_frame(pFormatCtx, &packet!.pointee)
            if rfe != 0 {
                NSLog("Error reading frame")
                av_packet_free(&packet)
                continue
            }
            // if the stream index is the right index
            if Int(packet!.pointee.stream_index) == videoStreamIndex {
                // decode the frame into raw data - save that raw data in pFrame->data
                avcodec_send_packet(usableCtx, &packet!.pointee)
                let f = avcodec_receive_frame(usableCtx, pFrame)

                if f == -541478725 {
                    // EOF reached
                    NSLog("Reached end of file")
                    break
                }
                // if the frame has finished decoding, we can process it
                if f == 0 {
                    // scale the frame from pFrame into pFrameRgb
                    scaleFrame(srcFrame: pFrame!, dstFrame: pFrameRgb!, ctx: swsContext!)
                    // find the png encoder
                    guard let outCodec = avcodec_find_encoder(AV_CODEC_ID_PNG), var usablePngCtx: UnsafeMutablePointer<AVCodecContext>?  = avcodec_alloc_context3(outCodec) else {
                        NSLog("Unable to get PNG codex and context")
                        return nil
                    }
                    // set the needed parameters on the png encoder context
                    setPngContextParams(pngCtx: &usablePngCtx!, videoCtx: &usableCtx!)
                    
                    // open the png codec
                    guard avcodec_open2(usablePngCtx, outCodec, nil) >= 0 else {
                        avcodec_close(usablePngCtx)
                        NSLog("Unable to open png codec")
                        return nil
                    }
                
                    var pngPacket = av_packet_alloc()
                    avcodec_send_frame(usablePngCtx, pFrameRgb)
                    let gotPacket = avcodec_receive_packet(usablePngCtx, &pngPacket!.pointee)
                    
                    guard gotPacket == 0 else {
                        NSLog("Couldn't encode video to PNG")
                        avcodec_close(usablePngCtx)
                        return nil
                    }
                    
                    let image = NSImage.init(data: Data.init(bytes: pngPacket!.pointee.data, count: Int(pngPacket!.pointee.size)))
                    
                    av_packet_free(&pngPacket)
                    
                    guard let _image = image else {
                        NSLog("NSImage failed to initialize")
                        avcodec_close(usablePngCtx)
                        return nil
                    }
                    
                    var seconds = Double(packet!.pointee.pts) * (Double(origAvStream.pointee.time_base.num) / Double(origAvStream.pointee.time_base.den))
                    seconds.round()
                    let roundedSeconds = Int(seconds)
                    let hms = secondsToHoursMinutesSeconds(seconds: roundedSeconds)
                    let timestamp = createSimplifiedVidDurationString(dur: hms)
                    let frameWrapper = FrameWrapper.init(_image: _image, _timestamp: timestamp)
                    
                    images.append(frameWrapper)
                    
                    seekPos = (seekPos + timeBetweenFrames)
                    tempSeekPos = seekPos
                    avformat_seek_file(pFormatCtx, -1, 0, Int64(seekPos), Int64.max, flag)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationKeys.VideoFrameGenerated), object: self, userInfo: nil)
                    
                    ind = ind + 1
                        
                    last_ts = timestamp
                    avcodec_flush_buffers(usableCtx)
                    
                    avcodec_close(usablePngCtx)
                    avcodec_free_context(&usablePngCtx)
                }
            }
            av_packet_free(&packet)
        }
        
        return images
        
    }
    func getVideoInformation() -> [String: AnyObject?]? {
        var usableCtx: UnsafeMutablePointer<AVCodecContext>?
        var dstParams: UnsafeMutablePointer<AVCodecParameters>?
        var info = [String: AnyObject]()
        if let usablePFormatCtx = pFormatCtx, let streams = usablePFormatCtx.pointee.streams {
            guard let origAvStream = streams[videoStreamIndex] else {
                NSLog("Couldnt get original stream")
                return nil
            }
            
            usableCtx = avcodec_alloc_context3(decoder)
            guard usableCtx != nil else {
                return nil
            }
            
            defer {
                avcodec_parameters_free(&dstParams)
                avcodec_close(usableCtx)
                avcodec_free_context(&usableCtx)
            }
            
            dstParams = avcodec_parameters_alloc()
            
            guard dstParams != nil else {
                NSLog("AVCodecParameters failed to initialize")
                return nil
            }
            
            av_stream_get_codec_timebase(origAvStream)
            
            guard avcodec_parameters_copy(dstParams, origAvStream.pointee.codecpar) >= 0 else {
                NSLog("Failed to copy orig parameters to new parameters")
                return nil
            }
            
            guard avcodec_parameters_to_context(usableCtx, dstParams) >= 0 else {
                NSLog("Failed to copy parameters to usable ctx")
                return nil
            }
            
            usableCtx!.pointee.time_base = av_stream_get_codec_timebase(origAvStream)
            
            guard avcodec_open2(usableCtx, decoder, nil) >= 0 else {
                return nil
            }
            
            let width = Int(usableCtx!.pointee.width)
            let height = Int(usableCtx!.pointee.height)
            let resolutionString = String(width) + "x" + String(height)
            info["resolution"] = resolutionString as AnyObject
            info["width"] = width as AnyObject
            info["height"] = height as AnyObject
            //NSLog(resolutionString)
            
            let codecName = String.init(cString: usableCtx!.pointee.codec.pointee.name)
            info["codec"] = codecName as AnyObject
            //NSLog(codecName)
            
            let vidDuration = secondsToHoursMinutesSeconds(seconds: Int(duration))
            let durationString = createVidDurationString(dur: vidDuration)
            
            info["duration"] = durationString as AnyObject
            
            let bits = usablePFormatCtx.pointee.bit_rate
            let mbps = Double(bits) / 1000000.0
            info["bitrate"] = (String(format: "%.2f", mbps) + "Mbps") as AnyObject
            
            //var filesize: UInt64 = 1
            
            do {
                let attr = try FileManager.default.attributesOfItem(atPath: filePath)
                let filesize: Int64 = attr[FileAttributeKey.size] as! Int64
                let stringifiedBytes = ByteCountFormatter.string(fromByteCount: filesize, countStyle: ByteCountFormatter.CountStyle.binary)
                info["size"] = stringifiedBytes as AnyObject
            } catch {
                NSLog("An error ccured getting the file size")
            }
            //let vidSize = usablePFormatCtx.pointee.
            //NSLog(durationString)
            //let resolutionString = String(width) + "x" + String(height) + "px"
            return info
        }
        return nil
    }
    
    private
    
    func createSimplifiedVidDurationString(dur: (Int, Int, Int)) -> String {
        var durationString = ""
        durationString = durationString + String(format: "%02d", dur.0)
        durationString = durationString + ":"
        durationString = durationString + String(format: "%02d", dur.1)
        durationString = durationString + ":"
        durationString = durationString + String(format: "%02d", dur.2)
        return durationString
    }
    
    func createVidDurationString(dur: (Int, Int, Int)) -> String {
        var durationString = ""
        if (dur.0 > 1) {
            durationString = durationString + String(dur.0) + " hours, "
        } else if (dur.0 == 1) {
            durationString = durationString + String(dur.0) + " hour, "
        }
        
        if (dur.1 > 1) {
            durationString = durationString + String(dur.1) + " minutes, "
        } else if (dur.1 == 1) {
            durationString = durationString + String(dur.1) + " minute, "
        }
        
        if (dur.2 > 1) {
            durationString = durationString + String(dur.2) + " seconds "
        } else if (dur.2 == 1) {
            durationString = durationString + String(dur.2) + " second "
        }
        
        return durationString
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func initFrame(pFrame: inout UnsafeMutablePointer<AVFrame>, width: Int32, height: Int32) {
        pFrame.pointee.width = width
        pFrame.pointee.height = height
        pFrame.pointee.format = AV_PIX_FMT_RGB24.rawValue
        
        av_image_alloc(&pFrame.pointee.data.0, &pFrame.pointee.linesize.0, pFrame.pointee.width, pFrame.pointee.height, AV_PIX_FMT_RGB24, 32)
    }
    
    func scaleFrame(srcFrame: UnsafeMutablePointer<AVFrame>, dstFrame: UnsafeMutablePointer<AVFrame>, ctx: OpaquePointer) {
        var sourceData = [UnsafePointer<UInt8>(srcFrame.pointee.data.0)]
        sourceData.append(UnsafePointer<UInt8>(srcFrame.pointee.data.1))
        sourceData.append(UnsafePointer<UInt8>(srcFrame.pointee.data.2))
        sourceData.append(UnsafePointer<UInt8>(srcFrame.pointee.data.3))
        sourceData.append(UnsafePointer<UInt8>(srcFrame.pointee.data.4))
        sourceData.append(UnsafePointer<UInt8>(srcFrame.pointee.data.5))
        sourceData.append(UnsafePointer<UInt8>(srcFrame.pointee.data.6))
        sourceData.append(UnsafePointer<UInt8>(srcFrame.pointee.data.7))
        
        var sourceLineSize = [srcFrame.pointee.linesize.0]
        sourceLineSize.append(srcFrame.pointee.linesize.1)
        sourceLineSize.append(srcFrame.pointee.linesize.2)
        sourceLineSize.append(srcFrame.pointee.linesize.3)
        sourceLineSize.append(srcFrame.pointee.linesize.4)
        sourceLineSize.append(srcFrame.pointee.linesize.5)
        sourceLineSize.append(srcFrame.pointee.linesize.6)
        sourceLineSize.append(srcFrame.pointee.linesize.7)
        
        var targetLineSize = [dstFrame.pointee.linesize.0]
        targetLineSize.append(dstFrame.pointee.linesize.1)
        targetLineSize.append(dstFrame.pointee.linesize.2)
        targetLineSize.append(dstFrame.pointee.linesize.3)
        targetLineSize.append(dstFrame.pointee.linesize.4)
        targetLineSize.append(dstFrame.pointee.linesize.5)
        targetLineSize.append(dstFrame.pointee.linesize.6)
        targetLineSize.append(dstFrame.pointee.linesize.7)
        
        var targetData = [dstFrame.pointee.data.0]
        targetData.append(dstFrame.pointee.data.1)
        targetData.append(dstFrame.pointee.data.2)
        targetData.append(dstFrame.pointee.data.3)
        targetData.append(dstFrame.pointee.data.4)
        targetData.append(dstFrame.pointee.data.5)
        targetData.append(dstFrame.pointee.data.6)
        targetData.append(dstFrame.pointee.data.7)
        
        sws_scale(ctx, sourceData, sourceLineSize, 0, srcFrame.pointee.height, targetData, targetLineSize)
    }
    
    func setPngContextParams(pngCtx: inout UnsafeMutablePointer<AVCodecContext>, videoCtx: inout UnsafeMutablePointer<AVCodecContext>) {
        pngCtx.pointee.bit_rate = videoCtx.pointee.bit_rate
        pngCtx.pointee.width = videoCtx.pointee.width
        pngCtx.pointee.height = videoCtx.pointee.height
        pngCtx.pointee.pix_fmt = AV_PIX_FMT_RGB24
        pngCtx.pointee.codec_type = AVMEDIA_TYPE_VIDEO
        pngCtx.pointee.time_base.num = videoCtx.pointee.time_base.num
        pngCtx.pointee.time_base.den = videoCtx.pointee.time_base.den
    }
    
    func writeEncodedPngToFile(filePath: String, size: Int, data: UnsafeMutablePointer<UInt8>) {
        let file = fopen(filePath.cString(using: String.Encoding.utf8), "wb")
        
        fwrite(data, size, 1, file)
        fclose(file)
    }

}
