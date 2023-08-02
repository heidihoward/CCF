import polars as pl
import subprocess
import numpy as np
import matplotlib.pyplot as plt
import datetime

throughputs = {}
sig_tx_intervals = [10,50,100,500,1000,5000,10000,20000]
timenow = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")

for sig_tx_interval in sig_tx_intervals:
    throughputs[sig_tx_interval] = []
    for i in range(3):
        basicperf_cmd = ["python3", "/home/azureuser/heidi/CCF/tests/infra/basicperf.py", "-b", ".", "-c", "./submit", "--host-log-level", "info", "--enclave-log-level", "info", "--worker-threads", "10", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/actions.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/validate.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/resolve.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/apply.js", "--write-tx-times", "--label", "pi_basic_mt_sgx_cft^", "--snapshot-tx-interval", "20000", "--package", "samples/apps/basic/libbasic", "--repetitions", "20000", "--num-localhost-clients", "30", "-e", "release", "-t", "sgx", "--workspace", f"/home/azureuser/heidi/CCF/build-sgx/ws-{timenow}-sig{sig_tx_interval}-i{i}", "--rw-mix", "1", "--sig-tx-interval", str(sig_tx_interval), "--sig-ms-interval", "1000" ,"--client-timeout-s", "200", "-n", "ssh://172.23.0.8"]
        subprocess.run(basicperf_cmd)

        agg = pl.read_parquet(f"/home/azureuser/heidi/CCF/build-sgx/ws-{timenow}-sig{sig_tx_interval}-i{i}/pi_basic_mt_sgx_cft^_common/aggregated_basicperf_output.parquet").filter(pl.col("messageID").cast(int) >= 1000)
        pl.Config.set_tbl_cols(10)
        pl.Config.set_tbl_rows(20)
        print(agg.select(pl.col("*"), pl.col("request").cast(str).alias("requestStr"), pl.col("rawResponse").cast(str).alias("responseStr")))
        start_send = agg["sendTime"].sort()[0]
        end_recv = agg["receiveTime"].sort()[-1]
        throughputs[sig_tx_interval].append(round(len(agg) / (end_recv - start_send)))

print(throughputs)

fontsize = 9
params = {
    "axes.labelsize": fontsize,
    "font.size": fontsize,
    "legend.fontsize": fontsize,
    "xtick.labelsize": fontsize,
    "ytick.labelsize": fontsize,
    "figure.figsize": (4,2),
    "xtick.direction": "in",
    "ytick.direction": "in",
    "xtick.top": True,
    "xtick.bottom": True,
    "ytick.right": True,
    "xtick.minor.visible": True,
    "ytick.minor.visible": True,
    "lines.linewidth": 2,
    "legend.frameon": False,
    "axes.grid": True,
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

plt.ylabel("Throughput (1000 tx/s)")
plt.xlabel("Signature interval (tx count)")
plt.xscale("log")
plt.savefig("throughput_sigs.pdf")
plt.close()