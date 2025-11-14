@echo off
setlocal enabledelayedexpansion

:: Initialize logging
set "LOG_FILE=split_log.txt"
echo Video Splitter Log - %date% %time% > "%LOG_FILE%"
echo ================================== >> "%LOG_FILE%"

:: Check if FFmpeg is available
echo Checking for FFmpeg...
ffmpeg -version >nul 2>&1
if !errorlevel! neq 0 (
    echo ERROR: FFmpeg is not found in your system PATH.
    echo Please install FFmpeg and add it to your PATH environment variable.
    echo ERROR: FFmpeg not found >> "%LOG_FILE%"
    exit /b 1
)
echo FFmpeg found successfully.
echo FFmpeg found successfully >> "%LOG_FILE%"

:: Present duration menu
echo.
echo ========================================
echo          VIDEO SPLITTER TOOL
echo ========================================
echo.
echo Select segment duration:
echo 1 - 28.5 seconds
echo 2 - 14.5 seconds  
echo 3 - 9.5 seconds
echo 4 - 4.8 seconds
echo 5 - 6.5 seconds
echo.
set /p "choice=Enter your choice (1-5): "

:: Set duration based on choice
if "%choice%"=="1" (
    set "duration=28.5"
    set "duration_name=28.5 seconds"
) else if "%choice%"=="2" (
    set "duration=14.5"
    set "duration_name=14.5 seconds"
) else if "%choice%"=="3" (
    set "duration=9.5"
    set "duration_name=9.5 seconds"
) else if "%choice%"=="4" (
    set "duration=4.8"
    set "duration_name=4.8 seconds"
) else if "%choice%"=="5" (
    set "duration=6.5"
    set "duration_name=6.5 seconds"
) else (
    echo Invalid choice. Exiting.
    echo Invalid choice selected >> "%LOG_FILE%"
    exit /b 1
)

echo Selected duration: %duration_name%
echo Selected duration: %duration_name% >> "%LOG_FILE%"
echo.

:: Initialize counters
set "total_files=0"
set "processed_files=0"
set "skipped_files=0"
set "output_files_created=0"

:: Video file extensions to search for
set "extensions=*.mp4 *.avi *.mov *.mkv *.wmv *.flv *.webm *.m4v *.3gp *.mpg *.mpeg"

:: Count total video files
echo Scanning for video files...
for %%e in (%extensions%) do (
    for %%f in ("%%e") do (
        set /a total_files+=1
    )
)

if !total_files! equ 0 (
    echo No video files found in the current directory.
    echo No video files found >> "%LOG_FILE%"
    echo Current directory: %CD%
    exit /b 0
)

echo Found !total_files! video file(s) to process.
echo Found !total_files! video file(s) >> "%LOG_FILE%"
echo.

:: Process each video file
echo Processing videos...
echo ========================================

for %%e in (%extensions%) do (
    for %%f in ("%%e") do (
        set "input_file=%%f"
        set "filename=%%~nf"
        set "extension=%%~xf"
        
        echo Processing: !input_file!
        echo Processing: !input_file! >> "%LOG_FILE%"
        
        :: Get video duration using ffprobe
        for /f "tokens=*" %%d in ('ffprobe -v quiet -show_entries format^=duration -of csv^=p^=0 "!input_file!" 2^>nul') do (
            set "video_duration_raw=%%d"
        )
        
        :: Check if duration was obtained
        if "!video_duration_raw!"=="" (
            echo   ERROR: Could not determine duration for !input_file!
            echo   ERROR: Could not determine duration for !input_file! >> "%LOG_FILE%"
            set /a skipped_files+=1
        ) else (
            :: Convert video duration to a comparable format
            for /f "tokens=1 delims=." %%s in ("!video_duration_raw!") do set "video_duration_int=%%s"
            for /f "tokens=1 delims=." %%s in ("!duration!") do set "segment_duration_int=%%s"
            
            if !video_duration_int! leq !segment_duration_int! (
                echo   SKIPPED: Video duration ^(!video_duration_raw!s^) is shorter than segment duration ^(!duration!s^)
                echo   SKIPPED: Video too short >> "%LOG_FILE%"
                set /a skipped_files+=1
            ) else (
                echo   Video duration: !video_duration_raw! seconds
                echo   Splitting into precise segments of %duration_name%...
                
                :: Calculate number of segments needed
                call :calculate_segments "!video_duration_raw!" "!duration!" num_segments
                
                echo   Will create !num_segments! segments
                
                :: Create output subfolder for each video
                set "output_dir=!filename!_parts"
                if not exist "!output_dir!" mkdir "!output_dir!"
                
                :: Create each segment precisely using FFmpeg with exact time cutting
                set "segment_counter=1"
                set "start_time=0"
                
                for /l %%i in (1,1,!num_segments!) do (
                    set "part_num=000%%i"
                    set "part_num=!part_num:~-3!"
                    
                    :: Calculate exact start and duration for this segment
                    call :format_time "!start_time!" start_formatted
                    
                    echo     Creating segment %%i of !num_segments! ^(start: !start_formatted!^)
                    
                    :: Use precise cutting with re-encoding to ensure exact duration
                    ffmpeg -ss !start_formatted! -i "!input_file!" -t !duration! -c:v libx264 -c:a aac -avoid_negative_ts make_zero "!output_dir!\!filename!_part_!part_num!!extension!" -y >nul 2>&1
                    
                    if !errorlevel! equ 0 (
                        echo       SUCCESS: Created !output_dir!\!filename!_part_!part_num!!extension!
                        echo       Created: !output_dir!\!filename!_part_!part_num!!extension! >> "%LOG_FILE%"
                        set /a output_files_created+=1
                    ) else (
                        echo       ERROR: Failed to create segment %%i
                        echo       ERROR: Failed to create segment %%i >> "%LOG_FILE%"
                    )
                    
                    :: Update start time for next segment
                    call :add_duration "!start_time!" "!duration!" start_time
                )
                
                :: Handle remaining time if there's a partial segment
                call :calculate_remaining "!video_duration_raw!" "!duration!" "!num_segments!" remaining_duration
                
                if not "!remaining_duration!"=="0" (
                    set /a num_segments+=1
                    set "part_num=000!num_segments!"
                    set "part_num=!part_num:~-3!"
                    
                    call :format_time "!start_time!" start_formatted
                    
                    echo     Creating final segment ^(remaining: !remaining_duration!s^)
                    
                    ffmpeg -ss !start_formatted! -i "!input_file!" -t !remaining_duration! -c:v libx264 -c:a aac -avoid_negative_ts make_zero "!output_dir!\!filename!_part_!part_num!!extension!" -y >nul 2>&1
                    
                    if !errorlevel! equ 0 (
                        echo       SUCCESS: Created !output_dir!\!filename!_part_!part_num!!extension!
                        echo       Created: !output_dir!\!filename!_part_!part_num!!extension! >> "%LOG_FILE%"
                        set /a output_files_created+=1
                    )
                )
                
                echo   COMPLETED: Video split into !num_segments! precise segments
                echo   SUCCESS: Video split completed >> "%LOG_FILE%"
                set /a processed_files+=1
            )
        )
        echo.
    )
)

:: Print summary
echo ========================================
echo                SUMMARY
echo ========================================
echo Total video files found: !total_files!
echo Successfully processed: !processed_files!
echo Skipped files: !skipped_files!
echo Total segment files created: !output_files_created!

echo ======================================== >> "%LOG_FILE%"
echo SUMMARY >> "%LOG_FILE%"
echo Total video files found: !total_files! >> "%LOG_FILE%"
echo Successfully processed: !processed_files! >> "%LOG_FILE%"
echo Skipped files: !skipped_files! >> "%LOG_FILE%"
echo Total segment files created: !output_files_created! >> "%LOG_FILE%"

if !output_files_created! equ 0 (
    echo.
    echo WARNING: No output files were created!
    echo WARNING: No output files were created! >> "%LOG_FILE%"
)

echo.
echo Current working directory: %CD%
echo Current working directory: %CD% >> "%LOG_FILE%"
echo.
echo Log file saved as: %LOG_FILE%

exit /b 0

:: Function to calculate number of full segments
:calculate_segments
set "total_duration=%~1"
set "segment_duration=%~2"
set "result_var=%~3"

:: Use PowerShell for precise floating point calculation
for /f %%r in ('powershell -command "[math]::Floor(%total_duration% / %segment_duration%)"') do (
    set "%result_var%=%%r"
)
goto :eof

:: Function to calculate remaining duration
:calculate_remaining
set "total_duration=%~1"
set "segment_duration=%~2"
set "num_full_segments=%~3"
set "result_var=%~4"

:: Calculate remaining time
for /f %%r in ('powershell -command "$remaining = %total_duration% - (%segment_duration% * %num_full_segments%); if ($remaining -gt 0.5) { $remaining } else { 0 }"') do (
    set "%result_var%=%%r"
)
goto :eof

:: Function to add duration to start time
:add_duration
set "current_time=%~1"
set "add_duration=%~2"
set "result_var=%~3"

for /f %%r in ('powershell -command "%current_time% + %add_duration%"') do (
    set "%result_var%=%%r"
)
goto :eof

:: Function to format time as HH:MM:SS.MS
:format_time
set "seconds=%~1"
set "result_var=%~2"

for /f %%r in ('powershell -command "$ts = [TimeSpan]::FromSeconds(%seconds%); $ts.ToString('hh\:mm\:ss\.fff')"') do (
    set "%result_var%=%%r"
)
goto :eof
