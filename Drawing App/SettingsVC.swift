//
//  SettingsVC.swift
//  Drawing App
//
//  Created by Ozan Mirza on 18/12/16.
//  Copyright © 2016 Ozan Mirza. All rights reserved.
//

import UIKit

protocol SettingsVCDelegate:class {
    func settingsViewControllerDidFinish(_ settingsVC:SettingsVC)
    func settingsViewControllerDidCancel()
}

class SettingsVC: UIViewController {

    @IBOutlet weak var shadowContainer: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var brushSizeLabel: UILabel!
    @IBOutlet var opacityLabel: UILabel!
    @IBOutlet var redLabel: UILabel!
    @IBOutlet var greenLabel: UILabel!
    @IBOutlet var blueLabel: UILabel!
    @IBOutlet var bgRedLabel: UILabel!
    @IBOutlet var bgGreenLabel: UILabel!
    @IBOutlet var bgBlueLabel: UILabel!
    
    @IBOutlet var brushSizeSlider: UISlider!
    @IBOutlet var opacitySlider: UISlider!
    @IBOutlet var redSlider: UISlider!
    @IBOutlet var greenSlider: UISlider!
    @IBOutlet var blueSlider: UISlider!
    @IBOutlet var bgRedSlider: UISlider!
    @IBOutlet var bgGreenSlider: UISlider!
    @IBOutlet var bgBlueSlider: UISlider!
    @IBOutlet weak var resetBgSettings: UIButton!
    
    var brushSize: CGFloat = 0.0
    var opacity: CGFloat = 0.0
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var bgRed: CGFloat = 0.0
    var bgGreen: CGFloat = 0.0
    var bgBlue: CGFloat = 0.0
    var shouldAcceptBg: Bool = false
    
    var delegate:SettingsVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        drawPreview(red: red, green: green, blue: blue, opacity:opacity)
        
        shadowContainer.layer.shadowColor = UIColor.gray.cgColor
        shadowContainer.layer.shadowOffset = CGSize(width: 2, height: 5)
        shadowContainer.layer.shadowRadius = 10
        shadowContainer.layer.shadowOpacity = 0.7
        imageView.layer.borderColor = UIColor.white.cgColor
        
        brushSizeSlider.value = Float(brushSize)
        opacitySlider.value = Float(opacity)
        redSlider.value = Float(red)
        greenSlider.value = Float(green)
        blueSlider.value = Float(red)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(_ sender: Any) {
        if delegate != nil {
            delegate?.settingsViewControllerDidFinish(self)
        }
        
        dismiss(animated: true, completion: nil)
    }
    @IBAction func brushSizeChanged(_ sender: Any) {
        brushSize = CGFloat((sender as! UISlider).value)
        drawPreview(red: red, green: green, blue: blue, opacity:opacity)
        brushSizeLabel.text = String(Int(brushSize))
    }
    @IBAction func opacityChanged(_ sender: Any) {
        opacity = CGFloat((sender as! UISlider).value)
        drawPreview(red: red, green: green, blue: blue, opacity:opacity)
        opacityLabel.text = String(format: "%\(0.2)f", opacity)
    }
    @IBAction func redSliderChanged(_ sender: Any) {
        
        let slider = sender as! UISlider
        red = CGFloat(slider.value)
        drawPreview(red: red, green: green, blue: blue, opacity:opacity)
        redLabel.text = "\(Int(slider.value * 255))"
        
    }
    @IBAction func greenSliderChanged(_ sender: Any) {
        let slider = sender as! UISlider
        green = CGFloat(slider.value)
        drawPreview(red: red, green: green, blue: blue, opacity:opacity)
        greenLabel.text = "\(Int(slider.value * 255))"
    }
    @IBAction func blueSliderChanged(_ sender: Any) {
        let slider = sender as! UISlider
        blue = CGFloat(slider.value)
        drawPreview(red: red, green: green, blue: blue, opacity:opacity)
        blueLabel.text = "\(Int(slider.value * 255))"
    }
    @IBAction func bgRedSliderChanged(_ sender: Any) {
        let slider = sender as! UISlider
        bgRed = CGFloat(slider.value)
        drawPreview(red: bgRed, green: bgGreen, blue: bgBlue, opacity:1)
        redLabel.text = "\(Int(slider.value * 255))"
        UIView.animate(withDuration: 0.3) {
            self.resetBgSettings.alpha = 1
        }
        shouldAcceptBg = true
    }
    @IBAction func bgGreenSliderChanged(_ sender: Any) {
        let slider = sender as! UISlider
        bgGreen = CGFloat(slider.value)
        drawPreview(red: bgRed, green: bgGreen, blue: bgBlue, opacity:1)
        greenLabel.text = "\(Int(slider.value * 255))"
        UIView.animate(withDuration: 0.3) {
            self.resetBgSettings.alpha = 1
        }
        shouldAcceptBg = true
    }
    @IBAction func bgBlueSliderChanged(_ sender: Any) {
        let slider = sender as! UISlider
        bgBlue = CGFloat(slider.value)
        drawPreview(red: bgRed, green: bgGreen, blue: bgBlue, opacity:1)
        blueLabel.text = "\(Int(slider.value * 255))"
        UIView.animate(withDuration: 0.3) {
            self.resetBgSettings.alpha = 1
        }
        shouldAcceptBg = true
    }
    
    @IBAction func resetBGSettings(_ sender: Any) {
        bgRedSlider.value = 255
        bgGreenSlider.value = 255
        bgBlueSlider.value = 255
        
        drawPreview(red: red, green: green, blue: blue, opacity:opacity)
        UIView.animate(withDuration: 0.3) {
            self.resetBgSettings.alpha = 0
        }
        shouldAcceptBg = false
    }
    
    func drawPreview (red:CGFloat,green:CGFloat,blue:CGFloat, opacity:CGFloat) {
        imageView.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: opacity)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.settingsViewControllerDidCancel()
    }
}
