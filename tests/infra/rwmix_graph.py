import subprocess
import numpy as np
import matplotlib.pyplot as plt
import datetime
import json

throughputs = {}
rw_mixes = range(0,7,1)
timenow = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
read_fraction = []

for rw_mix in rw_mixes:
    throughputs[rw_mix] = []
    for i in range(1):

        basicperf_cmd = ["python3", "/home/azureuser/heidi/CCF/tests/infra/basicperf.py", "-b", ".", "-c", "./submit", "--host-log-level", "info", "--enclave-log-level", "info", "--worker-threads", "10", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/actions.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/validate.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/resolve.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/apply.js", "--label", "pi_basic_mt_sgx_cft^", "--snapshot-tx-interval", "20000", "--package", "samples/apps/basic/libbasic", "-e", "release", "-t", "sgx", "--workspace", f"/home/azureuser/heidi/CCF/build-sgx/ws-{timenow}-w{rw_mix}-i{i}", "-n", "ssh://172.23.0.13", "--client-def", f"{6-rw_mix},write,1000000,primary","--client-def", f"{rw_mix},read,1000000,primary"] 
        
        subprocess.run(basicperf_cmd)
        stats = json.load(open(f"/home/azureuser/heidi/CCF/build-sgx/ws-{timenow}-w{rw_mix}-i{i}/pi_basic_mt_sgx_cft^_common/statistics.json"))
        throughputs[rw_mix].append(stats["all_clients_active_average_throughput_tx/s"] / 1000)
        read_fraction.append(1 - stats["all_clients_active_write_fraction"])

fontsize = 12
params = {
    "axes.labelsize": fontsize,
    "font.size": fontsize,
    "legend.fontsize": fontsize,
    "xtick.labelsize": fontsize,
    "ytick.labelsize": fontsize,
    "figure.figsize": (8, 3.5),
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
    "text.usetex": False,
}
plt.rcParams.update(params)

heights = []
max_errs = []
min_errs = []
for rw_mix in rw_mixes:
    medium = np.percentile(throughputs[rw_mix],50)
    heights.append(np.percentile(throughputs[rw_mix],50))
    max_errs.append(np.max(throughputs[rw_mix]) - medium)
    min_errs.append(medium - np.min(throughputs[rw_mix]))

plt.figure(figsize=[1.7,2.5])
# plt.errorbar(read_fraction,heights,yerr=[min_errs,max_errs], color="#E69F00")
plt.plot(read_fraction,heights,'.',ls="-",color="#E69F00")
plt.ylabel("Mixed throughput (Ktx/s)")
plt.xlabel("Read ratio")
plt.ylim([0,200])
plt.savefig(f"throughput_rwmix_set.pdf")
plt.close()