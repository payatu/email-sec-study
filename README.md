# README

1. Follow the `1_req.md` and make sure the Pre Requisites are met.
2. Modify variables in `2_run.sh` on ZDNS server and run it.
3. Create indexes on MongoDB server as follows:
```
db.spf.createIndex( { "domain": 1, "spf": 1 } )
db.dmarc.createIndex( { "domain": 1, "dmarc": 1 } )
db.dkim.createIndex( { "domain": 1, "host": 1, "dkim": 1 } )
db.mx.createIndex( { "domain": 1, "mx": 1 } )
db.ns.createIndex( { "domain": 1, "ns": 1 } )
```
4. Access the Jupyter Notebook, modify the variables and run it.
