import polars as pl
import subprocess
import numpy as np
import matplotlib.pyplot as plt
import datetime
import json

throughputs = {}
rw_mixes = [0, 0.2, 0.4, 0.6, 0.8, 1]
timenow = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
client_throughputs = {}

for rw_mix in rw_mixes:
    throughputs[rw_mix] = {}
    client_throughputs[rw_mix] = {}
    for nodes in [1,3,5]:
        throughputs[rw_mix][nodes] = []
        client_throughputs[rw_mix][nodes] = {}
        for i in range(1):
            clients = 10*nodes
            if rw_mix == 1:
                client_def = ["--client-def", f"{clients},write,100000,primary"]
            elif rw_mix == 0:
                client_def = ["--client-def", f"{clients},read,100000,any"]
            elif nodes == 1:
                client_def = ["--client-def", f"{int(rw_mix*clients)},write,10000,primary","--client-def", f"{int((1-rw_mix)*clients)},read,100000,primary"]
            else:
                client_def = ["--client-def", f"{int(rw_mix*clients)},write,10000,primary","--client-def", f"{int((1-rw_mix)*clients)},read,100000,backup"]
            print(nodes, client_def)

            basicperf_cmd = ["python3", "/home/azureuser/heidi/CCF/tests/infra/basicperf.py", "-b", ".", "-c", "./submit", "--host-log-level", "info", "--enclave-log-level", "info", "--worker-threads", "10", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/actions.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/validate.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/resolve.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/apply.js", "--label", "pi_basic_mt_sgx_cft^", "--snapshot-tx-interval", "20000", "--package", "samples/apps/basic/libbasic", "-e", "release", "-t", "sgx", "--workspace", f"/home/azureuser/heidi/CCF/build-sgx/ws-{timenow}-w{rw_mix}-n{nodes}-i{i}"] + ["-n", "ssh://172.23.0.13", "-n", "ssh://172.23.0.9","-n", "ssh://172.23.0.10", "-n", "ssh://172.23.0.11", "-n", "ssh://172.23.0.12"][:nodes*2] + client_def
            
            subprocess.run(basicperf_cmd)
            # timenow = "2023-08-02_14-10-32"
            # print(timenow)
            agg = pl.read_parquet(f"/home/azureuser/heidi/CCF/build-sgx/ws-{timenow}-w{rw_mix}-n{nodes}-i{i}/pi_basic_mt_sgx_cft^_common/aggregated_basicperf_output.parquet")
            pl.Config.set_tbl_cols(10)
            pl.Config.set_tbl_rows(20)
            print(agg.select(pl.col("*"), pl.col("request").cast(str).alias("requestStr"), pl.col("rawResponse").cast(str).alias("responseStr")))
            start_send = agg["sendTime"].sort()[0]
            end_recv = agg["receiveTime"].sort()[-1]
            throughputs[rw_mix][nodes].append(round(len(agg) / (end_recv - start_send).total_seconds()))
            print(throughputs[rw_mix][nodes])
            client_throughputs[rw_mix][nodes][i] = []
            for client in agg["client"].unique():
                client_agg = agg.filter(pl.col("client") == client)
                start_send = client_agg["sendTime"].sort()[0]
                end_recv = client_agg["receiveTime"].sort()[-1]
                client_throughputs[rw_mix][nodes][i].append((client,round(len(client_agg) / (end_recv - start_send).total_seconds())))

print("overall throughputs", throughputs)
print("client throughputs")
for nodes in [1,3,5]:
    print(f"nodes={nodes}",client_throughputs[0][nodes])

fontsize = 9
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

label_locations = np.arange(6)
xbars = [
    label_locations - 0.3,
    label_locations,
    label_locations + 0.3,
]

plt.figure()
for i, nodes in enumerate([1,3,5]):
    heights = []
    max_errs = []
    min_errs = []
    for rw_mix in rw_mixes:
        medium = np.percentile(throughputs[rw_mix][nodes],50) / 1000
        heights.append(medium)
        max_errs.append(np.max(throughputs[rw_mix][nodes]) / 1000 - medium)
        min_errs.append(medium - np.min(throughputs[rw_mix][nodes]) / 1000)
    print(heights)
    print(max_errs)
    print(min_errs)
    plt.bar(
        xbars[i],
        heights[::-1],
        0.3,
        edgecolor="black",
        label=nodes,
        color=["#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2","#D55E00", "#CC79A7", "#000000"][i],
        hatch=["xx", "..", "///"][i],
    )

    plt.errorbar(xbars[i],heights[::-1],yerr=[min_errs[::-1],max_errs[::-1]],fmt=".", color="black")

plt.ylabel("Throughput (1000 tx/s)")
plt.xlabel("Read ratio")
plt.xticks(label_locations,  ["0", "0.2", "0.4", "0.6", "0.8", "1"])
plt.xlim([-0.6, 5.6])
plt.legend(title="# of Nodes")
plt.savefig("throughput_comparison_sets.pdf")
plt.close()