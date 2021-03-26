//
//  GoogleMapsView.swift
//  Phonebook
//
//  Created by Pavel Miskevich on 24.03.21.
//

import SwiftUI
import GoogleMaps


struct GoogleMapsView: UIViewRepresentable {
    
    @EnvironmentObject var session: Session
    
    let assistant: GoogleMapsAssistant
    
    let showPhonebookLocationPins: Bool
    
    func makeCoordinator() -> GoogleMapsViewCoordinator {
        return GoogleMapsViewCoordinator(assistant: assistant)
    }
    
    func makeUIView(context: Self.Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 1)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = context.coordinator
        assistant.position = camera.target
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        if showPhonebookLocationPins {
            assistant.markers.forEach { (marker) in
                marker.map = nil
            }
            
            session.getLocalAssets()?.forEach({ (asset) in
                if let location = asset.suggestedLocation {
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )
                    marker.title = "\(asset.givenname + " " + asset.lastname)"
                    marker.snippet = location.note
                    marker.map = mapView
                    assistant.markers.append(marker)
                }
            })
        }
    }
}

class GoogleMapsViewCoordinator: NSObject, GMSMapViewDelegate {
    
    let assistant: GoogleMapsAssistant
    
    init(assistant: GoogleMapsAssistant) {
        self.assistant = assistant
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        assistant.position = position.target
    }
}
