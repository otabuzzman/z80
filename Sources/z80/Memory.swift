public class Memory
{
    private var bytes: [Byte]
    private var start: UShort
    private var ports: [MPorts]?

    public init(_ bytes: [Byte], _ start: UShort, _ ports: [MPorts]? = nil)
    {
        self.bytes = bytes
        self.start = start
        self.ports = ports
    }

    public func clear() {
        for addr in 0..<bytes.count {
            bytes[addr] = 0
        }
    }

    public subscript(addr: UShort) -> Byte {
        get {
            if let ports = self.ports {
                for block in ports {
                    if block.mmap.contains(addr) {
                        return block.rdPort(addr)
                    }
                }
            }
            return bytes[Int(addr)]
        }
        set(newValue) {
            if addr >= start {
                if let ports = self.ports {
                    for block in ports {
                        if block.mmap.contains(addr) {
                            block.wrPort(addr, newValue)
                            return
                        }
                    }
                }
                bytes[Int(addr)] = newValue
            }
        }
    }
}

extension Memory {
    public func replaceSubrange<C>(_ subrange: Range<Int>, with newBytes: C) where C: Collection, C.Element == Byte {
        bytes.replaceSubrange(subrange, with: newBytes)
    }
}

