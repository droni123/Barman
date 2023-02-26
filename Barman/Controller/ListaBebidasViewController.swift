//
//  ListaBebidasViewController.swift
//  Barman
//
//  Created by De la Cruz Hernandez on 24/02/23.
//

import UIKit

class ListaBebidasViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var currentBebida : BDBebidas?
    var dataManager : BDBebidasManager?
    var index:Int = 0
    @IBOutlet var tableBebidas: UITableView!
    let spinner = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        dataManager = BDBebidasManager(context: context)
        cargardatos()
    }
    func cargardatos(){
        dataManager!.fecth()
    }
    func recargarDatos(){
        cargardatos()
        self.tableBebidas.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        spinner.isHidden = true
        recargarDatos()
        if (dataManager?.countBebida() ?? 0) == 0 {
            let ad = UIApplication.shared.delegate as! AppDelegate
            if ad.internetStatus {
                guard let laURL = URL(string: "http://janzelaznog.com/DDAM/iOS/drinks.json") else {return}
                let configuracion = URLSessionConfiguration.ephemeral
                let session = URLSession(configuration: configuracion)
                let elReq = URLRequest(url: laURL)
                setLoadingScreen()
                let task = session.dataTask(with: elReq) { bytes, response, error in
                    if error == nil {
                        guard let data = bytes else { return }
                        let results = try? JSONDecoder().decode([Bebida].self, from: data)
                        
                        let todasBebidas = results ?? [Bebida]()
                        todasBebidas.forEach { bb in
                            let bbToBD = BDBebidas(context: self.context)
                            bbToBD.name = bb.name
                            bbToBD.img = bb.img
                            bbToBD.isremoto = true
                            bbToBD.ingredients = bb.ingredients
                            bbToBD.directions = bb.directions
                            do{
                                try self.context.save()
                            } catch{
                                print("Error al guardar: \(error) ")
                            }
                        }
                        DispatchQueue.main.async() {
                            self.recargarDatos()
                            self.removeLoadingScreen()
                        }
                    }else{
                        print("Error al guardar: \(String(describing: error)) ")
                        DispatchQueue.main.async() {
                            self.removeLoadingScreen()
                        }
                    }
                }
                task.resume()
            } else {
                print("No hay internet")
                mensajeAlert(mensaje: "No hay internet")
            }
        }
        
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return todasBebidas.count
        return dataManager!.countBebida()
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        //let bebida = todasBebidas[indexPath.row]
        let bebida = dataManager!.getBebida(at: indexPath.row)
            cell.textLabel?.text = bebida.name
        return cell
    }
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        index = indexPath.row
        return indexPath
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if sender as? UIBarButtonItem == nil {
            let destination = segue.destination as! DetalleBebidaViewController
            //destination.bebida = todasBebidas[index]
            destination.bebida = dataManager!.getBebida(at: index)
        }
    }
    @IBAction func unWindFromDetail(segue: UIStoryboardSegue){
        let source = segue.source as! DetalleBebidaViewController
        currentBebida = source.bebida
        do{
            try context.save()
        } catch{
            self.mensajeAlert(mensaje: "Error al guardar: \(error) ")
            print("Error al guardar: \(error) ")
        }
        recargarDatos()
    }
    func mensajeAlert(mensaje: String = "Message",titulo: String = "Warning"){
        let alertMensaje = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let cancelAcction = UIAlertAction(title: "Done", style: .cancel)
        alertMensaje.addAction(cancelAcction)
        self.present(alertMensaje, animated: true)
    }
    private func setLoadingScreen() {
        let guide = view.safeAreaLayoutGuide
        spinner.frame = CGRect(x: 0, y: 0, width: guide.layoutFrame.width, height: 20)
        spinner.startAnimating()
        self.view.addSubview(spinner)
    }
    private func removeLoadingScreen() {
        spinner.stopAnimating()
        spinner.isHidden = true
    }
}
