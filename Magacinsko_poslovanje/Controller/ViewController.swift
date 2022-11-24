//  Magacinsko_poslovanje
//  Created by Ana Cvejic

import UIKit
import CoreData



class ViewController: UIViewController{
    

    
    @IBOutlet weak var segmentProduct: UISegmentedControl!
    @IBOutlet weak var scrollViewFirst: UIScrollView!
    @IBOutlet weak var tfNameOfProduct: UITextField!
    @IBOutlet weak var tfCodeProduct: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var scrolViewSecond: UIScrollView!
    @IBOutlet weak var tfNumberInfoice: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var tfInsertedQuantity: UITextField!
    @IBOutlet weak var btnSaveProduct: UIButton!
    @IBOutlet weak var btnNameOfProduct: UIButton!
    
    var nazivProizvoda: String = ""
    var sifraProizvoda: String = ""
    var ukupnaKolicina: Int64 = 0
    
    var item: [String] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setControl()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }

    
    func setControl(){
    
        btnNameOfProduct.layer.borderWidth = 3
        btnNameOfProduct.layer.cornerRadius = 15
        btnNameOfProduct.layer.borderColor = UIColor.blue.cgColor
        
        scrolViewSecond.isHidden = true
        btnSaveProduct.isHidden = true
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.blue]
        segmentProduct.setTitleTextAttributes(titleTextAttributes, for:.normal)
        segmentProduct.selectedSegmentTintColor = UIColor.blue
        let titleTextAttributes1 = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentProduct.setTitleTextAttributes(titleTextAttributes1, for:.selected)
        segmentProduct.layer.borderWidth = 2
        segmentProduct.layer.borderColor = UIColor.blue.cgColor
    }

    @IBAction func btnSaveTapped(_ sender: Any) {
        
        let nameOfProduct = tfNameOfProduct.text
        let codeOfProduct = tfCodeProduct.text
        guard tfNameOfProduct.text != "" else{
            alert(title: "Polje naziv proizvoda ne sme biti prazno")
            return
        }
        
        guard nameOfProduct?.trimmingCharacters(in: .whitespacesAndNewlines) != "" else{
            alert(title: "Neispravan unos naziva proizvoda")
            return
        }
        
        guard codeOfProduct == "" || codeOfProduct?.trimmingCharacters(in: .whitespaces) == "" else{
            insertNewProduct(nameOfProduct: tfNameOfProduct.text!, codeOfProduct: tfCodeProduct.text!, quantity: 0)
            return
        }
        
        insertNewProduct(nameOfProduct: tfNameOfProduct.text!, codeOfProduct: "", quantity: 0)
        
    }
    
    @IBAction func btnSaveTypeOfProduct(_ sender: Any) {
        let numberInvoice = tfNumberInfoice.text
        let price = tfPrice.text
        let insertedQuantity = tfInsertedQuantity.text
        
        guard tfNumberInfoice.text != "" && tfPrice.text != "" && tfInsertedQuantity.text != "" else{
            alert(title: "Morate popuniti sva polja")
            return
        }
        guard numberInvoice?.trimmingCharacters(in: .whitespaces) != "" && price?.trimmingCharacters(in: .whitespaces) != "" && insertedQuantity?.trimmingCharacters(in: .whitespaces) != "" else {
            alert(title: "Neispravan unos parametara")
            return
        }
        guard nazivProizvoda != "" else{
            alert(title: "Morate odabrati proizvod")
            return
        }
        guard Int64(tfInsertedQuantity.text!) != nil && Int64(tfPrice.text!) != nil else {
            alert(title: "Polja uneta količina i cena po komadu moraju biti numerička")
            return
        }
        let pr: Proizvod = fetchProizvod(nameOfProduct: nazivProizvoda, codeOfProduct: sifraProizvoda)
        print("\(pr)")
        updateProizvod(product: pr)
        
        insertNewTypeOfPoduct(numberInvoice: tfNumberInfoice.text!, price: Int64(tfPrice.text!)! , insertedQuantity: Int64(tfInsertedQuantity.text!)!, product: pr)
    }
    
    func fetchProizvod(nameOfProduct: String, codeOfProduct: String)->Proizvod{
        let request: NSFetchRequest<Proizvod> = Proizvod.fetchRequest()
        request.predicate = NSPredicate(format: "nazivProizvoda = %@ AND sifraProizvoda = %@", nazivProizvoda, sifraProizvoda)
        var pr: Proizvod?
        
        do{
            pr = try self.context.fetch(request).first
        }catch{
            print("GRESKA")
        }
        return pr!
        
    }
    
    func updateProizvod(product: Proizvod){
        let currentQuantity = product.ukupnoProizvoda
        let newQuantity = currentQuantity + Int64(tfInsertedQuantity.text!)!
        print("NOVA KOLICINA: \(newQuantity)")
        product.ukupnoProizvoda = newQuantity
        
        do{
            try self.context.save()
            print("UKUPNA KOLICINA JE IZMENJENA")
        }catch{
            
        }
    }
    func insertNewTypeOfPoduct(numberInvoice: String, price: Int64, insertedQuantity: Int64, product: Proizvod){
        
        let currentDateTime = Date()

        
                         
        let typeOfProduct = VrstaProizvoda(context: self.context)
        typeOfProduct.brojFakture = "Br. " + numberInvoice
        typeOfProduct.cena = price
        typeOfProduct.kolkicinaUneto = insertedQuantity
        typeOfProduct.datumFakture = currentDateTime
        product.addToVrstaProizvoda(typeOfProduct)
        
        do{
            try self.context.save()
            print("USPESNO STE UNELI VRSTU PROIZVODA")
        }catch{
            
        }
        clearTypeOfProduct()
    }
    
    func insertNewProduct(nameOfProduct: String, codeOfProduct: String, quantity: Int64){
        let newProizvod = Proizvod(context: self.context)
        newProizvod.nazivProizvoda = nameOfProduct
        newProizvod.sifraProizvoda = codeOfProduct
        newProizvod.ukupnoProizvoda = quantity
        do{
            try self.context.save()
            print("USPESNO STE UNELI PROIZVOD")
        }catch{

        }
        clearElement()
    }
    
    func clearTypeOfProduct(){
        tfNumberInfoice.text = ""
        tfInsertedQuantity.text = ""
        tfPrice.text = ""
        btnNameOfProduct.setTitle("Naziv proizvoda", for: .normal)
    }
    
    func clearElement(){
        tfNameOfProduct.text = ""
        tfCodeProduct.text = ""
    }
    
    @IBAction func segmentTapped(_ sender: Any) {
        switch segmentProduct.selectedSegmentIndex{
        case 0:
            scrollViewFirst.isHidden = false
            btnSave.isHidden = false
            scrolViewSecond.isHidden = true
            btnSaveProduct.isHidden = true
        case 1:
            scrollViewFirst.isHidden = true
            btnSave.isHidden = true
            scrolViewSecond.isHidden = false
            btnSaveProduct.isHidden = false
        default:
            break
            
        }
        
    }
    
    
    @IBAction func btnNazivProizvodaTapped(_ sender: Any) {
        
        
        
    }
    
    func alert(title: String){
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func prepare(for segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwind(for segue: UIStoryboardSegue) {
        
        if segue.identifier == "backToInsert"{
            if let destination = segue.source as? ProizvodiViewController{
                
                nazivProizvoda = destination.nazivProizvoda
                sifraProizvoda = destination.sifraProizvoda
                ukupnaKolicina = destination.ukupnaKolicina
                btnNameOfProduct.setTitle(nazivProizvoda + " " + sifraProizvoda, for: .normal)
            }
            
        }
    }
}

