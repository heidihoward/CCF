import polars as pl
import subprocess
import matplotlib.pyplot as plt
import sys
import json
from datetime import datetime

timenow = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
workspace_path = f"/home/azureuser/heidi/CCF/build-sgx/ws-{timenow}-reconfig"

basicperf_cmd = ["python3", "/home/azureuser/heidi/CCF/tests/infra/basicperf.py", "-b", ".", "-c", "./submit", "--host-log-level", "info", "--enclave-log-level", "info", "--worker-threads", "10", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/actions.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/validate.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/resolve.js", "--constitution", "/home/azureuser/heidi/CCF/samples/constitutions/default/apply.js", "--label", "pi_basic_mt_sgx_cft^", "--snapshot-tx-interval", "20000", "--package", "samples/apps/basic/libbasic", "-e", "release", "-t", "sgx", "--workspace", workspace_path, "--client-def", "1,write,500000,primary","--client-def", "1,read,600000,backup", "--stop-primary-after-s", "6", "--add-new-node-after-primary-stops", "ssh://172.23.0.11", "--sig-ms-interval", "1000" , "-n", "ssh://172.23.0.8", "-n", "ssh://172.23.0.9", "-n", "ssh://172.23.0.10","--client-timeout-s", "300"]

subprocess.run(basicperf_cmd)

fontsize = 12
params = {
    "axes.labelsize": fontsize,
    "font.size": fontsize,
    "legend.fontsize": fontsize,
    "xtick.labelsize": fontsize,
    "ytick.labelsize": fontsize,
    "figure.figsize": (6.5, 2.5),
    "xtick.direction": "in",
    "ytick.direction": "in",
    "xtick.top": True,
    "xtick.bottom": True,
    "ytick.right": True,
    "xtick.minor.visible": True,
    "ytick.minor.visible": True,
    "lines.linewidth": 2,
    "legend.frameon": True,
    "axes.grid": False,
    "savefig.bbox": "tight",
    "figure.autolayout": True,
}

def recv_per(agg, bucket_period="100ms"):
    return agg.with_columns(
                        pl.col("receiveTime").dt.truncate(bucket_period).alias(bucket_period),
                    ).groupby(bucket_period).count().rename({"count": "rcvd"}).sort(bucket_period)
    
def main(path, stats_path):
    plt.rcParams.update(params)
    agg = pl.read_parquet(path)
    stats = json.load(open(stats_path))
    pl.Config.set_tbl_cols(agg.shape[1])
    ax = plt.subplot(111)
    start_time = agg["receiveTime"].min()

    series = [(b"GET",".","read","#009E73"), (b"PUT", "x","write","#56B4E9")]
    for verb, marker,label,color in series:
        if verb.endswith(b" 5xx"):
            verb_agg = agg.filter(pl.col("responseStatus") >= 500).filter(pl.col("request").bin.contains(verb.decode().split(" ")[0].encode()))
        else:
            verb_agg = agg.filter(pl.col("responseStatus") < 500).filter(pl.col("request").bin.contains(verb))
        period = "100ms"
        recv_per_100ms = recv_per(verb_agg, period)
        times_s = [(x - start_time).total_seconds() -5  for x in recv_per_100ms[period]]
        krecv_per_s = [i*10/1000 for i in recv_per_100ms["rcvd"]]
        ax.plot(times_s, krecv_per_s, marker=marker, linestyle='None', color=color, markersize=4, label=label)
    
    events = [
        ("initial_primary_shutdown_time", "$A$", 0.3),
        ("new_node_join_start_time", "$B$",-0.3),
        ("node_replacement_governance_start", "$C$", -0.2),
        ("node_replacement_governance_committed", "$D$", 0.2),
        ("old_node_removal_committed", "$E$", 0.3)
    ]

    stats["new_node_join_start_time"] = "2023-08-10T16:56:56.268432" # actual time of first postiive response
    offset = 0
    for event, marker, x_offset in events:
        x = (datetime.fromisoformat(stats[event]) - start_time).total_seconds() -5
        plt.axvline(x, color='black', linestyle='--',linewidth=1)
        ax.plot([x + x_offset], [3 + 2*(offset % 2)], marker=marker, markersize=6, color="black")
        offset += 1


    plt.xlim(0,15)
    plt.ylim(0,40)
    plt.xlabel("Time (seconds)")
    plt.legend(handletextpad=0.1,loc="lower right")
    plt.ylabel("Throughput (kreq/s)")
    plt.savefig("agg.pdf")
    plt.close()

main(f"{workspace_path}/pi_basic_mt_sgx_cft^_common/aggregated_basicperf_output.parquet",f"{workspace_path}/pi_basic_mt_sgx_cft^_common/statistics.json")

