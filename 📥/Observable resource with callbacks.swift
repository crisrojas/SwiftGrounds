//
//  Observable resource with callbacks.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 20/11/23.
//

import Foundation

/// Protocol Orient approach for creating a resource based architecture approach
///
/// Such architecture is based in the follow separation of concerns:
///
/// Instead of having an object that is charged of fetching a resource
/// (aka Repository) splitted in many sub objects (aka UseCases)
/// a resource should be able to retireve itself and perform the pertinent CRUD 
/// operations (see FilePersistable protocol for an example of this approach)
///
/// This is a flexible approach used in networking (resource based networking)
///
/// Some libraries, like Siesta, push the approach one level further: 
///
/// Resources are not only responsible for knowing how to perform the basic CRUD operations,
/// but they also need to hold their own state and be able to notify on state changes to observers.
///
/// For such behaviour we would need observers to have a shared instance:
///
/// final class Observer1 { var observable = Api.observedResource }
/// final class Observer2 { var observable = Api.observedResource }
///
/// We can push further the idea to a different domain: Persistency (heck we could even make a network resource observable & persistable!!!)
///
/// The idea is to have a common protocol that would define the contract of what an observableResource would need, and then have persistency protocols
/// for each persistency solution. The latest would "inherit" from it and implement defaults through protocol extension.
///
/// ex.:)
/// SQLiteObservableResource
/// FileCodableObservableResource
/// CoreDataObservableResource
/// etc...
///
/// This is my attempt to implement a FileCodableObservableResource.
/// I could have used combine, but wanted the thing to work with UIKit, so rely on callbacks and Jim Lai awesomely simple (yet powrful) Rx<T> struct
///
///

// MARK: - First Attempt: Generic Class
///
///
/// We want to have an observable resource that shares its state through the app 