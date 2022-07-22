public class Memory
{
    private(set) var _memory: [byte] 
    private(set) var _ramStart: ushort 

    init(_ count: int, _ ramStart: ushort)
    {
        _memory = Array<byte>(repeating: 0, count: count)
        _ramStart = ramStart
    }

	public func clear() {
		for addr in 0..<0x10000 {
			_memory[addr] = 0
		}
	}

    public subscript(address: ushort) -> byte {
        get {
            _memory[int(address)]
        }
        set(newValue) {
            if address >= _ramStart {
                _memory[int(address)] = newValue
            }
        }
    }
}
