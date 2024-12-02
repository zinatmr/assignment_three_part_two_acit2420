# assignment_three_part_one_acit2420

Download both generate_index and serversetup.sh.

1. Change the permission of serversetup.sh and generate_index script.
    ```bash
    chmod +x serversetup.sh
    chmod +x generate_index
    ```

2. Run the serversetup.sh script with root privilege or sudo.
    ```bash
    sudo ./serversetup.sh
    ```




NOTE: The command 'ufw' to setup firewall does not work due to issues with iptable in Linux kernel I have in the Digital ocean droplet. Comment out the commands under Task-5 in serversetup.sh to ignore the Firewall setup. Added TIME in the generate_index script. The html page will show time when the index page was generated. The time in the "assignment_3_part_one.png" is 2:40. It shows the time when I was testing it. But original timer is set for 05:00 everyday.

##Answers to Assingment three questions

Q1: What is the benefit of creating a system user for this task rather than using a regular user or root?

Ans: Creating a system user limits permission for security purposes. It cannot be accessed interactively. Also ensures task runs with minimal privileges,reducing risks.


Q2:  How will you verify that the timer is active and that the service runs successfully?" "What commands can you run to check logs and to confirm the service's execution?

Ans: To verify that the time is active I will use the following command:

```bash
systemctl list-timers | grep generate-index
```

To check service execution log I will use the following command:
```bash
journalctl -u generate-index.service
```

Q3: Why is it important to use a separate server block file instead of modifying the main nginx.conf file directly?

Ans: It keeps the nginx.conf clean and is easier to create manage multiple server blocks.

Q4: How can you check the status of the nginx services and test your nginx configuration?

Ans: I can check the nginx services status using following command:
```bash
sudo systemctl status nginx
```
I can test nginx configuration using the following command:
```bash
sudo nginx -t
```

Q5:  How can you check the status of your firewall?

Ans: I can check the status of the firewall using the following command:
```bash
sudo ufw status
```
