import subprocess
import numpy as np
import matplotlib.pyplot as plt
import datetime
import json

throughputs = {}
rw_mixes = [0, 1]
timenow = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
count_of_nodes = [1,3,5]

for rw_mix in rw_mixes:
    throughputs[rw_mix] = {}
    for nodes in count_of_nodes:
        throughputs[rw_mix][nodes] = []
        for i in range(5):
            clients = 6*nodes
            if rw_mix == 1:
                client_def = ["--client-def", f"{6},write,100000,primary"]
            else:
                client_def = ["--client-def", f"{6*nodes},read,100000,any"]

            basicperf_cmd = ["python3", "/home/azureuser/heidi/CCF/tests/infra/basicperf.py", "-b", ".", "-c", "./submit", "--host-log-level", "info", "--enclave-log-level", "info", "--worker-threads", "10", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/actions.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/validate.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/resolve.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/apply.js", "--label", "pi_basic_mt_sgx_cft^", "--snapshot-tx-interval", "20000", "--package", "samples/apps/basic/libbasic", "-e", "release", "-t", "sgx", "--workspace", f"/home/azureuser/heidi/CCF/build-sgx/ws-{timenow}-w{rw_mix}-n{nodes}-i{i}"] + ["-n", "ssh://172.23.0.13", "-n", "ssh://172.23.0.9","-n", "ssh://172.23.0.10", "-n", "ssh://172.23.0.11", "-n", "ssh://172.23.0.12"][:nodes*2] + client_def
            
            subprocess.run(basicperf_cmd)

            stats = json.load(open(f"/home/azureuser/heidi/CCF/build-sgx/ws-{timenow}-w{rw_mix}-n{nodes}-i{i}/pi_basic_mt_sgx_cft^_common/statistics.json"))
            throughputs[rw_mix][nodes].append(stats["all_clients_active_average_throughput_tx/s"] / 1000)

fontsize = 12
params = {
    "axes.labelsize": fontsize,
    "font.size": fontsize,
    "legend.fontsize": fontsize,
    "xtick.labelsize": fontsize,
    "ytick.labelsize": fontsize,
    "figure.figsize": (8, 2.5),
    "xtick.direction": "in",
    "ytick.direction": "in",
    "xtick.top": False,
    "xtick.bottom": False,
    "ytick.right": True,
    "xtick.minor.visible": True,
    "ytick.minor.visible": True,
    "lines.linewidth": 2,
    "legend.frameon": False,
    "axes.grid": False,
    "savefig.bbox": "tight",
}
plt.rcParams.update(params)

for rw_mix in rw_mixes:
    plt.figure(figsize=[1.7,2.5])
    heights = []
    max_errs = []
    min_errs = []
    for i, nodes in enumerate(count_of_nodes):
        medium = np.percentile(throughputs[rw_mix][nodes],50)
        heights.append(medium)
        max_errs.append(np.max(throughputs[rw_mix][nodes])  - medium)
        min_errs.append(medium - np.min(throughputs[rw_mix][nodes]))
    plt.bar(
        [str(i) for i in count_of_nodes],
        heights,
        edgecolor="black",
        color=["#E69F00", "#56B4E9", "#009E73"],
    )

    plt.errorbar([str(i) for i in count_of_nodes],heights,yerr=[min_errs,max_errs],capsize=3,fmt=".", color="black")
    if rw_mix==1:
        plt.ylabel("Write throughput (Ktx/s)")
    else:
        plt.ylabel("Read throughput (Ktx/s)")
    plt.xlabel("# of Nodes")
    plt.savefig(f"throughput_comparison_sets_{rw_mix}.pdf")
    plt.close()