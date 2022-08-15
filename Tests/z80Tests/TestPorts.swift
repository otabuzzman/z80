@testable import z80

final class TestPorts: IPorts
{
    private(set) var inputs = Array<Byte>(repeating: 0, count: 0x10000)
    private(set) var outputs = Array<Byte>(repeating: 0, count: 0x10000)
    private(set) var _data: Byte = 0x00
    private(set) var _mi: Bool = false
    private(set) var _nmi: Bool = false

    func SetInput(_ port: UShort, _ value: Byte)
    {
        inputs[port] = value
    }

    func GetOutput(_ port: UShort) -> Byte
    {
        return outputs[port];
    }

    func ReadPort(_ port: UShort) -> Byte
    {
        return inputs[port];
    }

    func WritePort(_ port: UShort, _ value: Byte)
    {
        outputs[port] = value
    }

    var NMI: Bool
    {
        get
        {
            let ret = _nmi
            _nmi = false
            return ret
        }
        set { _nmi = newValue }
    }

    var MI: Bool
    {
        get
        {
            let ret = _mi
            _mi = false
            return ret
        }
        set { _mi = newValue }
    }

    var Data: Byte
    {
        get
        {
            let ret = _data
            _data = 0x00
            return ret
        }
        set { _data = newValue }
    }
}
