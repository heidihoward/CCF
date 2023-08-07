import polars as pl
import subprocess
import datetime
import json

throughputs = {}
timenow = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")


basicperf_cmd = ["python3", "/home/azureuser/heidi/CCF/tests/infra/basicperf.py", "-b", ".", "-c", "./submit", "--host-log-level", "info", "--enclave-log-level", "info", "--worker-threads", "10", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/actions.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/validate.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/resolve.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/apply.js", "--label", "pi_basic_mt_sgx_cft^", "--snapshot-tx-interval", "20000", "--package", "samples/apps/basic/libbasic", "-e", "release", "-t", "sgx", "--workspace", f"/home/azureuser/heidi/CCF/build-sgx/ws-{timenow}-test", "-n", "ssh://172.23.0.13", "-n", "ssh://172.23.0.9","-n", "ssh://172.23.0.10", "--client-def", "6,write,1000000,primary","--client-def", "12,read,1000000,backup", "--client-timeout-s", "200", "--key-space-size","10000"]

subprocess.run(basicperf_cmd)
