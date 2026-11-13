# WorkBridge

WorkBridge connects customers with skilled local workers (electricians, plumbers, carpenters and similar). Customers find nearby workers, request work, pay and leave reviews. Workers list their services, accept or reject requests and receive payments. An admin web panel manages the whole platform.

The repository has two parts:

| Folder | What it is |
|---|---|
| `workbridge/` | Django backend: admin web panel and JSON API used by the mobile app |
| `untitled1/` | Flutter mobile app for customers (users) and workers |

## Features

### Customer (mobile app)
- Sign up with email OTP verification, log in, forgot/reset/change password
- Find **nearby workers** within a chosen radius, using location updates and distance calculation
- View a worker's services, rates and reviews
- Send work requests (place, description, time) and track their status
- Pay for accepted work with **Razorpay**
- View payment history
- Send complaints and read admin replies
- Rate and review workers
- View notifications from the admin

### Worker (mobile app)
- Register with a category and profile photo, edit profile
- Add, edit and delete services with their rates
- View, accept or reject work requests
- View accepted and rejected jobs, payments and reviews

### Admin (web panel)
- Approve or reject worker registrations
- Manage work categories (add, edit, delete)
- View users, workers, reviews and complaints, and reply to complaints
- Send notifications to app users

## Tech Stack

- **Backend:** Python, Django, SQLite, Gmail SMTP (OTP and notification email)
- **Mobile app:** Flutter (Dart SDK ^3.11), `http`, `shared_preferences`, `geolocator`, `permission_handler`, `image_picker`, `razorpay_flutter`, `url_launcher`, `fluttertoast`
- **Admin UI:** HTML templates with Bootstrap

## Project Structure

```
WorkBridge/
├── workbridge/                  # Django backend
│   ├── manage.py
│   ├── db.sqlite3
│   ├── requirements.txt
│   ├── media/                   # Uploaded photos
│   ├── templates/               # Admin panel pages
│   ├── workbridge/              # Project settings and root URLs
│   └── myapp/                   # Models, views, URLs, migrations, static files
└── untitled1/                   # Flutter app
    ├── pubspec.yaml
    └── lib/
        ├── main.dart, login.dart, forgetpassword.dart, ...
        ├── user/                # Customer screens
        └── worker/              # Worker screens
```

## Data Model

`Userprofile`, `Worker`, `Category`, `Worker_details` (services and rates), `Workrequest`, `payment`, `Review`, `Complaint`, `Chat`, `Location`, `Notification` and `EmailOTP`. Both `Userprofile` and `Worker` link one-to-one to Django's built-in `User`.

## Getting Started

### 1. Backend (Django)

Requires Python 3.10 or newer.

```bash
cd workbridge

python -m venv venv
source venv/bin/activate          # Windows: venv\Scripts\activate

pip install -r requirements.txt

python manage.py migrate
python manage.py createsuperuser  # Admin login

# Listen on all interfaces so a phone on the same network can reach it
python manage.py runserver 0.0.0.0:8000
```

The admin panel opens at <http://127.0.0.1:8000/myapp/login_get>. The mobile app talks to the API under `/myapp/`.

### 2. Mobile app (Flutter)

Requires the Flutter SDK (Dart ^3.11).

```bash
cd untitled1
flutter pub get
flutter run
```

On the app's first screen, enter the IP address of the machine running the Django server. The app builds its API URL as `http://<ip>:8000/myapp/...`. The phone and the server must be on the same network. When using the Android emulator, use `10.0.2.2` as the IP.

## Configuration

Set these before running outside a local test setup:

- **Email (OTP and notifications):** configure `EMAIL_HOST_USER` and `EMAIL_HOST_PASSWORD` (a Gmail app password) in `workbridge/workbridge/settings.py`. Read them from environment variables instead of committing them.
- **Razorpay:** add your own Razorpay key in `untitled1/lib/user/payment.dart`.
- **Production:** replace `SECRET_KEY`, set `DEBUG = False` and restrict `ALLOWED_HOSTS` (currently `['*']`).

## API Overview

Main endpoint groups, all under `/myapp/`:

| Area | Endpoints |
|---|---|
| Auth | `login_post`, `user_login`, `send_otp`, `verify_otp_register`, `send_forgot_otp`, `reset_password`, `fluttchangepassword` |
| Customer | `view_profile`, `update_profile`, `view_nearby_workers`, `send_work_request`, `user_view_request_status`, `make_payment`, `user_send_complaint`, `user_send_review` |
| Worker | `worker_register`, `worker_add_work`, `worker_view_requests`, `worker_accept_request`, `worker_reject_request`, `worker_view_payments` |
| Shared | `updatelocation`, `get_categories`, `view_notificationflutter` |

