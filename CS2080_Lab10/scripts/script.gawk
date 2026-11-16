BEGIN {
    FS = ","

    printf "%-12s %-16s %-10s %-12s %-10s %-12s\n", \
           "Hostname", "IP Address", "CPU Avg", \
           "Memory Avg", "Disk Avg", "Monitoring"

    print "--------------------------------------------------------------------------"
}

NR > 1 {
    hostname = $2
    ip[hostname] = $4

    cpu_total[hostname] += $5
    memory_total[hostname] += $6
    disk_total[hostname] += $7

    count[hostname]++
}

END {
    for (hostname in count) {

        avg_cpu = cpu_total[hostname] / count[hostname]
        avg_memory = memory_total[hostname] / count[hostname]
        avg_disk = disk_total[hostname] / count[hostname]

        if (avg_cpu > 80 || avg_memory > 80 || avg_disk > 85)
            monitoring = "ATTENTION"
        else
            monitoring = "NORMAL"

        printf "%-12s %-16s %8.1f%% %10.1f%% %8.1f%% %-12s\n", \
               hostname, ip[hostname], avg_cpu, avg_memory, \
               avg_disk, monitoring
    }
}