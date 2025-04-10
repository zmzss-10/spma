function ArrivalTime= arrivaltime(PacketLength,delta,arrivalrate)
    ArrivalTime=PacketLength/(delta*arrivalrate);
end

