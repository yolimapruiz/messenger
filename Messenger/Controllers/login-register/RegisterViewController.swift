//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Yolima Pereira Ruiz on 10/07/23.
//

import UIKit

class RegisterViewController: UIViewController {
    
    // MARK: - Creation of subviews
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    private let FirstNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue // para que cuando pulsen enter los lleve al field de la contraseña
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "First Name..."
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        return field
    }()
    
    private let LastNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue // para que cuando pulsen enter los lleve al field de la contraseña
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Last Name..."
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        return field
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue // para que cuando pulsen enter los lleve al field de la contraseña
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email address..."
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        return field
    }()

    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password.."
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        
        return field
    }()
    
    
    private let registerButton : UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemPink
        title = "Register"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        registerButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        //add subViews
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(FirstNameField)
        scrollView.addSubview(LastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        
        gesture.numberOfTouchesRequired = 1
       
        
        imageView.addGestureRecognizer(gesture)
    }
    
    @objc private func didTapChangeProfilePic() {
        print("Cambiando la imagen de perfil")
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        //here we can give the frame to our imageView
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2 ,
                                     y: 90,
                                     width: size,
                                     height: size)
        
        FirstNameField.frame = CGRect(x: 30 ,
                                  y: imageView.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52)
        
        LastNameField.frame = CGRect(x: 30 ,
                                  y: FirstNameField.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52)
        emailField.frame = CGRect(x: 30 ,
                                  y: LastNameField.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30 ,
                                     y: emailField.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 52)
        
        registerButton.frame = CGRect(x: 30 ,
                                     y: passwordField.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 52)
        
    }
    
    // MARK: - Validations
    
    @objc private func loginButtonTapped(){
        //to get rid of the keyboard
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        FirstNameField.resignFirstResponder()
        LastNameField.resignFirstResponder()
        
        //Is there text in all textFields?
        guard let firstName = FirstNameField.text,
                let lastName = LastNameField.text,
              let email = emailField.text,
                let password = passwordField.text,
              !email.isEmpty,
              !password.isEmpty,
              !firstName.isEmpty,
              !lastName.isEmpty,
              password.count >= 6 else {
            alertUserLogginError()
            return
        }
        
        //Firebase Log in
    }
    
    func alertUserLogginError(){
        let alert = UIAlertController(title: "Woops", message: "Please enter all the information to create a new account", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Ccount"
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
}


extension RegisterViewController: UITextFieldDelegate {
    //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //esta funcion se llama cuando el user pulsa enter = return
        
        if textField == emailField {
            //si el user esta en el email field y pulsa enter, el curso va a ir al password
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            //si ya esta en password entonces hace las veces del boton
            loginButtonTapped()
            
        }
        return true
    }
}
