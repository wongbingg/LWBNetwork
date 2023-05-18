//
//  ViewController.swift
//  LWBNetwork
//
//  Created by wongbingg on 04/22/2023.
//  Copyright (c) 2023 wongbingg. All rights reserved.
//

import UIKit
import LWBNetwork

class ViewController: UIViewController {

    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let chuckNorrisApi = ChuckNorrisAPI()
        
        // MARK: Async-await Version
        Task {
            do {
                let response = try await chuckNorrisApi.execute()
                myLabel.text = response.value
                resultLabel.text = "Networking Success!"
                resultLabel.textColor = .systemGreen
            } catch {
                myLabel.text = error.localizedDescription
                resultLabel.text = "Networking Fail"
                resultLabel.textColor = .systemRed
            }
        }
        
        // MARK: Escaping closure Version
//        chuckNorrisApi.execute { [self] result in
//            switch result {
//            case .success(let response):
//                DispatchQueue.main.async { [self] in
//                    myLabel.text = response.value
//                    resultLabel.text = "Networking Success!"
//                    resultLabel.textColor = .systemGreen
//                }
//            case .failure(let error):
//                DispatchQueue.main.async { [self] in
//                    myLabel.text = error.localizedDescription
//                    resultLabel.text = "Networking Fail"
//                    resultLabel.textColor = .systemRed
//                }
//            }
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

struct ChuckNorrisAPI: API {
    typealias ResponseType = ChuckNorrisResponseDTO
    
    var configuration: APIConfiguration?
    
    init() {
        configuration = APIConfiguration(
            method: .get,
            baseURL: "https://api.chucknorris.io",
            path: "/jokes/random",
            parameters: nil,
            headerField: nil
        )
    }
}

struct ChuckNorrisResponseDTO: Decodable {
    let value: String
}
