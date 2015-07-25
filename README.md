# redis-awk-monitor
Small AWK script to filter "redis-cli monitor" output and display a quick summary in real-time (# of operations executed, operations/keys processed).

See screenshot bellow for an example.

# Usage
```
$ redis-cli monitor | gawk -f redis-monitor.awk
```
(yes, it needs GNU awk)


Feel free to fork and improve it!

![Screenshot](https://raw.github.com/nanawel/redis-awk-monitor/master/capture.png)
