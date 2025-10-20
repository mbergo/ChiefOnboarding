# Quick Start: YouTube Video Feature

## How to Add a Video to a Task (2 minutes)

### Step 1: Navigate to To Do Items
1. Log into admin panel: http://localhost:9000/admin
2. Click "To Do Items" in the sidebar
3. Click "Create" or select an existing task

### Step 2: Add YouTube URL
1. In the form, locate the "YouTube Video URL" field
2. Paste any YouTube URL format:
   ```
   https://www.youtube.com/watch?v=VIDEO_ID
   https://youtu.be/VIDEO_ID
   ```
3. Fill in other task details (name, content, due date)
4. Click "Save"

### Step 3: Add Task to Sequence
1. Go to "Sequences" 
2. Select or create a sequence
3. Add the task with video to the timeline
4. Look for the 📹 icon next to the task name

### Step 4: View as New Hire
1. Assign sequence to a new hire
2. New hire logs in and views task
3. Video appears embedded at the top of the task
4. Full YouTube controls available (play, pause, fullscreen)

## Example URLs That Work

✅ Standard YouTube: `https://www.youtube.com/watch?v=dQw4w9WgXcQ`
✅ Short link: `https://youtu.be/dQw4w9WgXcQ`
✅ Already embedded: `https://www.youtube.com/embed/dQw4w9WgXcQ`

## Visual Indicators

- **Sequence Editor**: 📹 icon appears next to tasks with videos
- **New Hire View**: Full embedded player (16:9 responsive)
- **Form Field**: URL input with help text

## Tips

- Video field is optional - leave blank for tasks without videos
- Videos work on mobile devices
- No file uploads needed - just paste the URL
- Use unlisted YouTube videos for internal content
- Videos load on-demand (no performance impact)

## Support

For questions or issues, refer to:
- `YOUTUBE_VIDEO_FEATURE.md` - Full technical documentation
- `SESSION_SUMMARY.md` - Implementation details
