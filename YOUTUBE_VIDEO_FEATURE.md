# YouTube Video URL Feature for ToDo Items

## Overview
This feature allows administrators to attach YouTube videos to ToDo items in ChiefOnboarding sequences. When new hires view their tasks, they'll see the embedded video directly in the task view.

## Implementation Details

### Database Changes
- Added `video_url` field to the `ToDo` model (`back/admin/to_do/models.py`)
- Field accepts any valid URL (optimized for YouTube)
- Migration: `back/admin/to_do/migrations/0021_todo_video_url.py`

### Model Methods
- `get_embed_url()`: Converts various YouTube URL formats to embed format
  - Supports: `youtube.com/watch?v=...`, `youtu.be/...`, `youtube.com/embed/...`
  - Returns proper iframe embed URL

### UI Changes

#### Admin Interface
1. **ToDo Form** (`back/admin/to_do/forms.py`)
   - Added `video_url` field to the form layout
   - Appears in the left column alongside name, due date, and tags

2. **Sequence Editor** (`back/admin/sequences/templates/_condition_line_item.html`)
   - Shows video icon (📹) next to tasks that have videos attached
   - Tooltip displays "Has video" on hover

#### New Hire Portal
1. **Task Detail View** (`back/new_hire/templates/new_hire_to_do.html`)
   - Video embeds above task content
   - Responsive 16:9 aspect ratio
   - Full YouTube player controls (play, pause, fullscreen, etc.)

## Usage

### Adding a Video to a Task
1. Navigate to Admin → To Do Items
2. Create or edit a task
3. Enter YouTube URL in the "YouTube Video URL" field
   - Supports any YouTube URL format
4. Save the task

### Supported URL Formats
```
https://www.youtube.com/watch?v=VIDEO_ID
https://youtu.be/VIDEO_ID
https://www.youtube.com/embed/VIDEO_ID
```

All formats are automatically converted to the proper embed format.

### Example
```python
from admin.to_do.models import ToDo

todo = ToDo.objects.get(id=1)
todo.video_url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
todo.save()

# Automatically converts to: https://www.youtube.com/embed/dQw4w9WgXcQ
print(todo.get_embed_url())
```

## Files Modified

1. `back/admin/to_do/models.py` - Added video_url field and get_embed_url() method
2. `back/admin/to_do/forms.py` - Added video_url to form layout
3. `back/new_hire/templates/new_hire_to_do.html` - Added video embed display
4. `back/admin/sequences/templates/_condition_line_item.html` - Added video icon indicator

## Testing

Run the following in Django shell to test:
```python
from admin.to_do.models import ToDo

# Get first task
todo = ToDo.templates.first()

# Add video URL
todo.video_url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
todo.save()

# Verify embed URL conversion
print(todo.get_embed_url())
# Output: https://www.youtube.com/embed/dQw4w9WgXcQ
```

## Future Enhancements

Potential improvements:
- Support for Vimeo and other video platforms
- Video thumbnail preview in sequence editor
- Multiple videos per task
- Video playback analytics
- Custom video start/end times
