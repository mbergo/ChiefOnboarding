import re

from django.db import models
from django.template.loader import render_to_string
from django.urls import reverse
from django.utils.translation import gettext_lazy as _

from misc.fields import ContentJSONField
from organization.models import BaseItem, Notification


class ToDo(BaseItem):
    content = ContentJSONField(default=dict, verbose_name=_("Content"))
    due_on_day = models.IntegerField(verbose_name=_("Due on day"), default=1)
    video_url = models.URLField(
        verbose_name=_("YouTube Video URL"),
        blank=True,
        null=True,
        help_text=_("Optional YouTube video URL to embed with this task"),
    )
    # Chat bot specific actions
    send_back = models.BooleanField(
        verbose_name=_(
            "Post new hire's answers from form (if applicable) back to Slack channel"
        ),
        default=False,
    )
    slack_channel = models.ForeignKey(
        "slack_bot.SlackChannel",
        verbose_name=_("Slack channel"),
        null=True,
        on_delete=models.SET_NULL,
    )

    def get_icon_template(self):
        return render_to_string("_todo_icon.html")

    @property
    def notification_add_type(self):
        return Notification.Type.ADDED_TODO

    @property
    def update_url(self):
        return reverse("todo:update", args=[self.id])

    @property
    def delete_url(self):
        return reverse("todo:delete", args=[self.id])

    @property
    def inline_slack_form(self):
        valid = True
        blocks = self.content["blocks"]
        for i in blocks:
            if (
                "data" in i
                and "type" in i["data"]
                and i["data"]["type"] in ["check", "upload"]
            ):
                valid = False
                break
        return valid

    def get_video_id(self):
        if not self.video_url:
            return None
        
        youtube_patterns = [
            r'(?:https?://)?(?:www\.)?youtube\.com/watch\?v=([a-zA-Z0-9_-]+)',
            r'(?:https?://)?(?:www\.)?youtu\.be/([a-zA-Z0-9_-]+)',
            r'(?:https?://)?(?:www\.)?youtube\.com/embed/([a-zA-Z0-9_-]+)',
        ]
        
        for pattern in youtube_patterns:
            match = re.search(pattern, self.video_url)
            if match:
                return match.group(1)
        
        return None

    def get_embed_url(self):
        video_id = self.get_video_id()
        if video_id:
            return f"https://www.youtube.com/embed/{video_id}"
        return self.video_url
    
    def get_thumbnail_url(self):
        video_id = self.get_video_id()
        if video_id:
            return f"https://img.youtube.com/vi/{video_id}/hqdefault.jpg"
        return None
