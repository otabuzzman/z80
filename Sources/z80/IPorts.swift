public protocol IPorts
{
    func ReadPort(_ port: ushort) -> byte
    func WritePort(_ port: ushort, _ value: byte)
    var NMI: bool { get }
    var MI: bool { get }
    var Data: byte { get }
}
