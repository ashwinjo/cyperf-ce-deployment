import paramiko
from typing import Dict, Any
from app.core.config import settings

class CyperfService:
    def __init__(self):
        self.active_tests: Dict[str, Dict[str, Any]] = {}

    def _connect_ssh(self, hostname: str):
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(
            hostname=hostname,
            username=settings.SSH_USERNAME,
            key_filename=settings.SSH_KEY_PATH
        )
        return ssh

    def start_server(self, test_id: str, params: Dict[str, Any]) -> Dict[str, Any]:
        command = f"sudo cyperf -s"
        if params.get("cps"):
            command += " --cps"
        if params.get("port"):
            command += f" --port {params['port']}"
        if params.get("length"):
            command += f" --length {params['length']}"
        if params.get("csv_stats"):
            command += " --csv-stats"
        command += f" > {test_id}_server.log 2>&1 &"
        ssh = self._connect_ssh(settings.SERVER_IP)
        ssh.exec_command(command)
        find_cmd = "ps -ef | grep 'cyperf -s' | grep root | awk '{print $2}'"
        _, stdout, _ = ssh.exec_command(find_cmd)
        pids = stdout.read().decode().strip().split('\n')
        server_pid = int(pids[0]) if pids and pids[0] else None
        self.active_tests[test_id] = {
            "server_pid": server_pid,
            "server_log_path": f"{test_id}_server.log",
            "server_csv_path": f"{test_id}_server.csv"
        }
        ssh.close()
        return {"server_pid": server_pid}

    def start_client(self, test_id: str, server_ip: str, params: Dict[str, Any]) -> Dict[str, Any]:
        if test_id not in self.active_tests:
            raise Exception("Server not started for this test_id")
        command = f"sudo cyperf -c {server_ip}"
        if params.get("cps"):
            command += f" --cps {params['cps']}"
        if params.get("port"):
            command += f" --port {params['port']}"
        if params.get("length"):
            command += f" --length {params['length']}"
        if params.get("time"):
            command += f" --time {params['time']}"
        if params.get("bitrate"):
            command += f" --bitrate {params['bitrate']}"
        if params.get("parallel"):
            command += f" --parallel {params['parallel']}"
        if params.get("csv_stats"):
            command += " --csv-stats"
        if params.get("reverse"):
            command += " --reverse"
        if params.get("bidi"):
            command += " --bidir"
        if params.get("interval"):
            command += f" --interval {params['interval']}"
        command += f" > {test_id}_client.log 2>&1 &"
        ssh = self._connect_ssh(settings.CLIENT_IP)
        ssh.exec_command(command)
        find_cmd = "ps -ef | grep 'cyperf -c' | grep root | awk '{print $2}'"
        _, stdout, _ = ssh.exec_command(find_cmd)
        pids = stdout.read().decode().strip().split('\n')
        client_pid = int(pids[0]) if pids and pids[0] else None
        self.active_tests[test_id]["client_pid"] = client_pid
        self.active_tests[test_id]["client_log_path"] = f"{test_id}_client.log"
        self.active_tests[test_id]["client_csv_path"] = f"{test_id}_client.csv"
        ssh.close()
        return {"client_pid": client_pid}

    def stop_test(self, test_id: str) -> Dict[str, Any]:
        if test_id not in self.active_tests:
            raise Exception("Test not found")
        test_info = self.active_tests[test_id]
        if test_info.get("server_pid"):
            ssh = self._connect_ssh(settings.SERVER_IP)
            ssh.exec_command(f"sudo kill -9 {test_info['server_pid']}")
            ssh.close()
        if test_info.get("client_pid"):
            ssh = self._connect_ssh(settings.CLIENT_IP)
            ssh.exec_command(f"sudo kill -9 {test_info['client_pid']}")
            ssh.close()
        return test_info

    def get_server_stats(self, test_id: str) -> str:
        if test_id not in self.active_tests:
            raise Exception("Test not found")
        ssh = self._connect_ssh(settings.SERVER_IP)
        _, stdout, _ = ssh.exec_command(f"tail -n 50 {self.active_tests[test_id]['server_log_path']}")
        output = stdout.read().decode()
        ssh.close()
        return output

    def get_client_stats(self, test_id: str) -> str:
        if test_id not in self.active_tests:
            raise Exception("Test not found")
        ssh = self._connect_ssh(settings.CLIENT_IP)
        _, stdout, _ = ssh.exec_command(f"tail -n 50 {self.active_tests[test_id]['client_log_path']}")
        output = stdout.read().decode()
        ssh.close()
        return output
