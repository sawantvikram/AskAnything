//
//  ViewController.swift
//  AskAnything
//
//  Created by Touchzing media on 28/01/24.
//

import UIKit
import Lottie


class ViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    private  var animationView: LottieAnimationView!
   
    var totalmsg: [Int: (msg: String, user: String)] = [:]
 
    var flag :  Bool = false
    @IBOutlet weak var chatBox: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bgimg = UIImage(named: "Bg")
        self.view.layer.contents = bgimg?.cgImage
        tableView.delegate = self
                tableView.dataSource = self
        // Do any additional setup after loading the view.
        let dbManager = DatabaseManager.getInstance()
        
        totalmsg = dbManager.getAllChats()
        
        chatBox.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
               view.addGestureRecognizer(tapGesture)
   
        
        let leftView = UIView()
        
        leftView.frame = CGRect(x: 0, y: 0, width: 15, height: chatBox.frame.size.height)
        
        chatBox.leftView = leftView
        chatBox.leftViewMode = .always
        chatBox.clipsToBounds = true
        chatBox.layer.cornerRadius = chatBox.frame.size.height/2
        
        
       
        
        animationView = .init(name: "loadingAnimatoin")
         
         animationView!.frame = CGRect(x: 0, y: 0, width: 50, height: chatBox.frame.size.height)
         
         // 3. Set animation content mode
         
         animationView!.contentMode = .scaleAspectFit
         
         // 4. Set animation loop mode
         
         animationView!.loopMode = .loop
         
         // 5. Adjust animation speed
         
         animationView!.animationSpeed = 0.5
         
        chatBox.rightView = animationView
        chatBox.rightViewMode = .always
         // 6. Play animation
         
        chatBox.rightView?.isHidden = true
        
        tableView.contentSize = CGSize(width: tableView.contentSize.width, height: tableView.contentSize.height + 100)

        
        
        let attributes: [NSAttributedString.Key: Any] = [
                   .font: UIFont.systemFont(ofSize: 20, weight: .semibold), // Change font size and weight as needed
                   .foregroundColor: UIColor.gray // Change placeholder color as needed
               ]
               let attributedPlaceholder = NSAttributedString(string: "Message", attributes: attributes)
               
               // Assign attributed placeholder to text field
               chatBox.attributedPlaceholder = attributedPlaceholder
      
            self.scrollToLastItem()
     
        sendBtn.isEnabled = false
        
    }
    @IBAction func chatBoxEddditingChanged(_ sender: Any) {
        
        if(chatBox.text?.count == 0){
            sendBtn.isEnabled = false
        }else{
            sendBtn.isEnabled = true
        }
        
    }
    
    func startAnimation(){
        self.chatBox.rightView?.isHidden = false
        animationView!.play()
        scrollToLastItem()
    }
    func stopAnimation(){
        self.chatBox.rightView?.isHidden = true
        animationView!.stop()
        scrollToLastItem()
    }

    @IBAction func sendBtnClicked(_ sender: Any) {
        dismissKeyboard()
        
        
        if !Reachability.isConnectedToNetwork() {
            
            showToast(message: "No Network")
            return
        }
        
        
        let dbManager = DatabaseManager.getInstance()
        
        if let message = chatBox.text, !message.isEmpty {
            startAnimation()
            let Usermessage = (msg: message , user: "user")
            
            if totalmsg.count > 0 {
                
                totalmsg[totalmsg.count] = Usermessage
            }else {
                totalmsg[0] = Usermessage
            }
          
            self.chatBox.text = ""
            
            tableView.reloadData()
            
            scrollToLastItem()
            
            sendRequest(msg: message) { [self] fetchRole, content in
                // Ensure fetchRole and content are not nil
                guard let fetchRole = fetchRole, let content = content else {
                    print("Error: fetchRole or content is nil")
                    
                    if totalmsg.count > 1 {
                        
                        totalmsg.removeValue(forKey: totalmsg.count-1)
                    }else {
                        totalmsg.removeAll()
                    }
                    
                    DispatchQueue.main.async { [self] in
                        self.tableView.reloadData()
                        chatBox.text = message
                        stopAnimation()
                    }
                    
                    
                   
                    
                  
                    
                    return
                }
                
                
                DispatchQueue.main.async { [self] in
                    
                    if totalmsg.count > 1 {
                        
                        totalmsg.removeValue(forKey: totalmsg.count-1)
                    }else {
                        totalmsg.removeAll()
                    }
                    
                    
                    let Usermessage = (msg: message , user: "user")
                    
                    if totalmsg.count > 0 {
                        
                        totalmsg[totalmsg.count] = Usermessage
                    }else {
                        totalmsg[0] = Usermessage
                    }
                  
                  
                    dbManager.insertChats(user: "user", content: message)
                    
                    
                    // Create a new message
                    let newMessage = (msg: content, user: fetchRole)
                    
                    dbManager.insertChats(user: fetchRole, content: content)
                    
                    // Determine the index for the new message
                    let newIndex = totalmsg.count // Use count as the new index, assuming keys are consecutive integers
                    
                    // Add the new message to the totalmsg dictionary
                    totalmsg[newIndex] = newMessage
                    
                    self.chatBox.text = ""
                               // Reload the table view
                    tableView.reloadData()
                    stopAnimation()
                    
            
                           }
                
                
                
            }
            
         
        } else {
            print("Chat box is empty")
        }
        
      
    }

   
    
    func sendRequest(msg: String, completion: @escaping (_ fetchRole: String?, _ content: String?) -> Void) {
        // Replace "<YOUR_API_TOKEN>" with your actual ChatGPT API token
        let apiToken = "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"
        let apiUrl = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        // Prepare the request
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Construct the request body
        let requestData: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": msg]
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestData, options: [])
        } catch {
            print("Error serializing JSON: \(error)")
            completion(nil, nil)
            return
        }
        
        // Send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error sending request: \(error)")
                completion(nil, nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil, nil)
                return
            }
            
            // Print the JSON response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON Response: \(jsonString)")
                print("JSON Response: \(jsonString)")
                print("JSON Response: \(jsonString)")
                print("JSON Response: \(jsonString)")
                print("JSON Response: \(jsonString)")
                print("JSON Response: \(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(ChatCompletionResponse.self, from: data)
                
                // Check if choices array is not empty
                if let firstChoice = response.choices.first {
                    let fetchRole = firstChoice.message.role
                    let content = firstChoice.message.content
                    completion(fetchRole, content)
                } else {
                    print("No choices found in response")
                    completion(nil, nil)
                }
            } catch {
                print("Error parsing response: \(error)")
                completion(nil, nil)
            }
        }
        
        task.resume()
    }

    func parseResponse(data: Data) -> (fetchRole: String?, content: String?) {
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(ChatCompletionResponse.self, from: data)
            
            if let choice = response.choices.first {
                let role = choice.message.role
                let content = choice.message.content
                return (role, content)
            } else {
                print("No choices found in response")
            }
        } catch {
            print("Error decoding response: \(error)")
        }
        return (nil, nil)
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        totalmsg.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        UIPasteboard.general.string = totalmsg[indexPath.row]?.msg
        showToast(message: "Text Copied")
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! chatTableViewCell
        
        // Check if message exists for the current index
        guard let message = totalmsg[indexPath.row] else {
            return cell
        }
        
        
       
        // Set message text
        cell.message.text = message.msg
        
        // Calculate required width for the text
           let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
           let textSize = cell.message.sizeThatFits(maxSize)
           
           // Set label width based on text length
           let requiredWidth = min(textSize.width, tableView.frame.size.width - 80)
           
        let maxWidth  = tableView.frame.size.width - 30
        
        
        
        // Apply alignment based on user or assistant
        if message.user == "user" {
           
            cell.msgInsideRight.constant = 5
            cell.msgInsideLeft.constant = 5
            cell.msgusergap.constant = maxWidth - requiredWidth
            cell.msgAsstiGap.constant = 15
            cell.message.textAlignment = .left
            cell.chatView.backgroundColor = #colorLiteral(red: 1, green: 0.9148494601, blue: 0.73961097, alpha: 1)
            cell.message.textColor = .black
            
        } else {
            cell.message.textColor = .white
            cell.msgInsideRight.constant = 5
            cell.msgInsideLeft.constant = 5
            cell.msgusergap.constant = 15
            cell.msgAsstiGap.constant = maxWidth - requiredWidth
            cell.message.textAlignment = .left
            cell.chatView.backgroundColor = #colorLiteral(red: 0.1498186573, green: 0.2308027569, blue: 0.3140370939, alpha: 1)
        }
        
        return cell
        
    }

    func scrollToLastItem() {
//          guard totalmsg.isEmpty else { return }
        
        if totalmsg.count == 0 {
            return
        }
        
        tableView.scrollToRow(at: IndexPath(row: tableView.numberOfRows(inSection: 0) - 1, section: 0), at: .bottom, animated: true)
        tableView.contentOffset.y += tableView.adjustedContentInset.bottom


      }
      
    
    @objc func dismissKeyboard() {
          view.endEditing(true)
      }
      
      func textFieldDidBeginEditing(_ textField: UITextField) {
          // Move the text field above the keyboard
          moveTextField(textField: textField, moveDistance: -350, up: true)
      }
      
      func textFieldDidEndEditing(_ textField: UITextField) {
          // Reset the text field position
          moveTextField(textField: textField, moveDistance: -350, up: false)
      }
      
      func moveTextField(textField: UITextField, moveDistance: Int, up: Bool) {
          let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
          
          UIView.animate(withDuration: 0.3, animations: {
              self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
          })
      }
    
    struct ChatCompletionResponse: Codable {
        let object: String
        let created: Int
        let model: String
        let choices: [Choice]
        let usage: Usage
        let systemFingerprint: String?

        enum CodingKeys: String, CodingKey {
            case object, created, model, choices, usage
            case systemFingerprint = "system_fingerprint"
        }
    }

    struct Choice: Codable {
        let message: Message
        let finishReason: String

        enum CodingKeys: String, CodingKey {
            case message
            case finishReason = "finish_reason"
        }
    }

    struct Message: Codable {
        let role: String
        let content: String
    }

    struct Usage: Codable {
        let promptTokens, completionTokens, totalTokens: Int

        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }


    func showToast(message: String) {
        let toastView = CustomToastView(frame: CGRect(x: 20, y: view.frame.height - 100, width: view.frame.width - 40, height: 50))
        toastView.messageLabel.text = message
        
        view.addSubview(toastView)
        
        UIView.animate(withDuration: 0.3, animations: {
            toastView.alpha = 1.0
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                UIView.animate(withDuration: 0.3) {
                    toastView.alpha = 0.0
                } completion: { _ in
                    toastView.removeFromSuperview()
                }
            }
        }
    }
    
    
}

