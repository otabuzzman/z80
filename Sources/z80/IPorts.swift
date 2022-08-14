public protocol IPorts
{
    func ReadPort(_ port: ushort) -> byte
    func WritePort(_ port: ushort, _ value: byte)
    var NMI: Bool { get }
    var MI: Bool { get }
    var Data: byte { get }
}
