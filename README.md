# DDNS Scripts

Let's you update a Namecheap DDNS record with nothing more than `bash`, `curl`,
`awk`, `ip` and `hostname`.

## Usage:

### `namecheap.sh`

`NAMECHEAP_DDNS_PASS=foobarbaz ./namecheap.sh interface_name [hostname]`. If
`hostname` isn't provided, then we derive it from `hostname -f`.
