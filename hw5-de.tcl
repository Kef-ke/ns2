#Create a simulator object
set ns [new Simulator]

#Open the nam trace file
#set nf [open out.nam w]

set f0 [open out0.tr w]
set f1 [open out1.tr w]
set f2 [open out2.tr w]
#$ns namtrace-all $nf

proc attach-expoo-traffic { node sink size burst idle rate } {
	#Get an instance of the simulator
	set ns [Simulator instance]

	#Create a UDP agent and attach it to the node
	set source [new Agent/UDP]
	$ns attach-agent $node $source

	#Create an Expoo traffic agent and set its configuration parameters
	set traffic [new Application/Traffic/Exponential]
	$traffic set packetSize_ $size
	$traffic set burst_time_ $burst
	$traffic set idle_time_ $idle
	$traffic set rate_ $rate
        
        # Attach traffic source to the traffic generator
        $traffic attach-agent $source
	#Connect the source and the sink
	$ns connect $source $sink
	return $traffic
}

proc record {} {
        global sink7_1 sink8_1 sink8_2 f0 f1 f2
        #Get an instance of the simulator
        set ns [Simulator instance]
        #Set the time after which the procedure should be called again
        set time 0.5
        #How many bytes have been received by the traffic sinks?
        set bw0 [$sink7_1 set bytes_]
        set bw1 [$sink8_1 set bytes_]
        set bw2 [$sink8_2 set bytes_]
        #Get the current time
        set now [$ns now]
        #Calculate the bandwidth (in MBit/s) and write it to the files
        puts $f0 "$now [expr $bw0/$time*8/1000000]"
        puts $f1 "$now [expr $bw1/$time*8/1000000]"
        puts $f2 "$now [expr $bw2/$time*8/1000000]"
        #Reset the bytes_ values on the traffic sinks
        $sink7_1 set bytes_ 0
        $sink8_1 set bytes_ 0
        $sink8_2 set bytes_ 0
        #Re-schedule the procedure
        $ns at [expr $now+$time] "record"
}


#Define a 'finish' procedure
proc finish {} {
        global f0 f1 f2
        #$ns flush-trace
	#Close the trace file
        #close $nf	
	close $f0
	close $f1
	close $f2

	#Execute nam on the trace file
        # exec nam out.nam &
	exec xgraph out0.tr out1.tr out2.tr -geometry 800x400 &
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

set sink7_1 [new Agent/TCPSink]
#set sink7_2 [new Agent/TCPSink]
$ns attach-agent $n7 $sink7_1
#$ns attach-agent $n7 $sink7_2


#$ns connect $tcp1 $sink7_2


#Create a Null agent (a traffic sink) and attach it to node n8
set sink8_1 [new Agent/LossMonitor]
set sink8_2 [new Agent/LossMonitor]
$ns attach-agent $n8 $sink8_1
$ns attach-agent $n8 $sink8_2


 
#Create TCP agents and attach them
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
$ns connect $tcp0 $sink7_1

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
#$ftp0 set packetSize_ 1000
#$ftp0 set interval_ 0.005
$ftp0 set type_ FTP


set source1 [attach-expoo-traffic $n1 $sink8_1 1000 2s 1s 400k]


#Create a UDP agent and attach it to node n2
set udp2 [new Agent/UDP]
$ns attach-agent $n2 $udp2

# Create a CBR traffic source and attach it to udp2
set cbr2 [new Application/Traffic/CBR]
$cbr2 set packetSize_ 1000
$cbr2 set interval_ 0.005
$cbr2 attach-agent $udp2
$ns connect $udp2 $sink8_2

#



$ns rtmodel-at 2.0 down $n3 $n4
$ns rtmodel-at 4.0 up $n3 $n4

$ns rtproto DV
#Schedule events
$ns at 0.0 "record"
$ns at 0.1 "$ftp0 start"
$ns at 0.5 "$source1 start"
$ns at 1 "$cbr2 start"

$ns at 20.1 "$ftp0 stop"
$ns at 20.1 "$source1 stop"
$ns at 20.1 "$cbr2 stop"

#detach

#Call the finish procedure after 5 seconds of simulation time
$ns at 25.1 "finish"

#Run the simulation
$ns run
