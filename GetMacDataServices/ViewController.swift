//
//  ViewController.swift
//  GetMacDataServices
//
//  Created by liumenchen on 2018/1/26.
//  Copyright © 2018年 Mengchen Liu. All rights reserved.
//

import Cocoa

import CocoaAsyncSocket

class ViewController: NSViewController , GCDAsyncSocketDelegate , GCDAsyncUdpSocketDelegate {

    /** 服务器地址输入框 */
    @IBOutlet weak var textField_service_ip: NSTextField!
    
    /** 端口号 */
    @IBOutlet weak var textField_service_port: NSTextField!
    
    /** 发送内容 */
    @IBOutlet weak var textField_content: NSTextField!
    
    /** 服务器返回结果 */
    @IBOutlet var textView_accept: NSTextView!
    
    /** 两个按钮（连接与发送） */
    @IBOutlet weak var button_connect: NSButton!
    @IBOutlet weak var button_send: NSButton!
    
    @IBOutlet weak var button_TCP_AND_UDP: NSButton!
    
    
    var client_socket:      GCDAsyncSocket!
    var client_udp_socket:  GCDAsyncUdpSocket!
    let file_manager: FileManager = FileManager.default
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
 
        
        self.textField_service_ip.stringValue   = "10.59.13.224"
        self.textField_service_port.stringValue = "18000"
        
//        self.textView_accept.layoutManager?.allowsNonContiguousLayout = false
//        let allstrcount = self.textView_accept.string.characters.count //获取文字总个数
//        self.textView_accept.scrollRangeToVisible(NSMakeRange(0, allstrcount))
        
        self.button_TCP_AND_UDP.title = "当前选择 TCP"
        self.button_TCP_AND_UDP.state = .on
    }
    
    
    func getDataFromInt(id : Int) -> Void {
        
//        var bytes: [Byte] = []
//        bytes[0] = (Byte)(id>>24)
//        bytes[1] = (Byte)(id>>16)
//        bytes[2] = (Byte)(id>>8)
//        bytes[3] = (Byte)(id)
//
//        let data = NSData(bytes: bytes, length: 4)
//
//        print(data)
        
    }
    
    
    

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    /** 是否TCP_UDP */
    @IBAction func repsonseToButtonTCPOrUDP(_ sender: NSButton) {
    
//        self.button_TCP_AND_UDP.highlight(false)
        
        print(sender.state)
        
        if self.button_TCP_AND_UDP.state == NSControl.StateValue.on {
            print("1")
            self.button_TCP_AND_UDP.state = .on
            self.button_TCP_AND_UDP.title = "当前选择 TCP"
            
        } else {
            print("2")
            self.button_TCP_AND_UDP.state = .off
            self.button_TCP_AND_UDP.title = "当前选择 UDP"
        }
    }
    
    
    /** 服务器连接按钮事件 */
    @IBAction func responseToConnectButton(_ sender: NSButton) {
        
        print("正在进行 TCP 链接")
        
        self.client_socket                  = GCDAsyncSocket()
        self.client_socket.delegate         = self
        self.client_socket.delegateQueue    = DispatchQueue.global()
        
        do {
            try self.client_socket.connect(toHost: self.textField_service_ip.stringValue, onPort: uint16(self.textField_service_port.stringValue)!)
        } catch {
            
            print("try connect error: \(error)")
        }
        
        
        
        
//        if self.button_TCP_AND_UDP.state == .on { //TCP 链接
//
//            print("正在进行 TCP 链接")
//
//            self.client_socket                  = GCDAsyncSocket()
//            self.client_socket.delegate         = self
//            self.client_socket.delegateQueue    = DispatchQueue.global()
//
//            do {
//                try self.client_socket.connect(toHost: self.textField_service_ip.stringValue, onPort: uint16(self.textField_service_port.stringValue)!)
//            } catch {
//
//                print("try connect error: \(error)")
//            }
//
//        } else {
//
//            print("正在进行 UDP 链接")
//
//            self.client_udp_socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
//        }
        
        
        
    }
    
    /** 向服务器发送数据按钮事件*/
    @IBAction func responseToSendButton(_ sender: NSButton) {
        
        let serviceStr: NSMutableString = NSMutableString()
        serviceStr.append(self.textField_content.stringValue)
        serviceStr.append("\n")
        
        let showStr: NSMutableString = NSMutableString()
        showStr.append(self.textView_accept.string)
        showStr.append("tcp client:")
        showStr.append(serviceStr as String)
        showStr.append("\r\n")
        self.textView_accept.string = showStr as String
        
        if self.button_TCP_AND_UDP.state == .on {
            
            self.client_socket.write(serviceStr.data(using: String.Encoding.utf8.rawValue)!, withTimeout: -1, tag: 0)
            
        } else {
            
            self.client_udp_socket.send(serviceStr.data(using: String.Encoding.utf8.rawValue)!, toHost: self.textField_service_ip.stringValue, port: uint16(self.textField_service_port.stringValue)!, withTimeout: -1, tag: 0)
        }
        
    }
    
    
    //MARK: ********************************************** GCDAsyncSocket delegate
    
    /** 连接成功后 */
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        
        print("service connect success")
        
        DispatchQueue.main.async {
            
            let showStr: NSMutableString = NSMutableString()
            showStr.append("\n service:")
            showStr.append("service connect success")
            showStr.append("\r\n")
            self.textView_accept.string = showStr as String
        }
        
        self.client_socket.readData(withTimeout: -1, tag: 0)
    }
    
    /** 连接不成功 */
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        
        print("tcp connect error: \(err)")
        
        DispatchQueue.main.async {
            
            let showStr: NSMutableString = NSMutableString()
            showStr.append("\n")
            showStr.append("connect error: \(err)")
            showStr.append("\r\n")
            self.textView_accept.string = showStr as String
        }
    }
    
    /** 服务器返回数据 */
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        
        /** 1、获取客户端发来的数据，把 NSData 转 NSString */
        let readClientDataString: NSString? = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue) ?? "空数据"
        print("---Data Recv---")
        print("tcp 服务器返回的数据是：\(readClientDataString)")
        
        
//        let json: NSDictionary = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
//
//        print("json = \(json)")
//
//        if (json["istrue"] as! String) == "true" {
//
//            print("有命令来了")
//
//            let upfolder = json.object(forKey: "upfolder")
//            let arrays = self.getNextDirectors(upfolder: upfolder as! String)
//            let jsonaa = ["cmd" : upfolder , "data" : arrays]
//            let dataa = try? JSONSerialization.data(withJSONObject: jsonaa, options: [])
//
//            self.client_socket.write(dataa!, withTimeout: -1, tag: 0)
//        }
        
//        let fileData = try! Data(contentsOf: URL(fileURLWithPath: "/Users/liumenchen/Desktop/tu.png"))
//        self.client_socket.write(fileData, withTimeout: -1, tag: 0)
        
        /** 2.主界面显示数据 */
        DispatchQueue.main.async {

            let showStr: NSMutableString = NSMutableString()
            showStr.append(self.textView_accept.string)
            showStr.append("tcp service: ")
            showStr.append(readClientDataString! as String)
            showStr.append("\r\n")
            self.textView_accept.string = showStr as String
        }

        /** 3、处理请求，返回数据给客户端OK */
        let serviceStr: NSMutableString = NSMutableString()
        serviceStr.append("OK")
        serviceStr.append("\r\n")
        self.client_socket.write(serviceStr.data(using: String.Encoding.utf8.rawValue)!, withTimeout: -1, tag: 0)
        
        /** 4、每次读完数据后，都要调用一次监听数据的方法 */
        self.client_socket.readData(withTimeout: -1, tag: 0)
    }
    
    
    /** 命令处理 */
    func getNextDirectors(upfolder: String) -> [String]? {
        
        print("当前目录是 : \(upfolder)")
        
        var array: Array<String> = []
        
        let files = try! FileManager.default.contentsOfDirectory(atPath: upfolder)
        
        for item in files {
            
            let asas: String = upfolder + item
            print("当前目录下的文件有：\(asas)")
            
            array.append(asas)
        }
        
        return array
    }
    
    
    //MARK: ********************************************** GCDAsyncUDPSocket delegate
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        
        print("已经发送")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        
        print("发送不成功 \(error)")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        
        
        
        let recv:NSString = NSString(data: data, encoding:String.Encoding.utf8.rawValue)!;
        print("数据来了 = \(recv)")
        
        var hostname = [CChar].init(repeating: 0, count: Int(NI_MAXHOST))
        
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        
        print("连接不成功 \(error)")
    }
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        
        print("udp 连接关闭 \(error)")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        
        print("udp 连接不成功 ; 连接地址 \(address)")
    }
    
    
//    let fileData = try! Data(contentsOf: URL(fileURLWithPath: "/Users/liumenchen/Desktop/tu.png"))
//
//    let sending_data = NSMutableData()
//    sending_data.append("tu.png".data(using: String.Encoding.utf8)!)
//    sending_data.append("\(fileData.count)".data(using: String.Encoding.utf8)!)
//    sending_data.append(fileData)
//    sending_data.append("\n".data(using: String.Encoding.utf8)!)
//
//
//    print("count = \(fileData.count)")
//
//
//
//    self.client_socket.write(sending_data as Data, withTimeout: -1, tag: 0)
    
    
}

