//
//  PokedexViewController.swift
//  PokemonGoVargas
//
//  Created by Gonzalo Vargas on 28/06/23.
//

import UIKit

class PokedexViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var pokemonsAtrapados:[Pokemon] = []
    var pokemonsNoAtrapados:[Pokemon] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pokemonsAtrapados = obtenerPokemonsAtrapados()
        pokemonsNoAtrapados = obtenerPokemonsNoAtrapados()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func mapTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pokemon: Pokemon
        if indexPath.section == 0 {
            pokemon = pokemonsAtrapados[indexPath.row]
        } else {
            pokemon = pokemonsNoAtrapados[indexPath.row]
        }
        let cell = UITableViewCell()
        cell.imageView?.image = UIImage(named: pokemon.imagenNombre!)

        if indexPath.section == 0 {
            let contador = pokemon.contador
            cell.textLabel?.text = "\(pokemon.nombre!) (\(contador))"
        } else {
            cell.textLabel?.text = pokemon.nombre
        }
        return cell
    }
        
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Atrapados"
        }else{
            return "No Atrapados"
        }
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return pokemonsAtrapados.count
        }else{
            return pokemonsNoAtrapados.count
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let pokemon: Pokemon
            if indexPath.section == 0 {
                pokemon = pokemonsAtrapados[indexPath.row]
            } else {
                return
            }
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            if pokemon.contador > 1 {
                pokemon.contador -= 1
            } else {
                pokemon.atrapado = false
                pokemon.contador = 0
            }
            
            do {
                try context.save()
            } catch {
                print("Error al guardar los cambios después de marcar el Pokémon como no atrapado: \(error)")
            }
            
            if pokemon.contador == 0 {
                pokemonsAtrapados.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                if pokemonsAtrapados.isEmpty {
                    tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                }
                
                let indexPathNoAtrapados = IndexPath(row: pokemonsNoAtrapados.count, section: 1)
                pokemonsNoAtrapados.append(pokemon)
                tableView.insertRows(at: [indexPathNoAtrapados], with: .automatic)
            } else {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    

}
