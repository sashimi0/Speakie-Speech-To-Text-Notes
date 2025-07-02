# Speakie: Speech-to-Text Notes

Speakie is an iOS app that captures live speech, transcribes it to text, and *can* add correct punctuation using OpenAI. It’s designed as a minimal note-taking tool that creates polished text from your voice.

---

## Project Overview

Meant to show how to use SFSpeechRecognizer to display audio as text in a UITextView. The spoken audio is not punctuated by default. You must say the punctuation (ex: This is a test "period". Hello "comma" how are you "question mark".)
*You must add OpenAI API to have it done automatically. For the purposes of this project, I have not added API key, but instructions are included for how to generate one.

---

## Features

- Live speech-to-text transcription using SFSpeechRecognizer  
- Real-time updates displayed in a UITextView  
- Automatic grammar and punctuation correction via OpenAI’s API  
- Start/Stop recording button for intuitive use  
- Simple Storyboard-based UI for easy customization

---

## Technologies Used

- Swift + Storyboard
- AVFoundation (audio input)
- Speech framework (SFSpeechRecognizer)
- OpenAI Chat Completion API (for text correction)*

---

## Requirements

- macOS with Xcode 15 or newer
- iOS device running iOS 16.0 or later (microphone input does not work in Simulator)
- OpenAI account with an API key (only for automatic punctuation)

---

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/sashimi0/speakie-speech-to-text-notes.git
   cd speakie-speech-to-text-notes
   ```
3.	Connect your iPhone
Plug it into your Mac with a USB cable or connect via Wi-Fi.
4.	Open the project in Xcode
Double-click SpeakieSpeechToTextNotes.xcodeproj.
5.	Select your iPhone as the target
At the top of Xcode, next to the Run button, pick your iPhone from the device list.
6.	Set your development team
	•	Click the blue project file in the Xcode sidebar.
	•	Go to Signing & Capabilities.
	•	Under Team, choose your Apple Account.
(Use your personal Apple ID if you don’t have a paid developer account.)
7.	Make sure the Bundle Identifier is unique
For example: com.yourname.speakie.
8.	Click Run (▶️)
Xcode will build and install the app on your iPhone.
9.	Trust your developer certificate (first time only)
If you get a “developer not trusted” error on your phone:
	•	Go to Settings → General → VPN & Device Management.
	•	Tap your developer profile and tap Trust.
	8.	Use the app
	•	The app will launch on your iPhone.
	•	Grant permissions for the microphone and speech recognition when asked.
