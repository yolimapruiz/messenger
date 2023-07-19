//
//  ViewController.swift
//  Messenger
//
//  Created by Yolima Pereira Ruiz on 10/07/23.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
       
    }

    //check if they are singned in based on user defaults
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }

        private func validateAuth(){
            //si hay un usuario actual, quiere decir que alguien tiene inciada una sesion
            if FirebaseAuth.Auth.auth().currentUser == nil {
                
                let vc = LoginViewController()
                
                //creacion de un navigation controller que va a embeber el controller qu eya tenemos vc
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen // si no se especifica esto sale como una tarjeta a la que el user puede hacer swipe down
                present(nav, animated: false)
            }
        
    }
   

}

