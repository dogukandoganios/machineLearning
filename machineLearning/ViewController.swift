//
//  ViewController.swift
//  machineLearning
//
//  Created by Doğukan Doğan on 29.07.2022.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imageView = UIImageView()
    let resultLabel = UILabel()
    let changeButton = UIButton()
    var chosenImage = CIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        overrideUserInterfaceStyle = .light
        
        let width = view.frame.size.width
        let height = view.frame.size.height
        
        imageView.frame = CGRect(x: width * 0.5 - width * 0.8 / 2, y: height * 0.3 - height * 0.5 / 2, width: width * 0.8, height: height * 0.5)
        imageView.layer.borderWidth = 1
        view.addSubview(imageView)
        
        resultLabel.frame = CGRect(x: width * 0.5 - width * 0.8 / 2, y: height * 0.6 - height * 0.05 / 2, width: width * 0.8, height: height * 0.05)
        resultLabel.textAlignment = .center
        view.addSubview(resultLabel)
        
        changeButton.setTitle("Change", for: UIControl.State.normal)
        changeButton.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        changeButton.frame = CGRect(x: width * 0.5 - width * 0.3 / 2, y: height * 0.7 - height * 0.05 / 2, width: width * 0.3, height: height * 0.05)
        view.addSubview(changeButton)
        
        changeButton.addTarget(self, action: #selector(changeClick), for: UIControl.Event.touchUpInside)
        
    }

    @objc func changeClick(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        if let ciImage = CIImage(image: imageView.image!){
            
            chosenImage = ciImage
            
        }
        
        recognizeImage(image: chosenImage)
        
    }
    
    func recognizeImage(image : CIImage){
        
        if let model = try? VNCoreMLModel(for: MobileNetV2().model){
            
            let request = VNCoreMLRequest(model: model) { vnrequest, error in
                
                if let results = vnrequest.results as? [VNClassificationObservation]{
                    
                    let topResult = results.first
                    
                    DispatchQueue.main.async {
                        
                        let confidencelevel = (topResult?.confidence ?? 0) * 100
                        let rounded = Int(confidencelevel * 100) / 100
                        
                        self.resultLabel.text = "\(rounded)% it is \(topResult!.identifier)"
                        
                    }
                    
                }
                
            }
            
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                
                do{
                    
                try handler.perform([request])
                    
                }catch{
                    
                }
                
            }

        }
        
    }
}

