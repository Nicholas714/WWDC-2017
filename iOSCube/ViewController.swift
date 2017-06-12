//
//  ViewController.swift
//  iOSCube
//
//  Created by Nicholas Grana on 6/6/17.
//  Copyright © 2017 Nicholas Grana. All rights reserved.
//

import UIKit
import SceneKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        PlayArea.v  = SCNView(frame: self.view.frame)
        let playArea = PlayArea()
        let rubiks = RubiksCube(area: playArea) 
        
        view.addSubview(playArea.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

