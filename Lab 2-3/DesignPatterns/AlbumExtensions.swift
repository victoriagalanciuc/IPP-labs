//
//  AlbumExtensions.swift
//  BlueLibrarySwift
//
//  Created by Brandon on 2/20/17.
//  Copyright © 2017 Raywenderlich. All rights reserved.
//

import Foundation

extension Album {
    func ae_tableRepresentation() -> (titles:[String], values:[String]) {
        return(["Artists", "Album", "Genre", "Year"], [artist, title, genre, year])
    }
}
