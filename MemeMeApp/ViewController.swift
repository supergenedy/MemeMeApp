//
//  ViewController.swift
//  MemeMeApp
//
//  Created by Ahmed on 4/28/19.
//  Copyright © 2019 supergenedy. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {


    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var galleryButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var textTop: UITextField!
    @IBOutlet weak var textBottom: UITextField!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unSubscribeToKeyboard()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.isEnabled = false
        
        configureTextField(textTop, text: "TOP")
        configureTextField(textBottom, text: "BOTTOM")
    }
    
    func configureTextField(_ textField: UITextField, text: String) {
        textField.defaultTextAttributes = [
            .font: UIFont(name: "HelveticaNeue-Bold", size: 40)!,
            .foregroundColor: UIColor.white,
            .strokeColor: UIColor.black,
            .strokeWidth: -5.0
        ]
        textField.textAlignment = .center
        textField.text = text
        textField.delegate = self
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM"{
            textField.text = ""
        }
        if textField == textBottom {
            subscribeToKeyboard()
        }
    }
    
    //Keyboard dismiss on return clicked
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == textBottom {
            unSubscribeToKeyboard()
        }
        return true
    }
    
    
    @objc func keyboardWillShow(_ notification:Notification){
        if textBottom.isEditing {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
        
    }
    
    @objc func keyboardWillHide(_ notification:Notification){
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func unSubscribeToKeyboard(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    
    @IBAction func shareMEME(_ sender: Any) {
        share()
    }
    
    func share() {
        
        let memeToShare: UIImage = generateMemedImage()
        
        let activityViewController = UIActivityViewController(activityItems: [memeToShare], applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = {activity,success,items,error in
            if success {
                self.save(memedImage: memeToShare)
                self.dismiss(animated: true, completion: nil)
            }
        }
        present(activityViewController, animated: true, completion: nil)
    }
    
    func save(memedImage:UIImage?){
        
        let meme = Meme(topText: textTop.text!, bottomText: textBottom.text!, originalImage: imageView.image!, memedImage: memedImage)
        print(meme.topText)
    }
    
    
    @IBAction func cameraPicker(_ sender: Any) {
        pickPhoto(UIImagePickerController.SourceType.camera)
    }
    
    @IBAction func galleryPicker(_ sender: Any) {
        pickPhoto(UIImagePickerController.SourceType.photoLibrary)
    }
    
    func pickPhoto(_ source: UIImagePickerController.SourceType){
        let picker = UIImagePickerController();
        picker.delegate = self
        picker.sourceType = source
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            shareButton.isEnabled = true
            picker.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        
        topToolbar.isHidden = true
        bottomToolbar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        topToolbar.isHidden = false
        bottomToolbar.isHidden = false
        
        return memedImage
    }
    
    
    @IBAction func cancelAction(_ sender: Any) {
        textTop.text = "TOP"
        textBottom.text = "BOTTOM"
        imageView.image = nil
        shareButton.isEnabled = false
    }
    
}

