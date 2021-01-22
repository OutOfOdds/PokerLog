//
//  BackgroundViewController.swift
//  WinRateApp
//
//  Created by Mike Mailian on 10.11.2020.
//

import UIKit

class BackgroundViewController: UIViewController {
    
    // Making same background to all ViewControllers
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Transparent Navigation Bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Background.png")
        backgroundImage.contentMode = UIView.ContentMode.scaleToFill
        self.view.insertSubview(backgroundImage, at: 0)
    }
}
