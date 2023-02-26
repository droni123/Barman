//
//  DetalleBebidaViewController.swift
//  Barman
//
//  Created by De la Cruz Hernandez on 24/02/23.
//

import UIKit
import AVFoundation
import Messages
import MessageUI

class DetalleBebidaViewController: UIViewController, UIImagePickerControllerDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {

    //var bebida : Bebida?
    let context = (UIApplication.shared.delegate! as! AppDelegate).persistentContainer.viewContext
    var bebida : BDBebidas?
    var imgPickCon : UIImagePickerController?
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var direcctions: UITextView!
    @IBOutlet weak var ingredients: UITextView!
    @IBOutlet weak var StakButton: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if bebida != nil {
            name.text = bebida?.name
            ingredients.text = bebida?.ingredients
            direcctions.text = bebida?.directions
            getOrSaveImage(named:bebida?.img,isRemoto:bebida?.isremoto ?? false)
            StakButton.isHidden = false
        } else {
            bebida = BDBebidas(context: context)
            name.text = ""
            ingredients.text = ""
            direcctions.text = ""
            StakButton.isHidden = true
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //image.image = UIImage(systemName: "camera.fill.badge.ellipsis")
        setupTextFields()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        image.addGestureRecognizer(tapGR)
        image.isUserInteractionEnabled = true
    }
    func getOrSaveImage(named: String?,isRemoto:Bool) {
        guard let nombrefile = named else { return }
        if(!nombrefile.isEmpty){
            let fileManager = FileManager.default
            if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                let filePath = URL(fileURLWithPath: documentsURL.absoluteString).appendingPathComponent(nombrefile).path
                if fileManager.fileExists(atPath: filePath) {
                    image.image = UIImage(contentsOfFile: filePath)
                } else {
                    let ad = UIApplication.shared.delegate as! AppDelegate
                    if ad.internetStatus && isRemoto {
                        if let laUrl = URL(string: "http://janzelaznog.com/DDAM/iOS/drinksimages/\(nombrefile)"){
                            let configuracion = URLSessionConfiguration.ephemeral
                            let session = URLSession(configuration: configuracion)
                            let elReq = URLRequest(url: laUrl)
                            let task = session.dataTask(with: elReq) { bytes, response, error in
                                if error == nil {
                                    guard let data = bytes else { return }
                                    DispatchQueue.main.async() {
                                        do{
                                            try data.write(to: documentsURL.appendingPathComponent(nombrefile), options: .atomic)
                                        }catch{
                                            print("Error al almacenar imagen")
                                        }
                                        self.image.image = UIImage(data: data)
                                    }
                                }else{
                                    print("Error \(String(describing: error))")
                                }
                            }
                            task.resume()
                        }
                    } else {
                        if !isRemoto{
                            print("No hay internet")
                            mensajeAlert(mensaje: "No hay internet")
                        }
                    }
                }
            }
        }
    }
    @objc func imageTapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let img = bebida?.img ?? ""
            if img.isEmpty {
                btnFotoTouch()
            }else{
                let mensaje = "Do you want to replace image?"
                let ac = UIAlertController(title: "Warning", message: mensaje, preferredStyle: .alert)
                let action = UIAlertAction(title: "Done", style: .default) { alertaction in
                    self.btnFotoTouch()
                }
                let action2 = UIAlertAction(title: "Cancel", style: .default)
                ac.addAction(action)
                ac.addAction(action2)
                self.present(ac, animated: true)
            }
        }
    }
    @objc func btnFotoTouch(){
        imgPickCon = UIImagePickerController()
        imgPickCon?.delegate = self
        imgPickCon?.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            switch AVCaptureDevice.authorizationStatus(for:.video){
                case .authorized:
                    imgPickCon?.sourceType = .camera
                    self.present(imgPickCon!, animated: true)
                case .notDetermined:AVCaptureDevice.requestAccess (for: .video) { permiso in
                        if permiso {
                            self.mostrarImagenPiker(.camera)
                        }
                        else {
                            self.mostrarImagenPiker(.photoLibrary)
                        }
                    }
                default:
                    permisos()
                    return
            }
        }else{
            self.mostrarImagenPiker(.photoLibrary)
        }
    }
    func mostrarImagenPiker(_ type: UIImagePickerController.SourceType){
        DispatchQueue.main.async {
            self.imgPickCon?.sourceType = type
            self.present(self.imgPickCon!, animated: true)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[.editedImage] as? UIImage {
            guard let data = img.jpegData(compressionQuality: 1.0) else { return }
            var nombrefile = bebida?.img ?? ""
            if(nombrefile.isEmpty || bebida?.isremoto == true){
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YY_MM_dd_HH_mm_ss.jpg"
                nombrefile = dateFormatter.string(from: date)
                //para no remplazar cuando se vuelva a resetear la lista
                bebida?.isremoto = false
            }
            let fileManager = FileManager.default
            if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                do{
                    try data.write(to: documentsURL.appendingPathComponent(nombrefile), options: .atomic)
                }catch{
                    print("Error al almacenar imagen")
                }
            }
            image.image = UIImage(data: data)
            bebida?.img = nombrefile
        }else{
            print("mensaje")
        }
        picker.dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    func permisos(){
        let ac = UIAlertController(title: "", message:"Se requiere permiso para usar la cámara. Puede configurarlo desde settings ahora", preferredStyle: .alert)
        let action = UIAlertAction(title: "SI", style: .default) {
            alertaction in
            if let laURL = URL(string:UIApplication.openSettingsURLString) {
                UIApplication.shared.open(laURL)
            }
        }
        let action2 = UIAlertAction(title: "NO", style: .destructive)
        ac.addAction(action)
        ac.addAction(action2)
        self.present(ac, animated: true)
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var perform = false
        if validateText(text: name.text!){
            perform = true
        } else{
            mensajeAlert(mensaje: "Name is empty" )
        }
        return perform
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ListaBebidasViewController
        bebida?.name = name.text
        bebida?.ingredients = ingredients.text
        bebida?.directions = direcctions.text
        bebida?.img = bebida?.img ?? ""
        destination.currentBebida = bebida
    }
    @IBAction func btn_share(_ sender: UIButton) {
        //si es posoble enviar correo
        if MFMailComposeViewController.canSendMail() {
            DispatchQueue.main.async {
                let mcvc = MFMailComposeViewController()
                mcvc.setSubject("Drink APP")
                mcvc.setMessageBody("Name: <strong>\(self.bebida?.name ?? "")</strong><br>Ingredients: <strong>\(self.bebida?.ingredients ?? "")</strong><br>Directions: <strong>\(self.bebida?.directions ?? "")</strong><br>", isHTML: true)
                let fileManager = FileManager.default
                if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let img = self.bebida?.img ?? ""
                    if !img.isEmpty {
                        let filePath = URL(fileURLWithPath: documentsURL.absoluteString).appendingPathComponent(img).path
                        if fileManager.fileExists(atPath: filePath) {
                            let imagen = UIImage(contentsOfFile: filePath)
                            guard let bytes = imagen!.jpegData(compressionQuality: 1.0) else { return }
                            mcvc.addAttachmentData(bytes, mimeType: "image/jpeg", fileName: "foto")
                        }
                    }
                }
                mcvc.mailComposeDelegate = self
                self.present(mcvc, animated: true)
            }
        }
    }
    @IBAction func btn_delete(_ sender: UIButton) {
        let mensaje = "Are you sure you want to delete?"
        let ac = UIAlertController(title: "Warning", message: mensaje, preferredStyle: .alert)
        let action = UIAlertAction(title: "Done", style: .default) { alertaction in
            self.deleteItem(bebidaToDelete: self.bebida!)
            //self.dismiss(animated: true)
            if self.presentingViewController is UINavigationController {
                self.dismiss(animated: true)
            } else{
                self.navigationController?.popViewController(animated: true)
            }
        }
        let action2 = UIAlertAction(title: "Cancel", style: .default)
        ac.addAction(action)
        ac.addAction(action2)
        self.present(ac, animated: true)
    }
    func deleteItem(bebidaToDelete:BDBebidas){
        do{
            context.delete(bebidaToDelete)
            try context.save()
            
        } catch{
            self.mensajeAlert(mensaje: "Error al guardar: \(error) ")
        }
    }
    func setupTextFields(){
        let toolbar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([flexSpace,doneButton], animated: true)
        toolbar.sizeToFit()
        name.inputAccessoryView = toolbar
        ingredients.inputAccessoryView = toolbar
        direcctions.inputAccessoryView = toolbar
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    func mensajeAlert(mensaje: String = "Message",titulo: String = "Warning"){
        let alertMensaje = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let cancelAcction = UIAlertAction(title: "Done", style: .cancel)
        alertMensaje.addAction(cancelAcction)
        self.present(alertMensaje, animated: true)
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        print("\(String(describing: error))","ok")
        controller.dismiss(animated: true)
    }
}
