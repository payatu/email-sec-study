# Pre Requisites

## Infrastructure

### Server Instances

1. ZDNS 
	- 4vCPU(s)
	- 8GB RAM
	- 2TB Storage 
2. Jupyter Notebook 
	- 16vCPU(s)
	- 32GB RAM
	- 500GB Storage
3. MongoDB
	- 16vCPU(s)
	- 32GB RAM
	- 500GB Storage

### Networking

1. All the three instances must be in a private network.
2. ZDNS server should have multiple internet connections via multiple interfaces for faster results and less probablity of DNS rate limiting.

## Software

### On ZDNS Server

1. Clone this repository and `cd` into it. 
2. Fork https://github.com/tb0hdan/domains and archive the forked repository with "Include Git LFS objects in archives" checked. Download the archive as a zip file and place it in the current directory. 

### On MongoDB Server

1. Enable authentication on root user or a new user. 
2. Create a new db called 'data'.

### On Jupyter Notebook Server

1. Clone this repository and host a Jupyter Notebook with `./notebooks` as the root directory.
