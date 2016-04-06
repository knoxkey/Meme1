//
//  ViewController.swift
//  PKKMeme2
//
//  Created by KNOX KEY on 3/31/16.
//  Copyright © 2016 Wingwood. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var activityButton: UIBarButtonItem!

    @IBOutlet weak var toolBar: UIToolbar!


    //Set attributes of meme text fields
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -3
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Set text field delegates and alignment
        self.topText.delegate = self
        self.bottomText.delegate = self
        topText.defaultTextAttributes = memeTextAttributes
        bottomText.defaultTextAttributes = memeTextAttributes
        topText.textAlignment = NSTextAlignment.Center
        bottomText.textAlignment = NSTextAlignment.Center

        //Initialize meme text fields
        if topText.text == "" {
            topText.text = "TOP"
        }
        if bottomText.text == "" {
            bottomText.text = "BOTTOM"
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        //Call func to subscribe to Keyboard Notifications
        self.subscribeToKeyboardNotifications()
        //Disable Camera Button if device has no camera
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        if imagePickerView.image == nil {
            activityButton.enabled = false
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //Call func to unsubscribe from Keyboard Notifications
        self.unsubscribeFromKeyboardNotifications()
    }

    //Album button - present controller to pick an album image
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(pickerController, animated: true, completion: nil)
    }

    //Camera button - present the camera to take a photo
    @IBAction func pickanIMageFromCamera(sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(pickerController, animated: true, completion: nil)
    }

    //Present image picker for photo selection
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
        }
        dismissViewControllerAnimated(true, completion: nil)
        //Enable to share button
        activityButton.enabled = true
    }

    //Handle the cancel button on image picker
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    //Clear text field upon initial use
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField.text == "BOTTOM" {
            textField.text = ""
        }
        if textField.text == "TOP" {
            textField.text = ""
        }
        return true
    }

    //If text field is returned empty, re-iinitialize it
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text == "" {
            if bottomText.isFirstResponder() {
                textField.text = "BOTTOM"
            }
            if topText.isFirstResponder() {
                textField.text = "TOP"
            }
        }
        textField.resignFirstResponder()
        return true
    }

    //Raise screen image so bottom text is not obscured by keyboard
    func keyboardWillShow(notification: NSNotification) {
        if bottomText.isFirstResponder() {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }

    //Repostion screen image when keyboard is hidden
    func keyboardWillHide(notification: NSNotification) {
        if bottomText.isFirstResponder() {
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }

    //Subscribe to keyboard notifications
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    //Unsubscribe from keyboard notifications
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    //Find out keyboard height
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }

    //Handle meme cancel button - re-initizlize the view
    @IBAction func cancelMeme(sender: AnyObject) {
        topText.text = ""
        bottomText.text = ""
        imagePickerView.image = nil
        self.viewDidLoad()
        self.viewWillAppear(true)
    }

    //Handle share button - present Activity veiew
    @IBAction func shareMeme(sender: AnyObject) {
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(
            activityItems: [memedImage as UIImage],
            applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: nil)
        //Save Memed Image
        save(memedImage)
    }

    //Create memed image that combines the Image View and Text fields
    func generateMemedImage() -> UIImage {
        //Hide tool and nav bars
        self.navigationController?.setToolbarHidden(true, animated: false)
        toolBar.hidden = true
        //Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //Show tool and nav bars
        self.navigationController?.setToolbarHidden(false, animated: false)
        toolBar.hidden = false

        return memedImage
    }


    func save(memedimage: UIImage) {
        //Create the meme struct object
        let memedImage = generateMemedImage()
        var meme = Meme( topLine: topText.text!, bottomLine: bottomText.text!, imageView:
            imagePickerView.image!, memedImage: memedImage)
    }
}

struct Meme {
    var topLine: String
    var bottomLine: String
    var imageView: UIImage
    var memedImage: UIImage

    init(topLine: String, bottomLine: String, imageView: UIImage, memedImage: UIImage) {
        self.topLine = topLine
        self.bottomLine = bottomLine
        self.imageView = imageView
        self.memedImage = memedImage
    }
}
