public typealias byte = UInt8
public typealias sbyte = Int8

public typealias short = Int16
public typealias ushort = UInt16

extension Array {
    public subscript(index: byte) -> Element {
        get {
            self[Int(index)]
        }
        set(newValue) {
            self[Int(index)] = newValue
        }
    }

    public subscript(index: ushort) -> Element {
        get {
            self[Int(index)]
        }
        set(newValue) {
            self[Int(index)] = newValue
        }
    }
}

extension short {
    static var MaxValue: Self {
        Self.max
    }

    static var MinValue: Self {
        Self.min
    }
}

public func +(lhs: ushort, rhs: Int) -> ushort {
    ushort(truncatingIfNeeded: Int(lhs) + rhs)
}

public func +(lhs: ushort, rhs: sbyte) -> ushort {
    ushort(truncatingIfNeeded: Int(lhs) + Int(rhs))
}

public func +(lhs: ushort, rhs: byte) -> ushort {
    ushort(truncatingIfNeeded: Int(lhs) + Int(rhs))
}

public func -(lhs: ushort, rhs: Int) -> ushort {
    ushort(truncatingIfNeeded: Int(lhs) - rhs)
}

public func -(lhs: ushort, rhs: byte) -> ushort {
    ushort(truncatingIfNeeded: Int(lhs) - Int(rhs))
}
