# EduAssist

## Introduction

This Flutter application is designed to assist educators with two key tasks: creating lesson plans and providing automated feedback on student essays. Leveraging the power of Google Cloud Platform and cutting-edge AI, this app aims to streamline teaching workflows and enhance student learning. The frontend is built using Flutter and developed with the help of Google's Project IDX platform, ensuring a modern and efficient development experience. The backend utilizes Google Cloud Functions and the Google Gemini API to provide intelligent lesson plan generation and essay analysis.

## Features

* **Lesson Plan Generation:**
    * Generate comprehensive lesson plans based on a specified topic and grade level.
    * Leverages the Google Gemini API to create well-structured plans including objectives, key concepts, teaching strategies, and suggested activities.
    * Displays generated lesson plans in a clear, scrollable format.
* **Automated Essay Feedback:**
    * Allows teachers or students to input essay text for automated analysis.
    * Utilizes the Google Gemini API to assess essays based on predefined criteria (Grammar, Clarity, Content Relevance, Structure).
    * Provides an overall score/grade ("Excellent," "Good," "Needs Improvement").
    * Generates personalized, actionable feedback for each rubric criterion.
    * Presents the score and feedback in an organized and easy-to-understand manner.

## Screenshots

* **Welcome Screen:** Shows the app's name and options to navigate to the Lesson Planner or Essay Feedback features.
    * `[![welcomescreen.jpg](https://i.postimg.cc/YCGbkvMH/welcomescreen.jpg)](https://postimg.cc/9D2GYFD8)`
* **Lesson Planner Input:** Displays fields for entering the lesson topic and grade level.
    * `![Lesson Planner Input](https://photos.app.goo.gl/eWqBtbXAQbtQ9ui17)`
* **Generated Lesson Plan:** Shows a sample generated lesson plan with its different sections.
    * `![Generated Lesson Plan](https://photos.app.goo.gl/7Ye67gp49Lx463yo8)`
* **Essay Feedback Input:** Presents a text area for pasting the student essay.
    * `![Essay Feedback Input](https://photos.app.goo.gl/jaj9x8JF5rtmbrdr6)`
* **Essay Feedback Results:** Displays the overall score and detailed feedback for an analyzed essay.
    * `![Essay Feedback Results](https://photos.app.goo.gl/z5eFz4SGLESfBd7T8)`

## Installation and Setup

To run this application locally, you will need to have Flutter installed on your development machine.

1.  **Install Flutter:** Follow the official Flutter installation guide for your operating system: [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)

2.  **Clone the Repository:**
    ```bash
    git clone YOUR_REPOSITORY_URL
    cd myapp
    ```
    *(Replace `YOUR_REPOSITORY_URL` with the actual URL of your project's Git repository.)*

3.  **Get Dependencies:**
    ```bash
    flutter pub get
    ```
    This command downloads all the necessary Flutter packages and dependencies for the project.

4.  **Running the App:**
    ```bash
    flutter run
    ```
    This command builds and runs the Flutter application on your connected device or emulator.

**Note:** The automated features of this application rely on Google Cloud Functions and the Google Gemini API. To fully utilize these features in a deployed environment, you will need to:

* Set up a Google Cloud Project.
* Enable the Cloud Functions and Generative AI services.
* Deploy the backend Cloud Functions (code for which would be provided separately).
* Obtain a Gemini API key and configure it as an environment variable for your Cloud Function.
* Update the frontend code with the correct URL for your deployed Cloud Function.

This README provides a basic overview for running the Flutter frontend locally. Deployment of the backend and full integration with cloud services requires additional configuration on Google Cloud Platform.

