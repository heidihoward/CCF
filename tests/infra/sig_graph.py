import polars as pl
import subprocess
import numpy as np
import matplotlib.pyplot as plt
import datetime
import json

throughputs = {}
sig_tx_intervals = [10,50,100,500,1000,5000,10000,20000]
timenow = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")

for sig_tx_interval in sig_tx_intervals:
    throughputs[sig_tx_interval] = []
    for i in range(3):
        basicperf_cmd = ["python3", "/home/azureuser/heidi/CCF/tests/infra/basicperf.py", "-b", ".", "-c", "./submit", "--host-log-level", "info", "--enclave-log-level", "info", "--worker-threads", "10", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/actions.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/validate.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/resolve.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/apply.js", "--label", "pi_basic_mt_sgx_cft^", "--snapshot-tx-interval", "20000", "--package", "samples/apps/basic/libbasic", "-e", "release", "-t", "sgx", "--workspace", f"/home/azureuser/heidi/CCF/build-sgx/ws-{timenow}-sig{sig_tx_interval}-i{i}", "--sig-tx-interval", str(sig_tx_interval), "--sig-ms-interval", "5000" ,"--client-timeout-s", "300", "--client-def", "6,write,100000,primary", "-n", "ssh://172.23.0.8","-n", "ssh://172.23.0.9","-n", "ssh://172.23.0.10"]
        subprocess.run(basicperf_cmd)

        stats = json.load(open(f"/home/azureuser/heidi/CCF/build-sgx/ws-{timenow}-sig{sig_tx_interval}-i{i}/pi_basic_mt_sgx_cft^_common/statistics.json"))
        throughputs[sig_tx_interval].append(stats["all_clients_active_average_throughput_tx/s"])

print(throughputs)

fontsize = 12
params = {
    "axes.labelsize": fontsize,
    "font.size": fontsize,
    "legend.fontsize": fontsize,
    "xtick.labelsize": fontsize,
    "ytick.labelsize": fontsize,
    "figure.figsize": (2,2),
    "xtick.direction": "in",
    "ytick.direction": "in",
    "xtick.top": True,
    "xtick.bottom": True,
    "ytick.right": True,
    "xtick.minor.visible": True,
    "ytick.minor.visible": True,
    "lines.linewidth": 2,
    "legend.frameon": False,
    "axes.grid": False,
    "savefig.bbox": "tight",
}
plt.rcParams.update(params)

plt.figure()
heights = []
max_errs = []
min_errs = []
for sig_tx_interval in sig_tx_intervals:
    medium = np.percentile(throughputs[sig_tx_interval],50) / 1000
    heights.append(medium)
    max_errs.append(np.max(throughputs[sig_tx_interval]) / 1000 - medium)
    min_errs.append(medium - np.min(throughputs[sig_tx_interval]) / 1000)
print(heights)
print(max_errs)
print(min_errs)

plt.errorbar(sig_tx_intervals,heights,yerr=[min_errs,max_errs],capsize=3,color='black')

plt.ylabel("Throughput (Ktx/s)")
plt.xlabel("Signature interval")
plt.xscale("log")
plt.yticks([0,20,40,60,80])
plt.xticks([10,100,1000,10000])
plt.savefig("throughput_sigs.pdf")
plt.close()