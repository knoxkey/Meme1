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

    //MARK:- Initialize Variables
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var activityButton: UIBarButtonItem!

    //Define attributes for meme text fields
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -3
    ]

    //MARK:- Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Set text field delegates and alignment
        setUpTextFields(topText, defaulValue: "TOP")
        setUpTextFields(bottomText, defaulValue: "BOTTOM")
        if imagePickerView.image == nil {
            activityButton.enabled = false
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()

        //Disable Camera Button if device has no camera
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    //Set up attributes and delegates for textFields
    func setUpTextFields(textField: UITextField, defaulValue: String) {
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.Center
        textField.text = defaulValue
    }

    //MARK:- Button Actions
    //Album button - call picker using Photo Album
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        presentPickerController(.PhotoLibrary)
    }

    //Camera button - call picker using Camera
    @IBAction func pickanIMageFromCamera(sender: AnyObject) {
        presentPickerController(.Camera)
    }

    //Present pickerController for image selection
    func presentPickerController(sourceType: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = sourceType
        presentViewController(pickerController, animated: true, completion: nil)
    }

    //Handle meme cancel button - re-initizlize the view
    @IBAction func cancelMeme(sender: AnyObject) {
        imagePickerView.image = nil
        viewDidLoad()
    }

    //Handle share button - present Activity veiew
    @IBAction func shareMeme(sender: AnyObject) {
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(
            activityItems: [memedImage as UIImage],
            applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: nil)
        //Save Memed Image IF activity was completed
        activityViewController.completionWithItemsHandler = { activity, completed, items, error -> Void in
            if completed {
                self.save(memedImage)
            }
        self.dismissViewControllerAnimated(true, completion: nil)
        }

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

    //MARK:- Screen Positioning for Keyboard
    //Raise screen image so bottom text is not obscured by keyboard
    func keyboardWillShow(notification: NSNotification) {
        if bottomText.isFirstResponder() {
            view.frame.origin.y = getKeyboardHeight(notification) * -1        }
    }

    //Repostion screen image when keyboard is hidden
    func keyboardWillHide(notification: NSNotification) {
        if bottomText.isFirstResponder() {
            view.frame.origin.y = 0
        }
    }

    //Find out keyboard height
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }

    //MARK:- Keyboard Notification functions
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }



    //MARK:- Meme Handling
    //Create memed image that combines the Image View and Text fields
    func generateMemedImage() -> UIImage {
        //Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return memedImage
    }


    func save(memedimage: UIImage) {
        //Create the meme struct object
        let memedImage = generateMemedImage()
        let meme = Meme( topLine: topText.text!, bottomLine: bottomText.text!, imageView:
            imagePickerView.image!, memedImage: memedImage)
        //Add it to the memes array in the Application Delegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
}

