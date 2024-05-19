<#
.SYNOPSIS
This script compresses MP4 files using FFmpeg.

.DESCRIPTION
The script takes all MP4 files in the specified input folder and compresses them using FFmpeg. The compressed files are saved in the specified output folder.

.PARAMETER inputFolder
The path to the folder containing the MP4 files to be compressed. Default value is the current directory.

.PARAMETER outputFolder
The path to the folder where the compressed MP4 files will be saved. Default value is a subfolder named "compressed" in the current directory.

.EXAMPLE
.\compress_mp4.ps1 -inputFolder "C:\Videos" -outputFolder "C:\CompressedVideos"

.NOTES
- FFmpeg must be installed and added to the system's PATH environment variable for this script to work.
- This script only supports MP4 files.
#>

$inputFolder = "./" # Path to the folder containing the MP4 files to be compressed. Default value is the current directory.
$outputFolder = "./compressed/" # Path to the folder where the compressed MP4 files will be saved. Default value is a subfolder named "compressed" in the current directory.

# Check if the output folder exists, and create it if it doesn't.
if (!(Test-Path -Path $outputFolder)) {
    New-Item -ItemType Directory -Force -Path $outputFolder
}

$files = Get-ChildItem -Path $inputFolder -Filter *.mp4 # Get all MP4 files in the input folder.

foreach ($file in $files) {
    $inputFile = $file.FullName # Full path of the input MP4 file.
    $outputFile = Join-Path -Path $outputFolder -ChildPath $file.Name # Full path of the output compressed MP4 file.

    # -i "$inputFile": 
    #                  This flag specifies the input file. $inputFile is a variable that should hold the path of the input file.
    # -c:v hevc_nvenc:
    #                  This flag sets the codec for the video stream.
    #                  hevc_nvenc is the NVIDIA hardware-accelerated H.265 (HEVC) encoder.
    # -preset medium: 
    #                 This flag sets the encoding preset. A preset is a collection of options that will provide a certain encoding speed to compression ratio. 
    #                 A slower preset will provide better compression (compression is quality per filesize). The medium preset is a good balance between encoding speed and compression ratio.
    # -cq 28
    #                 This flag sets the constant quantizer parameter for the video stream. The quantizer parameter controls the trade-off between video quality and bitrate. 
    #                 Lower values result in better quality but higher bitrates. The range for H.265 is 0-51, where 0 is lossless, 23 is default, and 51 is worst quality. 
    #                 A value of 28 is a good balance between quality and bitrate.
    # -c:a copy: 
    #                 This flag sets the codec for the audio stream. copy means that the audio stream is copied from the input file to the output file without re-encoding.
    # "$outputFile"
    #                 This is the output file. $outputFile is a variable that should hold the path of the output file.
    #ffmpeg -i "$inputFile" -c:v hevc_nvenc -preset medium -cq 28 -c:a copy "$outputFile" # Compress the MP4 file using FFmpeg with NVIDIA GPU.
    ffmpeg -i "$inputFile" -c:v hevc_nvenc -vf "scale=1920:-1" -preset medium -cq 28 -c:a copy "$outputFile" # Compress and downscale the MP4 file using FFmpeg with NVIDIA GPU.
}