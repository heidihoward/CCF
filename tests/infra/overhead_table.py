import polars as pl
import subprocess
import datetime
import json

timenow = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")

throughputs = []
apps = [["--package", "samples/apps/basic/libbasic","--client-def","6,write,100000,primary"],
       ["--package", "samples/apps/basic/libbasic","--client-def","18,read,100000,any"],
       ["--js-app-bundle", "../samples/apps/basic/js/", "--client-def", "10,write,100000,primary"],
       ["--js-app-bundle", "../samples/apps/basic/js/", "--client-def", "30,read,100000,any"],
]

for app_conf in apps:

    basicperf_cmd = ["python3", "/home/azureuser/heidi/CCF/tests/infra/basicperf.py", "-b", ".", "-c", "./submit", "--host-log-level", "info", "--enclave-log-level", "info", "--worker-threads", "10", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/actions.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/validate.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/resolve.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/apply.js", "--label", "pi_basic_mt_sgx_cft^", "--client-timeout-s", "200", "--snapshot-tx-interval","20000",  "-e", "release", "-t", "sgx", "--workspace", f"/home/azureuser/heidi/CCF/build-sgx/ws-{timenow}-tab", "-n", "ssh://172.23.0.13", "-n", "ssh://172.23.0.9","-n", "ssh://172.23.0.10"] + app_conf
    
    subprocess.run(basicperf_cmd)

    stats = json.load(open(f"/home/azureuser/heidi/CCF/build-sgx/ws-{timenow}-tab/pi_basic_mt_sgx_cft^_common/statistics.json"))
    throughputs.append((app_conf, stats["average_throughput_tx/s"]))

print("throughputs", throughputs)
