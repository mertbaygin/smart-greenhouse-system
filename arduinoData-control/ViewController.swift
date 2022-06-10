//
//  ViewController.swift
//  arduinoDataShow
//
//  Created by mert baygın on 11.05.2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var light: UILabel!
    @IBOutlet weak var soil: UILabel!
    @IBOutlet weak var rain: UILabel!
    @IBOutlet weak var hum: UILabel!
    @IBOutlet weak var temp: UILabel!
    
    @IBOutlet weak var fan: UISwitch!
    @IBOutlet weak var lig: UISwitch!
    @IBOutlet weak var engine: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getApiDatas()
        // Do any additional setup after loading the view.
    }

    @IBAction func refreshButton(_ sender: Any) {
        getApiDatas()
        makePOSTRequest()
        
        
    }
    func getApiDatas(){
       let apiKey = URL(string: "https://api.thingspeak.com/channels/1618339/feeds.json?results=1")
       let session = URLSession.shared
       let task = session.dataTask(with: apiKey!) { (data,response, error) in
           if error != nil {
               
               let alert  = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
               
               let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:nil)
               alert.addAction(okButton)
               
               self.present(alert,animated: true,completion: nil)
           }else{
               if data != nil {
                  do {
                  let jsonResult = try JSONSerialization.jsonObject(with:data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String,Any>
                      
                      
                      DispatchQueue.main.async {
                          let rate = jsonResult["feeds"] as? [Any]
                          
                          let sozluk0:Dictionary = rate?[0] as! Dictionary<String, Any>
                          self.temp.text = (sozluk0["field1"] as! String)
                          self.hum.text = (sozluk0["field2"] as! String)
                          self.soil.text = (sozluk0["field3"] as! String)
                          self.rain.text = (sozluk0["field4"] as! String)
                          self.light.text = (sozluk0["field5"] as! String)
                          self.date.text = (sozluk0["created_at"] as! String)
                      }
                    
                   }catch{
                       print("error")
                       
                   }
               }
           }
           
       }
        
       task.resume()
    }
    func makePOSTRequest() {
       
        var switch1: Int = 0
        var switch2: Int = 0
        var switch3: Int = 0
        if engine.isOn{
            switch1 = 1
        }else{
            switch1 = 0}
        if lig.isOn{
            switch2 = 1
        }else{
            switch2 = 0}
        if fan.isOn{
            switch3 = 1
        }else{
            switch3 = 0}
        let url = URL(string: "http://flask-env.eba-f26pstrg.us-east-1.elasticbeanstalk.com/api/")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body: [String: Int] = [
            "engine": switch1,
            "light": switch2,
            "fan": switch3
        ]

        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            
        }catch let error{
            print("An error occured while parsing the body into JSON.", error)
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if  let error = error {
                print("An error occured", error)
                return
            }
            if let data = data{
                do{
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as?[String: Any]{
                    print("Json:", json)
                    }
                }catch let error {
                    print("Couldn't parse that data into JSON", error)
                    
                }
                
            }
        }.resume()
    }
}
