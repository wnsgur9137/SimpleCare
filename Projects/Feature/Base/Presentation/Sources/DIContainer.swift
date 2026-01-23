//
//  DIContainer.swift
//  BasePresentation
//
//  Created by JunHyeok Lee on 1/23/26.
//  Copyright © 2026 com.junhyeok.SimpleCare. All rights reserved.
//

import Foundation

public protocol DIContainer {
    associatedtype Dependencies
    var dependencies: Dependencies { get }
}
