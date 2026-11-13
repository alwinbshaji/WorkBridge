"""workbridge URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include

from myapp import views

urlpatterns = [
    path('login_get',views.login_get),
    path('login_post',views.login_post),
    path('view_worker',views.view_worker),
    path('view_approved_workers',views.view_approved_workers),
    path('add_category',views.add_category),
    path('view_category',views.view_category),
    path('edit_category/<id>',views.edit_category),
    path('delete_category/<id>',views.delete_category),
    path('view_user',views.view_user),
    path('view_complaint',views.view_complaint),
    path('view_reviews',views.view_reviews),
    path('admin_home/',views.admin_home),
    path('admin_approved_worker/<id>',views.admin_approved_worker),
    path('admin_rejected_worker/<id>',views.admin_rejected_worker),
    path('send_reply/<id>',views.send_reply),
    path('send_reply_post/',views.send_reply_post),
    path('add_category_post',views.add_category_post),
    path('edit_category_post',views.edit_category_post),
    path('addnotification_get/',views.addnotification_get),
    path('addnotification_post/',views.addnotification_post),
    path('viewnotification/',views.viewnotification),
    path('delete_notification/<id>',views.delete_notification),
    path('view_notificationflutter/',views.view_notificationflutter),







   path('get_categories/',views.get_categories),

    path('worker_register/',views.worker_register),
    path('user_login/',views.user_login),




    ########## USER ############

    path('send_otp/', views.send_otp),
    path('verify_otp_register/', views.verify_otp_register),
    path('send_forgot_otp/', views.send_forgot_otp),
    path('reset_password/', views.reset_password),
    path('view_profile/',views.view_userprofile),
    path('update_profile/',views.update_profile),
    path('user_view_work_details/',views.user_view_work_details),
    path('send_work_request/',views.send_work_request),
    path('user_view_request_status/',views.user_view_request_status),
    path('make_payment/',views.make_payment),
    path('view_payment_user/',views.view_payment_user),
    path('user_view_payment_history/',views.user_view_payment_history),
    path('user_send_complaint/',views.user_send_complaint),
    path('user_view_complaint/',views.user_view_complaint),
    path('user_send_review/',views.user_send_review),
    path('user_get_accepted_workers/',views.user_get_accepted_workers),
    path('user_view_review/',views.user_view_review),
    path('fluttchangepassword/',views.fluttchangepassword),

    ########worker######

    path('worker_view_profile/',views.view_workerprofile),
    path('worker_edit_profile/',views.edit_worker),
    path('worker_add_work/',views.worker_add_work),
    path('worker_view_work/',views.worker_view_work),
    path('worker_edit_work/',views.worker_edit_work),
    path('worker_delete_work/',views.worker_delete_work),
    path('worker_view_requests/',views.worker_view_requests),
    path('worker_accept_request/',views.worker_accept_request),
    path('worker_reject_request/',views.worker_reject_request),
    path('worker_view_accepted/',views.worker_view_accepted),
    path('worker_view_rejected/',views.worker_view_rejected),
    path('worker_view_payments/',views.worker_view_payments),
    path('worker_view_reviews/',views.worker_view_reviews),
    path('updatelocation/',views.updatelocation),
    path('view_nearby_workers/',views.view_nearby_workers),
    path('view_worker_work_details/',views.view_worker_work_details),



    path('view_worker_reviews/',views.view_worker_reviews),
]
