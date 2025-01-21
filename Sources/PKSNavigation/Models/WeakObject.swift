//
//  WeakObject.swift
//  PKSNavigation
//
//  Created by Ömer Hamid Kamışlı on 1/18/25.
//


/// Allows weak storage of reference types in arrays, dictionaries, and other collection types.
internal struct PKSWeakObject<T: AnyObject> {
    weak var object: T?
}
