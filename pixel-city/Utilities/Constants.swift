//
//  Constants.swift
//  pixel-city
//
//  Created by Sebastian Horatiu on 15/12/2019.
//  Copyright © 2019 Sebastian Horatiu. All rights reserved.
//

import Foundation

let API_KEY = "4813116377f0c9aadb9dec577a143992"
let NUMBER_OF_PHOTOS = 20

func flickrUrl(forApiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
    let url = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=km&per_page=\(number)&format=json&nojsoncallback=1"
    return url
}
