//
//  Typealiases.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 24/05/2022.
//

import Foundation

public typealias EmptyCompletion = () -> Void
public typealias CompletionObject<T> = (_ response: T) -> Void
public typealias CompletionOptionalObject<T> = (_ response: T?) -> Void
public typealias CompletionResponse = (_ response: Result<Void, Error>) -> Void
