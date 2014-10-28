//
//  NSPropertyDescription+Importing.swift
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 17-10-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import CoreData

extension NSPropertyDescription
{
    /**
    Keys that could contain data for this property as defined by the model
    
    :returns: Array of keys to look for when mapping data into this property
    */
    var mappings: [String] {
        var _mappings = [String]()

        // Fetch the unnumbered mapping
        if let unnumberedMapping = userInfo?[MappingUserInfoKey] as? String {
            if SuppressMappingUserInfoValue == unnumberedMapping {
                return [String]()
            } else {
                _mappings.append(unnumberedMapping)
            }
        }

        // Fetch the numbered mappings
        for i in 0...MaxNumberedMappings+1 {
            if let numberedMapping = userInfo?[MappingUserInfoKey + ".\(i)"] as? String {
                _mappings.append(numberedMapping)

                if i == MaxNumberedMappings+1 {
                    println("[CoreDataKit] Warning: Only mappings up to \(MappingUserInfoKey).\(MaxNumberedMappings) mappings are supported, you defined more for \(entity.name).\(name)")
                }
            }
        }

        // Fallback to the name of the property as a mapping if no mappings are defined
        if 0 == _mappings.count {
            _mappings.append(name)
        }

        return _mappings
    }

    /**
    Looks at the available mappings and takes the preferred value out of the given dictionary based on those mappings

    :param: dictionary Data to import from
    
    :returns: Value to import
    */
    func preferredValueFromDictionary(dictionary: [String: AnyObject]) -> ImportableValue {
        for keyPath in mappings {
            if let value: AnyObject = (dictionary as NSDictionary).valueForKeyPath(keyPath) {
                if value is NSNull {
                    return .Null
                } else {
                    return .Some(value)
                }
            }
        }

        return .None
    }
}