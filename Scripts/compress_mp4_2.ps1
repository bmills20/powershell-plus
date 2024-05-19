<#
.SYNOPSIS
This script compresses MP4 files using FFmpeg.

.DESCRIPTION
The script takes all MP4 files in the specified input folder and compresses them using FFmpeg.
The compressed files are saved in the specified output folder.
It also provides non-blocking progress information and estimated time remaining for each file during the compression process.

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

param (
    [string]$inputFolder = "./",
    [string]$outputFolder = "./compressed/"
)

# Check if the output folder exists, and create it if it doesn't.
if (!(Test-Path -Path $outputFolder)) {
    New-Item -ItemType Directory -Force -Path $outputFolder | Out-Null
}

$files = Get-ChildItem -Path $inputFolder -Filter *.mp4 # Get all MP4 files in the input folder.

$jobs = @()

foreach ($file in $files) {
    $inputFile = $file.FullName # Full path of the input MP4 file.
    $outputFile = Join-Path -Path $outputFolder -ChildPath $file.Name # Full path of the output compressed MP4 file.

    # Get the total duration of the video using ffprobe.
    $totalDuration = ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$inputFile"

    # Start the compression process using FFmpeg with NVIDIA GPU acceleration as a background job.
    $job = Start-Job -ScriptBlock {
        param($inputFile, $outputFile)
        ffmpeg -i "$inputFile" -c:v hevc_nvenc -preset medium -cq 28 -c:a copy "$outputFile" 2>&1
    } -ArgumentList $inputFile, $outputFile

    $jobs += @{
        Job           = $job
        File          = $file
        TotalDuration = $totalDuration
    }
}

# Monitor the background jobs and display progress information.
while ($jobs.Count -gt 0) {
    foreach ($jobInfo in $jobs) {
        $job = $jobInfo.Job
        $file = $jobInfo.File
        $totalDuration = $jobInfo.TotalDuration

        if ($job.State -eq 'Completed') {
            Write-Host "Compressed '$($file.Name)' completed."
            $jobs.Remove($jobInfo)
        }
        else {
            $output = Receive-Job -Job $job
            $progress = $output | Select-String -Pattern "time=(\d+:\d+:\d+\.\d+)" | Select-Object -Last 1
            if ($progress -match "time=(\d+:\d+:\d+\.\d+)") {
                $currentPosition = $matches[1]
                $currentPositionSeconds = ([timespan]$currentPosition).TotalSeconds
                $totalDurationSeconds = ([timespan]$totalDuration).TotalSeconds
                $remainingSeconds = $totalDurationSeconds - $currentPositionSeconds
                $estimatedRemaining = [timespan]::FromSeconds($remainingSeconds)
                Write-Host "Compressing '$($file.Name)' - Estimated time remaining: $estimatedRemaining"
            }
        }
    }
    Start-Sleep -Seconds 1
}

Write-Host "All files compressed successfully."