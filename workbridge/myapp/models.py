from django.contrib.auth.models import User
from django.db import models

# Create your models here.

class EmailOTP(models.Model):
    email = models.EmailField()
    otp = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)


class Userprofile(models.Model):
    name=models.CharField(max_length=100)
    LOGIN=models.OneToOneField(User,on_delete=models.CASCADE)
    ph_no= models.CharField(max_length=100)
    email= models.CharField(max_length=100)
    place=models.CharField(max_length=100)
    pin= models.CharField(max_length=100)
    post= models.CharField(max_length=100)
    photo= models.CharField(max_length=100)

class Category(models.Model):
    type = models.CharField(max_length=100)

class Worker(models.Model):
    LOGIN=models.OneToOneField(User,on_delete=models.CASCADE)
    name= models.CharField(max_length=100)
    photo= models.CharField(max_length=100)
    ph_no= models.CharField(max_length=100)
    place= models.CharField(max_length=100)
    pin= models.CharField(max_length=100)
    email= models.CharField(max_length=100)
    post= models.CharField(max_length=100)
    job= models.CharField(max_length=100)
    experience= models.CharField(max_length=100)
    Category=models.ForeignKey(Category,on_delete=models.CASCADE)
    status= models.CharField(max_length=100)

class Complaint(models.Model):
    date = models.CharField(max_length=100)
    user=models.ForeignKey(Userprofile,on_delete=models.CASCADE)
    content = models.CharField(max_length=1000)
    reply= models.CharField(max_length=100)
    status= models.CharField(max_length=100)

class Review(models.Model):
    USER=models.ForeignKey(Userprofile,on_delete=models.CASCADE,related_name='user')
    rating= models.CharField(max_length=100)
    review=models.CharField(max_length=100)
    WORKER=models.ForeignKey(Worker,on_delete=models.CASCADE)
    date = models.CharField(max_length=100)

class payment(models.Model):
    USER= models.ForeignKey(Userprofile, on_delete=models.CASCADE)
    WORKER= models.ForeignKey(Worker, on_delete=models.CASCADE)
    status= models.CharField(max_length=100)
    amount= models.CharField(max_length=100)

class Worker_details(models.Model):
    WORKER= models.ForeignKey(Worker, on_delete=models.CASCADE)
    job= models.CharField(max_length=100)
    amount= models.CharField(max_length=100)

class Workrequest(models.Model):
    USER = models.ForeignKey(Userprofile, on_delete=models.CASCADE)
    WORKER = models.ForeignKey(Worker_details, on_delete=models.CASCADE)
    status= models.CharField(max_length=100)
    date= models.CharField(max_length=100)
    place = models.CharField(max_length=100, default="unknown")
    description = models.TextField(default="no description")
    worktime = models.TimeField(default="10:00")

class Chat(models.Model):
    message= models.CharField(max_length=100)
    date= models.CharField(max_length=100)
    FROM= models.ForeignKey(User, on_delete=models.CASCADE,related_name='sender')
    TO= models.ForeignKey(User, on_delete=models.CASCADE,related_name='reciever')

class Location(models.Model):
    latitude= models.CharField(max_length=100)
    longitude= models.CharField(max_length=100)
    USER= models.ForeignKey(User, on_delete=models.CASCADE)

class Notification(models.Model):
    message=models.TextField()
    date=models.DateTimeField(auto_now_add=True)