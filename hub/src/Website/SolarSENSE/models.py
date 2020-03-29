from django.db import models
from django.utils.translation import ugettext_lazy as _
from taggit.managers import TaggableManager
from taggit.models import TagBase, GenericTaggedItemBase

class CustomTag(TagBase):
    type = models.CharField(max_length=255)
    min = models.DecimalField(max_digits=5, decimal_places=2)
    max = models.DecimalField(max_digits=5, decimal_places=2)

    class Meta:
        verbose_name = _("Tag")
        verbose_name_plural = _("Tags")

class DataTagged(GenericTaggedItemBase):
    tag = models.ForeignKey(
        CustomTag,
        on_delete=models.CASCADE,
        related_name="%(app_label)s_%(class)s_items"
    )

class Video(models.Model):

    def __str__(self):
        return self.name

    name = models.CharField(max_length=255)
    content = models.FileField()
    tags = TaggableManager(blank=True)


class SensorCollections(models.Model):
    date_time = models.DateTimeField(auto_now_add=True)
<<<<<<< HEAD
    moisture = models.DecimalField(max_digits=5, decimal_places=2 , default='0')
    temperature = models.DecimalField(max_digits=5, decimal_places=2, default='0')
    sunlight = models.DecimalField(max_digits=5, decimal_places=2, default='0')
    phosphate = models.DecimalField(max_digits=5, decimal_places=2, default='0')
=======
    moisture = models.DecimalField(max_digits=5, decimal_places=2)
    temperature = models.DecimalField(max_digits=5, decimal_places=2)
    sunlight = models.DecimalField(max_digits=5, decimal_places=2)
    phosphate = models.DecimalField(max_digits=5, decimal_places=2)
>>>>>>> 58fcd6678295281009c4408355d5c1fee05255a6
