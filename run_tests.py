import paramiko
import time
import  configurations

def ssh_and_stream_command(hostname, username, password=None, key_filename=None, command=None):
    # Create SSH client
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    try:
        # Connect to the remote server
        if key_filename:
            ssh.connect(hostname, username=username, key_filename=key_filename)
        else:
            ssh.connect(hostname, username=username, password=password)
        
        # Execute the command
        stdin, stdout, stderr = ssh.exec_command(command)

        find_cmd = "ps -ef | grep 'cyperf -s --cps' | grep root | awk '{print $2}'"
        stdin, stdout, stderr = ssh.exec_command(find_cmd)
        pids = stdout.read().decode().strip().split('\n')
        pids = [pid for pid in pids if pid]
        return pids
    except Exception as e:
        print(f"An error occurred: {str(e)}")
    finally:
        ssh.close()

def kill_cyperf_and_show_log(hostname, username, find_cmd=None, password=None, key_filename=None):
    """
    Finds the PID(s) of the cyperf server process, kills them, and then shows the last 15 lines of the log file.
    """
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        if key_filename:
            ssh.connect(hostname, username=username, key_filename=key_filename)
        else:
            ssh.connect(hostname, username=username, password=password)
            
        stdin, stdout, stderr = ssh.exec_command(find_cmd)
        pids = stdout.read().decode().strip().split('\n')
        pids = [pid for pid in pids if pid]

        if not pids:
            print("No cyperf process found.")
        else:
            for pid in pids:
                kill_cmd = f"sudo kill -9 {pid}"
                stdin, stdout, stderr = ssh.exec_command(kill_cmd)
                out = stdout.read().decode().strip()
                err = stderr.read().decode().strip()
                if out:
                    print(out)
                if err:
                    pass

        # Show the last 15 lines of the log file
        tail_cmd = "tail -n 15 /home/ubuntu/cce.txt"
        stdin, stdout, stderr = ssh.exec_command(tail_cmd)
        log_output = stdout.read().decode().strip()
        print(log_output)
        print("================================================")
    except Exception as e:
        print(f"An error occurred: {str(e)}")
    finally:
        ssh.close()

if __name__ == "__main__":
    # Example usage
    username = "ubuntu"
    # key_filename = "/Users/ashwjosh/Downloads/cce.pem"  # Optional if using password authentication
    key_filename = configurations.EC2_KEY_FILE_PATH

    # START SERVER
    command = f"{configurations.SERVER_COMMAND}  > /home/ubuntu/cce.txt" 
    print(command)
    ssh_and_stream_command(configurations.CYPERF_SERVER_IP, username, password=None, key_filename=key_filename, command=command)

    command = f"{configurations.CLIENT_COMMAND}  > /home/ubuntu/cce.txt" 
    print(command)
    ssh_and_stream_command(configurations.CYPERF_CLIENT_IP, username, password=None, key_filename=key_filename, command=command)


    time.sleep(configurations.TEST_RUN_TIME)


    # KILL SERVER
    print(" ======= SERVER STATISTICS ======= ")
    kill_cyperf_and_show_log(configurations.CYPERF_SERVER_IP, username, find_cmd="ps -ef | grep 'cyperf -s' | grep root | awk '{print $2}'", password=None, key_filename=key_filename)
    # KILL 
    print("=======  CLIENT STATISTICS ======= ")
    kill_cyperf_and_show_log(configurations.CYPERF_CLIENT_IP, username, find_cmd="ps -ef | grep 'cyperf -c' | grep root | awk '{print $2}'", password=None, key_filename=key_filename)
