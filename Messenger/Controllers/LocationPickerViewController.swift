//
//  LocationPickerViewController.swift
//  Messenger
//
//  Created by Yolima Pereira Ruiz on 15/10/23.
//

import UIKit
import CoreLocation
import MapKit

class LocationPickerViewController: UIViewController {
    
    public var completion: ((CLLocationCoordinate2D) -> Void)?
    private var coordinates: CLLocationCoordinate2D?
    private var isPickable = true
    
    private let map: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    init(coordinates: CLLocationCoordinate2D?) {
        self.coordinates = coordinates
        self.isPickable = false
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        if isPickable {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send",
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(sendButtonTapped))
            map.isUserInteractionEnabled = true
            
            let gesture = UITapGestureRecognizer(target: self,
                                              action: #selector(didTapMap(_:)))
            gesture.numberOfTouchesRequired = 1
            gesture.numberOfTapsRequired = 1
        //    gesture.
            map.addGestureRecognizer(gesture)
        }
        else {
            //just showing location
            guard let coordinates = self.coordinates else {
                return
            }
            
            //drop a pin on that location
            let pin = MKPointAnnotation()
            pin.coordinate = coordinates
         
            map.addAnnotation(pin)
        }
        view.addSubview(map)
        
      
    }
    
    @objc func sendButtonTapped() {
        guard let coordinates = coordinates else {
            return
        }
        navigationController?.popViewController(animated: true)
        completion?(coordinates)
    }
    
    @objc func didTapMap(_ gesture: UITapGestureRecognizer){
        //get the location of the tap and converte it into coordenates
        let locationInView = gesture.location(in: map)
        let coordinates = map.convert(locationInView, toCoordinateFrom: map)
        self.coordinates = coordinates
        
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }
        
        for anotation in map.annotations {
            map.removeAnnotation(anotation)
        }
        //drop a pin on that location
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
     
        map.addAnnotation(pin)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        map.frame = view.bounds
    }
    

}
