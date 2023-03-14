# ReminderApp

ReminderApp is a mobile application developed in Flutter that helps users to set reminders for various tasks. This app supports login and registration via a Python backend through a REST API.

## Installation

1. Clone the repository to your local machine using `git clone https://github.com/godfreyp/Flutter-Reminders-App.git`
2. Install [Flutter](https://flutter.dev/docs/get-started/install) and all dependencies required to run Flutter apps.
3. Run `flutter pub get` to install all necessary packages.

## Usage

To use the app, follow these steps:

1. Start the Python backend by running `python backendservice.py`.
2. Start the Python microservices for contact support; `microservice_server_flask.py`, `contacts_server_zmq.py`, and `handshake_server_zmq.py`
2. Launch the app in an emulator or a physical device by running `flutter run`.
3. Register a new user account or login to an existing account.
4. Set reminders for various tasks and view them in the app.

## Credits

ReminderApp was developed by [Patrick Godfrey](https://github.com/yourusername).
