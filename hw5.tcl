#Create a simulator object
set ns [new Simulator]

#Open the nam trace file
set nf [open out.nam w]
$ns namtrace-all $nf


#Define a 'finish' procedure
proc finish {} {
        global ns nf
        $ns flush-trace
	#Close the trace file
        close $nf
	#Execute nam on the trace file
        exec nam out.nam &
        exit 0
}

#Create 9 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]

#DropTail/SFQ     
#Create a duplex link between the nodes
$ns duplex-link $n0 $n3 1Mb 10ms DropTail
$ns duplex-link $n1 $n3 1Mb 10ms DropTail
$ns duplex-link $n2 $n3 1Mb 10ms DropTail
$ns duplex-link $n3 $n4 1Mb 10ms SFQ
$ns duplex-link $n3 $n5 1Mb 10ms SFQ
$ns duplex-link $n4 $n6 1Mb 10ms DropTail
$ns duplex-link $n5 $n6 1Mb 10ms DropTail
$ns duplex-link $n6 $n7 1Mb 10ms DropTail
$ns duplex-link $n6 $n8 1Mb 10ms DropTail


#
$ns duplex-link-op $n0 $n3 orient right-down      
$ns duplex-link-op $n1 $n3 orient right      
$ns duplex-link-op $n2 $n3 orient right-up      
$ns duplex-link-op $n3 $n4 orient right-up      
$ns duplex-link-op $n3 $n5 orient right-down      
$ns duplex-link-op $n4 $n6 orient right-down      
$ns duplex-link-op $n5 $n6 orient right-up      
$ns duplex-link-op $n6 $n7 orient right-up      
$ns duplex-link-op $n6 $n8 orient right-down      
#Create TCP agents and attach them to node n0,n1
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0

set ftp0 [new Application/FTP]
$ftp0 set packetSize_ 1000
$ftp0 set interval_ 0.005
$ftp0 attach-agent $tcp0

set tcp1 [new Agent/TCP]
$ns attach-agent $n1 $tcp1

set ftp1 [new Application/FTP]
$ftp1 set packetSize_ 1000
$ftp1 set interval_ 0.005
$ftp1 attach-agent $tcp1


#Create a UDP agent and attach it to node n2
set udp2 [new Agent/UDP]
$ns attach-agent $n2 $udp2

# Create a CBR traffic source and attach it to udp2
set cbr2 [new Application/Traffic/CBR]
$cbr2 set packetSize_ 1000
$cbr2 set interval_ 0.005
$cbr2 attach-agent $udp2


#
set sink7_1 [new Agent/TCPSink]
set sink7_2 [new Agent/TCPSink]
$ns attach-agent $n7 $sink7_1
$ns attach-agent $n7 $sink7_2

$ns connect $tcp0 $sink7_1
$ns connect $tcp1 $sink7_2


#Create a Null agent (a traffic sink) and attach it to node n8
set null8 [new Agent/Null]
$ns attach-agent $n8 $null8

$ns connect $udp2 $null8
 

#Making flows
$tcp0 set class_ 0
$tcp1 set class_ 1
$udp2 set class_ 2

$ns color 0 Blue
$ns color 1 Red
$ns color 2 Green

#Monitoring
#$ns duplex-link-op $n2 $n3 queuePos 0.5


$ns rtmodel-at 2.0 down $n3 $n4
$ns rtmodel-at 4.0 up $n3 $n4

$ns rtproto DV
#Schedule events
$ns at 0.1 "$ftp0 start"
$ns at 0.5 "$ftp1 start"
$ns at 1 "$cbr2 start"

$ns at 4.5 "$ftp0 stop"
$ns at 4.5 "$ftp1 stop"
$ns at 4.5 "$cbr2 stop"

#detach

#Call the finish procedure after 5 seconds of simulation time
$ns at 5.0 "finish"

#Run the simulation
$ns run
