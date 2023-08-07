import polars as pl
import subprocess
import numpy as np
import matplotlib.pyplot as plt
import datetime
import json

throughputs = {}
rw_mixes = range(0,7,1)
timenow = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
client_throughputs = {}

for rw_mix in rw_mixes:
    throughputs[rw_mix] = []
    client_throughputs[rw_mix] = {}
    for i in range(5):

        basicperf_cmd = ["python3", "/home/azureuser/heidi/CCF/tests/infra/basicperf.py", "-b", ".", "-c", "./submit", "--host-log-level", "info", "--enclave-log-level", "info", "--worker-threads", "10", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/actions.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/validate.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/resolve.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/apply.js", "--label", "pi_basic_mt_sgx_cft^", "--snapshot-tx-interval", "20000", "--package", "samples/apps/basic/libbasic", "-e", "release", "-t", "sgx", "--workspace", f"/home/azureuser/heidi/CCF/build-sgx/ws-{timenow}-w{rw_mix}-i{i}"] + ["-n", "ssh://172.23.0.13", "--client-def", f"{6-rw_mix},write,100000,primary","--client-def", f"{rw_mix},read,100000,primary"] 
        
        # subprocess.run(basicperf_cmd)
        timenow = "2023-08-07_14-24-16"
        print(timenow)
        agg = pl.read_parquet(f"/home/azureuser/heidi/CCF/build-sgx/ws-{timenow}-w{rw_mix}-i{i}/pi_basic_mt_sgx_cft^_common/aggregated_basicperf_output.parquet")
        pl.Config.set_tbl_cols(10)
        pl.Config.set_tbl_rows(20)
        print(agg.select(pl.col("*"), pl.col("request").cast(str).alias("requestStr"), pl.col("rawResponse").cast(str).alias("responseStr")))
        start_send = agg["sendTime"].sort()[0]
        end_recv = agg["receiveTime"].sort()[-1]
        throughputs[rw_mix].append(round(len(agg) / (end_recv - start_send).total_seconds()))

print("overall throughputs", throughputs)

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
    "xtick.top": False,
    "xtick.bottom": False,
    "ytick.right": True,
    "xtick.minor.visible": True,
    "ytick.minor.visible": True,
    "lines.linewidth": 2,
    "legend.frameon": False,
    "axes.grid": False,
    "savefig.bbox": "tight",
    "text.usetex": True,
}
plt.rcParams.update(params)
heights = []
max_errs = []
min_errs = []
for rw_mix in rw_mixes:
    plt.figure(figsize=[1.7,2.5])
    medium = np.percentile(throughputs[rw_mix],50) / 1000
    heights.append(medium)
    max_errs.append(np.max(throughputs[rw_mix]) / 1000 - medium)
    min_errs.append(medium - np.min(throughputs[rw_mix]) / 1000)

plt.bar(
    ["0",r'$\frac{1}{6}$', r'$\frac{1}{3}$',r'$\frac{1}{2}$', r'$\frac{2}{3}$', r'$\frac{5}{6}$', '1'],
    heights,
    edgecolor="black",
    color="#E69F00",
    hatch="xx",
)

plt.errorbar(rw_mixes,heights,yerr=[min_errs,max_errs],fmt=".", color="black")
plt.ylabel("Throughput (1000 tx/s)")
plt.xlabel("Read ratio")
plt.savefig(f"throughput_rwmix_set.pdf")
plt.close()