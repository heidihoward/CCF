import polars as pl
import subprocess
import numpy as np
import matplotlib.pyplot as plt
import datetime

timenow = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")

basicperf_cmd = ["python3", "/home/azureuser/heidi/CCF/tests/infra/basicperf.py", "-b", ".", "-c", "./submit", "--host-log-level", "info", "--enclave-log-level", "info", "--worker-threads", "0", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/actions.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/validate.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/resolve.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/apply.js", "--label", "pi_basic_mt_sgx_cft^", "--snapshot-tx-interval", "20000", "--package", "samples/apps/basic/libbasic", "-e", "release", "-t", "sgx", "--workspace", f"/home/azureuser/heidi/CCF/build-sgx/ws-{timenow}-lat", "--max-writes-ahead", "0","--sig-tx-interval", "100","--client-def", "1,write,3000,primary","--sig-ms-interval", "1000" , "-n", "ssh://172.23.0.8", "-n", "ssh://172.23.0.9"]
subprocess.run(basicperf_cmd)

agg = pl.read_parquet(f"/home/azureuser/heidi/CCF/build-sgx/ws-{timenow}-lat/pi_basic_mt_sgx_cft^_common/aggregated_basicperf_output.parquet")
pl.Config.set_tbl_cols(10)
pl.Config.set_tbl_rows(20)
print(agg.sort("index").head(10))
print(agg.sort("latency").head(10))
print(agg.describe())

writes_x = []
writes_y = []
reads_x = []
reads_y = []
for row in agg.iter_rows():
    if row[4].split(b" ")[0] == b'PUT':
        writes_x.append(int(row[0]))
        writes_y.append(row[9].microseconds/1000)
    else:
        reads_x.append(int(row[0]))
        reads_y.append(row[9].microseconds/1000)


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
    "axes.grid": False,
    "savefig.bbox": "tight",
}
plt.rcParams.update(params)

plt.figure()

plt.scatter(writes_x, writes_y,s=1,color="#009E73")
plt.scatter(reads_x, reads_y,s=1,color="#009E73")
plt.ylabel("Latency (ms)")
plt.xlabel("Requests")
plt.xlim(1000,2000)
plt.ylim(1,3)
plt.savefig("latency.pdf")

plt.close()

plt.figure(figsize=(1,2))

plt.violinplot(writes_y,showmedians=True)
plt.ylabel("Latency (ms)")

plt.savefig("latency_violin.pdf")

plt.close()

plt.figure(figsize=(4,2))
plt.hist(writes_y[1000:],bins=[x / 100.0 for x in range(0, 500,5)],color="#009E73")
plt.yscale('log')
plt.ylabel("Frequency")
plt.xlabel("Latency (ms)")
plt.xlim(1,2.5)
# plt.yticks([0, 1, 10, 100])
plt.savefig("latency_hist.pdf")

plt.close()