//
//  ViewController.swift
//  PokemonGoVargas
//
//  Created by Gonzalo Vargas on 28/06/23.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var ubicacion = CLLocationManager()
    var contActualizaciones = 0
    var pokemons:[Pokemon] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        ubicacion.delegate = self
        pokemons = obtenerPokemon()
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            setup()
        }else{
            ubicacion.requestWhenInUseAuthorization()
        }
        
        //resetCoreData()

    }
    
    @IBAction func centrarTapped(_ sender: Any) {
        if let coord = ubicacion.location?.coordinate{
            let region = MKCoordinateRegion.init(center: coord, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            contActualizaciones += 1
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if contActualizaciones<1{
            let region = MKCoordinateRegion.init(center: ubicacion.location!.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            contActualizaciones += 1
        }else{
            ubicacion.stopUpdatingLocation()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            let pinview = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            pinview.image = UIImage(named: "player")
            var frame = pinview.frame
            frame.size.height = 50
            frame.size.width = 50
            pinview.frame = frame
            return pinview
        }
        
        let pinview = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        let pokemon = (annotation as! PokePin).pokemon
        pinview.image = UIImage(named: pokemon.imagenNombre!)
        var frame = pinview.frame
        frame.size.height = 50
        frame.size.width = 50
        pinview.frame = frame
        return pinview
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        if view.annotation is MKUserLocation {
            return
        }
        
        let region = MKCoordinateRegion.init(center: (view.annotation?.coordinate)!, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(region, animated: true)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] (_) in
            guard let self = self, let coord = self.ubicacion.location?.coordinate else {
                return
            }
            
            let pokemon = (view.annotation as! PokePin).pokemon
            
            if mapView.visibleMapRect.contains(MKMapPoint(coord)) {
                if pokemon.atrapado {
                    let alertaVC = UIAlertController(title: "¡Atención!", message: "Ya tienes un \(pokemon.nombre!). ¿Aún así deseas capturarlo?", preferredStyle: .alert)
                    
                    let capturarAccion = UIAlertAction(title: "Sí", style: .default) { (_) in
                        self.realizarCaptura(pokemon, annotationView: view)
                    }
                    
                    let cancelarAccion = UIAlertAction(title: "No", style: .cancel, handler: nil)
                    
                    alertaVC.addAction(capturarAccion)
                    alertaVC.addAction(cancelarAccion)
                    
                    self.present(alertaVC, animated: true, completion: nil)
                } else {
                    self.realizarCaptura(pokemon, annotationView: view)
                }
            } else {
                // Pokémon demasiado lejos
                let alertaVC = UIAlertController(title: "¡Ups!", message: "Estás muy lejos para atrapar a \(pokemon.nombre!). Acércate más.", preferredStyle: .alert)
                let okAccion = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertaVC.addAction(okAccion)
                self.present(alertaVC, animated: true, completion: nil)
            }
        }
    }

    private func realizarCaptura(_ pokemon: Pokemon, annotationView: MKAnnotationView) {
        // Realizar la captura del Pokémon
        pokemon.atrapado = true
        pokemon.contador += 1
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        mapView.removeAnnotation(annotationView.annotation!)
        
        // Mostrar mensaje de Pokémon atrapado
        let alertaVC = UIAlertController(title: "¡Felicidades!", message: "¡Atrapaste a \(pokemon.nombre!)!", preferredStyle: .alert)
        
        let pokedexAccion = UIAlertAction(title: "Ver Pokédex", style: .default) { (_) in
            self.performSegue(withIdentifier: "pokedexSegue", sender: nil)
        }
        
        let okAccion = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertaVC.addAction(pokedexAccion)
        alertaVC.addAction(okAccion)
        
        present(alertaVC, animated: true, completion: nil)
    }

    
    func setup(){
        mapView.delegate = self
        mapView.showsUserLocation = true
        ubicacion.startUpdatingLocation()
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
            if let coord = self.ubicacion.location?.coordinate{
                let pokemon = self.pokemons[Int(arc4random_uniform(UInt32(self.pokemons.count)))]
                let pin = PokePin(coord: coord, pokemon: pokemon)
                let randomLat = (Double(arc4random_uniform(200))-100.0)/5000.0
                let randomLon = (Double(arc4random_uniform(200))-100.0)/5000.0
                pin.coordinate.latitude += randomLat
                pin.coordinate.longitude += randomLon
                self.mapView.addAnnotation(pin)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            setup()
        }
    }
}

