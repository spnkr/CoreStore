//
//  FIeldRelationshipType.swift
//  CoreStore
//
//  Copyright © 2020 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import CoreData
import Foundation


// MARK: - FieldRelationshipType

public protocol FieldRelationshipType {

    associatedtype DestinationObjectType: CoreStoreObject

    associatedtype NativeValueType: AnyObject

    associatedtype SnapshotValueType

    static func cs_toReturnType(from value: NativeValueType?) -> Self

    static func cs_toNativeType(from value: Self) -> NativeValueType?

    static func cs_valueForSnapshot(from value: NativeValueType?) -> SnapshotValueType
}

public protocol FieldRelationshipToOneType: FieldRelationshipType {}


public protocol FieldRelationshipToManyType: FieldRelationshipType where Self: Sequence {}
public protocol FieldRelationshipToManyOrderedType: FieldRelationshipToManyType {}
public protocol FieldRelationshipToManyUnorderedType: FieldRelationshipToManyType {}


extension Optional: FieldRelationshipType, FieldRelationshipToOneType where Wrapped: CoreStoreObject {

    public typealias DestinationObjectType = Wrapped

    public typealias NativeValueType = NSManagedObject

    public typealias SnapshotValueType = NSManagedObjectID?

    public static func cs_toReturnType(from value: NativeValueType?) -> Self {

        return value.map(Wrapped.cs_fromRaw(object:))
    }

    public static func cs_toNativeType(from value: Self) -> NativeValueType? {

        return value?.cs_toRaw()
    }

    public static func cs_valueForSnapshot(from value: NativeValueType?) -> SnapshotValueType {

        return value?.objectID
    }
}


extension Array: FieldRelationshipType, FieldRelationshipToManyType, FieldRelationshipToManyOrderedType where Element: CoreStoreObject {

    public typealias DestinationObjectType = Element

    public typealias NativeValueType = NSOrderedSet

    public typealias SnapshotValueType = [NSManagedObjectID]

    public static func cs_toReturnType(from value: NativeValueType?) -> Self {

        guard let value = value else {

            return []
        }
        return value.map({ Element.cs_fromRaw(object: $0 as! NSManagedObject) })
    }

    public static func cs_toNativeType(from value: Self) -> NativeValueType? {

        return NSOrderedSet(array: value.map({ $0.rawObject! }))
    }

    public static func cs_valueForSnapshot(from value: NativeValueType?) -> SnapshotValueType {

        guard let value = value else {

            return []
        }
        return value.map({ ($0 as! NSManagedObject).objectID })
    }
}

extension Set: FieldRelationshipType, FieldRelationshipToManyType, FieldRelationshipToManyUnorderedType where Element: CoreStoreObject {

    public typealias DestinationObjectType = Element

    public typealias NativeValueType = NSSet

    public typealias SnapshotValueType = Set<NSManagedObjectID>

    public static func cs_toReturnType(from value: NativeValueType?) -> Self {

        guard let value = value else {

            return []
        }
        return Set(value.map({ Element.cs_fromRaw(object: $0 as! NSManagedObject) }))
    }

    public static func cs_toNativeType(from value: Self) -> NativeValueType? {

        return NSSet(array: value.map({ $0.rawObject! }))
    }

    public static func cs_valueForSnapshot(from value: NativeValueType?) -> SnapshotValueType {

        guard let value = value else {

            return []
        }
        return .init(value.map({ ($0 as! NSManagedObject).objectID }))
    }
}
