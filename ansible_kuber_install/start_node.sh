#Start node for Kubernetes
#ssh ${user}@${host_proxmox} 'sudo qm start 3100 && sudo qm start 3200 && sudo qm start 3300'
sleep 3
#ssh ${user}@${host_proxmox} 'sudo qm status 3100 && sudo qm status 3200 && sudo qm status 3300'
for vm in 3100 3200 3300; do echo "Виртуальная машина ${vm}" `ssh ${user}@${host_proxmox} "sudo qm status $vm"`; done