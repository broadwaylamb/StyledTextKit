//
//  UIScreen+Static.swift
//  StyledTextKit
//
//  Created by Ryan Nystrom on 12/14/17.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import UIKit

// grab this once and avoid touching this on the main thread
@available(
    iOS,
    introduced: 2.0,
    deprecated: 26.0,
    message: "Use a UIScreen instance found through context instead (i.e, view.window.windowScene.screen), or for properties like UIScreen.scale with trait equivalents, use a traitCollection found through context."
)
@MainActor
public let StyledTextScreenScale = UIScreen.main.scale
