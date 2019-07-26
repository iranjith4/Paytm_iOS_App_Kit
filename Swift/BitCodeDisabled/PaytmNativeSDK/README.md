# PaytmNativeSDK


## Example

PaytmNativeSDK provided in the IOS plugin can be downloaded from here
Add framework to your project.
Enable this framework in Linked Frameworks and Libraries

## Requirements

Swift 4.2 

## Integration Steps

**Step 1a:** Add the framework to your project
**Step 1b:** Enable this framework in Linked Frameworks and Libraries

**Step 2:**  Following are the parameters : 

Params: 

1) isAoA : Bool : Merchant is AOA merchant or not
2) cid : String : Your Customer Id.
3) txnToken : String : Get this from Initiate transaction API call from merchant's end
4)  txnAmount: String =  Transaction Amount.
5) mid : String = YOUR MID
6) orderID: String =  Generated Order Id
7) String merchantName:  Merchant name
8) requestType : String = if AOA Merchant requestType = "UNI_PAY" else requestType = "Payment"
9) callbackUrlString  : String = " https://securegw.paytm.in/theia/paytmCallback?ORDER_ID="
Sample Body Param : 

**Step 3:** Configure the BodyParam as 

let bodyParams = ["head": ["channelId":"WAP","clientId":"C11","requestTimestamp":"Time","signature":"CH","version":"v1"],"body":["callbackUrl":callbackUrlString + "\(orderId)","mid":"\(merchantId)","orderId":"\(orderId)","requestType":requestType,"websiteName":"Retail","paytmSsoToken":"\(ssoToken)","txnAmount":["value":"\(txnAmount)","currency":"INR"],"userInfo":["custId":(cid)]]]

**Step 4:** Sample code for Invoking SDK :


let sdk = PaytmNativeSDK(txnToken: txnToken, orderId: orderId, merchantId: self!.merchantId, isAuthenticated: isAuthenticated, amount: CGFloat(Double(txnAmount) ?? 1.0), callbackUrl: callbackUrlString +"\(orderId)", andDelegate: self!, isAOA: self!.isAOA)

*Step 5** Add  following in your Run Script:
bash ./{Path}/PaytmNativeSDK.framework/strip-frameworks.sh


## Author

Pawan Agarwal, pawan.agarwal@paytm.com

## License

PaytmNativeSDK is available under the MIT license. See the LICENSE file for more info.
