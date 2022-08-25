//
//  UIFont+Extension.swift
//  RockReportTool
//
//  Created by Sergiy Shevchuk on 15.08.2022.
//

import UIKit

extension UIFont {

    private class MyDummyClass {}

    static func loadFontWith(name: String) {
        let frameworkBundle = Bundle(for: MyDummyClass.self)
        let pathForResourceString = frameworkBundle.path(forResource: name, ofType: "ttf")
        let fontData = NSData(contentsOfFile: pathForResourceString!)
        let dataProvider = CGDataProvider(data: fontData!)
        let fontRef = CGFont(dataProvider!)
        var errorRef: Unmanaged<CFError>? = nil

        if (CTFontManagerRegisterGraphicsFont(fontRef!, &errorRef) == false) {
            print("AAA")
            print("Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
        }
    }

//    let aaa = UIFont(name: "Gotham-Light", size: 12.0)
//    let bbb = UIFont(name: "Gotham-Medium-Lat", size: 12.0)
//    let ccc = UIFont(name: "Gotham-BookItalic", size: 12.0)
//    let ddd = UIFont(name: "Gotham-Book-Lat", size: 12.0)
//    let eee = UIFont(name: "Gotham-Bold-Lat", size: 12.0)
    
    public static let loadMyFonts: () = {
        loadFontWith(name: "Gotham-Bold-Lat")
        loadFontWith(name: "Gotham-Medium-Lat")
        loadFontWith(name: "Gotham-Book-Lat")
    }()
}

public extension UIFont {

    static func jbs_registerFont(withFilenameString filenameString: String, bundle: Bundle) {

        guard let pathForResourceString = bundle.path(forResource: filenameString, ofType: nil) else {
            print("UIFont+:  Failed to register font - path for resource not found.")
            return
        }

        guard let fontData = NSData(contentsOfFile: pathForResourceString) else {
            print("UIFont+:  Failed to register font - font data could not be loaded.")
            return
        }

        guard let dataProvider = CGDataProvider(data: fontData) else {
            print("UIFont+:  Failed to register font - data provider could not be loaded.")
            return
        }

        guard let font = CGFont(dataProvider) else {
            print("UIFont+:  Failed to register font - font could not be loaded.")
            return
        }

        var errorRef: Unmanaged<CFError>? = nil
        if (CTFontManagerRegisterGraphicsFont(font, &errorRef) == false) {
            print("UIFont+:  Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
        }
    }

}
