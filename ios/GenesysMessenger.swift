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
  var messengerTransport: MobileMessenger? = nil
  public var client: MessagingClient? = nil
  public override init() {
    super.init()
  }
  
    
  @objc func setupGenesis() {
    config = Configuration(deploymentId: "bfddd67f-c7da-406c-a47a-a8a49f2ee346",domain: "mypurecloud.jp", tokenStoreKey: "", logging: true )
    client = MobileMessenger.shared.createMessagingClient(configuration: config!)
   

    client?.stateListener = { stateChange in // Subscribe to socket states listener.
      print("stateChange")
      print(stateChange)
      switch stateChange {
      case is MessagingClientState.Connecting:
        print("MessagingClientState.Connecting")// Establishing a secure connection via WebSocket.
      case is MessagingClientState.Connected:
        print("MessagingClientState.Connected")// Secure connection was established.
        do {
          try self.client!.configureSession()
        } catch {
          ///
        }
      case let configured as MessagingClientState.Configured:
        print(configured.connected)
      default:
        print(stateChange)
        break
      }
    }
    
      
    
    client?.messageListener = { event in
        switch event {
        case let inserted as MessageEvent.MessageInserted:
            if(inserted.message.direction == Message.Direction.outbound) {
              print("Message sent by Agent (Received)")
              
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
      print(data.count)
      let bytes = [UInt8](data)

      let bytesLength =  Int32(bytes.count)
      print("bytesLength")
      print(bytesLength)
      
      let byteArray = KotlinByteArray.init(size: bytesLength)
      
            
      for (index, element) in bytes.enumerated() {
        byteArray.set(index: Int32(index), value: Int8(element))
      }
      
      print(byteArray.size)
      
      print(byteArray.get(index: 0))
      print(byteArray.get(index: bytesLength - 1))
          

      try self.client?.attach(byteArray: byteArray, fileName: filename)
      
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
  
  override func supportedEvents() -> [String]! {
    return ["onMessage"]
  }
  
  override class func requiresMainQueueSetup() -> Bool {
    true
  }
    
}

extension Data {
    var bytes: [UInt8] {
        return [UInt8](self)
    }
}
