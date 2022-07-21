public struct Memory
{
    private(set) var _memory: [byte] 
    private(set) var _ramStart: ushort 

    init(_ memory: [byte], ramStart: ushort)
    {
        _memory = memory
        _ramStart = ramStart
    }

    public subscript(address: ushort) -> byte {
        get {
            _memory[Int(address)]
        }
        set(newValue) {
            if address >= _ramStart {
                _memory[Int(address)] = newValue
            }
        }
    }
}
