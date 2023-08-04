import polars as pl
import subprocess
import matplotlib.pyplot as plt
import datetime

timenow = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
workspace_path = f"/home/azureuser/heidi/CCF/build-sgx/ws-{timenow}-failure"

# basicperf_cmd = ["python3", "/home/azureuser/heidi/CCF/tests/infra/basicperf.py", "-b", ".", "-c", "./submit", "--host-log-level", "info", "--enclave-log-level", "info", "--worker-threads", "0", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/actions.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/validate.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/resolve.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/apply.js", "--label", "pi_basic_mt_sgx_cft^", "--snapshot-tx-interval", "20000", "--package", "samples/apps/basic/libbasic", "-e", "release", "-t", "sgx", "--workspace", workspace_path, "--max-writes-ahead", "0","--sig-tx-interval", "100","--client-def", "1,read,100000,primary","--client-def", "1,write,100000,primary", "--stop-primary-after-s", "10", "--sig-ms-interval", "1000" , "-n", "ssh://172.23.0.8", "-n", "ssh://172.23.0.9", "-n", "ssh://172.23.0.10","--client-timeout-s", "180"]
# subprocess.run(basicperf_cmd)
workspace_path = "/home/azureuser/heidi/CCF/build-sgx/ws-2023-08-04_16-56-53-failure"

agg = pl.read_parquet(f"{workspace_path}/pi_basic_mt_sgx_cft^_common/aggregated_basicperf_output.parquet")
fontsize = 12
params = {
    "axes.labelsize": fontsize,
    "font.size": fontsize,
    "legend.fontsize": fontsize,
    "xtick.labelsize": fontsize,
    "ytick.labelsize": fontsize,
    "figure.figsize": (4, 2),
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

def recv_per(agg, bucket_period="100ms"):
    return agg.with_columns(
                        pl.col("receiveTime").dt.truncate(bucket_period).alias(bucket_period),
                    ).groupby(bucket_period).count().rename({"count": "rcvd"}).sort(bucket_period)
    
plt.rcParams.update(params)
pl.Config.set_tbl_cols(agg.shape[1])
print(agg)
start_time = agg["receiveTime"].min()
leader_election = 23.303032 - 08.082519 # from logs
print(start_time)
for verb, marker, name in [(b"GET",  "bo", "read"), (b"PUT", "ro", "write")]:
    verb_agg = agg.filter(pl.col("request").bin.contains(verb))
    period = "100ms"
    recv_per_100ms = recv_per(verb_agg, period)
    print(recv_per_100ms)
    times = [(x - start_time).total_seconds() - 5 for x in recv_per_100ms[period]]
    plt.plot(times, recv_per_100ms["rcvd"], marker, markersize=2, label=name)
plt.legend()
plt.xlabel("Time (seconds)")
plt.xlim(0,20)
plt.ylabel("Rate")
plt.ylim(0, 100)
plt.axvline(x=5, color='black', linestyle='--',linewidth=1)
plt.axvline(x=leader_election -5, color='black', linestyle='--',linewidth=1)
plt.savefig("agg.pdf")
plt.close()

