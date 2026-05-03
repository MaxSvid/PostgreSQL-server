# PostgreSQL-server

Personal pgAdmin on VPS server for multiple projects setup with network connection

The core idea is: one Docker network and one pgAdmin with multiple databases, multiple restricted pgAdmin users. 

Each project's team member only sees their own database because pgAdmin's user management controls which server connections each login can access.

## The network setup

Everything sits on one custom Docker bridge network. Containers on the same bridge network can reach each other by container name - so pgAdmin can talk to each contrainer just by using that as the hostname. No IPs needed, no ports exposed between containers at the moment.

For more information I documented in [Tutorial.md](TUTORIAL.md)