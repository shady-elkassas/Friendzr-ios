//
//  SignalRSwiftViewController.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 25/08/2021.
//

import UIKit
import SignalRSwift

class SignalRSwiftViewController: UIViewController {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var startButton: UIBarButtonItem!

    var chatHub: HubProxy!
    var connection: HubConnection!
    var name: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        connection = HubConnection(withUrl: "http://swiftr.azurewebsites.net") //SignalR("http://swiftr.azurewebsites.net")
        //        connection.signalRVersion = .v2_2_0

        chatHub = self.connection.createHubProxy(hubName: "chatHub")
        _ = chatHub.on(eventName: "broadcastMessage") { (args) in
            if let name = args[0] as? String, let message = args[1] as? String, let text = self.chatTextView.text {
                self.chatTextView.text = "\(text)\n\n\(name): \(message)"
            }
        }

        // SignalR events

        connection.started = { [unowned self] in
            self.statusLabel.text = "Connected"
            self.startButton.isEnabled = true
            self.startButton.title = "Stop"
            self.sendButton.isEnabled = true
        }

        connection.reconnecting = { [unowned self] in
            self.statusLabel.text = "Reconnecting..."
        }

        connection.reconnected = { [unowned self] in
            self.statusLabel.text = "Reconnected. Connection ID: \(self.connection!.connectionId!)"
            self.startButton.isEnabled = true
            self.startButton.title = "Stop"
            self.sendButton.isEnabled = true
        }

        connection.closed = { [unowned self] in
            self.statusLabel.text = "Disconnected"
            self.startButton.isEnabled = true
            self.startButton.title = "Start"
            self.sendButton.isEnabled = false
        }

        connection.connectionSlow = { print("Connection slow...") }

        connection.error = { [unowned self] error in
            let anError = error as NSError
            if anError.code == NSURLErrorTimedOut {
                self.connection.start()
            }
        }

        connection.start()
    }

    override func viewDidAppear(_ animated: Bool) {
        let alertController = UIAlertController(title: "Name", message: "Please enter your name", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.name = alertController.textFields?.first?.text

            if let name = self?.name , name.isEmpty {
                self?.name = "Anonymous"
            }

            alertController.textFields?.first?.resignFirstResponder()
        }

        alertController.addTextField { textField in
            textField.placeholder = "Your Name"
        }

        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func send(_ sender: AnyObject?) {
        if let hub = chatHub, let message = messageTextField.text {
            hub.invoke(method: "send", withArgs: [name, message])
        }
        messageTextField.resignFirstResponder()
    }

    @IBAction func startStop(_ sender: AnyObject?) {
        if startButton.title == "Start" {
            connection.start()
        } else {
            connection.stop()
        }
    }

}
