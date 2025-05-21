CYPERF_CLIENT_IP           = "44.246.181.137"
CYPERF_CLIENT_PRIVATE_IP   = "10.1.1.142"

CYPERF_SERVER_IP           = "44.201.53.244"
CYPERF_SERVER_PRIVATE_IP   = "10.0.1.146"


SERVER_COMMAND = "sudo cyperf -s --length 1k"
CLIENT_COMMAND = f"sudo cyperf -c {CYPERF_SERVER_PRIVATE_IP} --length 1k --bitrate 1G/s"
TEST_RUN_TIME = 30
EC2_KEY_FILE_PATH = "/Users/ashwjosh/vibecode.pem"




"""
Sample Command Help:

-- Throughput Test with Custom Payload Size and Bandwidth Limit of 1Gbps

Server (10.0.1.146):
sudo cyperf -s --length 1k

Client (10.1.1.142):
sudo cyperf -c 10.0.1.146 --length 1k --bitrate 1G/s

-- Connection Rate Test with Default Limits

Server (10.0.1.146):
sudo cyperf -s --cps

Client (10.1.1.142):
sudo cyperf -c 10.0.1.146 --cps

-- Connection Rate Test with Custom Payload Size and Connection Rate Limit of 1000 CPS

Server (10.0.1.146):
sudo cyperf -s --cps --length 1k

Client (10.1.1.142):
sudo cyperf -c 10.0.1.146 --cps 1k/s --length 1k

-- Customize Number of Parallel Sessions

Client (10.1.1.142):
sudo cyperf -c 10.0.1.146 --cps --parallel 8


Documentation Help:
cyperf
Either -c / --client or -s / --server option must be specified
Usage: sudo cyperf [-s|-c host] [options]
            cyperf [-h|--help] [-v|--version] [--about]

Quick help, for detailed information, check the man page by running "man cyperf"

Server specific:
  -s, --server                run in server mode
Client specific:
  -c, --client    <host>      run in client mode, connecting to <host>
  -b, --bitrate   #[KMG][/#]  target bitrate in bits/sec (0 for unlimited)
  -P, --parallel  #           number of parallel client sessions to run
Other options:
  --cps           [#KMG][/#]  target connection rate in connections/seconds
                              the value is optional and takes effect in client only
  -p, --port      #           server port to listen on/connect to
  -B, --bind      <host>      bind to the interface associated with the address <host>
  -l, --length    #[KMG]      length of buffer to read or write
  -F, --file      <filepath>  transmit / receive the specified file.
  --bidir                     run in bidirectional mode.
                              client and server send and receive data.
  -R, --reverse               run in reverse mode.
                              server sends and client receives.
  -i, --interval  #           seconds between periodic statistics reports
  -t, --time      #           time in seconds to run the test for (default 600 secs)
  -w, --window    #[KMG]      set TCP starting window size / socket buffer size
  --detailed-stats            show more detailed stats in console
  --csv-stats     <filepath>  write all stats to specified csv file
  -v, --version               show version information and quit
  -h, --help                  show this quick help and quit
  --about                     show the Keysight contact and license information.

[KMG] indicates options that support a K/M/G suffix for kilo-, mega-, or giga-


"""