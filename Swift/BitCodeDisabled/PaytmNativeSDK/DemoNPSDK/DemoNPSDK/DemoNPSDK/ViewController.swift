//
//  ViewController.swift
//  PaytmNativeSDK
//
//  Created by Ankit Agarwal on 02/05/18.
//  Copyright © 2018 One97. All rights reserved.
//

import UIKit
import PaytmNativeSDK
class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var textfieldMID: UITextField!
    @IBOutlet weak var textfieldOrderId: UITextField!
    @IBOutlet weak var textfieldSSOToken: UITextField!
    @IBOutlet weak var textfieldAmount: UITextField!
    @IBOutlet weak var isAOASwitch: UISwitch!
    @IBAction func switchAOA(_ sender: Any) {
        isAOA = isAOASwitch.isOn
    }
    
    var isAOA: Bool = false
    var merchantId = ""
    
    @IBOutlet weak var btn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        isAOASwitch.isOn = false
        textfieldMID.delegate = self
        textfieldOrderId.delegate = self
        textfieldSSOToken.delegate = self
        textfieldAmount.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //        btn.showLoader()
        //        btn.removeLoader()
    }
    
    @IBAction func pushChoosePayOption(_ sender: UIButton) {
        //        btn.removeLoader()
        //        abc()
        sender.isUserInteractionEnabled = false
        hitInitiateTransactionAPI()
    }
    
    func hitInitiateTransactionAPI() {
        var orderId = ""
        if let OID = textfieldOrderId.text, !OID.isEmpty{
            orderId = OID
        }else{
            orderId = "OrderTest" + "\(arc4random())"
        }
        if let MID = textfieldMID.text, !MID.isEmpty{
            merchantId = MID
        }else {
            
            if isAOA {
                merchantId = "216820000364645443343"
            } else {
                merchantId = "tAMcoi53684180041762"
            }

        }
        let callbackUrlString = "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID="
        var ssoToken = ""
        if let SSO = textfieldSSOToken.text, !SSO.isEmpty{
            ssoToken = SSO
        }
        var txnAmount = ""
        if let amount = textfieldAmount.text , !amount.isEmpty {
            txnAmount = amount
        }else {
            txnAmount = "1"
        }
        
        var requestType = ""
        if isAOA {
            requestType = "UNI_PAY"
        } else {
            requestType = "Payment"
        }
        var request = URLRequest(url: URL(string: "https://securegw.paytm.in/theia/api/v1/initiateTransaction?mid=\(merchantId)&orderId=\(orderId)")!)
        request.httpMethod = "POST"
        let bodyParams = ["head": ["channelId":"WAP","clientId":"C11","requestTimestamp":"Time","signature":"CH","version":"v1"],"body":["callbackUrl":callbackUrlString + "\(orderId)","mid":"\(merchantId)","orderId":"\(orderId)","requestType":requestType,"websiteName":"Retail","paytmSsoToken":"\(ssoToken)","txnAmount":["value":"\(txnAmount)","currency":"INR"],"userInfo":["custId":"cid"]]]
        do {
            let data = try JSONSerialization.data(withJSONObject: bodyParams, options: .prettyPrinted)
            request.httpBody = data
        } catch {}
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            do {
                guard let responseData = data else {
                    self?.showAlert("", message: error.debugDescription)
                    return
                }
                if let jsonDict = try JSONSerialization.jsonObject(with: responseData, options: [.mutableContainers]) as? [String: Any] {
                    let body = jsonDict["body"] as! [String : Any]
                    guard let txnToken =  body["txnToken"] as? String else {return}
                    let isAuthenticated = body["authenticated"] as! Bool
                    DispatchQueue.main.async {
                        self?.btn.isUserInteractionEnabled = true
                        if !((self?.tokenFetched(txnToken: txnToken, orderId: orderId,mid:self!.merchantId))!) {
                            let sdk = PaytmNativeSDK(txnToken: txnToken, orderId: orderId, merchantId: self!.merchantId, isAuthenticated: isAuthenticated, amount: CGFloat(Double(txnAmount) ?? 1.0), callbackUrl: callbackUrlString + "\(orderId)", andDelegate: self!, isAOA: self!.isAOA)
                            sdk.open(navController: self!.navigationController!)
                        }
                    }
                }
            }
            catch{
            }
            }.resume()
    }
    
    private func responseEncoding(string: String) -> String {
        let newCharacterSet = CharacterSet.init(charactersIn: "\"\\!*'() ;:@&+$,/{}?%#[]|-_").inverted
        return string.addingPercentEncoding(withAllowedCharacters: newCharacterSet) ?? ""
    }
    func tokenFetched(txnToken: String,orderId: String,mid: String) -> Bool {
        if let phoneCallURL:URL = URL(string: "paytm://merchantpayment?txnToken=\(txnToken)&orderId=\(orderId)&mid=\(mid)&amount=1") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:]) { (finish) in
                    print("asd")
                }
                return true
            }
        }
        return false
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
extension UIButton {
    func showLoader(shouldRemoveTitle: Bool = true) {
        let viewLoading = UIView(frame: self.bounds)
        viewLoading.backgroundColor = UIColor(red: 234.0/255.0, green: 250.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        let animationView =  UIView(frame: self.bounds)
        //LOTAnimationView(name: "Payments-Loader")
        animationView.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        animationView.center = viewLoading.center
        viewLoading.addSubview(animationView)
        if shouldRemoveTitle {
            self.setTitle("", for: .normal)
        }
        self.addSubview(viewLoading)
        //        JRPaytmLoaderAnimationView().infinitePlay(viewAnimate: animationView)
    }
    
    func removeLoader(title: String = "") {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        if title != "" {
            self.setTitle(title, for: .normal)
        }
    }
}


extension ViewController : PaytmPaymentCompletionProtocol{
    func onPaymentSuccess(response: [String : Any]) {
        print(response)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.showAlert("", message: response.debugDescription)
        }

    }
    
    func onPaymentError(errorCode: Int, description str: String) {
        print(errorCode)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.showAlert("", message: str)
        }

    }
    
    func showAlert(_ title: String, message: String) {
        let errorAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        errorAlert.addAction(action)
        self.present(errorAlert, animated: true, completion: nil)
    }

    
    
}
