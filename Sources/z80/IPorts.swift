public protocol IPorts
{
    func ReadPort(_ address: ushort) -> byte
    func WritePort(_ address: ushort, _ value: byte)
    var NMI: bool { get }
    var MI: bool { get }
    var Data: byte { get }
}
