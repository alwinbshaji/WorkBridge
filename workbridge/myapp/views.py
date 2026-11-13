from datetime import datetime

from django.contrib.auth import authenticate, login
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User, Group
from django.core.files.storage import FileSystemStorage
from django.http import JsonResponse
from django.shortcuts import render, redirect


# Create your views here.
from django.views.decorators.csrf import csrf_exempt
from math import radians, sin, cos, atan2, sqrt

from myapp.models import *
from workbridge.settings import EMAIL_HOST_USER


def login_get(request):
    return render(request,'login.html')
#
def login_post(request):
    username=request.POST['username']
    password=request.POST['password']
    ob=authenticate(request,username=username,password=password)
    if ob is not None:
        login(request,ob)
        if ob.groups.filter(name='Admin').exists():
            return redirect('/myapp/admin_home/')
        return redirect('/myapp/login_get')
    return redirect('/myapp/login_get')

@login_required(login_url='/myapp/login_get')
def admin_home(request):
    return render(request,'index.html')

@login_required(login_url='/myapp/login_get')
def view_worker(request):
    o=Worker.objects.all()
    return render(request,'view_worker.html',{'data':o})

@login_required(login_url='/myapp/login_get')
def admin_approved_worker(request,id):
    o=Worker.objects.get(id=id)
    o.status='Approved'
    o.save()
    return redirect('/myapp/view_worker')

@login_required(login_url='/myapp/login_get')
def admin_rejected_worker(request,id):
    o = Worker.objects.get(id=id)
    o.status = 'Rejected'
    o.save()
    return redirect('/myapp/view_worker')

@login_required(login_url='/myapp/login_get')
def view_approved_workers(request) :
    c=Worker.objects.filter(status='Approved')
    return render(request,'view_approved_workers.html',{'data':c})

@login_required(login_url='/myapp/login_get')
def add_category(request) :
    return render(request,'add_category.html')

@login_required(login_url='/myapp/login_get')
def add_category_post(request):
    j=request.POST['type']

    i=Category()
    i.type=j
    i.save()
    return redirect('/myapp/view_category')

@login_required(login_url='/myapp/login_get')
def view_category(request) :
    d=Category.objects.all()
    return render(request,'view_category.html',{'data':d})

@login_required(login_url='/myapp/login_get')
def delete_category(request,id) :
    d = Category.objects.get(id=id)
    d.delete()

    return redirect('/myapp/view_category')

@login_required(login_url='/myapp/login_get')
def edit_category(request,id) :
    d = Category.objects.get(id=id)
    return render(request,'edit_category.html',{'data':d})

@login_required(login_url='/myapp/login_get')
def edit_category_post(request):
    d=request.POST['type']
    i=request.POST['cid']

    o=Category.objects.get(id=i)
    o.type=d
    o.save()
    return redirect('/myapp/view_category')



@login_required(login_url='/myapp/login_get')
def view_user(request) :
    n=Userprofile.objects.all()
    return render(request,'view_user.html',{'data':n})

@login_required(login_url='/myapp/login_get')
def view_complaint(request) :
    r=Complaint.objects.all()
    return render(request,'view_complaint.html',{'data':r})

@login_required(login_url='/myapp/login_get')
def view_reviews(request) :
    v=Review.objects.all()
    return render(request,'view_reviews.html',{'data':v})

@login_required(login_url='/myapp/login_get')
def send_reply(request,id):
    o=Complaint.objects.get(id=id)
    return render(request,'send&reply.html',{'data':o})

@login_required(login_url='/myapp/login_get')
def send_reply_post(request):
    reply=request.POST['reply']
    id=request.POST['id']
    o = Complaint.objects.get(id=id)
    o.status='Replied'
    o.reply=reply
    o.save()
    return redirect('/myapp/view_complaint')

def addnotification_get(request):
    return render(request,'addnotification.html')

def addnotification_post(request):
    message=request.POST['message']
    i=Notification()
    i.message=message
    i.save()
    return redirect('/myapp/viewnotification/')

def viewnotification(request):
    i=Notification.objects.all()
    return render(request,'viewnotification.html',{"data":i})

def delete_notification(request,id):
    i=Notification.objects.get(id=id)
    i.delete()
    return redirect('/myapp/viewnotification/')










def catergory(request):
    cat=Category.objects.all()
    data=[]

    for i in cat:
        data.append(
            {'id':i.id,
             'type':i.type}
        )
    return JsonResponse({'status':'ok'})


@csrf_exempt

def get_categories(request):
    categories = Category.objects.all()
    data = []

    for c in categories:
        data.append({
            'id': c.id,
            'type': c.type
        })

    return JsonResponse({'status': 'ok', 'data': data})

def  worker_register(request):
        name = request.POST.get('name')
        phone = request.POST.get('phone')
        email = request.POST.get('email')
        place = request.POST.get('place')
        pin = request.POST.get('pin')
        post = request.POST.get('post')
        job = request.POST.get('job')
        experience = request.POST.get('experience')
        category_id = request.POST.get('category')
        password = request.POST.get('password')
        photo = request.FILES.get('photo')

        # Validation
        if not all([name, phone, email, place, pin, post, job, experience, category_id, password]):
            return JsonResponse({'status': 'no', 'message': 'Missing fields'})

        if photo is None:
            return JsonResponse({'status': 'no', 'message': 'Photo required'})

        # Email already exists check
        if User.objects.filter(username=email).exists():
            return JsonResponse({'status': 'no', 'message': 'Email already exists'})

        # Save photo
        fs = FileSystemStorage()
        filename =('worker')+datetime.now().strftime('%Y%m%d%H%M%S') + ".jpg"
        fs.save(filename, photo)
        path = fs.url(filename)

        # Create auth user
        auth_user = User.objects.create_user(
            username=email,
            password=password,
            email=email
        )
        group = Group.objects.get(name='worker')
        auth_user.groups.add(group)
        auth_user.save()

        # Get category object
        category_obj = Category.objects.get(id=category_id)

        # Create worker (status pending for admin approval)
        Worker.objects.create(
            name=name,
            photo=path,
            ph_no=phone,
            place=place,
            pin=pin,
            email=email,
            post=post,
            job=job,
            experience=experience,
            Category=category_obj,
            status='pending',
            LOGIN=auth_user
        )

        return JsonResponse({'status': 'ok'})

#
# def user_signup(request):
#         name = request.POST['name']
#         phone = request.POST['ph_no']
#         email = request.POST['email']
#         place = request.POST['place']
#         pin = request.POST['pin']
#         post = request.POST['post']
#         password = request.POST['password']
#         photo = request.FILES['photo']
#
#         # Check email already exists
#         if User.objects.filter(username=email).exists():
#             return JsonResponse({'status': 'no', 'message': 'Email already exists'})
#
#         fs = FileSystemStorage()
#         filename = datetime.now().strftime('%Y%m%d%H%M%S') + ".jpg"
#         fs.save(filename, photo)
#         path = fs.url(filename)
#
#         # Create Auth User
#         auth_user = User.objects.create_user(
#             username=email,
#             password=password,
#             email=email
#         )
#
#         group = Group.objects.get(name='user')
#         auth_user.groups.add(group)
#         auth_user.save()
#
#         # Create User Profile
#         Userprofile.objects.create(
#             name=name,
#             ph_no=phone,
#             email=email,
#             place=place,
#             pin=pin,
#             post=post,
#             photo=path,
#             LOGIN=auth_user
#         )
#
#         return JsonResponse({'status': 'ok'})


import random
from django.core.mail import send_mail

@csrf_exempt
def send_otp(request):
    email = request.POST['email']

    if User.objects.filter(username=email).exists():
        return JsonResponse({'status':'no','message':'Email already exists'})

    otp = str(random.randint(100000,999999))

    EmailOTP.objects.update_or_create(
        email=email,
        defaults={'otp':otp}
    )

    send_mail(
        'Your OTP Verification',
        f'Your OTP is {otp}',
        EMAIL_HOST_USER,
        [email],
        fail_silently=False,
    )

    return JsonResponse({'status':'ok'})


@csrf_exempt
def verify_otp_register(request):

    name = request.POST['name']
    phone = request.POST['phone']
    email = request.POST['email']
    place = request.POST['place']
    pin = request.POST['pin']
    post = request.POST['post']
    password = request.POST['password']
    otp = request.POST['otp']
    photo = request.FILES['photo']

    try:
        otp_obj = EmailOTP.objects.get(email=email, otp=otp)
    except:
        return JsonResponse({'status':'no','message':'Invalid OTP'})


    fs = FileSystemStorage()
    filename = datetime.now().strftime('%Y%m%d%H%M%S') + ".jpg"
    fs.save(filename, photo)
    path = fs.url(filename)

    auth_user = User.objects.create_user(
        username=email,
        password=password,
        email=email
    )

    group = Group.objects.get(name='user')
    auth_user.groups.add(group)

    Userprofile.objects.create(
        name=name,
        ph_no=phone,
        email=email,
        place=place,
        pin=pin,
        post=post,
        photo=path,
        LOGIN=auth_user
    )

    otp_obj.delete()

    return JsonResponse({'status':'ok'})

@csrf_exempt
def send_forgot_otp(request):

    email = request.POST['email']

    if not User.objects.filter(username=email).exists():
        return JsonResponse({'status':'no','message':'Email not registered'})

    otp = str(random.randint(100000,999999))

    EmailOTP.objects.update_or_create(
        email=email,
        defaults={'otp':otp}
    )

    send_mail(
        'Password Reset OTP',
        f'Your OTP is {otp}',
        'eagaladvisorteam@gmail.com',
        [email],
        fail_silently=False
    )

    return JsonResponse({'status':'ok'})

@csrf_exempt
def reset_password(request):

    email = request.POST['email']
    otp = request.POST['otp']
    password = request.POST['password']

    try:
        obj = EmailOTP.objects.get(email=email, otp=otp)
    except:
        return JsonResponse({'status':'no'})

    user = User.objects.get(username=email)
    user.set_password(password)
    user.save()

    obj.delete()

    return JsonResponse({'status':'ok'})


@csrf_exempt

def user_login(request):
    if request.method == 'POST':
        email = request.POST.get('email')
        password = request.POST.get('password')

        # Check email exists
        user_obj = User.objects.filter(username=email).  first()
        if user_obj is None:
            return JsonResponse({
                'status': 'error',
                'message': 'Incorrect email'
            })

        # Authenticate password
        user = authenticate(username=email, password=password)
        if user is None:
            return JsonResponse({
                'status': 'error',
                'message': 'Incorrect password'
            })

        # USER MODULE LOGIN
        if user.groups.filter(name='user').exists():
            return JsonResponse({
                'status': 'ok',
                'lid': user.id,
                'type': 'user'
            })

        # WORKER LOGIN WITH APPROVAL CHECK
        elif user.groups.filter(name='worker').exists():
            worker = Worker.objects.filter(LOGIN=user).first()

            # If worker profile not found
            if worker is None:
                return JsonResponse({
                    'status': 'error',
                    'message': 'Worker profile not found'
                })

            # Check admin approval
            if worker.status == 'accept':
                return JsonResponse({
                    'status': 'ok',
                    'lid': user.id,
                    'type': 'worker'
                })
            else:
                return JsonResponse({
                    'status': 'error',
                    'message': 'Waiting for admin approval'
                })

        # OTHER USERS (NO GROUP)
        else:
            return JsonResponse({
                'status': 'error',
                'message': 'User not allowed'
            })

    return JsonResponse({
        'status': 'error',
        'message': 'Invalid request'
    })





def view_userprofile(request):
    lid=request.POST['lid']
    i=Userprofile.objects.get(LOGIN=lid)

    return JsonResponse({
        'status':'ok',
        'name':i.name,
        'phone':i.ph_no,
        'email':i.email,
        'place':i.place,
        'pin':i.pin,
        'post':i.post,
        'photo':i.photo
    })
#
# def view_workerprofile(request):
#     if request.method == "POST":
#
#         lid = request.POST.get('lid')
#
#         if not lid:
#             return JsonResponse({'status': 'no lid provided'})
#
#         try:
#             o = Worker.objects.get(LOGIN=lid)
#
#             return JsonResponse({
#                 'status': 'ok',
#                 'name': o.name,
#                 'photo': o.photo,
#                 'phone': o.ph_no,
#                 'place': o.place,
#                 'pin': o.pin,
#                 'email': o.email,
#                 'post': o.post,
#                 'job': o.job,
#                 'experience': o.experience,
#                 'category': o.Category.type,
#             })
#
#         except Worker.DoesNotExist:
#             return JsonResponse({'status': 'worker not found'})
#
#     return JsonResponse({'status': 'invalid request'})

def view_workerprofile(request):
    if request.method == "POST":

        lid = request.POST.get('lid')

        if not lid:
            return JsonResponse({'status': 'no lid provided'})

        try:
            o = Worker.objects.get(LOGIN=lid)

            # Safe category
            category_name = ""
            if o.Category:
                category_name = o.Category.type if o.Category.type else ""

            # Safe photo
            photo_url = ""
            if o.photo:
                photo_url = str(o.photo)

            return JsonResponse({
                'status': 'ok',
                'name': o.name or "",
                'photo': photo_url,
                'phone': o.ph_no or "",
                'place': o.place or "",
                'pin': o.pin or "",
                'email': o.email or "",
                'post': o.post or "",
                'job': o.job or "",
                'experience': o.experience or "",
                'category': category_name,
            })

        except Worker.DoesNotExist:
            return JsonResponse({'status': 'worker not found'})

    return JsonResponse({'status': 'invalid request'})

def update_profile(request):
    if request.method == 'POST':
        try:
            lid = request.POST.get('lid')
            name = request.POST.get('name')
            ph_no = request.POST.get('phone')
            place = request.POST.get('place')
            pin = request.POST.get('pin')
            post = request.POST.get('post')

            u = Userprofile.objects.get(LOGIN=lid)

            u.name = name
            u.ph_no = ph_no
            u.place = place
            u.pin = pin
            u.post = post

            # ✅ SAFE PHOTO CHECK
            if 'photo' in request.FILES:
                photo = request.FILES['photo']
                fs = FileSystemStorage()

                filename = "Userprofile" + datetime.now().strftime('%Y%m%d%H%M%S') + ".jpg"
                fs.save(filename, photo)
                path = fs.url(filename)

                u.photo = path

            u.save()

            return JsonResponse({'status': 'ok'})

        except Exception as e:
            print("Update Error:", e)
            return JsonResponse({'status': 'error'})

    return JsonResponse({'status': 'no'})

def edit_worker(request):
    if request.method == 'POST':
        try:
            lid = request.POST.get('lid')

            if not lid:
                return JsonResponse({'status': 'no lid provided'})

            o = Worker.objects.get(LOGIN=lid)

            # Safe field updates
            o.name = request.POST.get('name', o.name)
            o.ph_no = request.POST.get('phone', o.ph_no)
            o.place = request.POST.get('place', o.place)
            o.post = request.POST.get('post', o.post)
            o.pin = request.POST.get('pin', o.pin)
            o.job = request.POST.get('job', o.job)
            o.experience = request.POST.get('experience', o.experience)

            # ✅ FIX CATEGORY (ForeignKey)
            category_id = request.POST.get('category')
            if category_id:
                try:
                    cat = Category.objects.get(id=category_id)
                    o.Category = cat
                except Category.DoesNotExist:
                    pass

            # ✅ SAFE PHOTO UPDATE
            if 'photo' in request.FILES:
                photo = request.FILES['photo']
                fs = FileSystemStorage()

                filename = "Worker_" + datetime.now().strftime('%Y%m%d%H%M%S') + ".jpg"
                fs.save(filename, photo)
                o.photo = fs.url(filename)

            o.save()

            return JsonResponse({'status': 'ok'})

        except Worker.DoesNotExist:
            return JsonResponse({'status': 'worker not found'})

        except Exception as e:
            print("Edit Worker Error:", e)
            return JsonResponse({'status': 'error'})

    return JsonResponse({'status': 'invalid request'})

def view_nearbyworker(request):
    w=Worker_details.objects.select_related('workers').all()

    data=[]
    for i in w:
        data.append(
            {
            'id':w.WORKER,
            'job':w.job,
            'amount':w.amount,
            'name':w.WORKER.name,
            'phone':w.WORKER.ph_no
        }
        )
    return JsonResponse({'status':'ok','data':data})

def request_status(request):
    lid=request.POST['lid']
    w=Workrequest.objects.filter(USER__LOGIN=lid)
    data=[]
    for i in w:
        data.append({
            'work':i.WORKER.job,
            'worker':i.WORKER.WORKER.name,
            'status':i.status,
            'payment':i.WORKER.amount,
            'date':i.date,
        })
    return JsonResponse({'status':'ok','data':data})



def view_complant(request):
    lid=request.POST['lid']
    c=Complaint.objects.filter(user__LOGIN=lid)
    data=[]
    for i in c:
        data.append({
            'date':i.date,
            'content':i.content,
            'reply':i.reply,
            'status':i.status
        })
    return JsonResponse({'status':'ok','data':data})


# def add_work_details(request):
#     lid=request.POST['lid']
#     job=request.POST['job']
#     amount=request.POST['amount']
#     i=Worker_details()
#     i.WORKER=Worker.objects.get(LOGIN=lid)
#     i.job=job
#     i.amount=amount
#     i.save()
#     return JsonResponse({'status':'ok'})

# def view_work_details(request):
#     lid=request.POST['lid']
#     w=Worker_details.objects.filter(WORKER__LOGIN=lid)
#     data=[]
#     for i in w:
#         data.append({
#             'job':i.job,
#             'amount':i.amount,
#         })
#     return JsonResponse({'status':'ok','data':data})

# def edit_work_details(request):
#     wid=request.POST['wid']
#     lid=request.POST['lid']
#     job=request.POST['job']
#     amount=request.POST['amount']
#     i=Worker_details.objects.get(id=wid)
#     i.WORKER=Worker.objects.get(LOGIN=lid)
#     i.job=job
#     i.amount=amount
#     i.save()
#     return JsonResponse({'status':'ok'})

# def delete_work_details(request):
#     wid=request.POST['wid']
#     i = Worker_details.objects.get(id=wid)
#     i.delete()
#     return JsonResponse({'status': 'ok'})


def worker_add_work(request):
    try:
        lid = request.POST.get('lid')
        job = request.POST.get('job')
        amount = request.POST.get('amount')

        worker = Worker.objects.get(LOGIN=lid)

        Worker_details.objects.create(
            WORKER=worker,
            job=job,
            amount=amount
        )

        return JsonResponse({'status': 'ok'})
    except Exception as e:
        return JsonResponse({'status': 'no', 'error': str(e)})


def worker_view_work(request):
    try:
        lid = request.POST.get('lid')
        worker = Worker.objects.get(LOGIN=lid)
        works = Worker_details.objects.filter(WORKER=worker)

        data = []
        for w in works:
            data.append({
                'id': w.id,
                'job': w.job,
                'amount': w.amount
            })

        return JsonResponse({'status': 'ok', 'data': data})
    except Exception as e:
        return JsonResponse({'status': 'no', 'error': str(e)})


def worker_edit_work(request):
    try:
        wid = request.POST.get('wid')
        job = request.POST.get('job')
        amount = request.POST.get('amount')

        work = Worker_details.objects.get(id=wid)
        work.job = job
        work.amount = amount
        work.save()

        return JsonResponse({'status': 'ok'})
    except Exception as e:
        return JsonResponse({'status': 'no', 'error': str(e)})


def worker_delete_work(request):
    try:
        wid = request.POST.get('wid')
        Worker_details.objects.get(id=wid).delete()
        return JsonResponse({'status': 'ok'})
    except Exception as e:
        return JsonResponse({'status': 'no', 'error': str(e)})

def view_workrequest(request):
    lid=request.POST['lid']
    w= Worker_details.objects.filter(WORKER__LOGIN=lid)
    data=[]
    for i in w:
        data.append({
            'USER':i.USER,
            'status':i.status,
            'date':i.date,
        })
    return JsonResponse({'status':'pending','data':data})

def view_payment(request):
    lid=request.POST['lid']
    w= Worker_details.objects.filter(WORKER__LOGIN=lid)
    data=[]
    for i in w:
        data.append({
            'USER':i.USER,
            'status':i.status,
            'amount':i.amount,
        })
    return JsonResponse({'status':'pending','data':data})


def view_review(request):
    lid=request.POST['lid']
    w= Worker_details.objects.filter(WORKER__LOGIN=lid)
    data=[]
    for i in w:
        data.append({
            'USER':i.USER,
            'rating':i.rating,
            'date':i.date,
            'review':i.review,
        })
    return JsonResponse({'status':'ok','data':data})

def approve_workrequest(request):
    if request.method=='POST':
        rid=request.POST['rid']

        Workrequest.objects.get(id=rid).update(status='accept')

    return JsonResponse({'status':'ok'})


def reject_workrequest(request):
    if request.method == 'POST':
        rid = request.POST['rid']

        Workrequest.objects.get(id=rid).update(status='reject')

    return JsonResponse({'status': 'ok'})


@csrf_exempt
def user_login(request):
    if request.method == 'POST':
        email = request.POST.get('email')
        password = request.POST.get('password')

        # Check email exists
        user_obj = User.objects.filter(username=email).first()
        if user_obj is None:
            return JsonResponse({
                'status': 'error',
                'message': 'Incorrect email'
            })

        # Authenticate password
        user = authenticate(username=email, password=password)
        if user is None:
            return JsonResponse({
                'status': 'error',
                'message': 'Incorrect password'
            })

        # USER MODULE LOGIN
        if user.groups.filter(name='user').exists():
            return JsonResponse({
                'status': 'ok',
                'lid': user.id,
                'type': 'users'
            })

        # WORKER LOGIN WITH APPROVAL CHECK
        elif user.groups.filter(name='worker').exists():
            worker = Worker.objects.filter(LOGIN=user).first()

            # If worker profile not found
            if worker is None:
                return JsonResponse({
                    'status': 'error',
                    'message': 'Worker profile not found'
                })

            # Check admin approval
            if worker.status == 'Approved':
                return JsonResponse({
                    'status': 'ok',
                    'lid': user.id,
                    'type': 'workers'
                })
            else:
                return JsonResponse({
                    'status': 'error',
                    'message': 'Waiting for admin approval'
                })

        # OTHER USERS (NO GROUP)
        else:
            return JsonResponse({
                'status': 'error',
                'message': 'User not allowed'
            })

    return JsonResponse({
        'status': 'error',
        'message': 'Invalid request'
    })


#
# def user_view_work_details(request):
#     works =Worker_details.objects.select_related('WORKER').all()
#
#     data = []
#     for w in works:
#         data.append({
#             'id': w.id,
#             'job': w.job,
#             'amount': w.amount,
#             'worker_name': w.WORKER.name,
#             'place': w.WORKER.place,
#             'phone': w.WORKER.ph_no,
#             'experience': w.WORKER.experience,
#         })
#
#     return JsonResponse({'status': 'ok', 'data': data})

@csrf_exempt
def user_view_work_details(request):
    works = Worker_details.objects.select_related('WORKER').all()

    data = []
    for w in works:
        data.append({
            'id': w.id,
            'worker_id': w.WORKER.id,   # ✅ ADD THIS LINE
            'job': w.job,
            'amount': w.amount,
            'worker_name': w.WORKER.name,
            'place': w.WORKER.place,
            'phone': w.WORKER.ph_no,
            'experience': w.WORKER.experience,
        })

    return JsonResponse({'status': 'ok', 'data': data})

@csrf_exempt
def send_work_request(request):
    try:
        lid = request.POST.get('lid')
        work_id = request.POST.get('work_id')
        date = request.POST.get('date')
        place = request.POST.get('place')
        description = request.POST.get('description')
        worktime = request.POST.get('worktime')

        user = Userprofile.objects.get(LOGIN__id=lid)
        work = Worker_details.objects.get(id=work_id)

        if Workrequest.objects.filter(USER=user, WORKER=work, date=date).exists():
            return JsonResponse({'status': 'already'})

        Workrequest.objects.create(
            USER=user,
            WORKER=work,
            place=place,
            description=description,
            worktime=worktime,
            status='pending',
            date=date
        )

        return JsonResponse({'status': 'ok'})

    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})


#
# def user_view_request_status(request):
#     lid = request.POST.get('lid')
#
#     try:
#         user = Userprofile.objects.get(LOGIN=lid)
#
#         requests = Workrequest.objects.select_related(
#             'WORKER__WORKER'
#         ).filter(USER=user)
#
#         data = []
#         for r in requests:
#             data.append({
#                 'request_id': r.id,
#                 'job': r.WORKER.job,
#                 'amount': r.WORKER.amount,
#                 'date': r.date,
#                 'status': r.status,
#                 'worker_name': r.WORKER.WORKER.name,
#                 'worker_id': r.WORKER.WORKER.id,  # 🔥 needed for payment
#                 'phone': r.WORKER.WORKER.ph_no,
#             })
#
#         return JsonResponse({'status': 'ok', 'data': data})
#     except Exception as e:
#         return JsonResponse({'status': 'error', 'message': str(e)})


@csrf_exempt
def user_view_request_status(request):

    lid = request.POST.get('lid')

    try:
        user = Userprofile.objects.get(LOGIN=lid)

        requests = Workrequest.objects.select_related(
            'WORKER__WORKER'
        ).filter(USER=user).order_by('-id')

        data = []

        for r in requests:

            worker = r.WORKER.WORKER

            data.append({
                'request_id': r.id,
                'job': r.WORKER.job,
                'amount': r.WORKER.amount,
                'date': r.date,
                'time': str(r.worktime),
                'place': r.place,
                'description': r.description,
                'status': r.status,
                'worker_name': worker.name,
                'worker_id': worker.id,
                'phone': worker.ph_no if worker.ph_no else "",
            })

        return JsonResponse({'status': 'ok', 'data': data})

    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})
#
# def worker_view_requests(request):
#     if request.method == "POST":
#         lid = request.POST.get('lid')
#
#         worker = Worker.objects.get(LOGIN=lid)
#
#         works = Workrequest.objects.filter(
#             WORKER__WORKER=worker,
#             status="pending"
#         )
#
#         data = []
#         for i in works:
#             data.append({
#                 "id": i.id,
#                 "username": i.USER.name,
#                 "job": i.WORKER.job,
#                 "amount": i.WORKER.amount,
#                 "date": i.date,
#                 "status": i.status
#             })
#
#         return JsonResponse({"status": "ok", "data": data})


@csrf_exempt
def worker_view_requests(request):
    if request.method == "POST":
        lid = request.POST.get('lid')

        worker = Worker.objects.get(LOGIN=lid)

        works = Workrequest.objects.filter(
            WORKER__WORKER=worker,
            status="pending"
        )

        data = []

        for i in works:
            data.append({
                "id": i.id,
                "username": i.USER.name,
                "job": i.WORKER.job,
                "amount": i.WORKER.amount,
                "date": i.date,
                "place": i.place,
                "time": str(i.worktime),
                "description": i.description,
                "status": i.status
            })

        return JsonResponse({"status": "ok", "data": data})



def worker_accept_request(request):
    if request.method == "POST":
        rid = request.POST.get("rid")

        Workrequest.objects.filter(id=rid).update(status="accept")

        return JsonResponse({"status": "ok"})


# ===============================
# Reject Work Request
# ===============================
def worker_reject_request(request):
    if request.method == "POST":
        rid = request.POST.get("rid")

        Workrequest.objects.filter(id=rid).update(status="reject")

        return JsonResponse({"status": "ok"})

# ==============================
def worker_view_accepted(request):
    if request.method == "POST":
        lid = request.POST.get('lid')

        try:
            worker = Worker.objects.get(LOGIN=lid)

            works = Workrequest.objects.filter(
                WORKER__WORKER=worker,
                status="accept"
            ).order_by('-id')

            data = []
            for i in works:
                data.append({
                    "id": i.id,
                    "username": i.USER.name,
                    "job": i.WORKER.job,
                    "amount": i.WORKER.amount,
                    "date": i.date,
                    "status": i.status
                })

            return JsonResponse({"status": "ok", "data": data})
        except:
            return JsonResponse({"status": "no"})


# ==============================
# WORKER - VIEW REJECTED WORK
# ==============================
def worker_view_rejected(request):
    if request.method == "POST":
        lid = request.POST.get('lid')

        try:
            worker = Worker.objects.get(LOGIN=lid)

            works = Workrequest.objects.filter(
                WORKER__WORKER=worker,
                status="reject"
            ).order_by('-id')

            data = []
            for i in works:
                data.append({
                    "id": i.id,
                    "username": i.USER.name,
                    "job": i.WORKER.job,
                    "amount": i.WORKER.amount,
                    "date": i.date,
                    "status": i.status
                })

            return JsonResponse({"status": "ok", "data": data})
        except:
            return JsonResponse({"status": "no"})
###paymnet###
def make_payment(request):
    if request.method == "POST":
        lid = request.POST.get('lid')
        worker_id = request.POST.get('request_id')   # coming as request_id
        amount = request.POST.get('amount')

        try:
            user = Userprofile.objects.get(LOGIN=lid)
            worker = Worker.objects.get(id=worker_id)

            # 🔹 Prevent duplicate payment
            if payment.objects.filter(USER=user, WORKER=worker, status="paid").exists():
                return JsonResponse({
                    'status': 'already_paid'
                })

            # 🔹 Create payment
            payment.objects.create(
                USER=user,
                WORKER=worker,
                amount=amount,
                status="paid"
            )

            return JsonResponse({
                'status': 'success'
            })

        except Userprofile.DoesNotExist:
            return JsonResponse({'status': 'invalid_user'})
        except Worker.DoesNotExist:
            return JsonResponse({'status': 'invalid_worker'})
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)})

    return JsonResponse({'status': 'failed'})

def view_payment_user(request):
    lid = request.POST.get('lid')

    try:
        user = Userprofile.objects.get(LOGIN=lid)
        payments = payment.objects.filter(USER=user)

        data = []
        for i in payments:
            data.append({
                'worker_name': i.WORKER.name,
                'amount': i.amount,
                'status': i.status,
            })

        return JsonResponse({'status': 'ok', 'data': data})
    except:
        return JsonResponse({'status': 'no'})


def user_view_payment_history(request):
    lid = request.POST.get('lid')

    try:
        user = Userprofile.objects.get(LOGIN__id=lid)
        payments = payment.objects.filter(USER=user).order_by('-id')

        data = []
        for i in payments:
            data.append({
                'payment_id': i.id,
                'worker_name': i.WORKER.name,  # change if your field name different
                'amount': i.amount,
                'status': i.status,
            })

        return JsonResponse({'status': 'ok', 'data': data})

    except Userprofile.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'User not found'})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})


def user_view_payment_history(request):
    lid = request.POST.get('lid')

    try:
        user = Userprofile.objects.get(LOGIN__id=lid)
        payments = payment.objects.filter(USER=user).order_by('-id')

        data = []
        for i in payments:
            data.append({
                'payment_id': i.id,
                'worker_name': i.WORKER.name,  # change if your field name different
                'amount': i.amount,
                'status': i.status,
            })

        return JsonResponse({'status': 'ok', 'data': data})

    except Userprofile.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'User not found'})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})



def user_send_complaint(request):
    if request.method == "POST":
        lid = request.POST.get('lid')
        content = request.POST.get('content')

        user = Userprofile.objects.get(LOGIN=lid)

        Complaint.objects.create(
                user=user,
                date=datetime.now().strftime("%Y-%m-%d"),
                content=content,
                reply="pending",
                status="pending"
            )

        return JsonResponse({"status": "ok"})

    return JsonResponse({"status": "no"})


def user_view_complaint(request):
    if request.method == "POST":
        lid = request.POST.get('lid')

        try:
            user = Userprofile.objects.get(LOGIN=lid)
            complaints = Complaint.objects.filter(user=user).order_by('-id')

            data = []
            for c in complaints:
                data.append({
                     "id": c.id,
                    "date": c.date,
                    "content": c.content,
                    "reply": c.reply,
                    "status": c.status,
                })

            return JsonResponse({
                "status": "ok",
                "data": data
            })
        except:
            return JsonResponse({"status": "no"})

@csrf_exempt
def user_get_accepted_workers(request):
    if request.method == "GET":
        workers = Worker.objects.filter(status="Approved")

        data = []
        for i in workers:
            data.append({
                "id": i.id,
                "name": i.name
            })

        return JsonResponse({"status": "ok", "data": data})

@csrf_exempt
def user_send_review(request):
    if request.method == "POST":
        user_id = request.POST.get('user_id')
        worker_id = request.POST.get('worker_id')
        rating = request.POST.get('rating')
        review_text = request.POST.get('review')

        user = Userprofile.objects.get(LOGIN=user_id)
        worker = Worker.objects.get(id=worker_id)

        Review.objects.create(
                USER=user,
                WORKER=worker,
                rating=rating,
                review=review_text,
                date=datetime.now().strftime("%Y-%m-%d")
            )

        return JsonResponse({"status": "ok"})

@csrf_exempt
def user_view_review(request):
    if request.method == "POST":
        lid = request.POST.get("lid")

        try:
            user = Userprofile.objects.get(LOGIN=lid)
            reviews = Review.objects.filter(USER=user).order_by("-id")

            data = []
            for r in reviews:
                data.append({
                    "id": r.id,
                    "worker_name": r.WORKER.name,
                    "job": r.WORKER.job,
                    "rating": r.rating,
                    "review": r.review,
                    "date": r.date,
                })

            return JsonResponse({"status": "ok", "data": data})
        except Exception as e:
            return JsonResponse({"status": "no", "error": str(e)})

    return JsonResponse({"status": "no"})







def fluttchangepassword(request):
    cpassword=request.POST['ucpassword']
    npassword=request.POST['unpassword']
    lid=request.POST['lid']
    conpassword=request.POST['uconpassword']
    u=User.objects.get(id=lid)
    if u.check_password(cpassword):
        if npassword==conpassword:
            u.set_password(npassword)
            u.save()
            return JsonResponse({'status':"ok"})
        else:
            return JsonResponse({'status':"no"})
    else:
        return JsonResponse({'status':"no"})


#
# @csrf_exempt
# def worker_view_accepted(request):
#     if request.method == "POST":
#         lid = request.POST.get('lid')
#
#         try:
#             worker = Worker.objects.get(LOGIN=lid)
#
#             works = Workrequest.objects.filter(
#                 WORKER__WORKER=worker,
#                 status="accept"
#             ).order_by('-id')
#
#             data = []
#             for i in works:
#                 data.append({
#                     "id": i.id,
#                     "username": i.USER.name,
#                     "job": i.WORKER.job,
#                     "amount": i.WORKER.amount,
#                     "date": i.date,
#                     "status": i.status
#                 })
#
#             return JsonResponse({"status": "ok", "data": data})
#         except:
#             return JsonResponse({"status": "no"})
#

@csrf_exempt
def worker_view_accepted(request):
    if request.method == "POST":
        lid = request.POST.get('lid')

        try:
            worker = Worker.objects.get(LOGIN=lid)

            works = Workrequest.objects.filter(
                WORKER__WORKER=worker,
                status="accept"
            ).order_by('-id')

            data = []

            for i in works:
                data.append({
                    "id": i.id,
                    "username": i.USER.name,
                    "job": i.WORKER.job,
                    "amount": i.WORKER.amount,
                    "date": i.date,
                    "time": str(i.worktime),
                    "place": i.place,
                    "description": i.description,
                    "status": i.status
                })

            return JsonResponse({"status": "ok", "data": data})

        except Exception as e:
            return JsonResponse({"status": "error", "message": str(e)})


# ==============================
# WORKER - VIEW REJECTED WORK
# ==============================
@csrf_exempt
def worker_view_rejected(request):
    if request.method == "POST":
        lid = request.POST.get('lid')

        try:
            worker = Worker.objects.get(LOGIN=lid)

            works = Workrequest.objects.filter(
                WORKER__WORKER=worker,
                status="reject"
            ).order_by('-id')

            data = []
            for i in works:
                data.append({
                    "id": i.id,
                    "username": i.USER.name,
                    "job": i.WORKER.job,
                    "amount": i.WORKER.amount,
                    "date": i.date,
                    "status": i.status
                })

            return JsonResponse({"status": "ok", "data": data})
        except:
            return JsonResponse({"status": "no"})



@csrf_exempt
def worker_view_payments(request):
    if request.method == "POST":
        lid = request.POST.get('lid')

        # 🔥 DEBUG PRINTS (VERY IMPORTANT)
        print("Received LID:", lid)

        if not lid:
            return JsonResponse({
                "status": "no",
                "error": "Login ID missing"
            })

        try:
            # 🔥 GET WORKER USING LOGIN ID
            worker = Worker.objects.get(LOGIN=lid)
            print("Worker Found:", worker)

            # 🔥 FETCH PAYMENTS FOR THIS WORKER
            payments = payment.objects.filter(WORKER=worker).order_by('-id')
            print("Total Payments Found:", payments.count())

            data = []
            for p in payments:
                data.append({
                    "payment_id": p.id,
                    "user_name": p.USER.name if p.USER else "Unknown",
                    "amount": p.amount,
                    "status": p.status,
                })

            return JsonResponse({
                "status": "ok",
                "data": data,
                "count": payments.count()  # 🔥 extra debug info
            })

        except Worker.DoesNotExist:
            print("Worker NOT found for LID:", lid)
            return JsonResponse({
                "status": "no",
                "error": "Worker not found"
            })

        except Exception as e:
            print("Error in worker_view_payments:", str(e))
            return JsonResponse({
                "status": "no",
                "error": str(e)
            })

@csrf_exempt
def worker_view_reviews(request):
    if request.method == "POST":
        lid = request.POST.get('lid')  # worker login id

        if not lid:
            return JsonResponse({
                "status": "no",
                "error": "Login ID missing"
            })

        try:
            # 🔥 Get worker using login id (same pattern as payments)
            worker = Worker.objects.get(LOGIN=lid)

            # 🔥 Fetch all reviews given to this worker
            reviews = Review.objects.filter(WORKER=worker).order_by('-id')

            data = []
            for r in reviews:
                data.append({
                    "review_id": r.id,
                    "user_name": r.USER.name if r.USER else "User",
                    "rating": r.rating,
                    "review": r.review,
                    "date": r.date,
                })

            return JsonResponse({
                "status": "ok",
                "data": data,
                "count": reviews.count()
            })

        except Worker.DoesNotExist:
            return JsonResponse({
                "status": "no",
                "error": "Worker not found"
            })

        except Exception as e:
            return JsonResponse({
                "status": "no",
                "error": str(e)
            })



@csrf_exempt
def updatelocation(request):
    try:
        lid = request.POST.get('lid')
        lat = request.POST.get('lat')
        lon = request.POST.get('lon')

        if not lid or not lat or not lon:
            return JsonResponse({
                "status": "error",
                "message": "Missing parameters"
            })

        # Get user
        try:
            user = User.objects.get(id=lid)
        except User.DoesNotExist:
            return JsonResponse({
                "status": "error",
                "message": "Invalid user"
            })

        # Check if location already exists
        location_obj = Location.objects.filter(USER=user).first()

        if location_obj:
            # Update existing location
            location_obj.latitude = lat
            location_obj.longitude = lon
            location_obj.save()
        else:
            # Create new location
            Location.objects.create(
                USER=user,
                latitude=lat,
                longitude=lon
            )

        return JsonResponse({
            "status": "ok",
            "message": "Location updated successfully"
        })

    except Exception as e:
        return JsonResponse({
            "status": "error",
            "message": str(e)
        })

def haversine(lat1, lon1, lat2, lon2):
    lat1, lon1, lat2, lon2 = map(float, [lat1, lon1, lat2, lon2])
    R = 6371  # km

    dLat = radians(lat2 - lat1)
    dLon = radians(lon2 - lon1)

    a = sin(dLat/2)**2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dLon/2)**2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))

    return R * c

@csrf_exempt
def view_nearby_workers(request):
    try:
        lid = request.POST.get('lid')
        radius = float(request.POST.get('radius', 5))

        print("LOGIN ID:", lid)

        # Get logged-in user
        try:
            login_user = User.objects.get(id=lid)
        except User.DoesNotExist:
            return JsonResponse({"status": "error", "message": "Invalid user"})

        # Get user location
        try:
            user_location = Location.objects.filter(USER=login_user).latest('id')
        except Location.DoesNotExist:
            return JsonResponse({
                "status": "error",
                "message": "User location not found"
            })

        user_lat = float(user_location.latitude)
        user_lon = float(user_location.longitude)

        print("USER LAT:", user_lat)
        print("USER LON:", user_lon)

        workers_list = []

        # Approved workers
        workers = Worker.objects.filter(status='Approved')
        print("TOTAL APPROVED WORKERS:", workers.count())

        for worker in workers:
            try:
                worker_user = worker.LOGIN

                # Check worker location
                worker_location = Location.objects.filter(USER=worker_user).latest('id')

                worker_lat = float(worker_location.latitude)
                worker_lon = float(worker_location.longitude)

                print(f"Worker {worker.name} Location:", worker_lat, worker_lon)

                distance = haversine(user_lat, user_lon, worker_lat, worker_lon)
                print(f"Distance to {worker.name}: {distance} KM")

                if distance <= radius:
                    workers_list.append({
                        "worker_id": worker.id,
                        "name": worker.name,
                        "phone": worker.ph_no,
                        "photo": worker.photo,
                        "job": worker.job,
                        "place": worker.place,
                        "experience": worker.experience,
                        "latitude": worker_lat,
                        "longitude": worker_lon,
                        "distance_km": round(distance, 2),
                    })

            except Location.DoesNotExist:
                print(f"No location for worker: {worker.name}")
                continue

        workers_list.sort(key=lambda x: x['distance_km'])

        print("FINAL NEARBY WORKERS:", len(workers_list))

        return JsonResponse({
            "status": "ok",
            "workers": workers_list
        })

    except Exception as e:
        print("ERROR:", str(e))
        return JsonResponse({
            "status": "error",
            "message": str(e)
        })


@csrf_exempt
def view_worker_work_details(request):
    try:
        worker_id = request.POST.get('worker_id')

        worker = Worker.objects.get(id=worker_id)

        works = Worker_details.objects.filter(WORKER=worker)

        work_list = []
        for w in works:
            work_list.append({
                "work_id": w.id,
                "job": w.job,
                "amount": w.amount,
            })

        return JsonResponse({
            "status": "ok",
            "works": work_list
        })

    except Worker.DoesNotExist:
        return JsonResponse({"status": "error", "message": "Worker not found"})
    except Exception as e:
        return JsonResponse({"status": "error", "message": str(e)})



@csrf_exempt
def view_worker_reviews(request):
    if request.method == "POST":

        worker_id = request.POST.get('worker_id')
        lid = request.POST.get('lid')

        try:
            user = Userprofile.objects.get(LOGIN=lid)
            worker = Worker.objects.get(id=worker_id)

            reviews = Review.objects.filter(
                WORKER=worker
            ).exclude(USER=user).order_by('-id')

            data = []

            for r in reviews:
                data.append({
                    "username": r.USER.name,
                    "rating": r.rating,
                    "review": r.review,
                    "date": r.date
                })

            return JsonResponse({
                "status": "ok",
                "data": data
            })

        except Exception as e:
            return JsonResponse({
                "status": "error",
                "message": str(e)
            })




def view_notificationflutter(request):
    notifications = Notification.objects.all().order_by('-date')

    data = []
    for i in notifications:
        data.append({
            'id': i.id,
            'message': i.message,
            'date': i.date.strftime("%Y-%m-%d %H:%M:%S")
        })

    return JsonResponse({
        'status': 'ok',
        'data': data
    })