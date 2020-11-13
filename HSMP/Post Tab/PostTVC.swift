//
//  PostTVC.swift
//  HSMP
//
//  Created by Kerry Zhou on 10/7/20.
//

import UIKit
import CoreData

class PostTVC: UITableViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        //connect data
        currencyPV.dataSource = self
        currencyPV.delegate = self
        
        
        
        //set delegate for all textfield
        titleTF.delegate = self
        subTitleTF.delegate = self
        priceTF.delegate = self
        noteTV.delegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        

        
        
        
        
        //recognizer
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
    }

    

    @objc func selectImage(){//MARK:
        let picker = UIImagePickerController()
        picker.delegate = self
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhoto = UIAlertAction(
            title: "Take Photo",
            style: .default,
            handler: { (UIAlertAction) -> Void in
                picker.sourceType = .camera
                picker.allowsEditing = true
                self.present(picker, animated: true, completion: nil)
                
        })
        let choosePhotoAction = UIAlertAction(
            title: "Open Library",
            style: .default,
            handler: {
                (UIAlertAction) -> Void in
                picker.sourceType = .photoLibrary
                picker.allowsEditing = true
                self.present(picker, animated: true, completion: nil)
                
        })
        let cancel = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil)
        
        alert.addAction(takePhoto)
        alert.addAction(choosePhotoAction)
        alert.addAction(cancel)
        

        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        
        self.present(alert, animated: true, completion: nil)
    }
    

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
       * Called when 'return' key pressed. return NO to ignore.
       */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
      }


     /**
      * Called when the user click on the view (outside the UITextField).
      */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if (text == "\n") {
//               textView.resignFirstResponder()
//               return false
//           }
//           return false
//    }
    

    
    

    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var subTitleTF: UITextField!
    @IBOutlet weak var priceTF: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var noteTV: UITextView!
    @IBOutlet weak var currencyPV: UIPickerView!
    
    
    
    let currencyOptions = ["$", "¥", "£", "€"]
    
    var currency = "$"

    func resetAllFields(){
        titleTF.text = ""
        subTitleTF.text = ""
        priceTF.text = ""
        imageView.image = UIImage(named: "addImage")
        noteTV.text = ""
        
        currencyPV.selectRow(0, inComponent: 0, animated: true)
        
        self.view.endEditing(true)
    }
    
    
    
    
    
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        
        //MARK: need to have check whether the use fill out the information
        
        let alert = UIAlertController(title: nil, message: "Are you sure to post?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) -> Void in
            

            if self.checkWhetherRequiredDone(){
                //MARK: Package Up, and also need to detect whether image is selected
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let newProduct = NSEntityDescription.insertNewObject(forEntityName: "AllLocalProduct", into: context)
                
                //Attributes
                
                newProduct.setValue(self.titleTF.text!, forKey: "title")
                newProduct.setValue(self.subTitleTF.text!, forKey: "subTitle")
                
                let priceRaw = Double(self.priceTF.text!)!
                if priceRaw == floor(priceRaw){
                    newProduct.setValue("\(self.currency)\(Int(priceRaw))", forKey: "price")
                }
                
                newProduct.setValue(UUID(), forKey: "id")
                
                if self.imageView.image?.jpegData(compressionQuality: 1) != UIImage(named: "addImage")?.jpegData(compressionQuality: 1){
                    newProduct.setValue(self.imageView.image?.jpegData(compressionQuality: 0.1), forKey: "image")
                }else{
                    newProduct.setValue(nil, forKey: "image")
                }
                
                if self.noteTV.text != ""{
                    newProduct.setValue(self.noteTV.text, forKey: "note")
                }else{
                    newProduct.setValue("", forKey: "note")
                }
                
                let date = Date()
                newProduct.setValue(date, forKey: "date")
                
                newProduct.setValue(true, forKey: "isSelfPosted")
                
                newProduct.setValue(false, forKey: "isFavorite")
                
                newProduct.setValue(false, forKey: "isViewed")
                
                newProduct.setValue("Me", forKey: "seller")
                
                do {
                    try context.save()
                    print("success")
                } catch {
                    print("error")
                }
                
            }
            
            
            self.resetAllFields()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        

        
        
    }
    
    
    @IBAction func trashButtonPressed(_ sender: Any) {
        resetAllFields()
    }
    
    
    func checkWhetherRequiredDone() -> Bool{
        if titleTF.text == ""{
            makeAlert(title: "No Title", subTitle: "Need to include title, doesn't need to be long")
            return false
        }
        
        if subTitleTF.text == ""{
            makeAlert(title: "No Sub-Title", subTitle: "Need to include sub-title")
            return false
        }
        
        if priceTF.text != ""{
            if Double(priceTF.text!) == nil{
                makeAlert(title: "Cannot Read Price", subTitle: "Change price into a two digits decimal")
                return false
            }
        }else{
            makeAlert(title: "No Price", subTitle: "Need to include price")
            return false
        }
        
        return true
    }
    
    
    func makeAlert(title:String, subTitle:String){
        let alert = UIAlertController(title: title, message: subTitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}



extension PostTVC: UIPickerViewDelegate{
    
}

extension PostTVC: UIPickerViewDataSource{
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyOptions.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return currencyOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currency = currencyOptions[row]
    }
    
}
