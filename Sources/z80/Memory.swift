public class Memory
{
    private(set) var mem: [Byte]
    private(set) var start: UShort
    private(set) var ports: [MPorts]?

    public init(_ ram: [Byte], _ start: UShort, _ ports: [MPorts]? = nil)
    {
        mem = ram
        self.start = start
        self.ports = ports
    }

    public func clear() {
        for addr in 0..<mem.count {
            mem[addr] = 0
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
            return mem[Int(addr)]
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
                mem[Int(addr)] = newValue
            }
        }
    }
}
