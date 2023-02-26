//
//  Helpers.swift
//  Barman
//
//  Created by De la Cruz Hernandez on 26/02/23.
//

import Foundation
import UIKit

func validateText(text : String) -> Bool{
    if (text.trimmingCharacters(in: .whitespaces).isEmpty){
        return false
    } else{
        return true
    }
}

