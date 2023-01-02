//
//  Font.swift
//  RegistrationApp
//
//  Created by Кирилл Коновалов on 02.01.2023.
//

import SwiftUI

extension Font {
    static func bold(size: CGFloat) -> Font {
        return Font.system(size: getSizeWithAdoptation(size), weight: .bold, design: .default)
    }
    
    static func medium(size: CGFloat) -> Font {
        return Font.system(size: getSizeWithAdoptation(size), weight: .medium, design: .default)
    }
    
    //Уменьшаем шрифт, если экран маленький
    static func getSizeWithAdoptation(_ size: CGFloat) -> CGFloat {
        if UIScreen.main.bounds.height <= CGFloat(568) {
            return size - 3.0
        } else {
            return size
        }
    }
}
