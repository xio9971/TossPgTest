//
//  ViewController.swift
//  tossPgTest
//
//  Created by 민트팟 on 2021/05/26.
//

import UIKit
import WebKit

class ViewController: UIViewController,WKUIDelegate,WKNavigationDelegate, WKScriptMessageHandler{
    
    struct paymentData : Codable {
        
        var orderId : Int
        var paymentKey : String
    }
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        print("callBack!!!")
        
        if(message.name == "callbackHandler"){
            
            guard let data = message.body as? String else {
                return
            }
                        
            //data = {"orderId":1622175012156,"paymentKey":"p5EnNZRJGvaBX7zk2yd8yNaNRNJE03x9POLqKQjmAw4b0e1Y"}
            
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()
            
            let temp = try? encoder.encode(data)
            
            
            //let payment = try? decoder.decode(paymentData.self, from: temp!)
            
            //decoder.decode(paymentData.self, from: <#T##Data#>)
            
            if let data = data.data(using: .utf8) {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] {
                        print(json["orderId"] ?? "")
                        print(json["paymentKey"] ?? "") }
                    
                } catch {
                    print("JSON 파싱 에러")
                    
                }
                
            }
            
            
            let jasonData = data.data(using: .utf8)
            
            if let data = jasonData, let myPerson = try? decoder.decode(paymentData.self, from: data) {

                print(">>>>>> \(myPerson.orderId)")

                print(">>>>>>  \(myPerson.paymentKey)")

            }
            
            
//            print(data.data(using: .utf8))
//            print(data)
//            print(payment)
//            print(payment?.orderId)
//            print(payment?.paymentKey)
        }
    }

    
    @IBOutlet weak var webView: WKWebView!
    
    override func loadView() {
            super.loadView()
            

            let contentController = WKUserContentController()
            let config = WKWebViewConfiguration()
            contentController.add(self, name: "callbackHandler")
            config.userContentController = contentController
        
            webView = WKWebView(frame: self.view.frame, configuration: config)
             
            
             
            webView.uiDelegate = self
            webView.navigationDelegate = self
            self.view = self.webView
        }

    override func viewDidLoad() {
        super.viewDidLoad()
       
//        let url = URL(string: "https://www.naver.com/")
        let url = URL(string: "http://localhost:8080/")
        
        let request = URLRequest(url: url!)
        //self.webView?.allowsBackForwardNavigationGestures = true  //뒤로가기 제스쳐 허용
        webView.configuration.preferences.javaScriptEnabled = true  //자바스크립트 활성화
        webView.load(request)

        
         
        // self.view = self.webView!
        //self.view.addSubview(webView)
    }
    
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() } //모달창 닫힐때 앱 종료현상 방지.
    
    //alert 처리
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void){
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in completionHandler() }))
        self.present(alertController, animated: true, completion: nil) }

    //confirm 처리
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in completionHandler(false) }))
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in completionHandler(true) }))
        self.present(alertController, animated: true, completion: nil) }
    
    // href="_blank" 처리
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil { webView.load(navigationAction.request) }
        return nil }

}
