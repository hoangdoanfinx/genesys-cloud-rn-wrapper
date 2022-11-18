//
//  GenesysMessenger.swift
//  InAppChat
//
//  Created by HoangDoan on 15/11/2022.
//

import Foundation
import MessengerTransport



@objc(GenesysMessenger)
class GenesysMessenger: RCTEventEmitter {


  
  var config:Configuration? = nil
  var messengerTransport: MessengerTransport? = nil
  public var client: MessagingClient? = nil
  var attachmentId: String? = nil

  public override init() {
    super.init()
  }
  
    
  @objc func setupGenesis() {
    config = Configuration(deploymentId: "d407da6f-32f6-4f67-b37e-fdcc56fe2f53",domain: "mypurecloud.jp", logging: true, reconnectionTimeoutInSeconds: 300 )
    messengerTransport = MessengerTransport(configuration: config!)
    client = messengerTransport?.createMessagingClient()


    
    client?.stateChangedListener = { [weak self] stateChange in
      print("State Event. New state: \(stateChange.newState), old state: \(stateChange.oldState)")
      let newState = stateChange.newState
      switch newState {
      case _ as MessagingClientState.Configured:
        print("confifured")
      case _ as MessagingClientState.Closed:
        print("closed")
      case let error as MessagingClientState.Error:
        print("Socket <error>. code: <\(error.code.description)> , message: <\(error.message ?? "No message")>")
      default:
        break
      }

    }
    
         
    
    client?.messageListener = { event in
        switch event {
        case let attachmentUpdated as MessageEvent.AttachmentUpdated:
          print("Attachment Updated: <\(attachmentUpdated.attachment.description)>")
          // Only finish the wait when the attachment has finished uploading.
          if let uploadedAttachment = attachmentUpdated.attachment.state as? Attachment.StateUploaded {
            print("uploadedAttachmentinbound")
            self.sendAttachment(attachmentId: self.attachmentId!)
          }
          if let uploadedAttachment = attachmentUpdated.attachment.state as? Attachment.StateSent {
            self.sendEvent(withName: "onMessage", body: ["type": "inbound", "data": uploadedAttachment.downloadUrl])
          }
        case let inserted as MessageEvent.MessageInserted:

          if(inserted.message.direction == Message.Direction.outbound) {

            
            self.sendEvent(withName: "onMessage", body: ["type": "outbound", "message": inserted.message.text])
              // Message sent by Agent (Received)
          }
          if(inserted.message.direction == Message.Direction.inbound) {

            self.sendEvent(withName: "onMessage", body: ["type": "inbound", "message": inserted.message.text])
          }
        case let history as MessageEvent.HistoryFetched:
          print(history.messages)
        default:
          break
        }
    }
    
    do {

      try client?.connect()
    } catch {
      print("there is an error here")
      // Handle exceptions here.
    }
    
  }
  
  
  
  @objc func uploadAttachment(_ data: Data, withFileName filename: String) { // path or base64 String
    do {
      //
      guard let data = Data(base64Encoded: data) else {
           // handle errors in decoding base64 string here
           return
       }

       let bytes = data.map { $0 }

       let swiftByteArray : [UInt8] = bytes

      let intArray : [Int8] = swiftByteArray
          .map { Int8(bitPattern: $0) }
      let kotlinByteArray: KotlinByteArray = KotlinByteArray.init(size: Int32(swiftByteArray.count))
      for (index, element) in intArray.enumerated() {
          kotlinByteArray.set(index: Int32(index), value: element)
      }
      
      let attachmentId = try self.client?.attach(byteArray: kotlinByteArray, fileName: filename)
      self.attachmentId = attachmentId!
//    sel
    } catch {
      print("Errorrrr")
    }
  }
    
  @objc func sendMessage(_ message: String) {
    do {
      try self.client!.sendMessage(text: message)
    } catch {
      ///
    }
  }
  
  func sendAttachment(attachmentId: String) {
    do {
      try self.client!.sendMessage(text: "", customAttributes: ["attachmentId" : attachmentId])
    } catch {
      ///
    }
  }
  
  override func supportedEvents() -> [String]! {
    return ["onMessage"]
  }
  
  override class func requiresMainQueueSetup() -> Bool {
    true
  }
    
}

extension Data {
    init?(base64EncodedURLSafe string: String, options: Base64DecodingOptions = []) {
        let string = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        self.init(base64Encoded: string, options: options)
    }
}
