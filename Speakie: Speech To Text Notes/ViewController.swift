//
//  ViewController.swift
//  SpeakieSpeechToTextNotes
//
//  Created by sasha on 7/2/25.
//

import UIKit
import Speech
import AVFoundation

class ViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var startButton: UIButton!

    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    var request: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?

    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.isEnabled = false
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.startButton.isEnabled = true
                case .denied, .restricted, .notDetermined:
                    self.startButton.isEnabled = false
                    self.textView.text = "Speech recognition not available."
                @unknown default:
                    self.startButton.isEnabled = false
                    self.textView.text = "Unknown authorization status."
                }
            }
        }
    }

    @IBAction func startRecordingTapped(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            request?.endAudio()
            startButton.setTitle("Start Recording", for: .normal)
        } else {
            startRecording()
            startButton.setTitle("Stop Recording", for: .normal)
        }
    }

    func startRecording() {
        recognitionTask?.cancel()
        recognitionTask = nil

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session error: \(error.localizedDescription)")
            textView.text = "Audio session setup failed: \(error.localizedDescription)"
            return
        }

        request = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = request else {
            print("Failed to create recognition request")
            textView.text = "Failed to create recognition request."
            return
        }

        let inputNode = audioEngine.inputNode

        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                let rawText = result.bestTranscription.formattedString
                self.textView.text = rawText
                if result.isFinal {
                    self.punctuateText(rawText)
                }
            }

            if let error = error {
                print("Recognition error: \(error.localizedDescription)")
                self.textView.text = "Recognition error: \(error.localizedDescription)"
            }

            if error != nil || (result?.isFinal ?? false) {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.request = nil
                self.recognitionTask = nil
                self.startButton.setTitle("Start Recording", for: .normal)
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine start error: \(error.localizedDescription)")
            textView.text = "Audio engine failed to start: \(error.localizedDescription)"
            return
        }

        textView.text = "Listening..."
    }

    func punctuateText(_ rawText: String) {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            print("OpenAI API key not set in environment.")
            textView.text = "OpenAI API key missing."
            return
        }
        
        let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let prompt = "Please punctuate and correct the grammar of this text: \"\(rawText)\""
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant that formats speech text."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.3
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("OpenAI request error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.textView.text = "Error contacting OpenAI: \(error.localizedDescription)"
                }
                return
            }
            guard let data = data else {
                print("No data returned from OpenAI.")
                DispatchQueue.main.async {
                    self.textView.text = "No response from OpenAI."
                }
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    DispatchQueue.main.async {
                        self.textView.text = content
                    }
                } else {
                    print("Unexpected response: \(String(data: data, encoding: .utf8) ?? "")")
                    DispatchQueue.main.async {
                        self.textView.text = "Unexpected OpenAI response."
                    }
                }
            } catch {
                print("JSON parse error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.textView.text = "Failed to parse OpenAI response."
                }
            }
        }
        task.resume()
    }
}
