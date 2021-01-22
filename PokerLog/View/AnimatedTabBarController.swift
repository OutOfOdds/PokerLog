//
//  AnimatedTabBarController.swift
//  WinRateApp
//
//  Created by Mike Mailian on 09.11.2020.
//

import UIKit

class AnimatedTabBarController: UITabBarController {

    private var bounceAnimation: CAKeyframeAnimation = {
         let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
         bounceAnimation.values = [1.0, 1.4, 0.9, 1.02, 1.0]
         bounceAnimation.duration = TimeInterval(0.3)
         bounceAnimation.calculationMode = CAAnimationCalculationMode.cubic
         return bounceAnimation
     }()
    
     override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let idx = tabBar.items?.firstIndex(of: item), tabBar.subviews.count > idx + 1, let imageView = tabBar.subviews[idx + 1].subviews.compactMap({ $0 as? UIImageView }).first else {
             return
         }
         imageView.layer.add(bounceAnimation, forKey: nil)
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
}
