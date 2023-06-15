//
//  Comics.swift
//  xkcdviewer
//
//  Created by Dipro on 6/14/23.
//  Copyright © 2023 TheRedSpecial. All rights reserved.
//

import Foundation

struct Comic: Codable {
    let month: String
    let num: Int
    let link: String
    let year: String
    let news: String
    let safe_title: String
    let transcript: String
    let alt: String
    let img: String
    let title: String
    let day: String
}
