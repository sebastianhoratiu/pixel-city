//
//  PopVC.swift
//  pixel-city
//
//  Created by Sebastian Horatiu on 08/03/2020.
//  Copyright © 2020 Sebastian Horatiu. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var popImageView: UIImageView!
    
    var passedImage: UIImage!
    
    func initData (forImage image: UIImage) {
        self.passedImage = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        popImageView.image = passedImage
        addDoubleTap()
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }

}
