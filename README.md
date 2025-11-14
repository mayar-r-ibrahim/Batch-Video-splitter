# VideoSplit 

A powerful Windows batch script for automatically splitting video files into precise segments of configurable durations. Perfect for content creators, video editors, and anyone needing to break down large video files into manageable chunks.

## Features

- 🎯 **Precise Segment Timing** - Split videos with exact duration control
- 📁 **Multi-format Support** - Works with MP4, AVI, MOV, MKV, WMV, FLV, WebM, M4V, 3GP, MPG, and MPEG
- ⚡ **FFmpeg Powered** - Uses industry-standard FFmpeg for reliable video cessing
- 📊 **Smart Organization** - Creates dedicated folders for each cessed video
- 📝 **Comprehensive Logging** - Detailed log file for tracking all operations
- 🎚️ **Multiple Duration Presets** - Choose from 5 pre-configured segment durations
- 🔄 **Automatic Skipping** - Intelligently skips videos shorter than selected segment duration

## Quick Start

### Prerequisites

1. **Install FFmpeg**
   - Download from [FFmpeg Official Website](https://ffmpeg.org/download.html)
   - Add FFmpeg to your system PATH environment variable
   - Verify installation by running `ffmpeg -version` in Command mpt

### Usage

1. **Place videos in a directory**
   - Copy all your video files to a folder
   - Place `VideoSplitPro.bat` in the same folder

2. **Run the script**
   - Double-click `VideoSplitPro.bat`
   - Or run from Command mpt: `VideoSplitPro.bat`

3. **Select segment duration**
   ```
   ========================================
            VIDEO SPLITTER TOOL
   ========================================

   Select segment duration:
   1 - 28.5 seconds
   2 - 14.5 seconds  
   3 - 9.5 seconds
   4 - 4.8 seconds
   5 - 6.5 seconds

   Enter your choice (1-5): 
   ```

4. **Let it cess**
   - Script automatically cesses all supported video files
   - Creates organized output folders
   - Generates detailed log file

## Output Structure

For each input video file `myvideo.mp4`, the script creates:
```
myvideo_parts/
├── myvideo_part_001.mp4
├── myvideo_part_002.mp4
├── myvideo_part_003.mp4
└── ...
```

## Supported Video Formats

- **MP4** (.mp4, .m4v)
- **AVI** (.avi)
- **MOV** (.mov)
- **MKV** (.mkv)
- **WMV** (.wmv)
- **FLV** (.flv)
- **WebM** (.webm)
- **3GP** (.3gp)
- **MPEG** (.mpg, .mpeg)

## Segment Duration Options

| Option | Duration | Use Case |
|--------|----------|----------|
| 1 | 28.5 seconds | Instagram Reels |
| 2 | 14.5 seconds | Short clips |
| 3 | 9.5 seconds | Quick segments |
| 4 | 4.8 seconds | Ultra-short clips |
| 5 | 6.5 seconds | Medium segments |

## Log File

The script generates `split_log.txt` with:
- cessing timestamps
- File-by-file cessing status
- Error messages and warnings
- Final summary statistics

## Technical Details

- **Encoding**: Uses H.264 video codec and AAC audio codec
- **Precision**: Handles partial segments and remaining time
- **Error Handling**: Comprehensive error checking and reporting
- **Performance**: cesses files sequentially with gress reporting

## Troubleshooting

### Common Issues

1. **"FFmpeg not found" error**
   - Solution: Install FFmpeg and add to system PATH

2. **No video files cessed**
   - Check file extensions are supported
   - Ensure videos are in the same directory as the script

3. **Partial segments not created**
   - This is normal if remaining duration is less than 0.5 seconds

### Performance Tips

- Close other applications during cessing for better performance
- Ensure sufficient disk space for output files
- cess smaller batches for better monitoring

## License

Free to use and modify. Please credit the original author if distributing modified versions.

## Support

For issues and feature requests, please ensure:
1. FFmpeg is perly installed
2. Video files are in supported formats
3. Check the generated log file for detailed error information

---

**VideoSplit ** - Making video segmentation simple and precise! 🎬✂️
