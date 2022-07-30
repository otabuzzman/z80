public typealias int = Int

public typealias byte = UInt8
public typealias sbyte = Int8

public typealias short = Int16
public typealias ushort = UInt16

public typealias bool = Bool

public typealias string = String

extension Array {
    public subscript(index: byte) -> Element {
        get {
            self[int(index)]
        }
        set(newValue) {
            self[int(index)] = newValue
        }
    }

    public subscript(index: ushort) -> Element {
        get {
            self[int(index)]
        }
        set(newValue) {
            self[int(index)] = newValue
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

func +(lhs: ushort, rhs: sbyte) -> ushort {
    ushort(truncatingIfNeeded: int(lhs) + int(rhs))
}

func +(lhs: ushort, rhs: byte) -> ushort {
    ushort(truncatingIfNeeded: int(lhs) + int(rhs))
}

func -(lhs: ushort, rhs: byte) -> ushort {
    ushort(truncatingIfNeeded: int(lhs) - int(rhs))
}
